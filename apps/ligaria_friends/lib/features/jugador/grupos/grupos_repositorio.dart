import 'package:supabase_flutter/supabase_flutter.dart';

/// Grupo de amigos tal como lo expone la vista `v_mis_grupos`.
class Grupo {
  const Grupo({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.codigo,
    required this.esAdmin,
    required this.miembros,
  });
  final String id;
  final String nombre;
  final String? descripcion;
  final String codigo;
  final bool esAdmin;
  final int miembros;

  factory Grupo.desdeFila(Map<String, dynamic> f) => Grupo(
    id: f['id'] as String,
    nombre: f['nombre'] as String,
    descripcion: f['descripcion'] as String?,
    codigo: f['codigo_invitacion'] as String,
    esAdmin: f['rol'] == 'ADMIN',
    miembros: (f['miembros'] as num).toInt(),
  );
}

/// Miembro de un grupo (de `grupo_miembro` + `perfil`).
class Miembro {
  const Miembro({
    required this.id,
    required this.nombre,
    required this.esAdmin,
    required this.esYo,
    this.esCreador = false,
  });
  final String id;
  final String nombre;
  final bool esAdmin;
  final bool esYo;

  /// Quien creó el grupo: siempre administrador y no se le puede quitar el rol.
  final bool esCreador;
}

/// Amigo al que el usuario invitó alguna vez a un grupo (vista `v_mis_contactos`).
class Contacto {
  const Contacto({required this.id, required this.nombre});
  final String id;
  final String nombre;
}

class GruposException implements Exception {
  const GruposException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Contrato de acceso a grupos. [GruposSupabase] en producción, [GruposDemo] sin configuración / tests.
abstract class GruposRepositorio {
  /// Id del usuario actual (va en los enlaces de invitación para que quede como contacto).
  String? get yo;

  Future<List<Grupo>> misGrupos();
  Future<void> crear({required String nombre, String? descripcion});

  /// [invitador]: quien compartió el enlace; pasa a tener al nuevo miembro como contacto.
  Future<void> unirse(String codigo, {String? invitador});
  Future<List<Miembro>> miembros(String grupoId);

  /// Amigos invitados por el usuario (siguen visibles aunque ya no compartan grupo).
  Future<List<Contacto>> contactos();

  /// Quienes pueden jugar un amistoso contigo: tú, tus amigos y los miembros de tus grupos.
  Future<List<Miembro>> jugadoresPosibles();

  /// Añade a un amigo a este grupo (solo administradores).
  Future<void> anadirContacto(String grupoId, String usuarioId);

  /// Nombra (o quita) a un miembro como administrador del grupo (solo administradores).
  Future<void> cambiarAdmin(String grupoId, String usuarioId, bool admin);

  /// Genera un código de invitación nuevo (solo administradores) y lo devuelve.
  Future<String> regenerarCodigo(String grupoId);

  /// Envía por email (plantilla de Supabase) una invitación al grupo. [urlApp]: dirección de la app.
  Future<void> invitarPorEmail({
    required String grupoId,
    required String email,
    required String urlApp,
  });
}

class GruposSupabase implements GruposRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  String? get yo => _c.auth.currentUser?.id;

  @override
  Future<List<Grupo>> misGrupos() => _traducir(() async {
    final filas = await _c.from('v_mis_grupos').select().order('nombre');
    return filas.map(Grupo.desdeFila).toList();
  });

  @override
  Future<void> crear({required String nombre, String? descripcion}) =>
      _traducir(
        () => _c.rpc(
          'crear_grupo',
          params: {'p_nombre': nombre.trim(), 'p_descripcion': descripcion},
        ),
      );

  @override
  Future<void> unirse(String codigo, {String? invitador}) => _traducir(
    () => _c.rpc(
      'unirse_a_grupo',
      params: {'p_codigo': codigo.trim(), 'p_invitador': invitador},
    ),
  );

