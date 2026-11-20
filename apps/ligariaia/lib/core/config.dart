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
  static bool get configurada => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
