/// Configuración de Supabase. Por defecto usa el proyecto de Ligaria IA, así que basta `flutter run`.
/// Para otro proyecto: flutter run --dart-define-from-file=env.json
/// (la clave publishable es pública por diseño: la seguridad la da RLS; nunca pongas aquí la service_role).
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gftslrixaeggchimldmf.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_MmnoMReAd62-_66OR8dqyQ_sESfwFGk',
  );

  /// Página de registro de madres, padres y tutores (landing); es el enlace que la escuela les envía.
  static const familiasUrl = String.fromEnvironment(
    'FAMILIAS_URL',
    defaultValue: 'https://ligaria.app/familias.html',
  );

  /// Formulario de alta de escuelas, ayuntamientos y organizadores (landing).
  static const registroUrl = String.fromEnvironment(
    'REGISTRO_URL',
    defaultValue: 'https://ligaria.app/#registro',
  );
  static bool get configurada =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
