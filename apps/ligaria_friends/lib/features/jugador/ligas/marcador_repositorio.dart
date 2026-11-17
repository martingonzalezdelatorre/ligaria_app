import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'tanteo.dart';

/// Marcador en directo: quien puntúa lo publica y los demás miembros del grupo lo siguen.
/// Un partido se identifica por [amistosoId] o por [partidoId] (de liga).
abstract class MarcadorRepositorio {
  /// Lo fija `main()`. Por defecto, en memoria (demo y tests).
  static MarcadorRepositorio instancia = MarcadorDemo();

  /// Publica el estado actual; `null` lo retira (partido terminado o cancelado).
  Future<void> publicar({
    String? amistosoId,
    String? partidoId,
    Tanteo? tanteo,
  });

  /// Estado actual y cambios del marcador de un partido; `null` si no se está puntuando.
  Stream<Tanteo?> ver({String? amistosoId, String? partidoId});

  /// Ids de los partidos del grupo que se están jugando ahora mismo.
  Stream<Set<String>> enDirecto(String? grupoId);
}

class MarcadorSupabase implements MarcadorRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<void> publicar({
    String? amistosoId,
    String? partidoId,
    Tanteo? tanteo,
  }) async {
    await _c.rpc(
      'publicar_marcador',
      params: {
        'p_amistoso': amistosoId,
        'p_partido': partidoId,
        'p_estado': tanteo?.toJson(),
      },
    );
  }

  @override
  Stream<Tanteo?> ver({String? amistosoId, String? partidoId}) => _c
      .from('marcador_vivo')
      .stream(primaryKey: ['id'])
      .eq(
        amistosoId != null ? 'amistoso_id' : 'partido_id',
        (amistosoId ?? partidoId)!,
      )
      .map(
        (filas) => filas.isEmpty
            ? null
            : Tanteo.fromJson(filas.first['estado'] as Map<String, dynamic>),
      );

  @override
  Stream<Set<String>> enDirecto(String? grupoId) {
    final limite = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    final tabla = _c.from('marcador_vivo');
    // El stream no admite `is null`: sin grupo se filtra en cliente.
    return (grupoId == null
            ? tabla.stream(primaryKey: ['id'])
            : tabla.stream(primaryKey: ['id']).eq('grupo_id', grupoId))
        .map(
          (filas) => {
            for (final f in filas)
              if (f['grupo_id'] == grupoId &&
                  DateTime.parse(f['updated_at'] as String).isAfter(limite))
                (f['amistoso_id'] ?? f['partido_id']) as String,
          },
        );
  }
}

/// En memoria: sirve para la demo y para los tests.
class MarcadorDemo implements MarcadorRepositorio {
  final _estados = <String, Tanteo>{};
  final _cambios = StreamController<void>.broadcast();

  String _clave(String? a, String? p) => a != null ? 'a:$a' : 'p:$p';

  @override
  Future<void> publicar({
    String? amistosoId,
    String? partidoId,
    Tanteo? tanteo,
  }) async {
    final k = _clave(amistosoId, partidoId);
    tanteo == null ? _estados.remove(k) : _estados[k] = tanteo;
    _cambios.add(null);
  }

  Stream<T> _con<T>(T Function() leer) async* {
    yield leer();
    await for (final _ in _cambios.stream) {
      yield leer();
    }
  }

  @override
  Stream<Tanteo?> ver({String? amistosoId, String? partidoId}) =>
      _con(() => _estados[_clave(amistosoId, partidoId)]);

  @override
  Stream<Set<String>> enDirecto(String? grupoId) =>
      _con(() => {for (final k in _estados.keys) k.substring(2)});
}
