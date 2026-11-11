// Modelos de lectura de la app (reflejan las vistas/RPC de supabase/migrations).

DateTime? _fecha(dynamic v) => v == null ? null : DateTime.parse(v as String);
int? _int(dynamic v) => v == null ? null : (v as num).toInt();

enum Visibilidad { nombreCompleto, iniciales, soloEscuela }

Visibilidad visibilidadDesdeDb(String v) => switch (v) {
      'nombre_completo' => Visibilidad.nombreCompleto,
      'iniciales' => Visibilidad.iniciales,
      _ => Visibilidad.soloEscuela,
    };
String visibilidadADb(Visibilidad v) => switch (v) {
      Visibilidad.nombreCompleto => 'nombre_completo',
      Visibilidad.iniciales => 'iniciales',
      Visibilidad.soloEscuela => 'solo_escuela',
    };

class Liga {
  const Liga({required this.id, required this.nombre, required this.estado, this.deporte, this.organizationId});
  final String id;
  final String nombre;
  final String estado; // borrador | publicada | en_curso | finalizada
  final String? deporte;
  final String? organizationId;
  factory Liga.fromRow(Map<String, dynamic> r) => Liga(
        id: r['id'] as String,
        nombre: r['nombre'] as String,
        estado: r['estado'] as String,
        deporte: (r['deporte'] as Map?)?['nombre'] as String?,
        organizationId: r['organization_id'] as String?,
      );
}

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
  bool get confirmado => estado == 'confirmado';
  bool get propuesto => estado == 'propuesto';
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
        escuelaId: r['escuela_id'] as String, escuela: r['escuela'] as String, rol: r['rol'] as String,
        ligaId: r['competicion_id'] as String?, liga: r['competicion'] as String?,
      );
}

class Ficha {
  const Ficha({required this.personaId, required this.escuelaId, required this.escuela, required this.nombre,
      required this.apellidos, required this.fechaNacimiento, required this.visibilidad, required this.mostrarFoto,
      required this.menor14, required this.consentimiento, required this.relacion});
  final String personaId, escuelaId, escuela, nombre, apellidos;
  final DateTime fechaNacimiento;
  final Visibilidad visibilidad;
  final bool mostrarFoto, menor14, consentimiento;
  final String relacion; // propia | tutor
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Ficha.fromRow(Map<String, dynamic> r) => Ficha(
        personaId: r['persona_id'] as String, escuelaId: r['escuela_id'] as String, escuela: r['escuela'] as String,
        nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '',
        fechaNacimiento: DateTime.parse(r['fecha_nacimiento'] as String),
        visibilidad: visibilidadDesdeDb(r['visibilidad_ficha'] as String),
        mostrarFoto: r['mostrar_foto'] as bool, menor14: r['menor_14'] as bool,
        consentimiento: r['consentimiento'] as bool, relacion: r['relacion'] as String,
      );
}

class AccesoMenor {
  const AccesoMenor({required this.fecha, this.contexto});
  final DateTime fecha;
  final String? contexto;
}

class Jugador {
  const Jugador({required this.personaId, required this.nombre, required this.apellidos});
  final String personaId, nombre, apellidos;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory Jugador.fromRow(Map<String, dynamic> r) => Jugador(
      personaId: r['persona_id'] as String, nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '');
}

class NotificacionApp {
  const NotificacionApp({required this.id, required this.titulo, this.cuerpo, required this.leida, required this.fecha});
  final String id, titulo;
  final String? cuerpo;
  final bool leida;
  final DateTime fecha;
  factory NotificacionApp.fromRow(Map<String, dynamic> r) => NotificacionApp(
        id: r['id'] as String, titulo: r['titulo'] as String, cuerpo: r['cuerpo'] as String?,
        leida: r['leida'] as bool, fecha: DateTime.parse(r['created_at'] as String));
}

