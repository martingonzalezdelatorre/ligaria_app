import '../core/idioma.dart';
import 'categoria_edad.dart';
export 'categoria_edad.dart' show CategoriaEquipo;

// Modelos de lectura de la app (reflejan las vistas/RPC de supabase/migrations).

DateTime? _fecha(dynamic v) => v == null ? null : DateTime.parse(v as String);
int? _int(dynamic v) => v == null ? null : (v as num).toInt();

/// Puntos por victoria, empate y derrota de una liga (los registros comparan por valor).
typedef Puntuacion = ({int victoria, int empate, int derrota});
const Puntuacion puntuacionPorDefecto = (victoria: 3, empate: 1, derrota: 0);

/// Criterios con los que se desempata a equipos con los mismos puntos (valores de `competicion.desempate`).
const criteriosDesempate = [
  'ENFRENTAMIENTO',
  'DIF_PARTIDOS',
  'DIF_SETS',
  'DIF_JUEGOS',
];
const criteriosDesempatePorDefecto = ['DIF_PARTIDOS', 'DIF_SETS', 'DIF_JUEGOS'];

/// Nombre de una ronda de eliminatoria según los emparejamientos que tiene (incluidos los pases directos).
String nombreRonda(int? llaves, int numero) => switch (llaves) {
  1 => l10nActual.rondaFinal,
  2 => l10nActual.rondaSemis,
  4 => l10nActual.rondaCuartos,
  8 => l10nActual.rondaOctavos,
  null => l10nActual.rondaN(numero),
  _ => l10nActual.rondaDeN(llaves * 2),
};

/// «Grupo A» para el grupo 1, «Grupo B» para el 2…
String nombreGrupo(int grupo) =>
    l10nActual.grupoX(String.fromCharCode(64 + grupo));

String etiquetaFormato(String formato) => switch (formato) {
  'ELIMINATORIA' => l10nActual.fmtEliminatoria,
  'MIXTO' => l10nActual.fmtMixto,
  _ => l10nActual.fmtLiga,
};

class Liga {
  const Liga({
    required this.id,
    required this.nombre,
    required this.estado,
    this.deporte,
    this.organizationId,
    this.deporteId,
    this.tipo,
    this.fechaInicio,
    this.fechaFin,
    this.visibilidad = 'PUBLICA',
    this.puntuacion = puntuacionPorDefecto,
    this.formato = 'LIGA',
    this.desempate = criteriosDesempatePorDefecto,
  });
  final String id;
  final String nombre;
  final String
  estado; // borrador | publicada | en_curso | finalizada | cancelada
  final String? deporte; // nombre legible (Tenis / Pádel)
  final String? organizationId;
  final String? deporteId; // código de deporte_tipo: TENIS | PADEL
  final String?
  tipo; // competicion_tipo: MUNICIPAL | ENTRE_ESCUELAS | ESCUELA | AMIGOS
  final DateTime? fechaInicio, fechaFin;
  final String visibilidad; // competicion_visibilidad: PUBLICA | PRIVADA
  final Puntuacion puntuacion; // puntos por victoria, empate y derrota
  final String formato; // competicion_formato: LIGA | ELIMINATORIA | MIXTO
  final List<String> desempate; // criterios de desempate, por orden
  bool get finalizada => estado == 'finalizada';
  bool get enCurso => estado == 'en_curso';
  bool get esEliminatoria => formato == 'ELIMINATORIA';
  bool get esMixto => formato == 'MIXTO';
  bool get privada => visibilidad == 'PRIVADA';

