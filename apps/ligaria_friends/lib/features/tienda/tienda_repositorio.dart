import 'package:supabase_flutter/supabase_flutter.dart';
import '../compartido/store_modelos.dart';

export '../compartido/store_modelos.dart';

/// Acceso del perfil Tienda: su comercio, su catálogo y los pedidos que recibe.
/// [TiendaSupabase] en producción, [TiendaDemo] sin configuración.
abstract class TiendaRepositorio {
  /// Lo fija `main()`; por defecto, datos de demostración.
  static TiendaRepositorio instancia = TiendaDemo();

  Future<Comercio> miTienda();
  Future<List<Producto>> productos();

  /// Crea el producto, o lo actualiza si [id] no es null.
  Future<void> guardarProducto({
    String? id,
    required String nombre,
    required double precio,
    String? categoria,
    String? descripcion,
    String? imagenUrl,
  });
  Future<void> eliminarProducto(String id);

  Future<List<Pedido>> pedidosRecibidos();
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado);
}

class TiendaSupabase implements TiendaRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<Comercio> miTienda() => _traducir(() async {
    final uid = _c.auth.currentUser?.id;
    final fila = uid == null
        ? null
        : await _c
              .from('comercio')
              .select()
              .eq('owner_id', uid)
              .eq('tipo', 'TIENDA')
              .order('created_at')
              .limit(1)
              .maybeSingle();
    if (fila == null) {
      throw const StoreException('Tu cuenta no tiene una tienda asociada.');
    }
    return Comercio.desdeFila(fila);
  });

  @override
  Future<List<Producto>> productos() => _traducir(() async {
    final tienda = await miTienda();
    final filas = await _c
        .from('producto')
        .select()
        .eq('comercio_id', tienda.id)
        .order('nombre');
    return filas.map(Producto.desdeFila).toList();
  });

  @override
  Future<void> guardarProducto({
    String? id,
    required String nombre,
    required double precio,
    String? categoria,
    String? descripcion,
    String? imagenUrl,
  }) => _traducir(() async {
    String? vacio(String? v) => (v?.trim().isEmpty ?? true) ? null : v!.trim();
    final datos = {
      'nombre': nombre.trim(),
      'precio': precio,
      'categoria': vacio(categoria),
      'descripcion': vacio(descripcion),
      'imagen_url': vacio(imagenUrl),
    };
    if (id == null) {
      final tienda = await miTienda();
      await _c.from('producto').insert({...datos, 'comercio_id': tienda.id});
    } else {
      await _c.from('producto').update(datos).eq('id', id);
    }
  });

  @override
  Future<void> eliminarProducto(String id) =>
      _traducir(() => _c.from('producto').delete().eq('id', id));

  @override
  Future<List<Pedido>> pedidosRecibidos() => _traducir(() async {
    final filas = await _c.rpc('pedidos_recibidos') as List;
    return [for (final f in filas) Pedido.desdeFila(f as Map<String, dynamic>)];
  });

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) => _traducir(
    () => _c.rpc(
      'cambiar_estado_pedido',
      params: {'p_pedido': pedidoId, 'p_estado': estado.codigo},
    ),
  );

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw StoreException(e.message);
    }
  }
}

class TiendaDemo implements TiendaRepositorio {
  static const _tienda = Comercio(
    id: 'demo-tienda',
    nombre: 'Tienda Demo',
    tipo: TipoComercio.tienda,
    ciudad: 'Madrid',
  );
  final _productos = <Producto>[
    const Producto(
      id: 't1',
      comercioId: 'demo-tienda',
      nombre: 'Pala Carbono Control',
      precio: 129.9,
      categoria: 'Palas',
    ),
    const Producto(
      id: 't2',
      comercioId: 'demo-tienda',
      nombre: 'Pack 3 pelotas',
      precio: 6.5,
      categoria: 'Pelotas',
    ),
  ];
  late final _pedidos = <Pedido>[
    Pedido(
      id: 'dp1',
      comercio: 'Tienda Demo',
      producto: 'Pack 3 pelotas',
      cantidad: 4,
      precioUnitario: 6.5,
      estado: EstadoPedido.pendiente,
      creado: DateTime.now().subtract(const Duration(hours: 3)),
      nota: 'Las recojo el sábado',
      solicitante: 'Lucía',
      email: 'lucia@ejemplo.es',
    ),
  ];
  int _n = 0;

  @override
  Future<Comercio> miTienda() async => _tienda;

  @override
  Future<List<Producto>> productos() async => [..._productos];

  @override
  Future<void> guardarProducto({
    String? id,
    required String nombre,
    required double precio,
    String? categoria,
    String? descripcion,
    String? imagenUrl,
  }) async {
    String? vacio(String? v) => (v?.trim().isEmpty ?? true) ? null : v!.trim();
    final p = Producto(
      id: id ?? 'nuevo${_n++}',
      comercioId: _tienda.id,
      nombre: nombre.trim(),
      precio: precio,
      categoria: vacio(categoria),
      descripcion: vacio(descripcion),
      imagenUrl: vacio(imagenUrl),
    );
    final i = _productos.indexWhere((x) => x.id == id);
    i == -1 ? _productos.add(p) : _productos[i] = p;
  }

  @override
  Future<void> eliminarProducto(String id) async =>
      _productos.removeWhere((p) => p.id == id);

  @override
  Future<List<Pedido>> pedidosRecibidos() async => [..._pedidos];

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) async {
    final i = _pedidos.indexWhere((p) => p.id == pedidoId);
    final p = _pedidos[i];
    if (p.estado.cerrado) {
      throw const StoreException('El pedido ya está cerrado.');
    }
    _pedidos[i] = Pedido(
      id: p.id,
      comercio: p.comercio,
      producto: p.producto,
      cantidad: p.cantidad,
      precioUnitario: p.precioUnitario,
      estado: estado,
      creado: p.creado,
      nota: p.nota,
      solicitante: p.solicitante,
      email: p.email,
    );
  }
}
