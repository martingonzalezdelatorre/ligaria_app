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
  });
  final String id;
  final String nombre;
  final bool esAdmin;
  final bool esYo;
}

class GruposException implements Exception {
  const GruposException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Contrato de acceso a grupos. [GruposSupabase] en producción, [GruposDemo] sin configuración / tests.
abstract class GruposRepositorio {
  Future<List<Grupo>> misGrupos();
  Future<void> crear({required String nombre, String? descripcion});
  Future<void> unirse(String codigo);
  Future<List<Miembro>> miembros(String grupoId);

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
  Future<void> unirse(String codigo) => _traducir(
    () => _c.rpc('unirse_a_grupo', params: {'p_codigo': codigo.trim()}),
  );

  @override
  Future<List<Miembro>> miembros(String grupoId) => _traducir(() async {
    final yo = _c.auth.currentUser?.id;
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
      Miembro(id: 'u0', nombre: 'Demo', esAdmin: g.esAdmin, esYo: true),
      for (var i = 1; i < g.miembros; i++)
        Miembro(id: 'u$i', nombre: 'Amigo $i', esAdmin: false, esYo: false),
    ];
  }

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
  Future<void> unirse(String codigo) async {
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
