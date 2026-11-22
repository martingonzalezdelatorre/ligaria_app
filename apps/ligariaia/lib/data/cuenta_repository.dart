import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Datos personales del usuario (tabla `usuario`).
class PerfilCuenta {
  const PerfilCuenta({this.nombre = '', this.telefono = ''});
  final String nombre; // nombre completo, tal como se introdujo al registrarse
  final String telefono;
}

/// Datos de la organización (escuela, ayuntamiento u organizador) a la que pertenece el usuario.
class DatosOrganizacion {
  const DatosOrganizacion({
    required this.id,
    required this.nombre,
    this.cif = '',
    this.ciudad = '',
    this.direccion = '',
    this.codigoPostal = '',
    this.provincia = '',
    this.telefono = '',
    this.emailContacto = '',
    this.web = '',
  });
  final String id,
      nombre,
      cif,
      ciudad,
      direccion,
      codigoPostal,
      provincia,
      telefono,
      emailContacto,
      web;
}

abstract class CuentaRepository {
  Future<PerfilCuenta> perfil();
  Future<void> guardarPerfil({
    required String nombre,
    required String telefono,
  });
  Future<DatosOrganizacion> organizacion(String orgId);
  Future<void> guardarOrganizacion(DatosOrganizacion d);
}

class SupabaseCuentaRepository implements CuentaRepository {
  SupabaseClient get _c => Supabase.instance.client;
  static String _t(Object? v) => (v as String?) ?? '';

  @override
  Future<PerfilCuenta> perfil() async {
    final f = await _c
        .from('usuario')
        .select('nombre, telefono')
        .eq('id', _c.auth.currentUser!.id)
        .maybeSingle();
    return PerfilCuenta(nombre: _t(f?['nombre']), telefono: _t(f?['telefono']));
  }

  @override
  Future<void> guardarPerfil({
    required String nombre,
    required String telefono,
  }) => _c
      .from('usuario')
      .update({
        'nombre': nombre.trim(),
        'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
      })
      .eq('id', _c.auth.currentUser!.id);

  @override
  Future<DatosOrganizacion> organizacion(String orgId) async {
    final f = await _c.from('organizacion').select().eq('id', orgId).single();
    return DatosOrganizacion(
      id: orgId,
      nombre: _t(f['nombre']),
      cif: _t(f['cif']),
      ciudad: _t(f['ciudad']),
      direccion: _t(f['direccion']),
      codigoPostal: _t(f['codigo_postal']),
      provincia: _t(f['provincia']),
      telefono: _t(f['telefono']),
      emailContacto: _t(f['email_contacto']),
      web: _t(f['web']),
    );
  }

  @override
  Future<void> guardarOrganizacion(DatosOrganizacion d) => _c.rpc(
    'actualizar_organizacion',
    params: {
      'p_org': d.id,
      'p_nombre': d.nombre,
      'p_cif': d.cif,
      'p_ciudad': d.ciudad,
      'p_direccion': d.direccion,
      'p_codigo_postal': d.codigoPostal,
      'p_provincia': d.provincia,
      'p_telefono': d.telefono,
      'p_email_contacto': d.emailContacto,
      'p_web': d.web,
    },
  );
}

final cuentaRepositoryProvider = Provider<CuentaRepository>(
  (ref) => SupabaseCuentaRepository(),
);
