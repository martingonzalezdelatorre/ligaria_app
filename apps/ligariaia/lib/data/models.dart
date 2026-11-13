// Modelos de lectura de la app (reflejan las vistas/RPC de supabase/migrations).

DateTime? _fecha(dynamic v) => v == null ? null : DateTime.parse(v as String);
int? _int(dynamic v) => v == null ? null : (v as num).toInt();

class Liga {
  const Liga({
    required this.id, required this.nombre, required this.estado, this.deporte, this.organizationId,
    this.deporteId, this.tipo, this.fechaInicio, this.fechaFin,
  });
  final String id;
  final String nombre;
  final String estado; // borrador | publicada | en_curso | finalizada | cancelada
  final String? deporte; // nombre legible (Tenis / Pádel)
  final String? organizationId;
  final String? deporteId; // código de deporte_tipo: TENIS | PADEL
  final String? tipo; // competicion_tipo: MUNICIPAL | ENTRE_ESCUELAS | ESCUELA | AMIGOS
  final DateTime? fechaInicio, fechaFin;
  factory Liga.fromRow(Map<String, dynamic> r) => Liga(
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
const deportesDisponibles = [Deporte(id: 'TENIS', nombre: 'Tenis'), Deporte(id: 'PADEL', nombre: 'Pádel')];

/// Tipos de competición que puede crear una organización según su tipo (organizacion_tipo).
List<({String codigo, String etiqueta})> tiposCompeticionDe(String? orgTipo) => switch (orgTipo) {
      'AYUNTAMIENTO' => const [(codigo: 'MUNICIPAL', etiqueta: 'Municipal')],
      'GRUPO_AMIGOS' => const [(codigo: 'AMIGOS', etiqueta: 'Entre amigos')],
      _ => const [
          (codigo: 'ENTRE_ESCUELAS', etiqueta: 'Entre escuelas (abierta a inscripción)'),
          (codigo: 'ESCUELA', etiqueta: 'Interna de la escuela'),
        ],
    };

class LigaAbierta {
  const LigaAbierta({required this.id, required this.nombre, required this.deporteId, required this.deporte, required this.organizadora});
  final String id, nombre, deporteId, deporte, organizadora;
  factory LigaAbierta.fromRow(Map<String, dynamic> r) => LigaAbierta(
        id: r['competicion_id'] as String,
        nombre: r['nombre'] as String,
        deporteId: r['deporte_id'] as String,
        deporte: r['deporte'] as String,
        organizadora: r['organizadora'] as String,
      );
}

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
  });
  final String id, ligaId, estado, localId, local, visitanteId, visitante;
  final int jornada;
  final DateTime? fecha; // fecha propia del encuentro, o la de la jornada
  final int? partidosLocal, partidosVisitante; // null si el resultado no es visible
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
        fecha: _fecha(r['fecha']) ?? _fecha(r['jornada_fecha']),
        partidosLocal: _int(r['partidos_local']),
        partidosVisitante: _int(r['partidos_visitante']),
        incomparecencia: r['incomparecencia'] as String?,
      );
}

class Descanso {
  const Descanso({required this.jornada, required this.equipoId, required this.equipo});
  final int jornada;
  final String equipoId, equipo;
  factory Descanso.fromRow(Map<String, dynamic> r) =>
      Descanso(jornada: _int(r['jornada'])!, equipoId: r['equipo_id'] as String, equipo: r['equipo'] as String);
}

class FilaClasificacion {
  const FilaClasificacion({
    required this.posicion, required this.equipoId, required this.equipo, required this.escuela,
    required this.pj, required this.pg, required this.pe, required this.pp, required this.puntos,
    required this.partidosF, required this.partidosC, required this.setsF, required this.setsC,
    required this.juegosF, required this.juegosC,
  });
  final int posicion, pj, pg, pe, pp, puntos, partidosF, partidosC, setsF, setsC, juegosF, juegosC;
  final String equipoId, equipo, escuela;
  factory FilaClasificacion.fromRow(Map<String, dynamic> r) => FilaClasificacion(
        posicion: _int(r['posicion'])!, equipoId: r['equipo_id'] as String,
        equipo: r['equipo'] as String, escuela: r['escuela'] as String,
        pj: _int(r['pj'])!, pg: _int(r['pg'])!, pe: _int(r['pe'])!, pp: _int(r['pp'])!, puntos: _int(r['puntos'])!,
        partidosF: _int(r['partidos_f'])!, partidosC: _int(r['partidos_c'])!,
        setsF: _int(r['sets_f'])!, setsC: _int(r['sets_c'])!,
        juegosF: _int(r['juegos_f'])!, juegosC: _int(r['juegos_c'])!,
      );
}

