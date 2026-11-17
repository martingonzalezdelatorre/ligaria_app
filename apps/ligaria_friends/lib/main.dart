import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'core/config.dart';
import 'core/invitacion.dart';
import 'core/notificaciones.dart';
import 'features/auth/registro_page.dart';
import 'features/auth/auth_repositorio.dart';
import 'features/auth/login_page.dart';
import 'features/auth/nueva_password_page.dart';
import 'features/auth/supabase_auth.dart';
import 'features/jugador/amistosos/amistosos_repositorio.dart';
import 'features/jugador/jugador_shell.dart';
import 'features/jugador/ranking/ranking_repositorio.dart';
import 'features/jugador/store/store_repositorio.dart';
import 'features/tienda/tienda_repositorio.dart';
import 'features/tienda/tienda_shell.dart';
import 'features/jugador/grupos/grupos_repositorio.dart';
import 'features/jugador/ligas/confirmacion_repositorio.dart';
import 'features/jugador/ligas/ligas_repositorio.dart';
import 'features/jugador/ligas/marcador_repositorio.dart';

/// Acento propio de Friends; el resto del estilo viene de `ligaria_ui`.
const acentoFriends = Color(0xFF8B5CF6);

/// Lo fija `main()` si la app se abrió desde el enlace de recuperación (el evento puede llegar
/// antes de que exista ningún listener).
bool recuperacionInicial = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthRepositorio auth;
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  await Invitacion.cargar();
  if (AppConfig.configurada) {
    // Si venimos del enlace del correo de recuperación, hay que recordarlo antes de que Supabase consuma la URL.
    recuperacionInicial =
        kIsWeb &&
        (Uri.base.fragment.contains('type=recovery') ||
            // Invitado por email: llega con sesión pero aún sin contraseña.
            Uri.base.fragment.contains('type=invite'));
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    auth = SupabaseAuth();
    grupos = GruposSupabase();
    ligas = LigasSupabase();
    amistosos = AmistososSupabase();
    MarcadorRepositorio.instancia = MarcadorSupabase();
    ConfirmacionRepositorio.instancia = ConfirmacionSupabase();
    StoreRepositorio.instancia = StoreSupabase();
    RankingRepositorio.instancia = RankingSupabase();
    TiendaRepositorio.instancia = TiendaSupabase();
  } else {
    // Sin --dart-define: modo demo (demo@ligaria.es / demo1234).
    auth = AuthDemo();
    grupos = GruposDemo();
    ligas = LigasDemo();
    amistosos = AmistososDemo(grupos);
  }
  runApp(
    LigariaFriendsApp(
      auth: auth,
      grupos: grupos,
      ligas: ligas,
      amistosos: amistosos,
    ),
  );
}

class LigariaFriendsApp extends StatelessWidget {
  const LigariaFriendsApp({
    super.key,
    required this.auth,
    required this.grupos,
    required this.ligas,
    required this.amistosos,
  });
  final AuthRepositorio auth;
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ligaria Friends',
    debugShowCheckedModeBanner: false,
    theme: temaClaro(acento: acentoFriends),
    darkTheme: temaOscuro(acento: acentoFriends),
    themeMode: ThemeMode.dark,
    home: _Raiz(auth: auth, grupos: grupos, ligas: ligas, amistosos: amistosos),
  );
}

/// Muestra el login hasta que hay sesión; después, el inicio. Si el usuario llega desde el enlace
/// de recuperación, primero le pide la contraseña nueva.
class _Raiz extends StatefulWidget {
  const _Raiz({
    required this.auth,
    required this.grupos,
    required this.ligas,
    required this.amistosos,
  });
  final AuthRepositorio auth;
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
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
    _sub = widget.auth.recuperacion.listen(
      (_) => setState(() => _recuperando = true),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recuperando)
      return NuevaPasswordPage(auth: widget.auth, onTerminar: _terminar);
    return StreamBuilder<bool>(
      stream: widget.auth.sesion,
      initialData: widget.auth.haySesion,
      builder: (context, snap) => (snap.data ?? false)
          ? _SegunPerfil(
              auth: widget.auth,
              grupos: widget.grupos,
              ligas: widget.ligas,
              amistosos: widget.amistosos,
            )
          : _AbrirRegistro(auth: widget.auth),
    );
  }
}

