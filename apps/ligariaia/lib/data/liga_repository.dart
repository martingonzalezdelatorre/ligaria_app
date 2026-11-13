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

  // ── Entrenador ──
  Future<List<Jugador>> jugadores(String equipoId);
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId);
  /// resultado: {"incomparecencia": null|"local"|"visitante",
  ///   "partidos":[{"orden":1,"local":[jugadorId],"visitante":[jugadorId],"sets":[[6,4],[3,6]]}]}
  /// El entrenador de uno de los equipos lo registra una vez; la organización puede corregirlo.
  Future<void> registrarResultado(String encuentroId, Map<String, dynamic> resultado);

  // ── Administrador de escuela ──
  Future<List<JugadorLite>> jugadoresOrg(String orgId);
  Future<void> crearJugador(String orgId, String nombre, String apellidos, DateTime fechaNacimiento);
  Future<List<EquipoLite>> equipos(String orgId);
  Future<void> crearEquipo(String orgId, String nombre, String deporteId);
  Future<void> anadirJugador(String equipoId, String jugadorId);
  Future<void> asignarEntrenador(String equipoId, String usuarioId);
  Future<List<UsuarioEscuela>> usuarios(String orgId);
  Future<void> invitar(String orgId, String email, Rol rol, {String? jugadorId});
  Future<List<LigaAbierta>> ligasAbiertas();
  Future<void> inscribirEquipo(String ligaId, String equipoId);
  Future<List<Deporte>> deportes();

  // ── Organizador ──
  Future<List<Liga>> ligasOrganizadas(String orgId);
  /// [tipo]: código de competicion_tipo (MUNICIPAL | ENTRE_ESCUELAS | ESCUELA | AMIGOS).
  Future<void> crearLiga({
    required String orgId, required String deporteId, required String nombre, required String tipo,
    DateTime? fechaInicio, DateTime? fechaFin,
  });
  Future<void> editarLiga(String ligaId, {required String nombre, DateTime? fechaInicio, DateTime? fechaFin});
  /// Abre la liga a la inscripción de equipos.
  Future<void> publicarLiga(String ligaId);
  Future<int> generarCalendario(String ligaId, {DateTime? inicio, int diasEntreJornadas = 7, int vueltas = 1});

  // ── Administrador de la plataforma ──
  Future<List<OrganizacionAdmin>> organizaciones();
  Future<void> crearOrganizacion(String nombre, String tipo, {String? ciudad});
}

final ligaRepositoryProvider = Provider<LigaRepository>((ref) => SupabaseLigaRepository());

String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

class SupabaseLigaRepository implements LigaRepository {
  SupabaseClient get _c => Supabase.instance.client;
  List<Map<String, dynamic>> _rows(Object l) => (l as List).cast<Map<String, dynamic>>();

  @override
  Future<List<Liga>> misLigas() async =>
      _rows(await _c.from('v_ligas').select().order('created_at')).map(Liga.fromRow).toList();

  @override
  Future<List<MiEquipo>> misEquipos() async =>
      _rows(await _c.from('v_mis_equipos').select()).map(MiEquipo.fromRow).toList();

  @override
  Future<List<EncuentroVista>> encuentros(String ligaId) async => _rows(await _c
          .from('v_encuentros_competicion')
          .select()
          .eq('competicion_id', ligaId)
          .order('jornada')
          .order('local'))
      .map(EncuentroVista.fromRow)
      .toList();

  @override
  Future<List<Descanso>> descansos(String ligaId) async => _rows(
          await _c.from('v_descansos_competicion').select().eq('competicion_id', ligaId).order('jornada'))
      .map(Descanso.fromRow)
      .toList();

  @override
  Future<List<FilaClasificacion>> clasificacion(String ligaId) async => _rows(await _c
          .from('v_clasificacion_competicion')
          .select()
          .eq('competicion_id', ligaId)
          .order('categoria_id')
          .order('posicion'))
      .map(FilaClasificacion.fromRow)
      .toList();