class MiEquipo {
  const MiEquipo({required this.equipoId, required this.equipo, required this.escuelaId, required this.escuela,
      required this.rol, this.ligaId, this.liga});
  final String equipoId, equipo, escuelaId, escuela;
  final String rol; // entrenador | alumno | tutor
  final String? ligaId, liga;
  factory MiEquipo.fromRow(Map<String, dynamic> r) => MiEquipo(
        equipoId: r['equipo_id'] as String, equipo: r['equipo'] as String,
        escuelaId: r['organizacion_id'] as String, escuela: r['organizacion'] as String, rol: r['rol'] as String,
        ligaId: r['competicion_id'] as String?, liga: r['competicion'] as String?,
      );
}

class Ficha {
  const Ficha({required this.jugadorId, this.escuelaId, this.escuela, required this.nombre,
      required this.apellidos, this.fechaNacimiento, this.genero, this.nivel, this.manoDominante, required this.relacion});
  final String jugadorId, nombre, apellidos;
  final String? escuelaId, escuela;
  final DateTime? fechaNacimiento;
  final String? genero; // MASCULINO | FEMENINO | MIXTO
  final String? nivel;
  final String? manoDominante; // DIESTRO | ZURDO | AMBIDIESTRO
  final String relacion; // propia | tutor
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Ficha.fromRow(Map<String, dynamic> r) => Ficha(
        jugadorId: r['jugador_id'] as String, escuelaId: r['organizacion_id'] as String?, escuela: r['organizacion'] as String?,
        nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '',
        fechaNacimiento: _fecha(r['fecha_nacimiento']), genero: r['genero'] as String?, nivel: r['nivel'] as String?,
        manoDominante: r['mano_dominante'] as String?, relacion: r['relacion'] as String,
      );
}

String etiquetaMano(String? m) => switch (m) {
      'DIESTRO' => 'Diestro/a',
      'ZURDO' => 'Zurdo/a',
      'AMBIDIESTRO' => 'Ambidiestro/a',
      _ => '—',
    };

String etiquetaGenero(String? g) => switch (g) {
      'MASCULINO' => 'Masculino',
      'FEMENINO' => 'Femenino',
      'MIXTO' => 'Mixto',
      _ => '—',
    };

class Jugador {
  const Jugador({required this.jugadorId, required this.nombre, required this.apellidos});
  final String jugadorId, nombre, apellidos;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Jugador.fromRow(Map<String, dynamic> r) => Jugador(
      jugadorId: r['jugador_id'] as String, nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '');
}

/// Detalle de un encuentro: partidos con jugadores y sets (desde la óptica local-visitante).
class PartidoDetalle {
  const PartidoDetalle({required this.orden, required this.tipo, this.local = const [], this.visitante = const [],
      this.localIds = const [], this.visitanteIds = const [], this.sets = const []});
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
  const JugadorLite({required this.id, required this.nombre, required this.apellidos, this.fechaNacimiento});
  final String id, nombre, apellidos;
  final DateTime? fechaNacimiento;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory JugadorLite.fromRow(Map<String, dynamic> r) => JugadorLite(
      id: r['id'] as String, nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '',
      fechaNacimiento: _fecha(r['fecha_nacimiento']));
}

class EquipoLite {
  const EquipoLite({required this.id, required this.nombre, required this.deporteId});
  final String id, nombre;
  final String deporteId; // TENIS | PADEL
  factory EquipoLite.fromRow(Map<String, dynamic> r) =>
      EquipoLite(id: r['id'] as String, nombre: r['nombre'] as String, deporteId: r['deporte'] as String);
}

class UsuarioEscuela {
  const UsuarioEscuela({required this.usuarioId, required this.email, this.nombre, required this.rol});
  final String usuarioId, email, rol; // rol: código de la BD (ENTRENADOR, TUTOR…)
  final String? nombre;
}

class Deporte {
  const Deporte({required this.id, required this.nombre});
  final String id, nombre; // id: código de deporte_tipo
}

/// Organización vista por el administrador de la plataforma.
class OrganizacionAdmin {
  const OrganizacionAdmin({required this.id, required this.nombre, required this.tipo, this.ciudad, required this.activa, this.administradores = 0});
  final String id, nombre;
  final String tipo; // ESCUELA | AYUNTAMIENTO | GRUPO_AMIGOS
  final String? ciudad;
  final bool activa;
  final int administradores;
  factory OrganizacionAdmin.fromRow(Map<String, dynamic> r) => OrganizacionAdmin(
      id: r['id'] as String, nombre: r['nombre'] as String, tipo: r['tipo'] as String, ciudad: r['ciudad'] as String?,
      activa: r['activa'] as bool, administradores: _int(r['administradores']) ?? 0);
}

String etiquetaTipoOrg(String tipo) => switch (tipo) {
      'AYUNTAMIENTO' => 'Ayuntamiento',
      'GRUPO_AMIGOS' => 'Grupo de amigos',
      _ => 'Escuela',
    };