  /// Solo las ligas municipales y entre escuelas admiten escuelas de fuera (y por tanto invitaciones).
  bool get admiteEscuelasExternas =>
      tipo == 'MUNICIPAL' || tipo == 'ENTRE_ESCUELAS';
  factory Liga.fromRow(Map<String, dynamic> r) => Liga(
    visibilidad: (r['visibilidad'] as String?) ?? 'PUBLICA',
    formato: (r['formato'] as String?) ?? 'LIGA',
    desempate: r['desempate'] == null
        ? criteriosDesempatePorDefecto
        : (r['desempate'] as String).split(','),
    puntuacion: (
      victoria: _int(r['puntos_victoria']) ?? 3,
      empate: _int(r['puntos_empate']) ?? 1,
      derrota: _int(r['puntos_derrota']) ?? 0,
    ),
    id: r['id'] as String,
    nombre: r['nombre'] as String,
    estado: r['estado'] as String,
    deporte: r['deporte'] as String?,
    organizationId: r['organizacion_id'] as String?,
    deporteId: r['deporte_id'] as String?,
    tipo: r['tipo'] as String?,
    fechaInicio: _fecha(r['fecha_inicio']),
    fechaFin: _fecha(r['fecha_fin']),
  );
}

/// Jornadas de un todos-contra-todos: n-1 (n par) o n (impar, con descanso), por vuelta.
int jornadasLiga(int equipos, int vueltas) {
  if (equipos < 2) return 0;
  return (equipos.isEven ? equipos - 1 : equipos) * vueltas;
}

/// Deportes disponibles (enum deporte_tipo de la base de datos).
const deportesDisponibles = [
  Deporte(id: 'TENIS', nombre: 'Tenis'),
  Deporte(id: 'PADEL', nombre: 'Pádel'),
];

/// Tipos de competición que puede crear una organización según su tipo (organizacion_tipo).
List<({String codigo, String etiqueta})> tiposCompeticionDe(String? orgTipo) =>
    switch (orgTipo) {
      'AYUNTAMIENTO' => [
        (codigo: 'MUNICIPAL', etiqueta: l10nActual.tipoMunicipal),
      ],
      'GRUPO_AMIGOS' => [(codigo: 'AMIGOS', etiqueta: l10nActual.tipoAmigos)],
      _ => [
        (codigo: 'ENTRE_ESCUELAS', etiqueta: l10nActual.tipoEntreEscuelas),
        (codigo: 'ESCUELA', etiqueta: l10nActual.tipoInterna),
      ],
    };

class LigaAbierta {
  const LigaAbierta({
    required this.id,
    required this.nombre,
    required this.deporteId,
    required this.deporte,
    required this.organizadora,
    this.visibilidad = 'PUBLICA',
  });
  final String id, nombre, deporteId, deporte, organizadora;
  final String
  visibilidad; // PUBLICA | PRIVADA (privada: la escuela fue invitada)
  bool get privada => visibilidad == 'PRIVADA';
  factory LigaAbierta.fromRow(Map<String, dynamic> r) => LigaAbierta(
    id: r['competicion_id'] as String,
    nombre: r['nombre'] as String,
    deporteId: r['deporte_id'] as String,
    deporte: r['deporte'] as String,
    organizadora: r['organizadora'] as String,
    visibilidad: (r['visibilidad'] as String?) ?? 'PUBLICA',
  );
}

/// Invitación de una liga a una escuela, vista por quien organiza la liga.
class InvitacionLiga {
  const InvitacionLiga({
    required this.ligaId,
    required this.escuelaId,
    required this.escuela,
    this.ciudad,
    required this.estado,
  });
  final String ligaId, escuelaId, escuela;
  final String? ciudad;
  final String estado; // pendiente | aceptada | rechazada
  factory InvitacionLiga.fromRow(Map<String, dynamic> r) => InvitacionLiga(
    ligaId: r['competicion_id'] as String,
    escuelaId: r['organizacion_id'] as String,
    escuela: r['escuela'] as String,
    ciudad: r['ciudad'] as String?,
    estado: r['estado'] as String,
  );
}

/// Invitación pendiente de responder, vista por la escuela invitada.
class MiInvitacion {
  const MiInvitacion({
    required this.ligaId,
    required this.escuelaId,
    required this.nombre,
    required this.deporte,
    required this.organizadora,
  });
  final String ligaId, escuelaId, nombre, deporte, organizadora;
  factory MiInvitacion.fromRow(Map<String, dynamic> r) => MiInvitacion(
    ligaId: r['competicion_id'] as String,
    escuelaId: r['organizacion_id'] as String,
    nombre: r['nombre'] as String,
    deporte: r['deporte'] as String,
    organizadora: r['organizadora'] as String,
  );
}

