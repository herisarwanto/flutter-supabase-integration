class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fhpfmepyofhywrfizfuw.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZocGZtZXB5b2ZoeXdyZml6ZnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMDMzMjYsImV4cCI6MjA2ODY3OTMyNn0.cxVPrzSYzO1DcP2QXZ2HJzuXD7jThNi5w0hDmrD-aZw',
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
