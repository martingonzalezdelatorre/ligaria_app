import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Roles de la app. Se corresponden con `rol.codigo` de la base de datos (asignacion_rol):
/// ADMINISTRADOR → superadmin, ORGANIZADOR_LIGAS, ADMIN_ESCUELAS, ENTRENADOR, TUTOR, JUGADOR → alumno.
enum Rol { superadmin, organizadorLiga, adminEscuela, entrenador, alumno, tutor }

Rol rolDesdeDb(String v) => switch (v) {
      'ADMINISTRADOR' => Rol.superadmin,
      'ORGANIZADOR_LIGAS' => Rol.organizadorLiga,
      'ADMIN_ESCUELAS' => Rol.adminEscuela,
      'ENTRENADOR' => Rol.entrenador,
      'JUGADOR' => Rol.alumno,
      'TUTOR' => Rol.tutor,
      _ => throw ArgumentError('rol desconocido: $v'),
    };

String rolADb(Rol r) => switch (r) {
      Rol.superadmin => 'ADMINISTRADOR',
      Rol.organizadorLiga => 'ORGANIZADOR_LIGAS',
      Rol.adminEscuela => 'ADMIN_ESCUELAS',
      Rol.entrenador => 'ENTRENADOR',
      Rol.alumno => 'JUGADOR',
      Rol.tutor => 'TUTOR',
    };

String etiquetaRol(Rol r) => switch (r) {
      Rol.superadmin => 'Administrador de la plataforma',
      Rol.organizadorLiga => 'Organizador de ligas',
      Rol.adminEscuela => 'Administrador de escuela',
      Rol.entrenador => 'Entrenador',
      Rol.alumno => 'Jugador',
      Rol.tutor => 'Tutor',
    };

/// Un rol del usuario en una organización (escuela, ayuntamiento o grupo de amigos).
/// `escuelaId`/`escuela` son el id y el nombre de la organización, sea del tipo que sea.
class Pertenencia {
  const Pertenencia({required this.escuelaId, required this.escuela, required this.rol, this.orgTipo});
  final String? escuelaId; // null solo para el administrador de la plataforma
  final String? escuela;
  final Rol rol;
  final String? orgTipo; // ESCUELA | AYUNTAMIENTO | GRUPO_AMIGOS
  bool get esAyuntamiento => orgTipo == 'AYUNTAMIENTO';
}

/// Acceso a autenticación y pertenencias; se sustituye por un falso en los tests.
abstract class AuthRepository {
  String? get userId;
  String? get email;
  Stream<String?> get cambios; // id de usuario o null
  Stream<void> get recuperacion; // se emite al abrir el enlace de «recuperar contraseña»
  Future<void> iniciarSesion(String email, String password);
  Future<void> enviarRecuperacion(String email);
  Future<void> cerrarSesion();
  Future<void> cambiarPassword(String nueva);
  Future<List<Pertenencia>> misPertenencias();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  String? get userId => _c.auth.currentUser?.id;
  @override
  String? get email => _c.auth.currentUser?.email;
  @override
  Stream<String?> get cambios => _c.auth.onAuthStateChange.map((e) => e.session?.user.id);

  @override
  Stream<void> get recuperacion =>
      _c.auth.onAuthStateChange.where((e) => e.event == AuthChangeEvent.passwordRecovery);

  @override
  Future<void> iniciarSesion(String email, String password) =>
      _c.auth.signInWithPassword(email: email.trim(), password: password);

  /// El enlace del correo vuelve a la propia app (debe estar en Redirect URLs de Supabase).
  @override
  Future<void> enviarRecuperacion(String email) =>
      _c.auth.resetPasswordForEmail(email.trim(), redirectTo: kIsWeb ? Uri.base.origin : null);

  @override
  Future<void> cerrarSesion() => _c.auth.signOut();

  @override
  Future<void> cambiarPassword(String nueva) => _c.auth.updateUser(UserAttributes(password: nueva));

  @override
  Future<List<Pertenencia>> misPertenencias() async {
    final filas = await _c.from('v_mis_pertenencias').select('organizacion_id, organizacion, org_tipo, rol');
    return [
      for (final f in filas)
        Pertenencia(
          escuelaId: f['organizacion_id'] as String?,
          escuela: f['organizacion'] as String?,
          rol: rolDesdeDb(f['rol'] as String),
          orgTipo: f['org_tipo'] as String?,
        ),
    ];
  }
}

/// Lo fija `main()` si la app se abrió desde el enlace de recuperación (el evento puede llegar antes
/// de que exista ningún listener).
bool recuperacionInicial = false;

/// `true` mientras el usuario viene de un enlace de recuperación y aún debe elegir contraseña nueva.
class RecuperacionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final sub = ref.read(authRepositoryProvider).recuperacion.listen((_) => state = true);
    ref.onDispose(sub.cancel);
    return recuperacionInicial;
  }

  void terminar() {
    recuperacionInicial = false;
    state = false;
  }
}

final recuperacionProvider = NotifierProvider<RecuperacionNotifier, bool>(RecuperacionNotifier.new);

final authRepositoryProvider = Provider<AuthRepository>((ref) => SupabaseAuthRepository());

/// Id del usuario autenticado (null si no hay sesión).
final sesionProvider = StreamProvider<String?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.userId;
  yield* repo.cambios;
});

final pertenenciasProvider = FutureProvider<List<Pertenencia>>((ref) async {
  final uid = ref.watch(sesionProvider).value;
  if (uid == null) return const [];
  return ref.watch(authRepositoryProvider).misPertenencias();
});