/// Escuela a la que se puede invitar (solo nombre y ciudad).
class EscuelaInvitable {
  const EscuelaInvitable({required this.id, required this.nombre, this.ciudad});
  final String id, nombre;
  final String? ciudad;
  factory EscuelaInvitable.fromRow(Map<String, dynamic> r) => EscuelaInvitable(
    id: r['organizacion_id'] as String,
    nombre: r['nombre'] as String,
    ciudad: r['ciudad'] as String?,
  );
}

/// Categoría de una liga (género, edad y nivel son opcionales).
class CategoriaLiga {
  const CategoriaLiga({
    required this.id,
    required this.ligaId,
    required this.nombre,
    this.genero,
    this.edadMin,
    this.edadMax,
    this.nivel,
  });
  final String id, ligaId, nombre;
  final String? genero, nivel; // genero: MASCULINO | FEMENINO | MIXTO
  final int? edadMin, edadMax;
  factory CategoriaLiga.fromRow(Map<String, dynamic> r) => CategoriaLiga(
    id: r['categoria_id'] as String,
    ligaId: r['competicion_id'] as String,
    nombre: r['nombre'] as String,
    genero: r['genero'] as String?,
    edadMin: _int(r['edad_min']),
    edadMax: _int(r['edad_max']),
    nivel: r['nivel'] as String?,
  );

  /// «Mixto · hasta 10 años · Iniciación», o null si no tiene ningún criterio.
  String? get detalle {
    final partes = [
      if (genero != null) etiquetaGenero(genero),
      if (edadMin != null && edadMax != null)
        l10nActual.edadRango(edadMin!, edadMax!)
      else if (edadMax != null)
        l10nActual.edadHasta(edadMax!)
      else if (edadMin != null)
        l10nActual.edadDesde(edadMin!),
      if (nivel != null && nivel!.isNotEmpty) nivel!,
    ];
    return partes.isEmpty ? null : partes.join(' · ');
  }
}

/// Co-organizador de una liga (gestiona solo esa liga).
class OrganizadorLiga {
  const OrganizadorLiga({
    this.usuarioId,
    required this.email,
    this.nombre,
    this.pendiente = false,
  });
  final String? usuarioId; // null mientras la invitación no se ha activado
  final String email;
  final String? nombre;

  /// Invitado por correo y aún sin cuenta: se activará cuando se registre.
  final bool pendiente;
  String get etiqueta =>
      (nombre == null || nombre!.isEmpty) ? email : '$nombre · $email';
  factory OrganizadorLiga.fromRow(Map<String, dynamic> r) => OrganizadorLiga(
    usuarioId: r['usuario_id'] as String?,
    email: (r['email'] as String?) ?? '',
    nombre: r['nombre'] as String?,
    pendiente: (r['pendiente'] as bool?) ?? false,
  );
}

String etiquetaEstadoInvitacion(String estado) => switch (estado) {
  'pendiente' => l10nActual.estInvPendiente,
  'aceptada' => l10nActual.estAceptada,
  'rechazada' => l10nActual.estRechazada,
  _ => estado,
};

/// Solicitud de un equipo para participar en una liga.
class InscripcionVista {
  const InscripcionVista({
    required this.id,
    required this.ligaId,
    required this.equipoId,
    required this.equipo,
    required this.escuelaId,
    required this.escuela,
    required this.estado,
    this.categoria,
  });
  final String id, ligaId, equipoId, equipo, escuelaId, escuela;
  final String? categoria;
  final String estado; // pendiente | aceptada | rechazada | retirada
  bool get pendiente => estado == 'pendiente';
  factory InscripcionVista.fromRow(Map<String, dynamic> r) => InscripcionVista(
    id: r['inscripcion_id'] as String,
    ligaId: r['competicion_id'] as String,
    equipoId: r['equipo_id'] as String,
    equipo: r['equipo'] as String,
    escuelaId: r['organizacion_id'] as String,
    escuela: r['escuela'] as String,
    estado: r['estado'] as String,
    categoria: r['categoria'] as String?,
  );
}

