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

/// Ranking global. [RankingSupabase] en producción, [RankingDemo] sin configuración.
abstract class RankingRepositorio {
  /// Lo fija `main()`; por defecto, datos de demostración.
  static RankingRepositorio instancia = RankingDemo();

  /// Ordenado por puntos, luego porcentaje de victorias y partidos jugados.
  Future<List<PuestoRanking>> ranking();
}

class RankingSupabase implements RankingRepositorio {
  @override
  Future<List<PuestoRanking>> ranking() async {
    try {
      final filas = await Supabase.instance.client.rpc('ranking_global');
      return [
        for (final f in filas as List)
          PuestoRanking.desdeFila(f as Map<String, dynamic>),
      ];
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }
}

class RankingDemo implements RankingRepositorio {
  @override
  Future<List<PuestoRanking>> ranking() async => const [
    PuestoRanking(usuarioId: 'u1', nombre: 'Lucía', jugados: 12, ganados: 10),
    PuestoRanking(usuarioId: 'u2', nombre: 'Carlos', jugados: 20, ganados: 15),
    PuestoRanking(usuarioId: 'u3', nombre: 'Marta', jugados: 8, ganados: 5),
    PuestoRanking(usuarioId: 'u4', nombre: 'Demo', jugados: 10, ganados: 4),
  ];
}