/// Con sesión: según el perfil de la cuenta, entra al flujo Jugador o al de Tienda.
class _SegunPerfil extends StatefulWidget {
  const _SegunPerfil({
    required this.auth,
    required this.grupos,
    required this.ligas,
    required this.amistosos,
  });
  final AuthRepositorio auth;
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  @override
  State<_SegunPerfil> createState() => _SegunPerfilState();
}

class _SegunPerfilState extends State<_SegunPerfil> {
  late final Future<(TipoCuenta, NotificacionesServicio?)> _datos = _cargar();

  Future<(TipoCuenta, NotificacionesServicio?)> _cargar() async {
    final tipo = await widget.auth.tipoCuenta();
    return (tipo, await crearServicioNotificaciones());
  }

  @override
  void dispose() {
    // Al cerrar sesión (o salir) se detiene y libera el servicio de notificaciones.
    _datos.then((d) => d.$2?.liberar(), onError: (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<(TipoCuenta, NotificacionesServicio?)>(
        future: _datos,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final (tipo, notif) = snap.data!;
          return NotificacionesHost(
            servicio: notif,
            child: tipo == TipoCuenta.tienda
                ? TiendaShell(
                    repo: TiendaRepositorio.instancia,
                    onSalir: widget.auth.cerrarSesion,
                    notificaciones: notif,
                  )
                : _UnirseAlEntrar(
                    grupos: widget.grupos,
                    ligas: widget.ligas,
                    amistosos: widget.amistosos,
                    onSalir: widget.auth.cerrarSesion,
                    notificaciones: notif,
                  ),
          );
        },
      );
}

/// Sin sesión: login; si se llegó por un enlace de invitación, abre directamente el registro.
class _AbrirRegistro extends StatefulWidget {
  const _AbrirRegistro({required this.auth});
  final AuthRepositorio auth;
  @override
  State<_AbrirRegistro> createState() => _AbrirRegistroState();
}

class _AbrirRegistroState extends State<_AbrirRegistro> {
  @override
  void initState() {
    super.initState();
    if (Invitacion.pendiente != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RegistroPage(auth: widget.auth, invitado: true),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => LoginPage(auth: widget.auth);
}

/// Con sesión: si hay una invitación pendiente, entra al grupo antes de mostrar el inicio.
class _UnirseAlEntrar extends StatefulWidget {
  const _UnirseAlEntrar({
    required this.grupos,
    required this.ligas,
    required this.amistosos,
    required this.onSalir,
    this.notificaciones,
  });
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  final VoidCallback onSalir;
  final NotificacionesServicio? notificaciones;
  @override
  State<_UnirseAlEntrar> createState() => _UnirseAlEntrarState();
}

class _UnirseAlEntrarState extends State<_UnirseAlEntrar> {
  late final Future<String?> _union = _unirse();

  Future<String?> _unirse() async {
    final codigo = Invitacion.pendiente;
    if (codigo == null) return null;
    try {
      await widget.grupos.unirse(codigo);
      await Invitacion.limpiar();
      return '¡Ya estás en el grupo! Puedes crear ligas y partidos amistosos.';
    } on GruposException catch (e) {
      await Invitacion.limpiar();
      return e.mensaje;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _union,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final aviso = snap.data;
      if (aviso != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) avisar(context, aviso);
        });
      }
      return JugadorShell(
        grupos: widget.grupos,
        ligas: widget.ligas,
        amistosos: widget.amistosos,
        onSalir: widget.onSalir,
        notificaciones: widget.notificaciones,
      );
    },
  );
}
