/// Configuración inyectada en compilación:
/// flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get configurada => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
