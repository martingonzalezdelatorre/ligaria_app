import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/auth.dart';
import 'models.dart';

/// Acceso a datos de competiciones. Las pantallas dependen solo de esta interfaz;
/// en los tests se sustituye con un mock (mocktail).
abstract class LigaRepository {
  // ── Común / alumno / familia ──
  Future<List<Liga>> misLigas();
  Future<List<MiEquipo>> misEquipos();
  Future<List<EncuentroVista>> encuentros(String ligaId);
  Future<List<Descanso>> descansos(String ligaId);
  Future<List<FilaClasificacion>> clasificacion(String ligaId);
  Future<List<Ficha>> misFichas();
  Future<void> actualizarPrivacidad(String personaId, Visibilidad visibilidad, bool mostrarFoto);
  Future<void> registrarConsentimiento(String personaId, bool otorgado);
  /// Registra el acceso a la ficha de un menor (RPC leer_ficha).
  Future<void> registrarAccesoFicha(String personaId, {String? contexto});
  Future<List<AccesoMenor>> accesosFicha(String personaId);
  Future<Map<String, bool>> prefsNotificacion();
  Future<void> guardarPrefsNotificacion(Map<String, bool> prefs);
  Future<List<NotificacionApp>> notificaciones();
  Future<void> marcarNotificacionLeida(String id);

  // ── Entrenador ──
  Future<List<Jugador>> jugadores(String equipoId);
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId);
  /// resultado: {"incomparecencia": null|"local"|"visitante",
  ///   "partidos":[{"orden":1,"local":[personaId],"visitante":[personaId],"sets":[[6,4],[3,6]]}]}
  Future<void> proponerResultado(String encuentroId, Map<String, dynamic> resultado);

  // ── Admin de escuela ──
  Future<List<PersonaLite>> personas(String escuelaId);
  Future<void> crearPersona(String escuelaId, String nombre, String apellidos, DateTime fechaNacimiento);
  Future<List<EquipoLite>> equipos(String escuelaId);
  Future<void> crearEquipo(String escuelaId, String nombre, String deporteId, {String? categoriaId});
  Future<void> anadirJugador(String equipoId, String escuelaId, String personaId);
  Future<void> asignarEntrenador(String equipoId, String escuelaId, String usuarioId);
  Future<List<UsuarioEscuela>> usuarios(String escuelaId);
  Future<void> invitar(String escuelaId, String email, Rol rol, {String? personaId});
  Future<List<LigaAbierta>> ligasAbiertas();
  Future<void> inscribirEquipo(String ligaId, String equipoId, String escuelaId);
  Future<List<Deporte>> deportes();

  // ── Organizador ──
  Future<List<Temporada>> temporadas();
  Future<List<Liga>> ligasOrganizadas(String escuelaId);
  Future<void> crearLiga({
    required String escuelaId, required String temporadaId, required String deporteId,
    required String nombre, ReglasLiga reglas = const ReglasLiga(),
  });
  Future<void> publicarLiga(String ligaId);
  Future<int> generarCalendario(String ligaId, {DateTime? inicio, int diasEntreJornadas = 7});
  Future<List<EncuentroVista>> pendientes(String escuelaId);
  Future<void> confirmarResultado(String encuentroId);
  Future<void> rechazarResultado(String encuentroId, String motivo);
  Future<void> corregirResultado(String encuentroId, Map<String, dynamic> resultado, String motivo);
  Future<List<Correccion>> correcciones(String encuentroId);

  // ── Superadmin ──
  Future<List<EscuelaAdmin>> escuelas();
  Future<void> crearEscuela(String nombre, String slug);
  Future<void> setModulo(String escuelaId, String modulo, bool activo);
  Future<void> crearTemporada(String nombre, DateTime inicio, DateTime fin);
  Future<List<RegistroCambio>> registroCambios({int limite = 100});
}

final ligaRepositoryProvider = Provider<LigaRepository>((ref) => SupabaseLigaRepository());

String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

class SupabaseLigaRepository implements LigaRepository {
  SupabaseClient get _c => Supabase.instance.client;
  String get _uid => _c.auth.currentUser!.id;
  List<Map<String, dynamic>> _rows(Object l) => (l as List).cast<Map<String, dynamic>>();

