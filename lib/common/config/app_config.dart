class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'Your Supabase URL here',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'Your Supabase Anon Key here',
  );

  static const List<String> allowedSchemes = [
    'supabasemagiclink',
    'flutter_supabase_integration',
  ];
  static const List<String> allowedDomains = [
    'fhpfmepyofhywrfizfuw.supabase.co',
    'supabasemagiclink.com',
  ];

  static const String appTitle = 'Flutter Supabase Integration';
  static const String redirectTo =
      'supabasemagiclink://supabasemagiclink.com/dashboard';

  static bool isValidDeepLink(Uri uri) {
    return allowedSchemes.contains(uri.scheme) ||
        allowedDomains.contains(uri.host);
  }
}
