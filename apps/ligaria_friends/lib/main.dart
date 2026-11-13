import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'core/config.dart';
import 'features/auth/auth_repositorio.dart';
import 'features/auth/login_page.dart';
import 'features/auth/nueva_password_page.dart';
import 'features/auth/supabase_auth.dart';

/// Acento propio de Friends; el resto del estilo viene de `ligaria_ui`.
const acentoFriends = Color(0xFF8B5CF6);

/// Lo fija `main()` si la app se abrió desde el enlace de recuperación (el evento puede llegar
/// antes de que exista ningún listener).
bool recuperacionInicial = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthRepositorio auth;
  if (AppConfig.configurada) {
    // Si venimos del enlace del correo de recuperación, hay que recordarlo antes de que Supabase consuma la URL.
    recuperacionInicial = kIsWeb && Uri.base.fragment.contains('type=recovery');
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseAnonKey);
    auth = SupabaseAuth();
  } else {
    // Sin --dart-define: modo demo (demo@ligaria.es / demo1234).
    auth = AuthDemo();
  }
  runApp(LigariaFriendsApp(auth: auth));
}

class LigariaFriendsApp extends StatelessWidget {
  const LigariaFriendsApp({super.key, required this.auth});
  final AuthRepositorio auth;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ligaria Friends',
        debugShowCheckedModeBanner: false,
        theme: temaClaro(acento: acentoFriends),
        darkTheme: temaOscuro(acento: acentoFriends),
        themeMode: ThemeMode.dark,
        home: _Raiz(auth: auth),
      );
}

/// Muestra el login hasta que hay sesión; después, el inicio. Si el usuario llega desde el enlace
/// de recuperación, primero le pide la contraseña nueva.
class _Raiz extends StatefulWidget {
  const _Raiz({required this.auth});
  final AuthRepositorio auth;
  @override
  State<_Raiz> createState() => _RaizState();
}

class _RaizState extends State<_Raiz> {
  late bool _recuperando = recuperacionInicial;
  late final StreamSubscription<void> _sub;

  void _terminar() {
    recuperacionInicial = false;
    setState(() => _recuperando = false);
  }

  @override
  void initState() {
    super.initState();
    _sub = widget.auth.recuperacion.listen((_) => setState(() => _recuperando = true));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recuperando) return NuevaPasswordPage(auth: widget.auth, onTerminar: _terminar);
    return StreamBuilder<bool>(
      stream: widget.auth.sesion,
      initialData: widget.auth.haySesion,
      builder: (context, snap) =>
          (snap.data ?? false) ? InicioPage(onSalir: widget.auth.cerrarSesion) : LoginPage(auth: widget.auth),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key, this.onSalir});
  final VoidCallback? onSalir;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            LogoLigaria(tam: 34, icono: Icons.groups),
            SizedBox(width: 12),
            Text('Ligaria Friends'),
          ]),
          actions: [
            if (onSalir != null) IconButton(tooltip: 'Cerrar sesión', onPressed: onSalir, icon: const Icon(Icons.logout_rounded)),
          ],
        ),
        body: const ContenidoCentrado(
          child: EstadoVacio(icono: Icons.groups, texto: 'Aún no tienes grupos. Crea uno para empezar tu liga entre amigos.'),
        ),
      );
}