  @override
  Future<List<Liga>> misLigas() async => _rows(await _c
          .from('competicion')
          .select('id, nombre, estado, organization_id, deporte(nombre)')
          .order('created_at'))
      .map(Liga.fromRow)
      .toList();

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
  Future<List<FilaClasificacion>> clasificacion(String ligaId) async =>
      _rows(await _c.rpc('clasificacion', params: {'p_competicion': ligaId}))
          .map(FilaClasificacion.fromRow)
          .toList();

  @override
  Future<List<Ficha>> misFichas() async =>
      _rows(await _c.from('v_mis_fichas').select().order('nombre')).map(Ficha.fromRow).toList();

  @override
  Future<void> actualizarPrivacidad(String personaId, Visibilidad visibilidad, bool mostrarFoto) =>
      _c.rpc('actualizar_privacidad', params: {
        'p_persona': personaId,
        'p_visibilidad': visibilidadADb(visibilidad),
        'p_mostrar_foto': mostrarFoto,
      });

  @override
  Future<void> registrarConsentimiento(String personaId, bool otorgado) => _c.from('consentimiento').insert({
        'persona_id': personaId,
        'tutor_usuario_id': _uid,
        'otorgado': otorgado,
      });

  @override
  Future<void> registrarAccesoFicha(String personaId, {String? contexto}) =>
      _c.rpc('leer_ficha', params: {'p_persona': personaId, 'p_contexto': contexto});

  @override
  Future<List<AccesoMenor>> accesosFicha(String personaId) async => _rows(await _c
          .from('registro_acceso_menores')
          .select('created_at, contexto')
          .eq('persona_id', personaId)
          .order('created_at', ascending: false)
          .limit(50))
      .map((r) => AccesoMenor(fecha: DateTime.parse(r['created_at'] as String), contexto: r['contexto'] as String?))
      .toList();

  @override
  Future<Map<String, bool>> prefsNotificacion() async {
    final r = await _c.from('usuario').select('notif_prefs').eq('id', _uid).single();
    final m = (r['notif_prefs'] as Map?) ?? const {};
    return {for (final e in m.entries) e.key as String: e.value == true};
  }

  @override
  Future<void> guardarPrefsNotificacion(Map<String, bool> prefs) =>
      _c.from('usuario').update({'notif_prefs': prefs}).eq('id', _uid);

  @override
  Future<List<NotificacionApp>> notificaciones() async => _rows(await _c
          .from('notificacion')
          .select()
          .order('created_at', ascending: false)
          .limit(50))
      .map(NotificacionApp.fromRow)
      .toList();

  @override
  Future<void> marcarNotificacionLeida(String id) => _c.from('notificacion').update({'leida': true}).eq('id', id);

  @override
  Future<List<Jugador>> jugadores(String equipoId) async =>
      _rows(await _c.from('v_jugadores_equipo').select().eq('equipo_id', equipoId).order('nombre'))
          .map(Jugador.fromRow)
          .toList();

  @override
  Future<DetalleEncuentro> detalleEncuentro(String encuentroId) async {
    final enc = await _c.from('encuentro').select('incomparecencia').eq('id', encuentroId).single();
    final partidos = _rows(await _c
        .from('partido')
        .select('id, orden, tipo, resultado_set(numero, juegos_local, juegos_visitante)')
        .eq('encuentro_id', encuentroId)
        .order('orden'));
    final ids = partidos.map((p) => p['id'] as String).toList();
    final jug = ids.isEmpty
        ? <Map<String, dynamic>>[]
        : _rows(await _c
            .from('v_jugadores_competicion')
            .select('partido_id, lado, persona_id, nombre_mostrado')
            .inFilter('partido_id', ids));
    List<Map<String, dynamic>> de(String pid, String lado) =>
        jug.where((j) => j['partido_id'] == pid && j['lado'] == lado).toList();
    return DetalleEncuentro(
      incomparecencia: enc['incomparecencia'] as String?,
      partidos: [
        for (final p in partidos)
          PartidoDetalle(
            orden: (p['orden'] as num).toInt(),
            tipo: p['tipo'] as String,
            local: de(p['id'] as String, 'local').map((j) => j['nombre_mostrado'] as String).toList(),
            visitante: de(p['id'] as String, 'visitante').map((j) => j['nombre_mostrado'] as String).toList(),
            localIds: de(p['id'] as String, 'local').map((j) => j['persona_id'] as String).toList(),
            visitanteIds: de(p['id'] as String, 'visitante').map((j) => j['persona_id'] as String).toList(),
            sets: (((p['resultado_set'] as List?) ?? const []).cast<Map<String, dynamic>>().toList()
                  ..sort((a, b) => (a['numero'] as num).compareTo(b['numero'] as num)))
                .map((s) => [(s['juegos_local'] as num).toInt(), (s['juegos_visitante'] as num).toInt()])
                .toList(),
          ),
      ],
    );
  }

