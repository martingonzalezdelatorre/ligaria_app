import 'package:supabase_flutter/supabase_flutter.dart';
import '../grupos/grupos_repositorio.dart';

enum Deporte {
  tenis('TENIS', 'Tenis'),
  padel('PADEL', 'Pádel');

  const Deporte(this.codigo, this.etiqueta);
  final String codigo, etiqueta;
  static Deporte desde(String c) => values.firstWhere((d) => d.codigo == c);
}

enum Modalidad {
  individual('INDIVIDUAL', 'Individual'),
  parejas('PAREJAS', 'Parejas');

  const Modalidad(this.codigo, this.etiqueta);
  final String codigo, etiqueta;
  static Modalidad desde(String c) => values.firstWhere((m) => m.codigo == c);
}

class Liga {
  const Liga({
    required this.id,
    required this.grupoId,
    required this.nombre,
    required this.deporte,
    required this.modalidad,
    required this.estado,
    required this.setsParaGanar,
    required this.participantes,
    required this.partidos,
    required this.jugados,
    required this.creadoPor,
  });
  final String id, grupoId, nombre, estado, creadoPor;
  final Deporte deporte;
  final Modalidad modalidad;
  final int setsParaGanar, participantes, partidos, jugados;

  bool get enBorrador => estado == 'BORRADOR';
  bool get enCurso => estado == 'EN_CURSO';
  String get estadoEtiqueta => switch (estado) {
    'BORRADOR' => 'Preparando',
    'EN_CURSO' => 'En curso',
    'FINALIZADA' => 'Finalizada',
    'CANCELADA' => 'Cancelada',
    _ => estado,
  };

  factory Liga.desdeFila(Map<String, dynamic> f) => Liga(
    id: f['id'] as String,
    grupoId: f['grupo_id'] as String,
    nombre: f['nombre'] as String,
    deporte: Deporte.desde(f['deporte'] as String),
    modalidad: Modalidad.desde(f['modalidad'] as String),
    estado: f['estado'] as String,
    setsParaGanar: (f['sets_para_ganar'] as num).toInt(),
    participantes: (f['participantes'] as num).toInt(),
    partidos: (f['partidos'] as num).toInt(),
    jugados: (f['partidos_jugados'] as num).toInt(),
    creadoPor: f['creado_por'] as String,
  );
}

class Participante {
  const Participante({required this.id, required this.nombre});
  final String id, nombre;
}

class PartidoLiga {
  const PartidoLiga({
    required this.id,
    required this.ronda,
    required this.localNombre,
    required this.visitanteNombre,
    required this.estado,
    this.ganador,
    this.resultado,
    this.fechaHora,
    this.lugar,
  });
  final String id, localNombre, visitanteNombre, estado;
  final int ronda;
  final String? ganador, resultado, lugar;
  final DateTime? fechaHora;
  bool get jugado => estado == 'JUGADO';

  factory PartidoLiga.desdeFila(Map<String, dynamic> f) => PartidoLiga(
    id: f['id'] as String,
    ronda: (f['ronda'] as num).toInt(),
    localNombre: f['local_nombre'] as String,
    visitanteNombre: f['visitante_nombre'] as String,
    estado: f['estado'] as String,
    ganador: f['ganador'] as String?,
    resultado: f['resultado'] as String?,
    fechaHora: f['fecha_hora'] == null
        ? null
        : DateTime.parse(f['fecha_hora'] as String).toLocal(),
    lugar: f['lugar'] as String?,
  );
}

class FilaClasificacion {
  const FilaClasificacion({
    required this.nombre,
    required this.pj,
    required this.pg,
    required this.pp,
    required this.difSets,
    required this.difJuegos,
    required this.puntos,
  });
  final String nombre;
  final int pj, pg, pp, difSets, difJuegos, puntos;

