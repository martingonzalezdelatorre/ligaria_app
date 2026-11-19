/// Configuración inyectada en compilación:
/// flutter run   (usa por defecto el Supabase de Friends; se puede sobrescribir con
/// --dart-define-from-file=env.json)
/// (copia `env.example.json` a `env.json` y rellena la clave publicable).
///
/// Dos modos:
/// * **Desde cero** (por defecto con `env.json`): Supabase real, sin datos de ejemplo.
/// * **Demo** (`--dart-define=MODO=demo`, o sin `env.json`): todo en memoria, con datos de ejemplo
///   (usuario `demo@ligaria.es` / `demo1234`). No toca Supabase aunque haya claves.
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
  static bool get configurada =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
