/// Configuración de la app. `flutter run` / `flutter build` a secas ya apuntan al Supabase de
/// Friends (valores por defecto de abajo); no hace falta ningún `--dart-define`.
/// Solo para apuntar a otro proyecto: `--dart-define-from-file=env.json`
/// (copia `env.example.json` a `env.json`).
///
/// Dos modos:
/// * **Normal** (por defecto): Supabase real, sin datos de ejemplo.
/// * **Demo** (`--dart-define=MODO=demo`): todo en memoria, con datos de ejemplo
///   (usuario `demo@ligaria.es` / `demo1234`). No toca Supabase.
class AppConfig {
  static const modo = String.fromEnvironment('MODO');
  static bool get demo => modo == 'demo' || !configurada;

  /// Si la app habla con Supabase (modo «desde cero»).
  static bool get usaSupabase => configurada && !demo;

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vzfgmodarizrnjewbeiy.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    // Clave publishable: pública por diseño (la seguridad la da RLS).
    defaultValue: 'sb_publishable_rAVjP_DsvQTPAiqVeAu21Q_375OFQbq',
  );
  /// Páginas legales publicadas en la web de Friends.
  static const urlPrivacidad = String.fromEnvironment(
    'URL_PRIVACIDAD',
    defaultValue: 'https://ligariafriends.app/privacidad.html',
  );
  static const urlTerminos = String.fromEnvironment(
    'URL_TERMINOS',
    defaultValue: 'https://ligariafriends.app/terminos.html',
  );
  static bool get configurada =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
