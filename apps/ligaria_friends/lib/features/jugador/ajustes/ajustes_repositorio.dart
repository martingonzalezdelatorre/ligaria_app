import 'package:supabase_flutter/supabase_flutter.dart';
import '../ligas/ligas_repositorio.dart';

/// Provincias de España (para elegir la del usuario y que el ranking provincial coincida).
const provinciasEspana = [
  'A Coruña',
  'Álava',
  'Albacete',
  'Alicante',
  'Almería',
  'Asturias',
  'Ávila',
  'Badajoz',
  'Barcelona',
  'Burgos',
  'Cáceres',
  'Cádiz',
  'Cantabria',
  'Castellón',
  'Ceuta',
  'Ciudad Real',
  'Córdoba',
  'Cuenca',
  'Girona',
  'Granada',
  'Guadalajara',
  'Gipuzkoa',
  'Huelva',
  'Huesca',
  'Illes Balears',
  'Jaén',
  'La Rioja',
  'Las Palmas',
  'León',
  'Lleida',
  'Lugo',
  'Madrid',
  'Málaga',
  'Melilla',
  'Murcia',
  'Navarra',
  'Ourense',
  'Palencia',
  'Pontevedra',
  'Salamanca',
  'Santa Cruz de Tenerife',
  'Segovia',
  'Sevilla',
  'Soria',
  'Tarragona',
  'Teruel',
  'Toledo',
  'Valencia',
  'Valladolid',
  'Bizkaia',
  'Zamora',
  'Zaragoza',
];

/// Preferencias de la cuenta que se activan o desactivan con un interruptor.
enum Preferencia {
  rankingGlobal('ranking_global'),
  rankingProvincia('ranking_provincia'),
  rankingLocalidad('ranking_localidad'),
  notificaciones('notificaciones'),
  buscable('buscable'),
  telefonoVisible('telefono_visible');

  const Preferencia(this.columna);
  final String columna;
}

/// Datos y ajustes del usuario registrado.
class PerfilUsuario {
  const PerfilUsuario({
    required this.email,
    this.nombre = '',
    this.apellidos = '',
    this.localidad = '',
    this.provincia = '',
    this.rankingGlobal = false,
    this.rankingProvincia = false,
    this.rankingLocalidad = false,
    this.notificaciones = true,
    this.telefono = '',
    this.buscable = false,
    this.telefonoVisible = false,
  });
  final String email;
  final String nombre, apellidos, localidad, provincia, telefono;
  final bool buscable, telefonoVisible;
  final bool rankingGlobal, rankingProvincia, rankingLocalidad, notificaciones;

  bool get tieneProvincia => provincia.trim().isNotEmpty;
  bool get tieneLocalidad => localidad.trim().isNotEmpty;

  bool valorDe(Preferencia p) => switch (p) {
    Preferencia.rankingGlobal => rankingGlobal,
    Preferencia.rankingProvincia => rankingProvincia,
    Preferencia.rankingLocalidad => rankingLocalidad,
    Preferencia.notificaciones => notificaciones,
    Preferencia.buscable => buscable,
    Preferencia.telefonoVisible => telefonoVisible,
  };

  PerfilUsuario copiaCon({
    String? nombre,
    String? apellidos,
    String? localidad,
    String? provincia,
    String? telefono,
    Preferencia? preferencia,
    bool? valor,
  }) => PerfilUsuario(
    email: email,
    nombre: nombre ?? this.nombre,
    apellidos: apellidos ?? this.apellidos,
    localidad: localidad ?? this.localidad,
    provincia: provincia ?? this.provincia,
    telefono: telefono ?? this.telefono,
    buscable: preferencia == Preferencia.buscable ? valor! : buscable,
    telefonoVisible: preferencia == Preferencia.telefonoVisible
        ? valor!
        : telefonoVisible,
    rankingGlobal: preferencia == Preferencia.rankingGlobal
        ? valor!
        : rankingGlobal,
    rankingProvincia: preferencia == Preferencia.rankingProvincia
        ? valor!
        : rankingProvincia,
    rankingLocalidad: preferencia == Preferencia.rankingLocalidad
        ? valor!
        : rankingLocalidad,
    notificaciones: preferencia == Preferencia.notificaciones
        ? valor!
        : notificaciones,
  );