  factory FilaClasificacion.desdeFila(Map<String, dynamic> f) =>
      FilaClasificacion(
        nombre: f['nombre'] as String,
        pj: (f['pj'] as num).toInt(),
        pg: (f['pg'] as num).toInt(),
        pp: (f['pp'] as num).toInt(),
        difSets: (f['dif_sets'] as num).toInt(),
        difJuegos: (f['dif_juegos'] as num).toInt(),
        puntos: (f['puntos'] as num).toInt(),
      );
}

class LigasException implements Exception {
  const LigasException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Acceso a ligas, participantes, calendario y resultados. [LigasSupabase] en producción, [LigasDemo] sin configuración.
abstract class LigasRepositorio {
  /// Id del usuario con sesión iniciada.
  String? get yo;

  /// Gestiona una liga (participantes, calendario, partidos) quien es admin del grupo o quien la creó.
  bool puedeGestionar(Liga l, Grupo g);

  Future<List<Liga>> ligas(String grupoId);
  Future<void> crearLiga({
    required String grupoId,
    required String nombre,
    required Deporte deporte,
    required Modalidad modalidad,
    required int setsParaGanar,
  });
  Future<List<Participante>> participantes(String ligaId);

  /// Ids de usuario que ya juegan en la liga (no se pueden inscribir dos veces).
  Future<Set<String>> jugadoresInscritos(String ligaId);
  Future<void> agregarParticipante({
    required String ligaId,
    required String nombre,
    required List<String> usuarios,
  });
  Future<void> quitarParticipante(String participanteId);

  /// Genera todos los partidos (todos contra todos) y pone la liga en curso. Devuelve cuántos partidos creó.
  Future<int> generarCalendario(String ligaId);
  Future<List<PartidoLiga>> partidos(String ligaId);
  Future<List<FilaClasificacion>> clasificacion(String ligaId);

  /// [sets]: pares [juegosLocal, juegosVisitante] por set.
  Future<void> registrarResultado(String partidoId, List<List<int>> sets);

  /// Crea un partido suelto entre dos participantes de una liga en curso (solo administradores).
  Future<void> crearPartido({
    required String ligaId,
    required String localId,
    required String visitanteId,
    DateTime? fechaHora,
    String? lugar,
  });
}

class LigasSupabase implements LigasRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  String? get yo => _c.auth.currentUser?.id;

  @override
  bool puedeGestionar(Liga l, Grupo g) => g.esAdmin;

  @override
  Future<List<Liga>> ligas(String grupoId) => _traducir(() async {
    final filas = await _c
        .from('v_ligas')
        .select()
        .eq('grupo_id', grupoId)
        .order('created_at', ascending: false);
    return filas.map(Liga.desdeFila).toList();
  });

  @override
  Future<void> crearLiga({
    required String grupoId,
    required String nombre,
    required Deporte deporte,
    required Modalidad modalidad,
    required int setsParaGanar,
  }) => _traducir(
    () => _c.from('liga').insert({
      'grupo_id': grupoId,
      'nombre': nombre.trim(),
      'deporte': deporte.codigo,
      'modalidad': modalidad.codigo,
      'sets_para_ganar': setsParaGanar,
    }),
  );

  @override
  Future<List<Participante>> participantes(String ligaId) =>
      _traducir(() async {
        final filas = await _c
            .from('participante')
            .select('id, nombre')
            .eq('liga_id', ligaId)
            .order('created_at');
        return filas
            .map(
              (f) => Participante(
                id: f['id'] as String,
                nombre: f['nombre'] as String,
              ),
            )
            .toList();
      });

  @override
  Future<Set<String>> jugadoresInscritos(String ligaId) => _traducir(() async {
    final filas = await _c
        .from('participante_jugador')
        .select('usuario_id')
        .eq('liga_id', ligaId);
    return filas.map((f) => f['usuario_id'] as String).toSet();
  });