  @override
  Future<void> proponerResultado(String encuentroId, Map<String, dynamic> resultado) =>
      _c.rpc('proponer_resultado', params: {'p_encuentro': encuentroId, 'p_resultado': resultado});

  @override
  Future<List<PersonaLite>> personas(String escuelaId) async => _rows(await _c
          .from('persona')
          .select('id, nombre, apellidos, fecha_nacimiento')
          .eq('escuela_id', escuelaId)
          .order('apellidos'))
      .map(PersonaLite.fromRow)
      .toList();

  @override
  Future<void> crearPersona(String escuelaId, String nombre, String apellidos, DateTime fechaNacimiento) =>
      _c.from('persona').insert({
        'escuela_id': escuelaId, 'nombre': nombre, 'apellidos': apellidos, 'fecha_nacimiento': _iso(fechaNacimiento),
      });

  @override
  Future<List<EquipoLite>> equipos(String escuelaId) async =>
      _rows(await _c.from('equipo').select('id, nombre, deporte_id, categoria_id').eq('escuela_id', escuelaId).order('nombre'))
          .map(EquipoLite.fromRow)
          .toList();

  @override
  Future<void> crearEquipo(String escuelaId, String nombre, String deporteId, {String? categoriaId}) =>
      _c.from('equipo').insert({
        'escuela_id': escuelaId, 'nombre': nombre, 'deporte_id': deporteId, 'categoria_id': categoriaId,
      });

  @override
  Future<void> anadirJugador(String equipoId, String escuelaId, String personaId) =>
      _c.from('equipo_miembro').insert({'equipo_id': equipoId, 'escuela_id': escuelaId, 'persona_id': personaId});

  @override
  Future<void> asignarEntrenador(String equipoId, String escuelaId, String usuarioId) =>
      _c.from('equipo_entrenador').insert({'equipo_id': equipoId, 'escuela_id': escuelaId, 'usuario_id': usuarioId});

  @override
  Future<List<UsuarioEscuela>> usuarios(String escuelaId) async => _rows(await _c
          .from('pertenencia')
          .select('rol, usuario(id, email, nombre)')
          .eq('escuela_id', escuelaId))
      .map((r) {
        final u = r['usuario'] as Map<String, dynamic>;
        return UsuarioEscuela(
            usuarioId: u['id'] as String, email: (u['email'] as String?) ?? '', nombre: u['nombre'] as String?, rol: r['rol'] as String);
      })
      .toList();

  @override
  Future<void> invitar(String escuelaId, String email, Rol rol, {String? personaId}) =>
      _c.rpc('invitar_usuario', params: {
        'p_escuela': escuelaId, 'p_email': email, 'p_rol': rolADb(rol), 'p_persona': personaId,
      });

  @override
  Future<List<LigaAbierta>> ligasAbiertas() async =>
      _rows(await _c.from('v_ligas_abiertas').select()).map(LigaAbierta.fromRow).toList();

  @override
  Future<void> inscribirEquipo(String ligaId, String equipoId, String escuelaId) =>
      _c.from('inscripcion_equipo').insert({'competicion_id': ligaId, 'equipo_id': equipoId, 'escuela_id': escuelaId});

  @override
  Future<List<Deporte>> deportes() async => _rows(await _c.from('deporte').select().order('nombre'))
      .map((r) => Deporte(id: r['id'] as String, nombre: r['nombre'] as String))
      .toList();

  @override
  Future<List<Temporada>> temporadas() async => _rows(await _c.from('temporada').select().order('inicio', ascending: false))
      .map((r) => Temporada(
          id: r['id'] as String, nombre: r['nombre'] as String,
          inicio: DateTime.parse(r['inicio'] as String), fin: DateTime.parse(r['fin'] as String)))
      .toList();

  @override
  Future<List<Liga>> ligasOrganizadas(String escuelaId) async => _rows(await _c
          .from('competicion')
          .select('id, nombre, estado, organization_id, deporte(nombre)')
          .eq('organization_id', escuelaId)
          .order('created_at'))
      .map(Liga.fromRow)
      .toList();

