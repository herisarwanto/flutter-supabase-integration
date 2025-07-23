class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
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