  @override
  Future<void> agregarParticipante({
    required String ligaId,
    required String nombre,
    required List<String> usuarios,
  }) => _traducir(() async {
    final p = await _c
        .from('participante')
        .insert({'liga_id': ligaId, 'nombre': nombre.trim()})
        .select('id')
        .single();
    final id = p['id'] as String;
    try {
      await _c.from('participante_jugador').insert([
        for (final u in usuarios)
          {'participante_id': id, 'liga_id': ligaId, 'usuario_id': u},
      ]);
    } catch (_) {
      await _c
          .from('participante')
          .delete()
          .eq('id', id); // no dejar un participante a medias
      rethrow;
    }
  });

  @override
  Future<void> quitarParticipante(String participanteId) => _traducir(
    () => _c.from('participante').delete().eq('id', participanteId),
  );

  @override
  Future<int> generarCalendario(String ligaId) => _traducir(
    () async =>
        (await _c.rpc('generar_calendario', params: {'p_liga': ligaId}) as num)
            .toInt(),
  );

  @override
  Future<List<PartidoLiga>> partidos(String ligaId) => _traducir(() async {
    final filas = await _c
        .from('v_partidos_liga')
        .select()
        .eq('liga_id', ligaId)
        .order('ronda');
    return filas.map(PartidoLiga.desdeFila).toList();
  });

  @override
  Future<List<FilaClasificacion>> clasificacion(String ligaId) =>
      _traducir(() async {
        final filas = await _c
            .from('clasificacion')
            .select()
            .eq('liga_id', ligaId);
        return ordenar(filas.map(FilaClasificacion.desdeFila).toList());
      });

  @override
  Future<void> crearPartido({
    required String ligaId,
    required String localId,
    required String visitanteId,
    DateTime? fechaHora,
    String? lugar,
  }) => _traducir(() async {
    if (localId == visitanteId) {
      throw const LigasException('Elige dos participantes distintos.');
    }
    final ultima = await _c
        .from('partido')
        .select('ronda')
        .eq('liga_id', ligaId)
        .order('ronda', ascending: false)
        .limit(1);
    await _c.from('partido').insert({
      'liga_id': ligaId,
      'ronda': ultima.isEmpty ? 1 : (ultima.first['ronda'] as num).toInt(),
      'local_id': localId,
      'visitante_id': visitanteId,
      'fecha_hora': fechaHora?.toUtc().toIso8601String(),
      'lugar': (lugar?.trim().isEmpty ?? true) ? null : lugar!.trim(),
      'estado': fechaHora == null ? 'PROPUESTO' : 'PROGRAMADO',
    });
  });