String etiquetaEstadoInscripcion(String estado) => switch (estado) {
  'pendiente' => l10nActual.estPendiente,
  'aceptada' => l10nActual.estAceptada,
  'rechazada' => l10nActual.estRechazada,
  'retirada' => l10nActual.estRetirada,
  _ => estado,
};

class EncuentroVista {
  const EncuentroVista({
    required this.id,
    required this.ligaId,
    required this.jornada,
    required this.estado,
    required this.localId,
    required this.local,
    required this.visitanteId,
    required this.visitante,
    this.fecha,
    this.partidosLocal,
    this.partidosVisitante,
    this.incomparecencia,
    this.categoria,
    this.fase = 'liga',
    this.grupo,
    this.llaves,
    this.llave,
    this.conHora = false,
    this.sede,
    this.pista,
  });
  final String id, ligaId, estado, localId, local, visitanteId, visitante;
  final bool conHora; // la fecha es propia del encuentro y lleva hora
  final String? sede, pista;
  final String? categoria; // nombre de la categoría de la liga
  final String fase; // liga | eliminatoria
  final int? grupo; // grupo de la fase de liga (formato MIXTO)
  final int?
  llaves; // eliminatoria: emparejamientos de la ronda (decide su nombre)
  final int?
  llave; // eliminatoria: posición del emparejamiento en su ronda (1…llaves)
  bool get esEliminatoria => fase == 'eliminatoria';

  /// «Jornada 2» en la fase de liga o el nombre de la ronda («Semifinales») en eliminatoria.
  String get etiquetaJornada => esEliminatoria
      ? nombreRonda(llaves, jornada)
      : l10nActual.jornadaN(jornada);
  final int jornada;
  final DateTime? fecha; // fecha propia del encuentro, o la de la jornada
  final int? partidosLocal,
      partidosVisitante; // null si el resultado no es visible
  final String? incomparecencia; // 'local' | 'visitante'
  bool get tieneMarcador => partidosLocal != null && partidosVisitante != null;

  /// Encuentro ya jugado (resultado registrado, incluida la incomparecencia).
  bool get confirmado => estado == 'finalizado' || estado == 'no_presentado';
  factory EncuentroVista.fromRow(Map<String, dynamic> r) => EncuentroVista(
    id: r['encuentro_id'] as String,
    ligaId: r['competicion_id'] as String,
    jornada: _int(r['jornada'])!,
    estado: r['estado'] as String,
    localId: r['local_equipo_id'] as String,
    local: r['local'] as String,
    visitanteId: r['visitante_equipo_id'] as String,
    visitante: r['visitante'] as String,
    fecha: _fecha(r['fecha'])?.toLocal() ?? _fecha(r['jornada_fecha']),
    conHora: r['fecha'] != null,
    sede: r['sede'] as String?,
    pista: r['pista'] as String?,
    partidosLocal: _int(r['partidos_local']),
    partidosVisitante: _int(r['partidos_visitante']),
    incomparecencia: r['incomparecencia'] as String?,
    categoria: r['categoria'] as String?,
    fase: (r['fase'] as String?) ?? 'liga',
    grupo: _int(r['grupo']),
    llaves: _int(r['llaves']),
    llave: _int(r['llave']),
  );
}

/// Sesión de entrenamiento que el entrenador asigna a un equipo (aparece en el calendario).
class Entreno {
  const Entreno({
    required this.id,
    required this.equipoId,
    required this.equipo,
    required this.fecha,
    this.duracionMin,
    this.lugar,
    this.notas,
  });
  final String id, equipoId, equipo;
  final DateTime fecha; // hora local
  final int? duracionMin;
  final String? lugar, notas;
  factory Entreno.fromRow(Map<String, dynamic> r) => Entreno(
    id: r['entreno_id'] as String,
    equipoId: r['equipo_id'] as String,
    equipo: r['equipo'] as String,
    fecha: _fecha(r['fecha'])!.toLocal(),
    duracionMin: _int(r['duracion_min']),
    lugar: r['lugar'] as String?,
    notas: r['notas'] as String?,
  );
}