/// Detalle de un encuentro: partidos con jugadores y sets (desde la óptica local-visitante).
class PartidoDetalle {
  const PartidoDetalle({required this.orden, required this.tipo, this.local = const [], this.visitante = const [],
      this.localIds = const [], this.visitanteIds = const [], this.sets = const []});
  final int orden;
  final String tipo; // individual | dobles
  final List<String> local, visitante; // nombres mostrados
  final List<String> localIds, visitanteIds; // ids de persona
  final List<List<int>> sets; // [[juegosLocal, juegosVisitante], ...]
}

class DetalleEncuentro {
  const DetalleEncuentro({required this.partidos, this.incomparecencia});
  final List<PartidoDetalle> partidos;
  final String? incomparecencia;
}

class Correccion {
  const Correccion({required this.motivo, required this.fecha});
  final String motivo;
  final DateTime fecha;
}

// ───────── Escuela / organización / plataforma ─────────
class PersonaLite {
  const PersonaLite({required this.id, required this.nombre, required this.apellidos, required this.fechaNacimiento});
  final String id, nombre, apellidos;
  final DateTime fechaNacimiento;
  String get nombreCompleto => '$nombre $apellidos'.trim();
  factory PersonaLite.fromRow(Map<String, dynamic> r) => PersonaLite(
      id: r['id'] as String, nombre: r['nombre'] as String, apellidos: (r['apellidos'] as String?) ?? '',
      fechaNacimiento: DateTime.parse(r['fecha_nacimiento'] as String));
}

class EquipoLite {
  const EquipoLite({required this.id, required this.nombre, required this.deporteId, this.categoriaId});
  final String id, nombre, deporteId;
  final String? categoriaId;
  factory EquipoLite.fromRow(Map<String, dynamic> r) => EquipoLite(
      id: r['id'] as String, nombre: r['nombre'] as String, deporteId: r['deporte_id'] as String,
      categoriaId: r['categoria_id'] as String?);
}

class UsuarioEscuela {
  const UsuarioEscuela({required this.usuarioId, required this.email, this.nombre, required this.rol});
  final String usuarioId, email, rol; // rol en formato BD
  final String? nombre;
}

class Deporte {
  const Deporte({required this.id, required this.nombre});
  final String id, nombre;
}

class Temporada {
  const Temporada({required this.id, required this.nombre, required this.inicio, required this.fin});
  final String id, nombre;
  final DateTime inicio, fin;
}

class EscuelaAdmin {
  const EscuelaAdmin({required this.id, required this.nombre, required this.slug, required this.activa, this.modulos = const {}});
  final String id, nombre, slug;
  final bool activa;
  final Map<String, bool> modulos;
}

class RegistroCambio {
  const RegistroCambio({required this.id, required this.tabla, required this.accion, required this.fecha, this.escuelaId});
  final int id;
  final String tabla, accion;
  final DateTime fecha;
  final String? escuelaId;
}

/// Reglas configurables de una liga (se serializan al formato JSON de competicion.reglas).
class ReglasLiga {
  const ReglasLiga({
    this.vueltas = 1, this.individuales = 2, this.dobles = 1,
    this.puntosVictoria = 3, this.puntosEmpate = 1, this.puntosDerrota = 0,
    this.desempates = const ['enfrentamiento_directo', 'diferencia_partidos', 'diferencia_sets', 'diferencia_juegos'],
  });
  final int vueltas, individuales, dobles, puntosVictoria, puntosEmpate, puntosDerrota;
  final List<String> desempates;
  Map<String, dynamic> toJson() => {
        'vueltas': vueltas,
        'partidos_por_encuentro': {'individuales': individuales, 'dobles': dobles},
        'puntos': {'victoria': puntosVictoria, 'empate': puntosEmpate, 'derrota': puntosDerrota},
        'desempates': desempates,
        'incomparecencia': {'partidos_local': 0, 'partidos_visitante': individuales + dobles},
      };
}
