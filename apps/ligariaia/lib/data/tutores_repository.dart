import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const parentescos = ['Madre', 'Padre', 'Tutor legal', 'Otro familiar'];

/// Padre, madre o tutor de un jugador. `pendiente`: aún no ha creado su cuenta (se vincula al registrarse).
class TutorJugador {
  const TutorJugador({
    required this.nombre,
    required this.email,
    this.parentesco,
    this.telefono,
    this.pendiente = false,
  });
  final String nombre, email;
  final String? parentesco, telefono;
  final bool pendiente;
}

/// Datos para asociar un tutor (alta del alumno o después).
class TutorNuevo {
  const TutorNuevo({
    required this.nombre,
    required this.parentesco,
    required this.email,
    this.telefono = '',
  });
  final String nombre, parentesco, email, telefono;
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'parentesco': parentesco,
    'email': email,
    'telefono': telefono,
  };
}

abstract class TutoresRepository {
  /// Da de alta al jugador y asocia a sus tutores en una sola operación.
  Future<void> crearJugador(
    String orgId,
    String nombre,
    String apellidos,
    DateTime nacimiento,
    List<TutorNuevo> tutores,
  );

  /// Asocia un tutor a un jugador existente. Devuelve 'vinculado' (ya tenía cuenta) o 'pendiente'.
  Future<String> anadirTutor(String jugadorId, TutorNuevo t);

  Future<Map<String, List<TutorJugador>>> tutoresDe(List<String> jugadorIds);

  /// Corrige los datos de un tutor cuya invitación sigue pendiente. Devuelve 'pendiente' o 'vinculado'.
  Future<String> editarTutorPendiente(
    String jugadorId,
    String emailActual,
    TutorNuevo t,
  );

  /// Envía por correo la invitación para crear cuenta a cada madre, padre o tutor con invitación pendiente.
  /// Devuelve true si todos los correos salieron; si falla no se pierde nada: la invitación sigue pendiente.
  Future<bool> enviarInvitaciones(String orgId, List<String> emails);

  /// Un tutor da de alta a su hijo o hija en la organización que le invitó.
  Future<void> anadirHijo(
    String orgId,
    String nombre,
    String apellidos,
    DateTime nacimiento,
    String parentesco,
  );
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class SupabaseTutoresRepository implements TutoresRepository {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<void> crearJugador(
    String orgId,
    String nombre,
    String apellidos,
    DateTime nacimiento,
    List<TutorNuevo> tutores,
  ) => _c.rpc(
    'crear_jugador_con_tutores',
    params: {
      'p_org': orgId,
      'p_nombre': nombre,
      'p_apellidos': apellidos,
      'p_fecha_nacimiento': _iso(nacimiento),
      'p_tutores': [for (final t in tutores) t.toJson()],
    },
  );

  @override
  Future<String> anadirTutor(String jugadorId, TutorNuevo t) async =>
      await _c.rpc(
            'anadir_tutor',
            params: {
              'p_jugador': jugadorId,
              'p_nombre': t.nombre,
              'p_parentesco': t.parentesco,
              'p_email': t.email,
              'p_telefono': t.telefono,
            },
          )
          as String;

  @override
  Future<void> anadirHijo(
    String orgId,
    String nombre,
    String apellidos,
    DateTime nacimiento,
    String parentesco,
  ) => _c.rpc(
    'anadir_hijo',
    params: {
      'p_org': orgId,
      'p_nombre': nombre,
      'p_apellidos': apellidos,
      'p_fecha_nacimiento': _iso(nacimiento),
      'p_parentesco': parentesco,
    },
  );

  @override
  Future<String> editarTutorPendiente(
    String jugadorId,
    String emailActual,
    TutorNuevo t,
  ) async =>
      await _c.rpc(
            'editar_tutor_pendiente',
            params: {
              'p_jugador': jugadorId,
              'p_email_actual': emailActual,
              'p_nombre': t.nombre,
              'p_parentesco': t.parentesco,
              'p_email': t.email,
              'p_telefono': t.telefono,
            },
          )
          as String;

  @override
  Future<bool> enviarInvitaciones(String orgId, List<String> emails) async {
    if (emails.isEmpty) return true;
    try {
      final r = await _c.functions.invoke(
        'invitar-familia',
        body: {'org_id': orgId, 'emails': emails},
      );
      final d = r.data;
      return d is Map && (d['fallidos'] as List? ?? const []).isEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, List<TutorJugador>>> tutoresDe(
    List<String> jugadorIds,
  ) async {
    if (jugadorIds.isEmpty) return {};
    final filas = await _c
        .from('v_tutores_jugador')
        .select()
        .inFilter('jugador_id', jugadorIds);
    final m = <String, List<TutorJugador>>{};
    for (final f in filas) {
      (m[f['jugador_id'] as String] ??= []).add(
        TutorJugador(
          nombre: (f['nombre'] as String?) ?? '',
          email: (f['email'] as String?) ?? '',
          parentesco: f['parentesco'] as String?,
          telefono: f['telefono'] as String?,
          pendiente: f['estado'] == 'pendiente',
        ),
      );
    }
    return m;
  }
}

final tutoresRepositoryProvider = Provider<TutoresRepository>(
  (ref) => SupabaseTutoresRepository(),
);