/// Dónde está mi equipo en un cuadro de eliminatoria, a partir de los encuentros visibles:
/// `estado` es `en_juego`, `clasificado` (ganó y espera la siguiente ronda), `campeon`, `eliminado`,
/// `pase_directo` (descansa en la primera ronda) o `sin_cuadro` (aún no hay cuadro).
/// `ronda` es la ronda de su último encuentro («Semifinales»…), o «—».
({String ronda, String estado}) situacionEliminatoria(
  List<EncuentroVista> encs,
  Set<String> mios, {
  bool pasoDirecto = false,
}) {
  final mias =
      encs
          .where(
            (e) =>
                e.esEliminatoria &&
                (mios.contains(e.localId) || mios.contains(e.visitanteId)),
          )
          .toList()
        ..sort((a, b) => a.jornada.compareTo(b.jornada));
  if (mias.isEmpty) {
    return (ronda: '—', estado: pasoDirecto ? 'pase_directo' : 'sin_cuadro');
  }
  final e = mias.last;
  if (!e.confirmado) return (ronda: e.etiquetaJornada, estado: 'en_juego');
  final local = e.partidosLocal ?? 0, visitante = e.partidosVisitante ?? 0;
  final gane = mios.contains(e.localId) ? local > visitante : visitante > local;
  if (!gane) return (ronda: e.etiquetaJornada, estado: 'eliminado');
  return (
    ronda: e.etiquetaJornada,
    estado: e.llaves == 1 ? 'campeon' : 'clasificado',
  );
}

String etiquetaSituacionEliminatoria(String estado) => switch (estado) {
  'en_juego' => l10nActual.sitEnJuego,
  'clasificado' => l10nActual.sitClasificado,
  'campeon' => l10nActual.sitCampeon,
  'eliminado' => l10nActual.sitEliminado,
  'pase_directo' => l10nActual.sitPaseDirecto,
  _ => '—',
};

/// Encuentros de una misma jornada (o ronda) de una categoría y grupo.
class GrupoEncuentros {
  const GrupoEncuentros({
    required this.categoria,
    required this.fase,
    this.grupo,
    required this.jornada,
    required this.encuentros,
    required this.equiposDelGrupo,
    this.conCategoria = false,
  });
  final String categoria, fase;
  final int? grupo;
  final int jornada;
  final List<EncuentroVista> encuentros;

  /// Equipos que juegan en esa categoría, fase y grupo (para asignar descansos al grupo correcto).
  final Set<String> equiposDelGrupo;
  final bool conCategoria;
  bool get esEliminatoria => fase == 'eliminatoria';
  int? get llaves => encuentros.first.llaves;

  /// «Sub-10 · Grupo A · Jornada 2» o «Semifinales» (la categoría solo si la liga tiene varias).
  String get titulo => [
    if (conCategoria) categoria.isEmpty ? l10nActual.general : categoria,
    if (esEliminatoria)
      nombreRonda(llaves, jornada)
    else ...[
      if (grupo != null) nombreGrupo(grupo!),
      l10nActual.jornadaN(jornada),
    ],
  ].join(' · ');
}

