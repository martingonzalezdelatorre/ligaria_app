import 'package:supabase_flutter/supabase_flutter.dart';

import '../ligas/ligas_repositorio.dart';

/// Posición de un jugador en el ranking global.
class PuestoRanking {
  const PuestoRanking({
    required this.usuarioId,
    required this.nombre,
    required this.jugados,
    required this.ganados,
  });
  final String usuarioId, nombre;
  final int jugados, ganados;

  /// Puntos por partido ganado.
  static const puntosPorVictoria = 10;

  int get puntos => ganados * puntosPorVictoria;

  /// Partidos ganados / partidos jugados (0..1).
  double get puntaje => jugados == 0 ? 0 : ganados / jugados;

  factory PuestoRanking.desdeFila(Map<String, dynamic> f) => PuestoRanking(
    usuarioId: f['usuario_id'] as String,
    nombre: (f['nombre'] as String?) ?? 'Jugador',
    jugados: (f['jugados'] as num).toInt(),
    ganados: (f['ganados'] as num).toInt(),
  );
}

/// Rankings. [RankingSupabase] en modo real, [RankingDemo] en demo.
abstract class RankingRepositorio {
  /// Lo fija `main()`; por defecto, datos de demostración.
  static RankingRepositorio instancia = RankingDemo();

  /// Global de la app: solo jugadores que se unieron en Ajustes.
  /// Ordenado por puntos, luego porcentaje de victorias y partidos jugados.
  Future<List<PuestoRanking>> ranking();

  /// De tu provincia / localidad: quienes se unieron a ese ranking y viven en el mismo sitio que tú.
  Future<List<PuestoRanking>> rankingProvincia();
  Future<List<PuestoRanking>> rankingLocalidad();

  /// De un grupo: todos sus miembros, con los partidos jugados en ese grupo.
  Future<List<PuestoRanking>> rankingGrupo(String grupoId);
}

class RankingSupabase implements RankingRepositorio {
  Future<List<PuestoRanking>> _rpc(
    String funcion, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final filas = await Supabase.instance.client.rpc(funcion, params: params);
      return [
        for (final f in filas as List)
          PuestoRanking.desdeFila(f as Map<String, dynamic>),
      ];
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }

  @override
  Future<List<PuestoRanking>> ranking() => _rpc('ranking_global');

  @override
  Future<List<PuestoRanking>> rankingProvincia() => _rpc('ranking_provincia');

  @override
  Future<List<PuestoRanking>> rankingLocalidad() => _rpc('ranking_localidad');

  @override
  Future<List<PuestoRanking>> rankingGrupo(String grupoId) =>
      _rpc('ranking_grupo', {'p_grupo': grupoId});
}

class RankingDemo implements RankingRepositorio {
  @override
  Future<List<PuestoRanking>> ranking() async => const [
    PuestoRanking(usuarioId: 'u1', nombre: 'Lucía', jugados: 12, ganados: 10),
    PuestoRanking(usuarioId: 'u2', nombre: 'Carlos', jugados: 20, ganados: 15),
    PuestoRanking(usuarioId: 'u3', nombre: 'Marta', jugados: 8, ganados: 5),
    PuestoRanking(usuarioId: 'u4', nombre: 'Demo', jugados: 10, ganados: 4),
  ];

  @override
  Future<List<PuestoRanking>> rankingProvincia() async => const [
    PuestoRanking(usuarioId: 'u2', nombre: 'Carlos', jugados: 20, ganados: 15),
    PuestoRanking(usuarioId: 'u4', nombre: 'Demo', jugados: 10, ganados: 4),
  ];

  @override
  Future<List<PuestoRanking>> rankingLocalidad() async => const [
    PuestoRanking(usuarioId: 'u4', nombre: 'Demo', jugados: 10, ganados: 4),
  ];

  @override
  Future<List<PuestoRanking>> rankingGrupo(String grupoId) async => const [
    PuestoRanking(usuarioId: 'u1', nombre: 'Amigo 1', jugados: 3, ganados: 2),
    PuestoRanking(usuarioId: 'u0', nombre: 'Demo', jugados: 3, ganados: 1),
    PuestoRanking(usuarioId: 'u2', nombre: 'Amigo 2', jugados: 0, ganados: 0),
  ];
}
