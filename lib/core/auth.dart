import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Rol { superadmin, organizadorLiga, adminEscuela, entrenador, alumno, tutor }

Rol rolDesdeDb(String v) => switch (v) {
      'superadmin' => Rol.superadmin,
      'organizador_liga' => Rol.organizadorLiga,
      'admin_escuela' => Rol.adminEscuela,
      'entrenador' => Rol.entrenador,
      'alumno' => Rol.alumno,
      'tutor' => Rol.tutor,
      _ => throw ArgumentError('rol desconocido: $v'),
    };

String rolADb(Rol r) => switch (r) {
      Rol.superadmin => 'superadmin',
      Rol.organizadorLiga => 'organizador_liga',
      Rol.adminEscuela => 'admin_escuela',
      Rol.entrenador => 'entrenador',
      Rol.alumno => 'alumno',
      Rol.tutor => 'tutor',
    };

String etiquetaRol(Rol r) => switch (r) {
      Rol.superadmin => 'Superadministrador',
      Rol.organizadorLiga => 'Organizador de liga',
      Rol.adminEscuela => 'Administrador de escuela',
      Rol.entrenador => 'Entrenador',
      Rol.alumno => 'Alumno',
      Rol.tutor => 'Tutor',
    };

class Pertenencia {
  const Pertenencia({required this.escuelaId, required this.escuela, required this.rol});
  final String? escuelaId;
  final String? escuela;
  final Rol rol;
}

/// Acceso a autenticación y pertenencias; se sustituye por un falso en los tests.
abstract class AuthRepository {
  String? get userId;
  String? get email;
  Stream<String?> get cambios; // id de usuario o null
  Future<void> iniciarSesion(String email, String password);
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
  Future<void> iniciarSesion(String email, String password) =>
      _c.auth.signInWithPassword(email: email.trim(), password: password);

  @override
  Future<void> cerrarSesion() => _c.auth.signOut();

  @override
  Future<void> cambiarPassword(String nueva) => _c.auth.updateUser(UserAttributes(password: nueva));

  @override
  Future<List<Pertenencia>> misPertenencias() async {
    final filas = await _c.from('v_mis_pertenencias').select('escuela_id, escuela, rol');
    return [
      for (final f in filas)
        Pertenencia(
          escuelaId: f['escuela_id'] as String?,
          escuela: f['escuela'] as String?,
          rol: rolDesdeDb(f['rol'] as String),
        ),
    ];
  }
}

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