/// Agrupa los encuentros por categoría, fase, grupo y jornada (los números de jornada se repiten entre
/// grupos, categorías y fases). Orden: categoría, fase de liga antes que eliminatoria, grupo y jornada.
List<GrupoEncuentros> agruparEncuentros(List<EncuentroVista> encs) {
  final varias = encs.map((e) => e.categoria ?? '').toSet().length > 1;
  String clave(EncuentroVista e) =>
      '${e.categoria ?? ''}|${e.fase}|${e.grupo ?? 0}';
  final equipos = <String, Set<String>>{};
  for (final e in encs) {
    equipos.putIfAbsent(clave(e), () => {}).addAll([e.localId, e.visitanteId]);
  }
  final grupos = <String, List<EncuentroVista>>{};
  for (final e in encs) {
    grupos.putIfAbsent('${clave(e)}|${e.jornada}', () => []).add(e);
  }
  final lista = [
    for (final g in grupos.values)
      GrupoEncuentros(
        categoria: g.first.categoria ?? '',
        fase: g.first.fase,
        grupo: g.first.grupo,
        jornada: g.first.jornada,
        encuentros: g,
        equiposDelGrupo: equipos[clave(g.first)]!,
        conCategoria: varias,
      ),
  ];
  int fase(String f) => f == 'liga' ? 0 : 1;
  lista.sort((a, b) {
    var c = a.categoria.compareTo(b.categoria);
    if (c == 0) c = fase(a.fase).compareTo(fase(b.fase));
    if (c == 0) c = (a.grupo ?? 0).compareTo(b.grupo ?? 0);
    if (c == 0) c = a.jornada.compareTo(b.jornada);
    return c;
  });
  return lista;
}

class Descanso {
  const Descanso({
    required this.jornada,
    required this.equipoId,
    required this.equipo,
    this.categoria,
    this.llave,
  });
  final int jornada;
  final String equipoId, equipo;
  final String? categoria; // solo en los pases directos de una eliminatoria
  final int? llave; // posición del pase directo en el cuadro
  factory Descanso.fromRow(Map<String, dynamic> r) => Descanso(
    jornada: _int(r['jornada'])!,
    equipoId: r['equipo_id'] as String,
    equipo: r['equipo'] as String,
    categoria: r['categoria'] as String?,
    llave: _int(r['llave']),
  );
}

class FilaClasificacion {
  const FilaClasificacion({
    required this.posicion,
    required this.equipoId,
    required this.equipo,
    required this.escuela,
    required this.pj,
    required this.pg,
    required this.pe,
    required this.pp,
    required this.puntos,
    required this.partidosF,
    required this.partidosC,
    required this.setsF,
    required this.setsC,
    required this.juegosF,
    required this.juegosC,
    this.categoria,
    this.grupo,
  });
  final int posicion,
      pj,
      pg,
      pe,
      pp,
      puntos,
      partidosF,
      partidosC,
      setsF,
      setsC,
      juegosF,
      juegosC;
  final String equipoId, equipo, escuela;
  final String?
  categoria; // la posición se calcula dentro de cada categoría (y grupo)
  final int? grupo; // grupo de la fase de liga (formato MIXTO)
  factory FilaClasificacion.fromRow(Map<String, dynamic> r) =>
      FilaClasificacion(
        posicion: _int(r['posicion'])!,
        equipoId: r['equipo_id'] as String,
        equipo: r['equipo'] as String,
        escuela: r['escuela'] as String,
        pj: _int(r['pj'])!,
        pg: _int(r['pg'])!,
        pe: _int(r['pe'])!,
        pp: _int(r['pp'])!,
        puntos: _int(r['puntos'])!,
        partidosF: _int(r['partidos_f'])!,
        partidosC: _int(r['partidos_c'])!,
        setsF: _int(r['sets_f'])!,
        setsC: _int(r['sets_c'])!,
        juegosF: _int(r['juegos_f'])!,
        juegosC: _int(r['juegos_c'])!,
        categoria: r['categoria'] as String?,
        grupo: _int(r['grupo']),
      );
}

class MiEquipo {
  const MiEquipo({
    required this.equipoId,
    required this.equipo,
    required this.escuelaId,
    required this.escuela,
    required this.rol,
    this.ligaId,
    this.liga,
  });
  final String equipoId, equipo, escuelaId, escuela;
  final String rol; // entrenador | alumno | tutor
  final String? ligaId, liga;
  factory MiEquipo.fromRow(Map<String, dynamic> r) => MiEquipo(
    equipoId: r['equipo_id'] as String,
    equipo: r['equipo'] as String,
    escuelaId: r['organizacion_id'] as String,
    escuela: r['organizacion'] as String,
    rol: r['rol'] as String,
    ligaId: r['competicion_id'] as String?,
    liga: r['competicion'] as String?,
  );
}

