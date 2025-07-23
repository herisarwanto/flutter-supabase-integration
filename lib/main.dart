import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'common/router/router.dart';
import 'common/services/shared_prefs.dart';
import 'common/router/routes.dart';
import 'common/config/app_config.dart';
import 'features/dashboard/presentation/providers/message_provider.dart';

late ProviderContainer _providerContainer;
late GoRouter _router;
bool _isRouterInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  await _initSupabase();
  await _initProviderContainer();
  await _initDeepLinks();
}

Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}

Future<void> _initProviderContainer() async {
  _providerContainer = ProviderContainer();

  // Handle existing user session on app start
  await _handleExistingUserSession();

  // Set up auth state change listener
  _setupAuthStateListener();
}

Future<void> _handleExistingUserSession() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      log('Found existing user: ${user.email}');
      await SharedPrefs.saveLogin(userId: user.id, email: user.email ?? '');
      // Set loading state and fetch messages for existing user
      _providerContainer.read(messageProvider.notifier).setLoadingState();
      _providerContainer.read(messageProvider.notifier).fetchMessages();
    } else {
      log('No existing user session found');
    }
  } catch (e) {
    log('Error handling existing user session: $e');
  }
}

void _setupAuthStateListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen(
    _handleAuthStateChange,
    onError: (error) => log('Auth state change error: $error'),
  );
}

Future<void> _handleAuthStateChange(AuthState data) async {
  try {
    final event = data.event;
    final session = data.session;

    log('Auth state change: $event');

    switch (event) {
      case AuthChangeEvent.signedIn:
        if (session != null) {
          log('User signed in: ${session.user.email}');
          await _handleUserSignIn(session.user);
          // Navigate to dashboard after successful login
          _navigateToDashboard();
        }
        break;
      case AuthChangeEvent.signedOut:
        log('User signed out');
        _handleUserSignOut();
        break;
      case AuthChangeEvent.tokenRefreshed:
        if (session != null) {
          log('Token refreshed for: ${session.user.email}');
          await _handleUserSignIn(session.user);
        }
        break;
      default:
        log('Unhandled auth event: $event');
        break;
    }
  } catch (e) {
    log('Error handling auth state change: $e');
  }
}

Future<void> _handleUserSignIn(User user) async {
  try {
    if (user.email != null) {
      log('Handling user sign in: ${user.email}');
      await SharedPrefs.saveLogin(userId: user.id, email: user.email!);

      // Set loading state and fetch messages immediately for magic link login
      _providerContainer.read(messageProvider.notifier).setLoadingState();
      _providerContainer.read(messageProvider.notifier).fetchMessages();
    }
  } catch (e) {
    log('Error handling user sign in: $e');
  }
}

void _navigateToDashboard() {
  try {
    log(
      'Attempting to navigate to dashboard. Router initialized: $_isRouterInitialized',
    );

    if (_isRouterInitialized) {
      log('Navigating to dashboard after login');
      _router.go(AppRoutes.dashboard);
    } else {
      log('Router not yet initialized, will navigate on next build');
      // The router will handle navigation based on the updated auth state
    }
  } catch (e) {
    log('Error navigating to dashboard: $e');
  }
}

void _handleUserSignOut() {
  try {
    log('Handling user sign out');
    _providerContainer.read(messageProvider.notifier).clearMessagesAndLoad();
  } catch (e) {
    log('Error handling user sign out: $e');
  }
}

Future<void> _initDeepLinks() async {
  try {
    log('Initializing deep links...');
    final appLinks = AppLinks();

    // Handle deep links when app is already running
    appLinks.uriLinkStream.listen((uri) {
      log('Deep link stream received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) => log('Deep link stream error: ${err.toString()}'));

    // Handle deep links when app is opened from a link
    final initialUri = await appLinks.getInitialAppLink();
    log('Initial deep link check: $initialUri');
    if (initialUri != null) {
      log('Handling initial deep link: $initialUri');
      _handleDeepLink(initialUri);
    } else {
      log('No initial deep link found');
    }
  } catch (e) {
    log('Error initializing deep links: $e');
  }
}

void _handleDeepLink(Uri? uri) {
  try {
    if (uri != null && AppConfig.isValidDeepLink(uri)) {
      log('Processing deep link: $uri');

      // Get session from URL and handle the authentication
      Supabase.instance.client.auth
          .getSessionFromUrl(uri)
          .then((response) {
            if (response.session != null && response.session.user != null) {
              log(
                'Deep link authentication successful for: ${response.session.user.email}',
              );
              // Save login data and fetch messages
              _handleUserSignIn(response.session.user);
              // Navigate to dashboard
              _navigateToDashboard();
            } else {
              log('No session found in deep link');
            }
          })
          .catchError((error) {
            log('Error processing deep link authentication: $error');
          });
    } else {
      log('Invalid deep link: $uri');
    }
  } catch (e) {
    log('Error handling deep link: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _LoadingApp();
        }

        return _buildApp(snapshot.data!);
      },
    );
  }

  Future<String> _getInitialRoute() async {
    try {
      final loggedIn = await SharedPrefs.isLoggedIn();
      log('Initial route check - logged in: $loggedIn');
      return loggedIn ? AppRoutes.dashboard : AppRoutes.intro;
    } catch (e) {
      log('Error getting initial route: $e');
      return AppRoutes.intro;
    }
  }

  Widget _buildApp(String initialRoute) {
    _router = AppRouter.createRouter(initialLocation: initialRoute);
    _isRouterInitialized = true;

    log('App built with initial route: $initialRoute');

    return UncontrolledProviderScope(
      container: _providerContainer,
      child: MaterialApp.router(
        title: AppConfig.appTitle,
        theme: _buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