  @override
  Future<List<Contacto>> contactos() => _traducir(() async {
    final filas = await _c.from('v_mis_contactos').select().order('nombre');
    return [
      for (final f in filas)
        Contacto(id: f['id'] as String, nombre: f['nombre'] as String),
    ];
  });

  @override
  Future<List<Miembro>> jugadoresPosibles() => _traducir(() async {
    final yo = _c.auth.currentUser?.id;
    final porId = <String, Miembro>{};
    // La RLS de grupo_miembro deja ver solo los miembros de mis grupos.
    final filas = await _c
        .from('grupo_miembro')
        .select('usuario_id, alias, perfil(nombre, apodo)');
    for (final f in filas) {
      final perfil = f['perfil'] as Map<String, dynamic>?;
      final id = f['usuario_id'] as String;
      porId[id] = Miembro(
        id: id,
        nombre:
            (perfil?['apodo'] as String?) ??
            (perfil?['nombre'] as String?) ??
            'Jugador',
        esAdmin: false,
        esYo: id == yo,
      );
    }
    for (final c in await contactos()) {
      porId.putIfAbsent(
        c.id,
        () => Miembro(id: c.id, nombre: c.nombre, esAdmin: false, esYo: false),
      );
    }
    final lista = porId.values.toList()
      ..sort(
        (a, b) =>
            a.esYo != b.esYo ? (a.esYo ? -1 : 1) : a.nombre.compareTo(b.nombre),
      );
    return lista;
  });

  @override
  Future<void> anadirContacto(String grupoId, String usuarioId) => _traducir(
    () => _c.rpc(
      'anadir_contacto_a_grupo',
      params: {'p_grupo': grupoId, 'p_usuario': usuarioId},
    ),
  );

  @override
  Future<List<Miembro>> miembros(String grupoId) => _traducir(() async {
    final yo = _c.auth.currentUser?.id;
    final creador =
        (await _c
                .from('grupo')
                .select('creado_por')
                .eq('id', grupoId)
                .maybeSingle())?['creado_por']
            as String?;
    final filas = await _c
        .from('grupo_miembro')
        .select('usuario_id, rol, alias, perfil(nombre, apodo)')
        .eq('grupo_id', grupoId);
    final lista = filas.map((f) {
      final perfil = f['perfil'] as Map<String, dynamic>?;
      final nombre =
          (f['alias'] as String?) ??
          (perfil?['apodo'] as String?) ??
          (perfil?['nombre'] as String?) ??
          'Jugador';
      return Miembro(
        id: f['usuario_id'] as String,
        nombre: nombre,
        esAdmin: f['rol'] == 'ADMIN',
        esYo: f['usuario_id'] == yo,
        esCreador: f['usuario_id'] == creador,
      );
    }).toList();
    lista.sort(
      (a, b) => a.esAdmin == b.esAdmin
          ? a.nombre.compareTo(b.nombre)
          : (a.esAdmin ? -1 : 1),
    );
    return lista;
  });

  @override
  Future<void> cambiarAdmin(String grupoId, String usuarioId, bool admin) =>
      _traducir(
        () => _c
            .from('grupo_miembro')
            .update({'rol': admin ? 'ADMIN' : 'MIEMBRO'})
            .eq('grupo_id', grupoId)
            .eq('usuario_id', usuarioId),
      );

  @override
  Future<String> regenerarCodigo(String grupoId) => _traducir(
    () async =>
        await _c.rpc('regenerar_codigo', params: {'p_grupo': grupoId})
            as String,
  );

  @override
  Future<void> invitarPorEmail({
    required String grupoId,
    required String email,
    required String urlApp,
  }) async {
    try {
      await _c.functions.invoke(
        'invitar',
        body: {'grupo_id': grupoId, 'email': email, 'redirect_to': urlApp},
      );
    } on FunctionException catch (e) {
      final d = e.details;
      throw GruposException(
        d is Map && d['error'] is String
            ? d['error'] as String
            : 'No se pudo enviar la invitación.',
      );
    }
  }

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw GruposException(e.message);
    }
  }
}