  @override
  Future<void> registrarResultado(String partidoId, List<List<int>> sets) =>
      _traducir(
        () => _c.rpc(
          'registrar_resultado',
          params: {
            'p_partido': partidoId,
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

/// Orden de la clasificación: puntos, diferencia de sets y de juegos.
List<FilaClasificacion> ordenar(List<FilaClasificacion> filas) =>
    filas..sort((a, b) {
      final c = b.puntos.compareTo(a.puntos);
      if (c != 0) return c;
      final s = b.difSets.compareTo(a.difSets);
      return s != 0 ? s : b.difJuegos.compareTo(a.difJuegos);
    });

/// En memoria, con la misma lógica básica que la base de datos.
class LigasDemo implements LigasRepositorio {
  @override
  String? get yo => 'u0'; // el usuario demo (ver GruposDemo.miembros)

  @override
  bool puedeGestionar(Liga l, Grupo g) => g.esAdmin;

  final _ligas = <Liga>[];
  final _participantes = <String, List<(Participante, List<String>)>>{};
  final _partidos = <String, List<_PartidoDemo>>{};
  int _n = 0;

  @override
  Future<List<Liga>> ligas(String grupoId) async => [
    for (final l in _ligas.reversed.where((l) => l.grupoId == grupoId))
      _refrescar(l),
  ];

  Liga _refrescar(Liga l) => Liga(
    id: l.id,
    grupoId: l.grupoId,
    nombre: l.nombre,
    deporte: l.deporte,
    modalidad: l.modalidad,
    estado: l.estado,
    setsParaGanar: l.setsParaGanar,
    participantes: _participantes[l.id]?.length ?? 0,
    partidos: _partidos[l.id]?.length ?? 0,
    jugados: _partidos[l.id]?.where((p) => p.sets != null).length ?? 0,
    creadoPor: l.creadoPor,
  );

  void _cambiarEstado(String ligaId, String estado) {
    final i = _ligas.indexWhere((l) => l.id == ligaId);
    final l = _ligas[i];
    _ligas[i] = Liga(
      id: l.id,
      grupoId: l.grupoId,
      nombre: l.nombre,
      deporte: l.deporte,
      modalidad: l.modalidad,
      estado: estado,
      setsParaGanar: l.setsParaGanar,
      participantes: l.participantes,
      partidos: l.partidos,
      jugados: l.jugados,
      creadoPor: l.creadoPor,
    );
  }

  @override
  Future<void> crearLiga({
    required String grupoId,
    required String nombre,
    required Deporte deporte,
    required Modalidad modalidad,
    required int setsParaGanar,
  }) async {
    _ligas.add(
      Liga(
        id: 'liga-${_n++}',
        grupoId: grupoId,
        nombre: nombre.trim(),
        deporte: deporte,
        modalidad: modalidad,
        estado: 'BORRADOR',
        setsParaGanar: setsParaGanar,
        participantes: 0,
        partidos: 0,
        jugados: 0,
        creadoPor: yo!,
      ),
    );
  }

  @override
  Future<List<Participante>> participantes(String ligaId) async => [
    for (final p in _participantes[ligaId] ?? []) p.$1,
  ];

  @override
  Future<Set<String>> jugadoresInscritos(String ligaId) async => {
    for (final p in _participantes[ligaId] ?? []) ...p.$2,
  };

  @override
  Future<void> agregarParticipante({
    required String ligaId,
    required String nombre,
    required List<String> usuarios,
  }) async {
    final lista = _participantes.putIfAbsent(ligaId, () => []);
    if (lista.any((p) => p.$1.nombre == nombre.trim())) {
      throw const LigasException('Ya hay un participante con ese nombre.');
    }
    lista.add((
      Participante(id: 'part-${_n++}', nombre: nombre.trim()),
      usuarios,
    ));
  }

  @override
  Future<void> quitarParticipante(String participanteId) async {
    for (final l in _participantes.values) {
      l.removeWhere((p) => p.$1.id == participanteId);
    }
  }

  @override
  Future<int> generarCalendario(String ligaId) async {
    final ps = [
      for (final p
          in _participantes[ligaId] ?? <(Participante, List<String>)>[])
        p.$1,
    ];
    if (ps.length < 2)
      throw const LigasException('Hacen falta al menos 2 participantes.');
    final arr = <Participante?>[...ps];
    if (arr.length.isOdd) arr.add(null);
    final n = arr.length;
    final out = <_PartidoDemo>[];
    for (var r = 1; r < n; r++) {
      for (var i = 0; i < n ~/ 2; i++) {
        final a = arr[i], b = arr[n - 1 - i];
        if (a != null && b != null)
          out.add(_PartidoDemo('partido-${_n++}', r, a.nombre, b.nombre));
      }
      arr.insert(1, arr.removeLast());
    }
    _partidos[ligaId] = out;
    _cambiarEstado(ligaId, 'EN_CURSO');
    return out.length;
  }

  @override
  Future<List<PartidoLiga>> partidos(String ligaId) async => [
    for (final p in _partidos[ligaId] ?? <_PartidoDemo>[])
      PartidoLiga(
        id: p.id,
        ronda: p.ronda,
        localNombre: p.local,
        visitanteNombre: p.visitante,
        estado: p.sets == null ? 'PROGRAMADO' : 'JUGADO',
        ganador: p.sets == null
            ? null
            : (p.setsLocal > p.setsVisitante ? 'LOCAL' : 'VISITANTE'),
        resultado: p.sets?.map((s) => '${s[0]}-${s[1]}').join(' '),
        fechaHora: p.fechaHora,
        lugar: p.lugar,
      ),
  ];

  @override
  Future<List<FilaClasificacion>> clasificacion(String ligaId) async {
    final filas = <String, List<int>>{
      for (final p in _participantes[ligaId] ?? [])
        p.$1.nombre: [
          0,
          0,
          0,
          0,
          0,
          0,
        ], // pj, pg, pp, difSets, difJuegos, puntos
    };
    for (final p in _partidos[ligaId] ?? <_PartidoDemo>[]) {
      if (p.sets == null) continue;
      final gl = p.setsLocal > p.setsVisitante;
      final dj = p.sets!.fold<int>(0, (a, s) => a + s[0] - s[1]);
      for (final (nombre, gana, signo) in [
        (p.local, gl, 1),
        (p.visitante, !gl, -1),
      ]) {
        final f = filas[nombre]!;
        f[0]++;
        gana ? f[1]++ : f[2]++;
        f[3] += signo * (p.setsLocal - p.setsVisitante);
        f[4] += signo * dj;
        if (gana) f[5] += 3;
      }
    }
    return ordenar([
      for (final e in filas.entries)
        FilaClasificacion(
          nombre: e.key,
          pj: e.value[0],
          pg: e.value[1],
          pp: e.value[2],
          difSets: e.value[3],
          difJuegos: e.value[4],
          puntos: e.value[5],
        ),
    ]);
  }

  @override
  Future<void> crearPartido({
    required String ligaId,
    required String localId,
    required String visitanteId,
    DateTime? fechaHora,
    String? lugar,
  }) async {
    if (localId == visitanteId) {
      throw const LigasException('Elige dos participantes distintos.');
    }
    final ps = _participantes[ligaId] ?? [];
    final l = ps.firstWhere((p) => p.$1.id == localId).$1;
    final v = ps.firstWhere((p) => p.$1.id == visitanteId).$1;
    final lista = _partidos.putIfAbsent(ligaId, () => []);
    final ronda = lista.isEmpty
        ? 1
        : lista.map((p) => p.ronda).reduce((a, b) => a > b ? a : b);
    lista.add(
      _PartidoDemo('partido-${_n++}', ronda, l.nombre, v.nombre)
        ..fechaHora = fechaHora
        ..lugar = (lugar?.trim().isEmpty ?? true) ? null : lugar!.trim(),
    );
  }

  @override
  Future<void> registrarResultado(
    String partidoId,
    List<List<int>> sets,
  ) async {
    final liga = _ligas.firstWhere(
      (l) => _partidos[l.id]?.any((p) => p.id == partidoId) ?? false,
    );
    final p = _partidos[liga.id]!.firstWhere((p) => p.id == partidoId);
    var sl = 0, sv = 0;
    for (final s in sets) {
      if (s[0] == s[1])
        throw const LigasException('Un set no puede acabar en empate.');
      if (sl == liga.setsParaGanar || sv == liga.setsParaGanar) {
        throw const LigasException(
          'El partido ya estaba decidido antes de ese set.',
        );
      }
      s[0] > s[1] ? sl++ : sv++;
    }
    if (sl != liga.setsParaGanar && sv != liga.setsParaGanar) {
      throw LigasException(
        'Ningún lado llega a ${liga.setsParaGanar} sets ganados.',
      );
    }
    p.sets = sets;
  }
}

class _PartidoDemo {
  _PartidoDemo(this.id, this.ronda, this.local, this.visitante);
  final String id, local, visitante;
  final int ronda;
  List<List<int>>? sets;
  DateTime? fechaHora;
  String? lugar;
  int get setsLocal => sets!.where((s) => s[0] > s[1]).length;
  int get setsVisitante => sets!.where((s) => s[0] < s[1]).length;
}
