import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/auth/recuperar_pages.dart';
import '../features/cuenta/cuenta_page.dart';
import '../features/home/home_page.dart';
import '../features/tutorial/tutorial_page.dart';
import 'auth.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresco = ValueNotifier<int>(0);
  ref.listen(sesionProvider, (_, _) => refresco.value++);
  ref.listen(recuperacionProvider, (_, _) => refresco.value++);
  ref.onDispose(refresco.dispose);

  return GoRouter(
    refreshListenable: refresco,
    initialLocation: '/',
    redirect: (context, state) {
      final sesion = ref.read(sesionProvider);
      if (sesion.isLoading) return null;
      final autenticado = sesion.value != null;
      final ruta = state.matchedLocation;
      final recuperando = ref.read(recuperacionProvider);
      if (!autenticado) return (ruta == '/login' || ruta == '/recuperar') ? null : '/login';
      // Llegó por el enlace de recuperación: solo puede elegir contraseña nueva.
      if (recuperando) return ruta == '/nueva-password' ? null : '/nueva-password';
      if (ruta == '/nueva-password') return '/';
      return (ruta == '/login' || ruta == '/recuperar') ? '/' : null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/recuperar', builder: (_, _) => const RecuperarPasswordPage()),
      GoRoute(path: '/nueva-password', builder: (_, _) => const NuevaPasswordPage()),
      GoRoute(path: '/cuenta', builder: (_, _) => const CuentaPage()),
      GoRoute(path: '/tutorial', builder: (_, _) => const TutorialPage()),
    ],
  );
});