  @override
  Future<void> crearLiga({
    required String escuelaId, required String temporadaId, required String deporteId,
    required String nombre, ReglasLiga reglas = const ReglasLiga(),
  }) =>
      _c.from('competicion').insert({
        'organization_id': escuelaId, 'temporada_id': temporadaId, 'deporte_id': deporteId,
        'nombre': nombre, 'tipo': 'liga', 'reglas': reglas.toJson(),
      });

  @override
  Future<void> publicarLiga(String ligaId) => _c.from('competicion').update({'estado': 'publicada'}).eq('id', ligaId);

  @override
  Future<int> generarCalendario(String ligaId, {DateTime? inicio, int diasEntreJornadas = 7}) async {
    final r = await _c.rpc('generar_calendario', params: {
      'p_competicion': ligaId,
      'p_fecha_inicio': inicio == null ? null : _iso(inicio),
      'p_dias_entre_jornadas': diasEntreJornadas,
    });
    return (r as num).toInt();
  }

  @override
  Future<List<EncuentroVista>> pendientes(String escuelaId) async {
    final ligas = await ligasOrganizadas(escuelaId);
    if (ligas.isEmpty) return const [];
    return _rows(await _c
            .from('v_encuentros_competicion')
            .select()
            .inFilter('competicion_id', ligas.map((l) => l.id).toList())
            .eq('estado', 'propuesto')
            .order('jornada'))
        .map(EncuentroVista.fromRow)
        .toList();
  }

  @override
  Future<void> confirmarResultado(String encuentroId) => _c.rpc('confirmar_resultado', params: {'p_encuentro': encuentroId});

  @override
  Future<void> rechazarResultado(String encuentroId, String motivo) =>
      _c.rpc('rechazar_resultado', params: {'p_encuentro': encuentroId, 'p_motivo': motivo});

  @override
  Future<void> corregirResultado(String encuentroId, Map<String, dynamic> resultado, String motivo) =>
      _c.rpc('corregir_resultado', params: {'p_encuentro': encuentroId, 'p_resultado': resultado, 'p_motivo': motivo});

  @override
  Future<List<Correccion>> correcciones(String encuentroId) async => _rows(await _c
          .from('correccion_resultado')
          .select('motivo, created_at')
          .eq('encuentro_id', encuentroId)
          .order('created_at', ascending: false))
      .map((r) => Correccion(motivo: r['motivo'] as String, fecha: DateTime.parse(r['created_at'] as String)))
      .toList();

  @override
  Future<List<EscuelaAdmin>> escuelas() async => _rows(await _c
          .from('escuela')
          .select('id, nombre, slug, activa, escuela_modulo(modulo, activo)')
          .order('nombre'))
      .map((r) => EscuelaAdmin(
            id: r['id'] as String, nombre: r['nombre'] as String, slug: r['slug'] as String, activa: r['activa'] as bool,
            modulos: {
              for (final m in ((r['escuela_modulo'] as List?) ?? const []).cast<Map<String, dynamic>>())
                m['modulo'] as String: m['activo'] as bool,
            },
          ))
      .toList();

  @override
  Future<void> crearEscuela(String nombre, String slug) => _c.from('escuela').insert({'nombre': nombre, 'slug': slug});

  @override
  Future<void> setModulo(String escuelaId, String modulo, bool activo) =>
      _c.from('escuela_modulo').upsert({'escuela_id': escuelaId, 'modulo': modulo, 'activo': activo});

  @override
  Future<void> crearTemporada(String nombre, DateTime inicio, DateTime fin) =>
      _c.from('temporada').insert({'nombre': nombre, 'inicio': _iso(inicio), 'fin': _iso(fin)});

  @override
  Future<List<RegistroCambio>> registroCambios({int limite = 100}) async => _rows(await _c
          .from('registro_cambios')
          .select('id, escuela_id, tabla, accion, created_at')
          .order('created_at', ascending: false)
          .limit(limite))
      .map((r) => RegistroCambio(
          id: (r['id'] as num).toInt(), tabla: r['tabla'] as String, accion: r['accion'] as String,
          fecha: DateTime.parse(r['created_at'] as String), escuelaId: r['escuela_id'] as String?))
      .toList();
}
