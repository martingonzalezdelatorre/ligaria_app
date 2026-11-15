import 'package:supabase_flutter/supabase_flutter.dart';
import '../grupos/grupos_repositorio.dart';
import '../ligas/ligas_repositorio.dart';

/// Partido de un grupo que no pertenece a ninguna liga.
class Amistoso {
  const Amistoso({
    required this.id,
    required this.grupoId,
    required this.deporte,
    required this.local,
    required this.visitante,
    required this.estado,
    required this.setsParaGanar,
    this.ganador,
    this.resultado,
    this.fechaHora,
    this.lugar,
  });
  final String id, grupoId, local, visitante, estado;
  final Deporte deporte;
  final int setsParaGanar;
  final String? ganador, resultado, lugar;
  final DateTime? fechaHora;
  bool get jugado => estado == 'JUGADO';

  factory Amistoso.desdeFila(Map<String, dynamic> f) => Amistoso(
    id: f['id'] as String,
    grupoId: f['grupo_id'] as String,
    deporte: Deporte.desde(f['deporte'] as String),
    local: (f['local_nombre'] as String?) ?? 'Jugador',
    visitante: (f['visitante_nombre'] as String?) ?? 'Jugador',
    estado: f['estado'] as String,
    setsParaGanar: (f['sets_para_ganar'] as num).toInt(),
    ganador: f['ganador'] as String?,
    resultado: f['resultado'] as String?,
    fechaHora: f['fecha_hora'] == null
        ? null
        : DateTime.parse(f['fecha_hora'] as String).toLocal(),
    lugar: f['lugar'] as String?,
  );
}

/// Acceso a amistosos. [AmistososSupabase] en producción, [AmistososDemo] sin configuración.
abstract class AmistososRepositorio {
  Future<List<Amistoso>> amistosos(String grupoId);

  /// [local] y [visitante]: ids de usuario (1 por lado en individual, 2 en parejas).
  Future<void> crear({
    required String grupoId,
    required Deporte deporte,
    required List<String> local,
    required List<String> visitante,
    required int setsParaGanar,
    DateTime? fechaHora,
    String? lugar,
  });

  /// [sets]: pares [juegosLocal, juegosVisitante] por set.
  Future<void> registrarResultado(String amistosoId, List<List<int>> sets);
}

class AmistososSupabase implements AmistososRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<List<Amistoso>> amistosos(String grupoId) => _traducir(() async {
    final filas = await _c
        .from('v_amistosos')
        .select()
        .eq('grupo_id', grupoId)
        .order('created_at', ascending: false);
    return filas.map(Amistoso.desdeFila).toList();
  });

  @override
  Future<void> crear({
    required String grupoId,
    required Deporte deporte,
    required List<String> local,
    required List<String> visitante,
    required int setsParaGanar,
    DateTime? fechaHora,
    String? lugar,
  }) => _traducir(
    () => _c.rpc(
      'crear_amistoso',
      params: {
        'p_grupo': grupoId,
        'p_deporte': deporte.codigo,
        'p_local': local,
        'p_visitante': visitante,
        'p_fecha': fechaHora?.toUtc().toIso8601String(),
        'p_lugar': lugar,
        'p_sets_para_ganar': setsParaGanar,
      },
    ),
  );

  @override
  Future<void> registrarResultado(String amistosoId, List<List<int>> sets) =>
      _traducir(
        () => _c.rpc(
          'registrar_resultado_amistoso',
          params: {
            'p_amistoso': amistosoId,
            'p_sets': [
              for (final s in sets) {'local': s[0], 'visitante': s[1]},
            ],
          },
        ),
      );

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }
}

/// En memoria; los nombres salen de los miembros del grupo demo.
class AmistososDemo implements AmistososRepositorio {
  AmistososDemo(this._grupos);
  final GruposRepositorio _grupos;
  final _lista = <Amistoso>[];
  int _n = 0;

  @override
  Future<List<Amistoso>> amistosos(String grupoId) async => [
    for (final a in _lista.reversed.where((a) => a.grupoId == grupoId)) a,
  ];

  @override
  Future<void> crear({
    required String grupoId,
    required Deporte deporte,
    required List<String> local,
    required List<String> visitante,
    required int setsParaGanar,
    DateTime? fechaHora,
    String? lugar,
  }) async {
    final miembros = await _grupos.miembros(grupoId);
    String nombres(List<String> ids) => [
      for (final id in ids) miembros.firstWhere((m) => m.id == id).nombre,
    ].join(' / ');
    _lista.add(
      Amistoso(
        id: 'amistoso-${_n++}',
        grupoId: grupoId,
        deporte: deporte,
        local: nombres(local),
        visitante: nombres(visitante),
        estado: fechaHora == null ? 'PROPUESTO' : 'PROGRAMADO',
        setsParaGanar: setsParaGanar,
        fechaHora: fechaHora,
        lugar: (lugar?.trim().isEmpty ?? true) ? null : lugar!.trim(),
      ),
    );
  }

  @override
  Future<void> registrarResultado(
    String amistosoId,
    List<List<int>> sets,
  ) async {
    final i = _lista.indexWhere((a) => a.id == amistosoId);
    final a = _lista[i];
    var sl = 0, sv = 0;
    for (final s in sets) {
      if (s[0] == s[1]) {
        throw const LigasException('Un set no puede acabar en empate.');
      }
      if (sl == a.setsParaGanar || sv == a.setsParaGanar) {
        throw const LigasException(
          'El partido ya estaba decidido antes de ese set.',
        );
      }
      s[0] > s[1] ? sl++ : sv++;
    }
    if (sl != a.setsParaGanar && sv != a.setsParaGanar) {
      throw LigasException(
        'Ningún lado llega a ${a.setsParaGanar} sets ganados.',
      );
    }
    _lista[i] = Amistoso(
      id: a.id,
      grupoId: a.grupoId,
      deporte: a.deporte,
      local: a.local,
      visitante: a.visitante,
      estado: 'JUGADO',
      setsParaGanar: a.setsParaGanar,
      ganador: sl > sv ? 'LOCAL' : 'VISITANTE',
      resultado: sets.map((s) => '${s[0]}-${s[1]}').join(' '),
      fechaHora: a.fechaHora,
      lugar: a.lugar,
    );
  }
}
