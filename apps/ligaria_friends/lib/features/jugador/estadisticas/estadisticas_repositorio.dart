import 'package:supabase_flutter/supabase_flutter.dart';

import '../ligas/ligas_repositorio.dart';

/// Estadísticas de un jugador sobre sus partidos con resultado confirmado.
///
/// En dobles los sets, juegos y puntos son los de su pareja: el punto se atribuye al lado, no
/// al jugador concreto. Los puntos solo existen en partidos puntuados con el tanteador.
class EstadisticasJugador {
  const EstadisticasJugador({
    required this.usuarioId,
    required this.nombre,
    this.partidos = 0,
    this.ganados = 0,
    this.setsGanados = 0,
    this.setsPerdidos = 0,
    this.juegosGanados = 0,
    this.juegosPerdidos = 0,
    this.partidosConPuntos = 0,
    this.puntosGanados = 0,
    this.puntosPerdidos = 0,
  });

  final String usuarioId, nombre;
  final int partidos, ganados;
  final int setsGanados, setsPerdidos;
  final int juegosGanados, juegosPerdidos;
  final int partidosConPuntos, puntosGanados, puntosPerdidos;

  int get perdidos => partidos - ganados;

  /// Victorias / partidos (0..1).
  double get pctVictorias => partidos == 0 ? 0 : ganados / partidos;

  /// Puntos ganados / puntos jugados (0..1), solo de los partidos con tanteo guardado.
  double get pctPuntos {
    final total = puntosGanados + puntosPerdidos;
    return total == 0 ? 0 : puntosGanados / total;
  }

  /// Media de puntos ganados por partido puntuado.
  double get mediaPuntosGanados =>
      partidosConPuntos == 0 ? 0 : puntosGanados / partidosConPuntos;

  /// Media de puntos perdidos por partido puntuado.
  double get mediaPuntosPerdidos =>
      partidosConPuntos == 0 ? 0 : puntosPerdidos / partidosConPuntos;

  bool get tienePuntos => partidosConPuntos > 0;

  factory EstadisticasJugador.desdeFila(Map<String, dynamic> f) {
    int n(String k) => (f[k] as num? ?? 0).toInt();
    return EstadisticasJugador(
      usuarioId: f['usuario_id'] as String,
      nombre: (f['nombre'] as String?) ?? 'Jugador',
      partidos: n('partidos'),
      ganados: n('ganados'),
      setsGanados: n('sets_ganados'),
      setsPerdidos: n('sets_perdidos'),
      juegosGanados: n('juegos_ganados'),
      juegosPerdidos: n('juegos_perdidos'),
      partidosConPuntos: n('partidos_con_puntos'),
      puntosGanados: n('puntos_ganados'),
      puntosPerdidos: n('puntos_perdidos'),
    );
  }
}

/// Estadísticas por jugador. [EstadisticasSupabase] en modo real, [EstadisticasDemo] en demo.
abstract class EstadisticasRepositorio {
  /// Lo fija `main()`; por defecto, datos de demostración.
  static EstadisticasRepositorio instancia = EstadisticasDemo();

  /// Las del usuario actual.
  Future<EstadisticasJugador> mias();

  /// Las de todos los miembros de un grupo, de más a menos victorias.
  Future<List<EstadisticasJugador>> grupo(String grupoId);
}

class EstadisticasSupabase implements EstadisticasRepositorio {
  Future<List<EstadisticasJugador>> _rpc(
    String funcion, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final filas = await Supabase.instance.client.rpc(funcion, params: params);
      return [
        for (final f in filas as List)
          EstadisticasJugador.desdeFila(f as Map<String, dynamic>),
      ];
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }

  @override
  Future<EstadisticasJugador> mias() async {
    final filas = await _rpc('estadisticas_mias');
    return filas.isEmpty
        ? const EstadisticasJugador(usuarioId: '', nombre: '')
        : filas.first;
  }

  @override
  Future<List<EstadisticasJugador>> grupo(String grupoId) async =>
      ordenarEstadisticas(
        await _rpc('estadisticas_grupo', {'p_grupo': grupoId}),
      );
}

/// Orden del grupo: victorias, luego porcentaje de victorias y partidos jugados.
List<EstadisticasJugador> ordenarEstadisticas(List<EstadisticasJugador> l) =>
    l..sort((a, b) {
      final v = b.ganados.compareTo(a.ganados);
      if (v != 0) return v;
      final p = b.pctVictorias.compareTo(a.pctVictorias);
      return p != 0 ? p : b.partidos.compareTo(a.partidos);
    });

class EstadisticasDemo implements EstadisticasRepositorio {
  @override
  Future<EstadisticasJugador> mias() async => const EstadisticasJugador(
    usuarioId: 'u0',
    nombre: 'Demo',
    partidos: 10,
    ganados: 4,
    setsGanados: 11,
    setsPerdidos: 14,
    juegosGanados: 88,
    juegosPerdidos: 97,
    partidosConPuntos: 6,
    puntosGanados: 301,
    puntosPerdidos: 322,
  );

  @override
  Future<List<EstadisticasJugador>> grupo(String grupoId) async =>
      ordenarEstadisticas([
        await mias(),
        const EstadisticasJugador(
          usuarioId: 'u1',
          nombre: 'Amigo 1',
          partidos: 3,
          ganados: 2,
          setsGanados: 5,
          setsPerdidos: 3,
          juegosGanados: 41,
          juegosPerdidos: 33,
        ),
        const EstadisticasJugador(usuarioId: 'u2', nombre: 'Amigo 2'),
      ]);
}