/// En memoria; el código de invitación «DEMO000001» une a un grupo de ejemplo.
class GruposDemo implements GruposRepositorio {
  final _grupos = <Grupo>[];
  int _n = 0;

  @override
  String? get yo => 'u0';

  @override
  Future<List<Grupo>> misGrupos() async => List.unmodifiable(_grupos);

  @override
  Future<void> crear({required String nombre, String? descripcion}) async {
    _grupos.add(
      Grupo(
        id: 'demo-${_n++}',
        nombre: nombre.trim(),
        descripcion: (descripcion?.trim().isEmpty ?? true)
            ? null
            : descripcion!.trim(),
        codigo: 'DEMO${(1000000 + _n).toString().substring(1)}',
        esAdmin: true,
        miembros:
            4, // demo: ya vienen amigos de ejemplo para poder probar las ligas
      ),
    );
  }

  @override
  Future<List<Miembro>> miembros(String grupoId) async {
    final g = _grupos.firstWhere((g) => g.id == grupoId);
    return [
      Miembro(
        id: 'u0',
        nombre: 'Demo',
        esAdmin: g.esAdmin,
        esYo: true,
        esCreador: g.esAdmin,
      ),
      for (var i = 1; i < g.miembros; i++)
        Miembro(id: 'u$i', nombre: 'Amigo $i', esAdmin: false, esYo: false),
    ];
  }

  @override
  Future<void> cambiarAdmin(
    String grupoId,
    String usuarioId,
    bool admin,
  ) async {}

  @override
  Future<void> invitarPorEmail({
    required String grupoId,
    required String email,
    required String urlApp,
  }) => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<String> regenerarCodigo(String grupoId) async {
    final i = _grupos.indexWhere((g) => g.id == grupoId);
    final g = _grupos[i];
    final nuevo = 'DEMO${(2000000 + (++_n)).toString().substring(1)}';
    _grupos[i] = Grupo(
      id: g.id,
      nombre: g.nombre,
      descripcion: g.descripcion,
      codigo: nuevo,
      esAdmin: g.esAdmin,
      miembros: g.miembros,
    );
    return nuevo;
  }

  @override
  Future<List<Contacto>> contactos() async => const [
    Contacto(id: 'u1', nombre: 'Amigo 1'),
    Contacto(id: 'u9', nombre: 'Amigo externo'),
  ];

  @override
  Future<List<Miembro>> jugadoresPosibles() async {
    final porId = <String, Miembro>{};
    for (final g in _grupos) {
      for (final m in await miembros(g.id)) {
        porId.putIfAbsent(m.id, () => m);
      }
    }
    for (final c in await contactos()) {
      porId.putIfAbsent(
        c.id,
        () => Miembro(id: c.id, nombre: c.nombre, esAdmin: false, esYo: false),
      );
    }
    porId.putIfAbsent(
      'u0',
      () => const Miembro(id: 'u0', nombre: 'Demo', esAdmin: false, esYo: true),
    );
    return porId.values.toList();
  }

  @override
  Future<void> anadirContacto(String grupoId, String usuarioId) async {
    final i = _grupos.indexWhere((g) => g.id == grupoId);
    final g = _grupos[i];
    _grupos[i] = Grupo(
      id: g.id,
      nombre: g.nombre,
      descripcion: g.descripcion,
      codigo: g.codigo,
      esAdmin: g.esAdmin,
      miembros: g.miembros + 1,
    );
  }

  @override
  Future<void> unirse(String codigo, {String? invitador}) async {
    if (codigo.trim().toUpperCase() != 'DEMO000001') {
      throw const GruposException('Código de invitación no válido.');
    }
    _grupos.add(
      Grupo(
        id: 'demo-${_n++}',
        nombre: 'Grupo de ejemplo',
        codigo: 'DEMO000001',
        esAdmin: false,
        miembros: 4,
      ),
    );
  }
}
