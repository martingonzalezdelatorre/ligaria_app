/// Configuración inyectada en compilación:
/// flutter run -d chrome --dart-define-from-file=env.json
/// (copia `env.example.json` a `env.json` y rellena la clave publicable).
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get configurada => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
