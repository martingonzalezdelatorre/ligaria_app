import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/auth.dart';
import 'models.dart';

/// Acceso a datos de competiciones. Las pantallas dependen solo de esta interfaz;
/// en los tests se sustituye con un mock (mocktail).
///
/// Se apoya en el esquema de `supabase/migrations`: tablas base (0001) y vistas/RPC de la app (0002).
abstract class LigaRepository {
  // ── Común / jugador / familia ──
  Future<List<Liga>> misLigas();
  Future<List<MiEquipo>> misEquipos();
  Future<List<EncuentroVista>> encuentros(String ligaId);
  Future<List<Descanso>> descansos(String ligaId);
  Future<List<FilaClasificacion>> clasificacion(String ligaId);
  Future<List<Ficha>> misFichas();

  /// Entrenos de mis equipos (como jugador, familia o entrenador), por fecha.
  Future<List<Entreno>> misEntrenos();

  // ── Entrenador ──
  /// Asigna un entreno a un equipo que entreno (o de mi escuela si la administro).
  Future<void> crearEntreno(
    String equipoId,
    DateTime fecha, {
    int? duracionMin,
    String? lugar,
    String? notas,
  });
  Future<void> eliminarEntreno(String entrenoId);
  Future<List<Jugador>> jugadores(String equipoId);
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId);

  /// resultado: {"incomparecencia": null|"local"|"visitante",
  ///   "partidos":[{"orden":1,"local":[jugadorId],"visitante":[jugadorId],"sets":[[6,4],[3,6]]}]}
  /// El entrenador de uno de los equipos lo registra una vez; la organización puede corregirlo.
  Future<void> registrarResultado(
    String encuentroId,
    Map<String, dynamic> resultado,
  );

  // ── Administrador de escuela ──
  Future<List<JugadorLite>> jugadoresOrg(String orgId);
  Future<void> crearJugador(
    String orgId,
    String nombre,
    String apellidos,
    DateTime fechaNacimiento,
  );
  Future<List<EquipoLite>> equipos(String orgId);

  /// ¿Tiene algún equipo de la organización inscrito (o con la inscripción pendiente) en una liga?
  Future<bool> tieneInscripciones(String orgId);

  /// Inscripciones (en cualquier estado) de los equipos de [orgId] en ligas de cualquier organizador.
  Future<List<InscripcionVista>> inscripcionesEscuela(String orgId);

  /// ¿Se ha invitado ya a algún entrenador a la organización (aunque aún no se haya registrado)?
  Future<bool> tieneInvitacionEntrenador(String orgId);
  Future<void> crearEquipo(
    String orgId,
    String nombre,
    String deporteId, {
    CategoriaEquipo? categoria,
  });
  Future<void> anadirJugador(String equipoId, String jugadorId);
  Future<void> asignarEntrenador(String equipoId, String usuarioId);
  Future<List<UsuarioEscuela>> usuarios(String orgId);
  Future<void> invitar(
    String orgId,
    String email,
    Rol rol, {
    String? jugadorId,
  });
  Future<List<LigaAbierta>> ligasAbiertas();

  /// Devuelve el estado resultante: 'aceptada' (organiza la propia escuela) o 'pendiente'
  /// (el organizador de la liga debe aprobarla).
  /// [categoriaId] solo hace falta si la liga tiene varias categorías.
  Future<String> inscribirEquipo(
    String ligaId,
    String equipoId, {
    String? categoriaId,
  });

  /// Categorías de una liga (las de mis ligas y las de las ligas abiertas a mi escuela).
  Future<List<CategoriaLiga>> categorias(String ligaId);
  Future<List<Deporte>> deportes();

  /// Invitaciones de otras organizaciones pendientes de responder.
  Future<List<MiInvitacion>> misInvitaciones();

  /// Acepta o rechaza la invitación de [ligaId] en nombre de la escuela [escuelaId].
  Future<void> responderInvitacion(
    String ligaId,
    String escuelaId, {
    required bool aceptar,
  });

  // ── Organizador ──
  Future<List<Liga>> ligasOrganizadas(String orgId);

  /// [tipo]: código de competicion_tipo (MUNICIPAL | ENTRE_ESCUELAS | ESCUELA | AMIGOS).
  /// [visibilidad]: PUBLICA (se ofrece a todas las escuelas) | PRIVADA (solo escuelas invitadas).
  Future<void> crearLiga({
    required String orgId,
    required String deporteId,
    required String nombre,
    required String tipo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String visibilidad = 'PUBLICA',
    Puntuacion puntuacion = puntuacionPorDefecto,

    /// competicion_formato: LIGA | ELIMINATORIA | MIXTO (grupos y playoff).
    String formato = 'LIGA',
  });

  /// Cambia los puntos por victoria, empate y derrota (solo mientras la liga está en borrador).
  Future<void> configurarPuntuacion(String ligaId, Puntuacion puntuacion);
  Future<void> crearCategoria(
    String ligaId,
    String nombre, {
    String? genero,
    int? edadMin,
    int? edadMax,
    String? nivel,
  });

  /// Solo se elimina una categoría sin equipos y nunca la última de la liga.
  Future<void> eliminarCategoria(String categoriaId);

  /// Organizadores de ligas de la organización (su equipo). Se invitan con [invitar] y el rol organizadorLiga.
  Future<List<UsuarioEscuela>> organizadoresOrg(String orgId);

  /// Co-organizadores de la liga.
  Future<List<OrganizadorLiga>> organizadores(String ligaId);

  /// Da a una persona la gestión de esta liga. Devuelve 'asignado' si ya tenía cuenta o 'invitado' si se
  /// activará cuando se registre con ese correo.
  Future<String> asignarOrganizador(String ligaId, String email);

  /// Retira una invitación de co-organizador que aún no se ha activado.
  Future<void> retirarInvitacionOrganizador(String ligaId, String email);
  Future<void> quitarOrganizador(String ligaId, String usuarioId);

  /// Escuelas invitadas a una liga y su respuesta.
  Future<List<InvitacionLiga>> invitacionesLiga(String ligaId);

  /// Escuelas a las que se puede invitar.
  Future<List<EscuelaInvitable>> escuelasInvitables();
  Future<void> invitarEscuela(String ligaId, String escuelaId);

  /// Retira una invitación mientras la escuela no tenga equipos inscritos.
  Future<void> retirarInvitacion(String ligaId, String escuelaId);
  Future<void> editarLiga(
    String ligaId, {
    required String nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  /// Fecha y hora, sede y pista de un partido (null borra el dato) y, si se indica, su estado
  /// ('PROGRAMADO', 'APLAZADO' o 'SUSPENDIDO'). Avisa a los equipos y a sus participantes.
  Future<void> programarEncuentro(
    String encuentroId, {
    DateTime? fechaHora,
    String? sede,
    String? pista,
    String? estado,
  });

  /// Marca un partido pendiente como 'PROGRAMADO', 'APLAZADO' o 'SUSPENDIDO'.
  Future<void> cambiarEstadoEncuentro(String encuentroId, String estado);

  /// Orden de los criterios de desempate (valores de [criteriosDesempate]).
  Future<void> fijarDesempate(String ligaId, List<String> criterios);

  /// Cierra la liga (debe estar en curso) o la reabre.
  Future<void> finalizarLiga(String ligaId);
  Future<void> reabrirLiga(String ligaId);

  /// Abre la liga a la inscripción de equipos.
  Future<void> publicarLiga(String ligaId);

  /// En una liga de formato MIXTO, [grupos] es el número de grupos (2 por defecto).
  Future<int> generarCalendario(
    String ligaId, {
    DateTime? inicio,
    int diasEntreJornadas = 7,
    int vueltas = 1,
    int? grupos,
  });

  /// Genera el cuadro de una eliminatoria (la primera ronda; las siguientes se crean solas).
  Future<int> generarEliminatoria(String ligaId, {DateTime? inicio});

  /// Con la fase de grupos terminada, crea el playoff con los [clasifican] primeros de cada grupo.
  Future<int> generarPlayoff(
    String ligaId, {
    int clasifican = 2,
    DateTime? inicio,
  });

  /// Equipos que pasan directamente de ronda en una eliminatoria.
  Future<List<Descanso>> pasanDirecto(String ligaId);

  /// Solicitudes de inscripción de una liga (pendientes y resueltas).
  Future<List<InscripcionVista>> inscripciones(String ligaId);

  /// Acepta o rechaza una inscripción pendiente.
  Future<void> resolverInscripcion(
    String inscripcionId, {
    required bool aceptar,
  });

  // ── Administrador de la plataforma ──
  Future<List<OrganizacionAdmin>> organizaciones();
  Future<void> crearOrganizacion(String nombre, String tipo, {String? ciudad});
}

final ligaRepositoryProvider = Provider<LigaRepository>(
  (ref) => SupabaseLigaRepository(),
);

String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

class SupabaseLigaRepository implements LigaRepository {
  SupabaseClient get _c => Supabase.instance.client;
  List<Map<String, dynamic>> _rows(Object l) =>
      (l as List).cast<Map<String, dynamic>>();

  @override
  Future<List<Liga>> misLigas() async => _rows(
    await _c.from('v_ligas').select().order('created_at'),
  ).map(Liga.fromRow).toList();

  @override
  Future<List<MiEquipo>> misEquipos() async => _rows(
    await _c.from('v_mis_equipos').select(),
  ).map(MiEquipo.fromRow).toList();

  @override
  Future<List<EncuentroVista>> encuentros(String ligaId) async => _rows(
    await _c
        .from('v_encuentros_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('jornada')
        .order('local'),
  ).map(EncuentroVista.fromRow).toList();

  @override
  Future<List<Descanso>> descansos(String ligaId) async => _rows(
    await _c
        .from('v_descansos_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('jornada'),
  ).map(Descanso.fromRow).toList();

  @override
  Future<List<FilaClasificacion>> clasificacion(String ligaId) async => _rows(
    await _c
        .from('v_clasificacion_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('categoria_id')
        .order('posicion'),
  ).map(FilaClasificacion.fromRow).toList();

  @override
  Future<List<Ficha>> misFichas() async => _rows(
    await _c.from('v_mis_fichas').select().order('nombre'),
  ).map(Ficha.fromRow).toList();

  @override
  Future<List<Entreno>> misEntrenos() async => _rows(
    await _c.from('v_entrenos').select().order('fecha'),
  ).map(Entreno.fromRow).toList();

  @override
  Future<void> crearEntreno(
    String equipoId,
    DateTime fecha, {
    int? duracionMin,
    String? lugar,
    String? notas,
  }) => _c.from('entreno').insert({
    'equipo_id': equipoId,
    'fecha_hora': fecha.toUtc().toIso8601String(),
    'duracion_min': duracionMin,
    'lugar': (lugar == null || lugar.trim().isEmpty) ? null : lugar.trim(),
    'notas': (notas == null || notas.trim().isEmpty) ? null : notas.trim(),
  });

  @override
  Future<void> eliminarEntreno(String entrenoId) =>
      _c.from('entreno').delete().eq('id', entrenoId);

  @override
  Future<List<Jugador>> jugadores(String equipoId) async => _rows(
    await _c
        .from('v_jugadores_equipo')
        .select()
        .eq('equipo_id', equipoId)
        .order('nombre'),
  ).map(Jugador.fromRow).toList();

  @override
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId) async {
    final partidos = _rows(
      await _c
          .from('partido')
          .select(
            'id, orden, tipo, set_partido(numero, juegos_local, juegos_visitante)',
          )
          .eq('encuentro_id', encuentroId)
          .order('orden'),
    );
    final ids = partidos.map((p) => p['id'] as String).toList();
    final jug = ids.isEmpty
        ? <Map<String, dynamic>>[]
        : _rows(
            await _c
                .from('v_jugadores_competicion')
                .select('partido_id, lado, jugador_id, nombre_mostrado')
                .inFilter('partido_id', ids),
          );
    final vista = _rows(
      await _c
          .from('v_encuentros_competicion')
          .select('incomparecencia')
          .eq('encuentro_id', encuentroId),
    );
    List<Map<String, dynamic>> de(String pid, String lado) =>
        jug.where((j) => j['partido_id'] == pid && j['lado'] == lado).toList();
    return DetalleEncuentro(
      incomparecencia: vista.isEmpty
          ? null
          : vista.first['incomparecencia'] as String?,
      partidos: [
        for (final p in partidos)
          PartidoDetalle(
            orden: (p['orden'] as num).toInt(),
            tipo: (p['tipo'] as String).toLowerCase(),
            local: de(
              p['id'] as String,
              'local',
            ).map((j) => j['nombre_mostrado'] as String).toList(),
            visitante: de(
              p['id'] as String,
              'visitante',
            ).map((j) => j['nombre_mostrado'] as String).toList(),
            localIds: de(
              p['id'] as String,
              'local',
            ).map((j) => j['jugador_id'] as String).toList(),
            visitanteIds: de(
              p['id'] as String,
              'visitante',
            ).map((j) => j['jugador_id'] as String).toList(),
            sets:
                (((p['set_partido'] as List?) ?? const [])
                        .cast<Map<String, dynamic>>()
                        .toList()
                      ..sort(
                        (a, b) =>
                            (a['numero'] as num).compareTo(b['numero'] as num),
                      ))
                    .map(
                      (s) => [
                        (s['juegos_local'] as num).toInt(),
                        (s['juegos_visitante'] as num).toInt(),
                      ],
                    )
                    .toList(),
          ),
      ],
    );
  }

  @override
  Future<void> registrarResultado(
    String encuentroId,
    Map<String, dynamic> resultado,
  ) => _c.rpc(
    'registrar_resultado',
    params: {'p_encuentro': encuentroId, 'p_resultado': resultado},
  );

  @override
  Future<List<JugadorLite>> jugadoresOrg(String orgId) async => _rows(
    await _c
        .from('jugador')
        .select('id, nombre, apellidos, fecha_nacimiento')
        .eq('organizacion_id', orgId)
        .order('apellidos'),
  ).map(JugadorLite.fromRow).toList();

  @override
  Future<void> crearJugador(
    String orgId,
    String nombre,
    String apellidos,
    DateTime fechaNacimiento,
  ) => _c.from('jugador').insert({
    'organizacion_id': orgId,
    'nombre': nombre,
    'apellidos': apellidos,
    'fecha_nacimiento': _iso(fechaNacimiento),
  });

  @override
  Future<List<EquipoLite>> equipos(String orgId) async => _rows(
    await _c
        .from('equipo')
        .select('id, nombre, deporte, categoria')
        .eq('organizacion_id', orgId)
        .order('nombre'),
  ).map(EquipoLite.fromRow).toList();

  @override
  Future<bool> tieneInscripciones(String orgId) async => _rows(
    await _c
        .from('inscripcion')
        .select('id, equipo!inner(organizacion_id)')
        .eq('equipo.organizacion_id', orgId)
        .limit(1),
  ).isNotEmpty;

  @override
  Future<List<InscripcionVista>> inscripcionesEscuela(String orgId) async =>
      _rows(
        await _c
            .from('inscripcion')
            .select(
              'id, estado, equipo_id, equipo!inner(nombre, organizacion_id), '
              'categoria!inner(nombre, competicion_id)',
            )
            .eq('equipo.organizacion_id', orgId)
            .order('fecha'),
      ).map((r) {
        final eq = r['equipo'] as Map<String, dynamic>;
        final cat = r['categoria'] as Map<String, dynamic>;
        return InscripcionVista(
          id: r['id'] as String,
          ligaId: cat['competicion_id'] as String,
          equipoId: r['equipo_id'] as String,
          equipo: eq['nombre'] as String,
          escuelaId: eq['organizacion_id'] as String,
          escuela: '',
          estado: (r['estado'] as String).toLowerCase(),
          categoria: cat['nombre'] as String?,
        );
      }).toList();

  @override
  Future<bool> tieneInvitacionEntrenador(String orgId) async => _rows(
    await _c
        .from('invitacion')
        .select('id, rol!inner(codigo)')
        .eq('organizacion_id', orgId)
        .eq('rol.codigo', 'ENTRENADOR')
        .limit(1),
  ).isNotEmpty;

  @override
  Future<void> crearEquipo(
    String orgId,
    String nombre,
    String deporteId, {
    CategoriaEquipo? categoria,
  }) => _c.from('equipo').insert({
    'organizacion_id': orgId,
    'nombre': nombre,
    'deporte': deporteId,
    'categoria': categoria?.codigo,
  });

  @override
  Future<void> anadirJugador(String equipoId, String jugadorId) => _c
      .from('equipo_miembro')
      .insert({'equipo_id': equipoId, 'jugador_id': jugadorId});

  @override
  Future<void> asignarEntrenador(String equipoId, String usuarioId) => _c
      .from('entrenador_equipo')
      .insert({'equipo_id': equipoId, 'usuario_id': usuarioId});

  @override
  Future<List<UsuarioEscuela>> usuarios(String orgId) async =>
      _rows(
            await _c
                .from('v_usuarios_org')
                .select()
                .eq('organizacion_id', orgId),
          )
          .map(
            (r) => UsuarioEscuela(
              usuarioId: r['usuario_id'] as String,
              email: (r['email'] as String?) ?? '',
              nombre: r['nombre'] as String?,
              rol: r['rol'] as String,
            ),
          )
          .toList();

  @override
  Future<void> invitar(
    String orgId,
    String email,
    Rol rol, {
    String? jugadorId,
  }) => _c.rpc(
    'invitar_usuario',
    params: {
      'p_organizacion': orgId,
      'p_email': email,
      'p_rol': rolADb(rol),
      'p_jugador': jugadorId,
    },
  );

  @override
  Future<List<LigaAbierta>> ligasAbiertas() async => _rows(
    await _c.from('v_ligas_abiertas').select(),
  ).map(LigaAbierta.fromRow).toList();

  @override
  Future<String> inscribirEquipo(
    String ligaId,
    String equipoId, {
    String? categoriaId,
  }) async =>
      (await _c.rpc(
            'inscribir_equipo',
            params: {
              'p_competicion': ligaId,
              'p_equipo': equipoId,
              'p_categoria': ?categoriaId,
            },
          ))
          as String;

  @override
  Future<List<CategoriaLiga>> categorias(String ligaId) async => _rows(
    await _c
        .from('v_categorias_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('nombre'),
  ).map(CategoriaLiga.fromRow).toList();

  @override
  Future<List<InscripcionVista>> inscripciones(String ligaId) async => _rows(
    await _c
        .from('v_inscripciones_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('fecha'),
  ).map(InscripcionVista.fromRow).toList();

  @override
  Future<void> resolverInscripcion(
    String inscripcionId, {
    required bool aceptar,
  }) => _c.rpc(
    'resolver_inscripcion',
    params: {'p_inscripcion': inscripcionId, 'p_aceptar': aceptar},
  );

  @override
  Future<List<Deporte>> deportes() async => deportesDisponibles;

  @override
  Future<List<Liga>> ligasOrganizadas(String orgId) async => _rows(
    await _c
        .from('v_ligas')
        .select()
        .eq('organizacion_id', orgId)
        .order('created_at'),
  ).map(Liga.fromRow).toList();

  @override
  Future<List<MiInvitacion>> misInvitaciones() async => _rows(
    await _c.from('v_mis_invitaciones').select().order('nombre'),
  ).map(MiInvitacion.fromRow).toList();

  @override
  Future<void> responderInvitacion(
    String ligaId,
    String escuelaId, {
    required bool aceptar,
  }) => _c.rpc(
    'responder_invitacion_org',
    params: {
      'p_competicion': ligaId,
      'p_organizacion': escuelaId,
      'p_aceptar': aceptar,
    },
  );

  @override
  Future<void> crearLiga({
    required String orgId,
    required String deporteId,
    required String nombre,
    required String tipo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String visibilidad = 'PUBLICA',
    Puntuacion puntuacion = puntuacionPorDefecto,
    String formato = 'LIGA',
  }) => _c.rpc(
    'crear_competicion',
    params: {
      'p_formato': formato,
      'p_organizacion': orgId,
      'p_nombre': nombre,
      'p_deporte': deporteId,
      'p_tipo': tipo,
      'p_fecha_inicio': fechaInicio == null ? null : _iso(fechaInicio),
      'p_fecha_fin': fechaFin == null ? null : _iso(fechaFin),
      'p_visibilidad': visibilidad,
      'p_puntos_victoria': puntuacion.victoria,
      'p_puntos_empate': puntuacion.empate,
      'p_puntos_derrota': puntuacion.derrota,
    },
  );

  @override
  Future<void> configurarPuntuacion(String ligaId, Puntuacion puntuacion) => _c
      .from('competicion')
      .update({
        'puntos_victoria': puntuacion.victoria,
        'puntos_empate': puntuacion.empate,
        'puntos_derrota': puntuacion.derrota,
      })
      .eq('id', ligaId)
      .eq('estado', 'BORRADOR');

  @override
  Future<void> crearCategoria(
    String ligaId,
    String nombre, {
    String? genero,
    int? edadMin,
    int? edadMax,
    String? nivel,
  }) => _c.rpc(
    'crear_categoria',
    params: {
      'p_competicion': ligaId,
      'p_nombre': nombre,
      'p_genero': genero,
      'p_edad_min': edadMin,
      'p_edad_max': edadMax,
      'p_nivel': nivel,
    },
  );

  @override
  Future<void> eliminarCategoria(String categoriaId) =>
      _c.rpc('eliminar_categoria', params: {'p_categoria': categoriaId});

  @override
  Future<List<UsuarioEscuela>> organizadoresOrg(String orgId) async =>
      _rows(
            await _c
                .from('v_organizadores_org')
                .select()
                .eq('organizacion_id', orgId)
                .order('email'),
          )
          .map(
            (r) => UsuarioEscuela(
              usuarioId: r['usuario_id'] as String,
              email: (r['email'] as String?) ?? '',
              nombre: r['nombre'] as String?,
              rol: 'ORGANIZADOR_LIGAS',
            ),
          )
          .toList();

  @override
  Future<List<OrganizadorLiga>> organizadores(String ligaId) async => _rows(
    await _c
        .from('v_organizadores_liga')
        .select()
        .eq('competicion_id', ligaId)
        .order('email'),
  ).map(OrganizadorLiga.fromRow).toList();

  @override
  Future<String> asignarOrganizador(String ligaId, String email) async =>
      (await _c.rpc(
            'asignar_organizador_liga',
            params: {'p_competicion': ligaId, 'p_email': email.trim()},
          ))
          as String;

  @override
  Future<void> retirarInvitacionOrganizador(String ligaId, String email) =>
      _c.rpc(
        'retirar_invitacion_organizador',
        params: {'p_competicion': ligaId, 'p_email': email.trim()},
      );

  @override
  Future<void> quitarOrganizador(String ligaId, String usuarioId) => _c.rpc(
    'quitar_organizador_liga',
    params: {'p_competicion': ligaId, 'p_usuario': usuarioId},
  );

  @override
  Future<List<InvitacionLiga>> invitacionesLiga(String ligaId) async => _rows(
    await _c
        .from('v_invitaciones_liga')
        .select()
        .eq('competicion_id', ligaId)
        .order('escuela'),
  ).map(InvitacionLiga.fromRow).toList();

  @override
  Future<List<EscuelaInvitable>> escuelasInvitables() async => _rows(
    await _c.from('v_escuelas_invitables').select().order('nombre'),
  ).map(EscuelaInvitable.fromRow).toList();

  @override
  Future<void> invitarEscuela(String ligaId, String escuelaId) => _c.rpc(
    'invitar_org_a_competicion',
    params: {'p_competicion': ligaId, 'p_organizacion': escuelaId},
  );

  @override
  Future<void> retirarInvitacion(String ligaId, String escuelaId) => _c.rpc(
    'retirar_invitacion_org',
    params: {'p_competicion': ligaId, 'p_organizacion': escuelaId},
  );

  @override
  Future<void> editarLiga(
    String ligaId, {
    required String nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) => _c
      .from('competicion')
      .update({
        'nombre': nombre,
        'fecha_inicio': fechaInicio == null ? null : _iso(fechaInicio),
        'fecha_fin': fechaFin == null ? null : _iso(fechaFin),
      })
      .eq('id', ligaId)
      .eq('estado', 'BORRADOR');

  @override
  Future<void> programarEncuentro(
    String encuentroId, {
    DateTime? fechaHora,
    String? sede,
    String? pista,
    String? estado,
  }) => _c.rpc(
    'programar_encuentro',
    params: {
      'p_encuentro': encuentroId,
      'p_fecha_hora': fechaHora?.toUtc().toIso8601String(),
      'p_sede': sede,
      'p_pista': pista,
      'p_estado': estado,
    },
  );

  @override
  Future<void> cambiarEstadoEncuentro(String encuentroId, String estado) =>
      _c.rpc(
        'cambiar_estado_encuentro',
        params: {'p_encuentro': encuentroId, 'p_estado': estado},
      );

  @override
  Future<void> fijarDesempate(String ligaId, List<String> criterios) => _c.rpc(
    'fijar_desempate',
    params: {'p_competicion': ligaId, 'p_orden': criterios.join(',')},
  );

  @override
  Future<void> finalizarLiga(String ligaId) =>
      _c.rpc('finalizar_competicion', params: {'p_competicion': ligaId});

  @override
  Future<void> reabrirLiga(String ligaId) =>
      _c.rpc('reabrir_competicion', params: {'p_competicion': ligaId});

  @override
  Future<void> publicarLiga(String ligaId) => _c
      .from('competicion')
      .update({'estado': 'INSCRIPCION_ABIERTA'})
      .eq('id', ligaId)
      .eq('estado', 'BORRADOR');

  @override
  Future<int> generarCalendario(
    String ligaId, {
    DateTime? inicio,
    int diasEntreJornadas = 7,
    int vueltas = 1,
    int? grupos,
  }) async {
    final r = await _c.rpc(
      'generar_calendario',
      params: {
        'p_competicion': ligaId,
        'p_fecha_inicio': inicio == null ? null : _iso(inicio),
        'p_dias_entre_jornadas': diasEntreJornadas,
        'p_vueltas': vueltas,
        'p_grupos': ?grupos,
      },
    );
    return (r as num).toInt();
  }

  @override
  Future<int> generarEliminatoria(String ligaId, {DateTime? inicio}) async {
    final r = await _c.rpc(
      'generar_eliminatoria',
      params: {
        'p_competicion': ligaId,
        'p_fecha_inicio': inicio == null ? null : _iso(inicio),
      },
    );
    return (r as num).toInt();
  }

  @override
  Future<int> generarPlayoff(
    String ligaId, {
    int clasifican = 2,
    DateTime? inicio,
  }) async {
    final r = await _c.rpc(
      'generar_playoff',
      params: {
        'p_competicion': ligaId,
        'p_clasifican': clasifican,
        'p_fecha_inicio': inicio == null ? null : _iso(inicio),
      },
    );
    return (r as num).toInt();
  }

  @override
  Future<List<Descanso>> pasanDirecto(String ligaId) async => _rows(
    await _c
        .from('v_byes_competicion')
        .select()
        .eq('competicion_id', ligaId)
        .order('jornada'),
  ).map(Descanso.fromRow).toList();

  @override
  Future<List<OrganizacionAdmin>> organizaciones() async => _rows(
    await _c.from('v_organizaciones_admin').select().order('nombre'),
  ).map(OrganizacionAdmin.fromRow).toList();

  @override
  Future<void> crearOrganizacion(
    String nombre,
    String tipo, {
    String? ciudad,
  }) => _c.from('organizacion').insert({
    'nombre': nombre,
    'tipo': tipo,
    'ciudad': ciudad,
  });
}
