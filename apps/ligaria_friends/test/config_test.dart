import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/core/config.dart';

/// `flutter run` / `flutter build` a secas (sin --dart-define) deben apuntar a Supabase.
void main() {
  test('sin dart-define la app usa Supabase, no el modo demo', () {
    expect(AppConfig.configurada, isTrue);
    expect(AppConfig.demo, isFalse);
    expect(AppConfig.usaSupabase, isTrue);
    expect(AppConfig.supabaseUrl, startsWith('https://'));
    expect(AppConfig.supabaseAnonKey, isNotEmpty);
  });
}