  @override
  Future<List<Ficha>> misFichas() async =>
      _rows(await _c.from('v_mis_fichas').select().order('nombre')).map(Ficha.fromRow).toList();

  @override
  Future<List<Jugador>> jugadores(String equipoId) async =>
      _rows(await _c.from('v_jugadores_equipo').select().eq('equipo_id', equipoId).order('nombre'))
          .map(Jugador.fromRow)
          .toList();

  @override
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId) async {
    final partidos = _rows(await _c
        .from('partido')
        .select('id, orden, tipo, set_partido(numero, juegos_local, juegos_visitante)')
        .eq('encuentro_id', encuentroId)
        .order('orden'));
    final ids = partidos.map((p) => p['id'] as String).toList();
    final jug = ids.isEmpty
        ? <Map<String, dynamic>>[]
        : _rows(await _c
            .from('v_jugadores_competicion')
            .select('partido_id, lado, jugador_id, nombre_mostrado')
            .inFilter('partido_id', ids));
    final vista = _rows(await _c
        .from('v_encuentros_competicion')
        .select('incomparecencia')
        .eq('encuentro_id', encuentroId));
    List<Map<String, dynamic>> de(String pid, String lado) =>
        jug.where((j) => j['partido_id'] == pid && j['lado'] == lado).toList();
    return DetalleEncuentro(
      incomparecencia: vista.isEmpty ? null : vista.first['incomparecencia'] as String?,
      partidos: [
        for (final p in partidos)
          PartidoDetalle(
            orden: (p['orden'] as num).toInt(),
            tipo: (p['tipo'] as String).toLowerCase(),
            local: de(p['id'] as String, 'local').map((j) => j['nombre_mostrado'] as String).toList(),
            visitante: de(p['id'] as String, 'visitante').map((j) => j['nombre_mostrado'] as String).toList(),
            localIds: de(p['id'] as String, 'local').map((j) => j['jugador_id'] as String).toList(),
            visitanteIds: de(p['id'] as String, 'visitante').map((j) => j['jugador_id'] as String).toList(),
            sets: (((p['set_partido'] as List?) ?? const []).cast<Map<String, dynamic>>().toList()
                  ..sort((a, b) => (a['numero'] as num).compareTo(b['numero'] as num)))
                .map((s) => [(s['juegos_local'] as num).toInt(), (s['juegos_visitante'] as num).toInt()])
                .toList(),
          ),
      ],
    );
  }

  @override
  Future<void> registrarResultado(String encuentroId, Map<String, dynamic> resultado) =>
      _c.rpc('registrar_resultado', params: {'p_encuentro': encuentroId, 'p_resultado': resultado});

  @override
  Future<List<JugadorLite>> jugadoresOrg(String orgId) async => _rows(await _c
          .from('jugador')
          .select('id, nombre, apellidos, fecha_nacimiento')
          .eq('organizacion_id', orgId)
          .order('apellidos'))
      .map(JugadorLite.fromRow)
      .toList();

  @override
  Future<void> crearJugador(String orgId, String nombre, String apellidos, DateTime fechaNacimiento) =>
      _c.from('jugador').insert({
        'organizacion_id': orgId, 'nombre': nombre, 'apellidos': apellidos, 'fecha_nacimiento': _iso(fechaNacimiento),
      });

  @override
  Future<List<EquipoLite>> equipos(String orgId) async =>
      _rows(await _c.from('equipo').select('id, nombre, deporte').eq('organizacion_id', orgId).order('nombre'))
          .map(EquipoLite.fromRow)
          .toList();

  @override
  Future<void> crearEquipo(String orgId, String nombre, String deporteId) =>
      _c.from('equipo').insert({'organizacion_id': orgId, 'nombre': nombre, 'deporte': deporteId});

  @override
  Future<void> anadirJugador(String equipoId, String jugadorId) =>
      _c.from('equipo_miembro').insert({'equipo_id': equipoId, 'jugador_id': jugadorId});

  @override
  Future<void> asignarEntrenador(String equipoId, String usuarioId) =>
      _c.from('entrenador_equipo').insert({'equipo_id': equipoId, 'usuario_id': usuarioId});

  @override
  Future<List<UsuarioEscuela>> usuarios(String orgId) async =>
      _rows(await _c.from('v_usuarios_org').select().eq('organizacion_id', orgId))
          .map((r) => UsuarioEscuela(
              usuarioId: r['usuario_id'] as String, email: (r['email'] as String?) ?? '',
              nombre: r['nombre'] as String?, rol: r['rol'] as String))
          .toList();

  @override
  Future<void> invitar(String orgId, String email, Rol rol, {String? jugadorId}) =>
      _c.rpc('invitar_usuario', params: {
        'p_organizacion': orgId, 'p_email': email, 'p_rol': rolADb(rol), 'p_jugador': jugadorId,
      });

  @override
  Future<List<LigaAbierta>> ligasAbiertas() async =>
      _rows(await _c.from('v_ligas_abiertas').select()).map(LigaAbierta.fromRow).toList();

  @override
  Future<void> inscribirEquipo(String ligaId, String equipoId) =>
      _c.rpc('inscribir_equipo', params: {'p_competicion': ligaId, 'p_equipo': equipoId});

  @override
  Future<List<Deporte>> deportes() async => deportesDisponibles;

  @override
  Future<List<Liga>> ligasOrganizadas(String orgId) async =>
      _rows(await _c.from('v_ligas').select().eq('organizacion_id', orgId).order('created_at'))
          .map(Liga.fromRow)
          .toList();

  @override
  Future<void> crearLiga({
    required String orgId, required String deporteId, required String nombre, required String tipo,
    DateTime? fechaInicio, DateTime? fechaFin,
  }) =>
      _c.rpc('crear_competicion', params: {
        'p_organizacion': orgId, 'p_nombre': nombre, 'p_deporte': deporteId, 'p_tipo': tipo,
        'p_fecha_inicio': fechaInicio == null ? null : _iso(fechaInicio),
        'p_fecha_fin': fechaFin == null ? null : _iso(fechaFin),
      });

  @override
  Future<void> editarLiga(String ligaId, {required String nombre, DateTime? fechaInicio, DateTime? fechaFin}) =>
      _c.from('competicion').update({
        'nombre': nombre,
        'fecha_inicio': fechaInicio == null ? null : _iso(fechaInicio),
        'fecha_fin': fechaFin == null ? null : _iso(fechaFin),
      }).eq('id', ligaId).eq('estado', 'BORRADOR');

  @override
  Future<void> publicarLiga(String ligaId) =>
      _c.from('competicion').update({'estado': 'INSCRIPCION_ABIERTA'}).eq('id', ligaId).eq('estado', 'BORRADOR');

  @override
  Future<int> generarCalendario(String ligaId, {DateTime? inicio, int diasEntreJornadas = 7, int vueltas = 1}) async {
    final r = await _c.rpc('generar_calendario', params: {
      'p_competicion': ligaId,
      'p_fecha_inicio': inicio == null ? null : _iso(inicio),
      'p_dias_entre_jornadas': diasEntreJornadas,
      'p_vueltas': vueltas,
    });
    return (r as num).toInt();
  }

  @override
  Future<List<OrganizacionAdmin>> organizaciones() async =>
      _rows(await _c.from('v_organizaciones_admin').select().order('nombre')).map(OrganizacionAdmin.fromRow).toList();

  @override
  Future<void> crearOrganizacion(String nombre, String tipo, {String? ciudad}) =>
      _c.from('organizacion').insert({'nombre': nombre, 'tipo': tipo, 'ciudad': ciudad});
}