class Ficha {
  const Ficha({
    required this.jugadorId,
    this.escuelaId,
    this.escuela,
    required this.nombre,
    required this.apellidos,
    this.fechaNacimiento,
    this.genero,
    this.nivel,
    this.manoDominante,
    required this.relacion,
  });
  final String jugadorId, nombre, apellidos;
  final String? escuelaId, escuela;
  final DateTime? fechaNacimiento;
  final String? genero; // MASCULINO | FEMENINO | MIXTO
  final String? nivel;
  final String? manoDominante; // DIESTRO | ZURDO | AMBIDIESTRO
  final String relacion; // propia | tutor
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Ficha.fromRow(Map<String, dynamic> r) => Ficha(
    jugadorId: r['jugador_id'] as String,
    escuelaId: r['organizacion_id'] as String?,
    escuela: r['organizacion'] as String?,
    nombre: r['nombre'] as String,
    apellidos: (r['apellidos'] as String?) ?? '',
    fechaNacimiento: _fecha(r['fecha_nacimiento']),
    genero: r['genero'] as String?,
    nivel: r['nivel'] as String?,
    manoDominante: r['mano_dominante'] as String?,
    relacion: r['relacion'] as String,
  );
}

String etiquetaMano(String? m) => switch (m) {
  'DIESTRO' => l10nActual.manoDiestro,
  'ZURDO' => l10nActual.manoZurdo,
  'AMBIDIESTRO' => l10nActual.manoAmbidiestro,
  _ => '—',
};

String etiquetaGenero(String? g) => switch (g) {
  'MASCULINO' => l10nActual.masculino,
  'FEMENINO' => l10nActual.femenino,
  'MIXTO' => l10nActual.mixto,
  _ => '—',
};

class Jugador {
  const Jugador({
    required this.jugadorId,
    required this.nombre,
    required this.apellidos,
  });
  final String jugadorId, nombre, apellidos;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Jugador.fromRow(Map<String, dynamic> r) => Jugador(
    jugadorId: r['jugador_id'] as String,
    nombre: r['nombre'] as String,
    apellidos: (r['apellidos'] as String?) ?? '',
  );
}

/// Detalle de un encuentro: partidos con jugadores y sets (desde la óptica local-visitante).
class PartidoDetalle {
  const PartidoDetalle({
    required this.orden,
    required this.tipo,
    this.local = const [],
    this.visitante = const [],
    this.localIds = const [],
    this.visitanteIds = const [],
    this.sets = const [],
  });
  final int orden;
  final String tipo; // individual | dobles
  final List<String> local, visitante; // nombres mostrados
  final List<String> localIds, visitanteIds; // ids de jugador
  final List<List<int>> sets; // [[juegosLocal, juegosVisitante], ...]
}

class DetalleEncuentro {
  const DetalleEncuentro({required this.partidos, this.incomparecencia});
  final List<PartidoDetalle> partidos;
  final String? incomparecencia; // 'local' | 'visitante'
}

// ───────── Organización / plataforma ─────────
class JugadorLite {
  const JugadorLite({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.fechaNacimiento,
  });
  final String id, nombre, apellidos;
  final DateTime? fechaNacimiento;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory JugadorLite.fromRow(Map<String, dynamic> r) => JugadorLite(
    id: r['id'] as String,
    nombre: r['nombre'] as String,
    apellidos: (r['apellidos'] as String?) ?? '',
    fechaNacimiento: _fecha(r['fecha_nacimiento']),
  );
}

class EquipoLite {
  const EquipoLite({
    required this.id,
    required this.nombre,
    required this.deporteId,
    this.categoria,
  });
  final String id, nombre;
  final String deporteId; // TENIS | PADEL
  final CategoriaEquipo? categoria; // null en equipos sin categoría (admiten a cualquiera)
  factory EquipoLite.fromRow(Map<String, dynamic> r) => EquipoLite(
    id: r['id'] as String,
    nombre: r['nombre'] as String,
    deporteId: r['deporte'] as String,
    categoria: CategoriaEquipo.deCodigo(r['categoria'] as String?),
  );
}

