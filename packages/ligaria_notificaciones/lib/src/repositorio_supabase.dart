import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'notificacion.dart';
import 'repositorio.dart';

/// Notificaciones sobre Supabase: tabla `notificacion` + Realtime (INSERT filtrado por usuario).
class NotificacionesSupabase implements NotificacionesRepositorio {
  NotificacionesSupabase(this._c);
  final SupabaseClient _c;

  @override
  String get usuarioId => _c.auth.currentUser!.id;

  @override
  Stream<Notificacion> nuevas() {
    late final StreamController<Notificacion> ctrl;
    RealtimeChannel? canal;
    ctrl = StreamController<Notificacion>(
      onListen: () {
        canal = _c
            .channel('notificaciones-$usuarioId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'notificacion',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'usuario_id',
                value: usuarioId,
              ),
              callback: (p) => ctrl.add(Notificacion.desdeMapa(p.newRecord)),
            )
            .subscribe();
      },
      onCancel: () async {
        final c = canal;
        if (c != null) await _c.removeChannel(c);
      },
    );
    return ctrl.stream;
  }

  @override
  Future<List<Notificacion>> listar({int limite = 50}) async {
    final filas = await _c
        .from('notificacion')
        .select()
        .order('created_at', ascending: false)
        .limit(limite);
    return filas.map(Notificacion.desdeMapa).toList();
  }

  @override
  Future<void> marcarLeida(String id) => _c
      .from('notificacion')
      .update({'leida_at': DateTime.now().toUtc().toIso8601String()})
      .eq('id', id);

  @override
  Future<void> marcarTodasLeidas() => _c
      .from('notificacion')
      .update({'leida_at': DateTime.now().toUtc().toIso8601String()})
      .isFilter('leida_at', null);

  @override
  Future<Map<String, PreferenciaNotificacion>> preferencias() async {
    final filas = await _c
        .from('notificacion_preferencia')
        .select('tipo, app, email');
    return {
      for (final f in filas)
        f['tipo'] as String: PreferenciaNotificacion(
          app: f['app'] as bool,
          email: f['email'] as bool,
        ),
    };
  }

  @override
  Future<void> guardarPreferencia(String tipo, PreferenciaNotificacion pref) =>
      _c.from('notificacion_preferencia').upsert({
        'usuario_id': usuarioId,
        'tipo': tipo,
        'app': pref.app,
        'email': pref.email,
      }, onConflict: 'usuario_id,tipo');
}
