import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'core/theme_mode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/auth.dart';
import 'core/config.dart';
import 'core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.configurada) {
    // Si venimos del enlace de «recuperar contraseña», lo recordamos antes de que Supabase consuma la URL.
    recuperacionInicial = kIsWeb && Uri.base.fragment.contains('type=recovery');
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
  }
  runApp(const ProviderScope(child: LigariaApp()));
}

const _locales = [Locale('es')];
const _delegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class LigariaApp extends ConsumerWidget {
  const LigariaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.configurada) {
      return MaterialApp(
        title: 'Ligaria',
        debugShowCheckedModeBanner: false,
        theme: temaClaro(),
        locale: _locales.first,
        supportedLocales: _locales,
        localizationsDelegates: _delegates,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Falta la configuración de Supabase.\n'
                'Ejecuta con --dart-define=SUPABASE_URL=… y --dart-define=SUPABASE_ANON_KEY=…',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    return MaterialApp.router(
      title: 'Ligaria',
      debugShowCheckedModeBanner: false,
      theme: temaClaro(),
      darkTheme: temaOscuro(),
      themeMode: ref.watch(themeModeProvider),
      locale: _locales.first,
      supportedLocales: _locales,
      localizationsDelegates: _delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