class UsuarioEscuela {
  const UsuarioEscuela({
    required this.usuarioId,
    required this.email,
    this.nombre,
    required this.rol,
  });
  final String usuarioId,
      email,
      rol; // rol: código de la BD (ENTRENADOR, TUTOR…)
  final String? nombre;
}

class Deporte {
  const Deporte({required this.id, required this.nombre});
  final String id, nombre; // id: código de deporte_tipo
}

/// Organización vista por el administrador de la plataforma.
class OrganizacionAdmin {
  const OrganizacionAdmin({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.ciudad,
    required this.activa,
    this.administradores = 0,
  });
  final String id, nombre;
  final String tipo; // ESCUELA | AYUNTAMIENTO | GRUPO_AMIGOS
  final String? ciudad;
  final bool activa;
  final int administradores;
  factory OrganizacionAdmin.fromRow(Map<String, dynamic> r) =>
      OrganizacionAdmin(
        id: r['id'] as String,
        nombre: r['nombre'] as String,
        tipo: r['tipo'] as String,
        ciudad: r['ciudad'] as String?,
        activa: r['activa'] as bool,
        administradores: _int(r['administradores']) ?? 0,
      );
}

String etiquetaTipoOrg(String tipo) => switch (tipo) {
  'AYUNTAMIENTO' => l10nActual.tipoAyuntamiento,
  'GRUPO_AMIGOS' => l10nActual.tipoGrupoAmigos,
  _ => l10nActual.tipoEscuela,
};

/// Campeón y subcampeón de una categoría (null mientras no estén decididos).
class ResumenCategoria {
  const ResumenCategoria(this.categoria, this.campeon, this.subcampeon);
  final String categoria;
  final String? campeon, subcampeon;
}

/// Resumen de una liga: partidos jugados y campeón de cada categoría.
class ResumenLiga {
  const ResumenLiga({
    required this.jugados,
    required this.total,
    required this.categorias,
  });
  final int jugados, total;
  final List<ResumenCategoria> categorias;
  int get pendientes => total - jugados;
}

/// Campeón por categoría: el ganador de la final si hay eliminatoria; en una liga, el primero de la
/// clasificación una vez jugados todos los partidos de la categoría.
ResumenLiga resumenLiga(
  List<EncuentroVista> encs,
  List<FilaClasificacion> clasificacion,
) {
  String nombre(String? c) => (c == null || c.isEmpty) ? '' : c;
  final nombres = <String>{
    for (final e in encs) nombre(e.categoria),
    for (final f in clasificacion) nombre(f.categoria),
  }.toList()..sort();
  final out = <ResumenCategoria>[];
  for (final cat in nombres) {
    final suyos = encs.where((e) => nombre(e.categoria) == cat).toList();
    String? campeon, sub;
    final elim = suyos.where((e) => e.esEliminatoria).toList();
    if (elim.isNotEmpty) {
      final ultima = elim.map((e) => e.jornada).reduce((a, b) => a > b ? a : b);
      final finales = elim
          .where((e) => e.jornada == ultima && e.llaves == 1 && e.confirmado)
          .toList();
      if (finales.isNotEmpty && finales.first.tieneMarcador) {
        final f = finales.first;
        final gana = f.partidosLocal! > f.partidosVisitante!;
        campeon = gana ? f.local : f.visitante;
        sub = gana ? f.visitante : f.local;
      }
    } else if (suyos.isNotEmpty && suyos.every((e) => e.confirmado)) {
      final filas =
          clasificacion
              .where((f) => nombre(f.categoria) == cat && f.grupo == null)
              .toList()
            ..sort((a, b) => a.posicion.compareTo(b.posicion));
      if (filas.isNotEmpty) campeon = filas[0].equipo;
      if (filas.length > 1) sub = filas[1].equipo;
    }
    out.add(ResumenCategoria(cat, campeon, sub));
  }
  return ResumenLiga(
    jugados: encs.where((e) => e.confirmado).length,
    total: encs.length,
    categorias: out,
  );
}