  factory PerfilUsuario.desdeFila(Map<String, dynamic> f, String email) =>
      PerfilUsuario(
        email: email,
        nombre: (f['nombre'] as String?) ?? '',
        apellidos: (f['apellidos'] as String?) ?? '',
        localidad: (f['localidad'] as String?) ?? '',
        provincia: (f['provincia'] as String?) ?? '',
        rankingGlobal: (f['ranking_global'] as bool?) ?? false,
        rankingProvincia: (f['ranking_provincia'] as bool?) ?? false,
        rankingLocalidad: (f['ranking_localidad'] as bool?) ?? false,
        notificaciones: (f['notificaciones'] as bool?) ?? true,
        telefono: (f['telefono'] as String?) ?? '',
        buscable: (f['buscable'] as bool?) ?? false,
        telefonoVisible: (f['telefono_visible'] as bool?) ?? false,
      );
}

/// Ajustes de la cuenta del jugador. [AjustesSupabase] en modo real, [AjustesDemo] en demo.
abstract class AjustesRepositorio {
  /// Lo fija `main()`; por defecto, en memoria.
  static AjustesRepositorio instancia = AjustesDemo();

  Future<PerfilUsuario> perfil();

  /// El email no se puede cambiar: no forma parte de los datos editables.
  Future<void> guardarDatos({
    required String nombre,
    required String apellidos,
    required String localidad,
    required String provincia,
    String telefono = '',
  });

  Future<void> establecer(Preferencia preferencia, bool valor);
}

class AjustesSupabase implements AjustesRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }

  @override
  Future<PerfilUsuario> perfil() => _traducir(() async {
    final user = _c.auth.currentUser!;
    final fila = await _c
        .from('perfil')
        .select(
          'nombre, apellidos, localidad, provincia, ranking_global, '
          'ranking_provincia, ranking_localidad, notificaciones, telefono, buscable, '
          'telefono_visible',
        )
        .eq('id', user.id)
        .maybeSingle();
    return PerfilUsuario.desdeFila(fila ?? const {}, user.email ?? '');
  });

  @override
  Future<void> guardarDatos({
    required String nombre,
    required String apellidos,
    required String localidad,
    required String provincia,
    String telefono = '',
  }) => _traducir(
    () => _c
        .from('perfil')
        .update({
          'nombre': nombre.trim(),
          'apellidos': apellidos.trim(),
          'localidad': localidad.trim(),
          'provincia': provincia.trim(),
          'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
        })
        .eq('id', _c.auth.currentUser!.id),
  );

  @override
  Future<void> establecer(Preferencia preferencia, bool valor) => _traducir(
    () => _c
        .from('perfil')
        .update({preferencia.columna: valor})
        .eq('id', _c.auth.currentUser!.id),
  );
}

class AjustesDemo implements AjustesRepositorio {
  PerfilUsuario _perfil = const PerfilUsuario(
    email: 'demo@ligaria.es',
    nombre: 'Demo',
    apellidos: 'Ligaria',
    localidad: 'Getafe',
    provincia: 'Madrid',
  );

  @override
  Future<PerfilUsuario> perfil() async => _perfil;

  @override
  Future<void> guardarDatos({
    required String nombre,
    required String apellidos,
    required String localidad,
    required String provincia,
    String telefono = '',
  }) async => _perfil = _perfil.copiaCon(
    telefono: telefono.trim(),
    nombre: nombre.trim(),
    apellidos: apellidos.trim(),
    localidad: localidad.trim(),
    provincia: provincia.trim(),
  );

  @override
  Future<void> establecer(Preferencia preferencia, bool valor) async =>
      _perfil = _perfil.copiaCon(preferencia: preferencia, valor: valor);
}
