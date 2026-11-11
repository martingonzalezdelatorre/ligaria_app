import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/cuenta/cuenta_page.dart';
import '../features/home/home_page.dart';
import '../features/tutorial/tutorial_page.dart';
import 'auth.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresco = ValueNotifier<int>(0);
  ref.listen(sesionProvider, (_, _) => refresco.value++);
  ref.onDispose(refresco.dispose);

  return GoRouter(
    refreshListenable: refresco,
    initialLocation: '/',
    redirect: (context, state) {
      final sesion = ref.read(sesionProvider);
      if (sesion.isLoading) return null;
      final autenticado = sesion.value != null;
      final enLogin = state.matchedLocation == '/login';
      if (!autenticado) return enLogin ? null : '/login';
      return enLogin ? '/' : null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/cuenta', builder: (_, _) => const CuentaPage()),
      GoRoute(path: '/tutorial', builder: (_, _) => const TutorialPage()),
    ],
  );
});
