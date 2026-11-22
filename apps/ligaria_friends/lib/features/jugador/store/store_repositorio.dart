import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/store_modelos.dart';
import '../../../core/idioma.dart';

export '../../compartido/store_modelos.dart';

/// Pista que un club alquila por hora.
class Pista {
  const Pista({
    required this.id,
    required this.comercioId,
    required this.nombre,
    required this.deporte,
    required this.precioHora,
    this.cubierta = false,
  });
  final String id, comercioId, nombre, deporte;
  final double precioHora;
  final bool cubierta;

  factory Pista.desdeFila(Map<String, dynamic> f) => Pista(
    id: f['id'] as String,
    comercioId: f['comercio_id'] as String,
    nombre: f['nombre'] as String,
    deporte: f['deporte'] as String,
    precioHora: (f['precio_hora'] as num).toDouble(),
    cubierta: (f['cubierta'] as bool?) ?? false,
  );
}

/// Reserva de una hora de pista hecha por el usuario.
class Reserva {
  const Reserva({
    required this.id,
    required this.pista,
    required this.club,
    required this.inicio,
    required this.precio,
  });
  final String id, pista, club;
  final DateTime inicio;
  final double precio;
  bool get futura => inicio.isAfter(DateTime.now());

  factory Reserva.desdeFila(Map<String, dynamic> f) {
    final p = f['pista'] as Map<String, dynamic>;
    final c = p['comercio'] as Map<String, dynamic>;
    return Reserva(
      id: f['id'] as String,
      pista: p['nombre'] as String,
      club: c['nombre'] as String,
      inicio: DateTime.parse(f['inicio'] as String).toLocal(),
      precio: (p['precio_hora'] as num).toDouble(),
    );
  }
}

/// Acceso a Store. [StoreSupabase] en producción, [StoreDemo] sin configuración.
abstract class StoreRepositorio {
  /// Lo fija `main()`; por defecto, datos de demostración.
  static StoreRepositorio instancia = StoreDemo();

  Future<List<Comercio>> comercios();
  Future<List<Producto>> productos(String comercioId);
  Future<List<Pista>> pistas(String comercioId);

  /// Inicios (hora en punto) ya reservados de [pista] durante el día de [dia].
  Future<Set<DateTime>> ocupadas(String pistaId, DateTime dia);

  Future<void> reservar(String pistaId, DateTime inicio);
  Future<List<Reserva>> misReservas();
  Future<void> cancelar(String reservaId);

  Future<void> solicitar(String productoId, int cantidad, {String? nota});
  Future<List<Pedido>> misPedidos();

  /// El cliente cancela un pedido que sigue pendiente.
  Future<void> cancelarPedido(String pedidoId);
}

class StoreSupabase implements StoreRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<List<Comercio>> comercios() => _traducir(() async {
    final filas = await _c.from('comercio').select().order('nombre');
    return filas.map(Comercio.desdeFila).toList();
  });

  @override
  Future<List<Producto>> productos(String comercioId) => _traducir(() async {
    final filas = await _c
        .from('producto')
        .select()
        .eq('comercio_id', comercioId)
        .order('nombre');
    return filas.map(Producto.desdeFila).toList();
  });

  @override
  Future<List<Pista>> pistas(String comercioId) => _traducir(() async {
    final filas = await _c
        .from('pista')
        .select()
        .eq('comercio_id', comercioId)
        .order('nombre');
    return filas.map(Pista.desdeFila).toList();
  });

  @override
  Future<Set<DateTime>> ocupadas(String pistaId, DateTime dia) =>
      _traducir(() async {
        final desde = DateTime(dia.year, dia.month, dia.day);
        final hasta = DateTime(dia.year, dia.month, dia.day + 1);
        final filas = await _c.rpc(
          'pistas_ocupadas',
          params: {
            'p_pista': pistaId,
            'p_desde': desde.toUtc().toIso8601String(),
            'p_hasta': hasta.toUtc().toIso8601String(),
          },
        );
        return {
          for (final f in filas as List) DateTime.parse(f as String).toLocal(),
        };
      });

  @override
  Future<void> reservar(String pistaId, DateTime inicio) => _traducir(
    () => _c.rpc(
      'reservar_pista',
      params: {
        'p_pista': pistaId,
        'p_inicio': inicio.toUtc().toIso8601String(),
      },
    ),
  );

  @override
  Future<List<Reserva>> misReservas() => _traducir(() async {
    final filas = await _c
        .from('reserva')
        .select('id, inicio, pista(nombre, precio_hora, comercio(nombre))')
        .order('inicio');
    return filas.map(Reserva.desdeFila).toList();
  });

  @override
  Future<void> cancelar(String reservaId) =>
      _traducir(() => _c.from('reserva').delete().eq('id', reservaId));

  @override
  Future<void> solicitar(String productoId, int cantidad, {String? nota}) =>
      _traducir(
        () => _c.rpc(
          'solicitar_pedido',
          params: {
            'p_producto': productoId,
            'p_cantidad': cantidad,
            'p_nota': nota,
          },
        ),
      );

  @override
  Future<List<Pedido>> misPedidos() => _traducir(() async {
    final filas = await _c
        .from('pedido')
        .select(
          'id, producto_nombre, cantidad, precio_unitario, nota, estado, '
          'created_at, comercio(nombre)',
        )
        .order('created_at', ascending: false);
    return filas.map(Pedido.desdeFila).toList();
  });

  @override
  Future<void> cancelarPedido(String pedidoId) => _traducir(
    () => _c.rpc(
      'cambiar_estado_pedido',
      params: {'p_pedido': pedidoId, 'p_estado': EstadoPedido.cancelado.codigo},
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

class StoreDemo implements StoreRepositorio {
  static const _comercios = [
    Comercio(
      id: 'c1',
      nombre: 'Pádel Pro Shop',
      tipo: TipoComercio.tienda,
      descripcion: 'Palas, ropa y accesorios de las mejores marcas.',
      ciudad: 'Madrid',
    ),
    Comercio(
      id: 'c2',
      nombre: 'Club Pádel Centro',
      tipo: TipoComercio.club,
      descripcion: 'Seis pistas de cristal, cuatro cubiertas.',
      ciudad: 'Madrid',
    ),
  ];
  static const _productos = [
    Producto(
      id: 'p1',
      comercioId: 'c1',
      nombre: 'Pala Carbono Control',
      precio: 129.9,
      categoria: 'Palas',
    ),
    Producto(
      id: 'p2',
      comercioId: 'c1',
      nombre: 'Pack 3 pelotas',
      precio: 6.5,
      categoria: 'Pelotas',
    ),
    Producto(
      id: 'p3',
      comercioId: 'c1',
      nombre: 'Zapatillas Court',
      precio: 74.9,
      categoria: 'Calzado',
    ),
  ];
  static const _pistas = [
    Pista(
      id: 'k1',
      comercioId: 'c2',
      nombre: 'Pista 1',
      deporte: 'Pádel',
      precioHora: 24,
      cubierta: true,
    ),
    Pista(
      id: 'k2',
      comercioId: 'c2',
      nombre: 'Pista 2',
      deporte: 'Pádel',
      precioHora: 20,
    ),
  ];

  @override
  Future<List<Comercio>> comercios() async => _comercios;

  @override
  Future<List<Producto>> productos(String comercioId) async => [
    for (final p in _productos)
      if (p.comercioId == comercioId) p,
  ];

  @override
  Future<List<Pista>> pistas(String comercioId) async => [
    for (final p in _pistas)
      if (p.comercioId == comercioId) p,
  ];

  // pistaId -> inicios reservados (por cualquiera); ids de las reservas propias.
  final _reservas = <({String id, String pistaId, DateTime inicio})>[];
  int _n = 0;

  @override
  Future<Set<DateTime>> ocupadas(String pistaId, DateTime dia) async => {
    for (final r in _reservas)
      if (r.pistaId == pistaId &&
          r.inicio.year == dia.year &&
          r.inicio.month == dia.month &&
          r.inicio.day == dia.day)
        r.inicio,
  };

  @override
  Future<void> reservar(String pistaId, DateTime inicio) async {
    if (!inicio.isAfter(DateTime.now())) {
      throw StoreException(l10nActual.errReservaPasada);
    }
    if (_reservas.any((r) => r.pistaId == pistaId && r.inicio == inicio)) {
      throw StoreException(l10nActual.errHoraReservada);
    }
    _reservas.add((id: 'r${_n++}', pistaId: pistaId, inicio: inicio));
  }

  @override
  Future<List<Reserva>> misReservas() async {
    final ordenadas = [..._reservas]
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return [
      for (final r in ordenadas)
        () {
          final p = _pistas.firstWhere((p) => p.id == r.pistaId);
          final c = _comercios.firstWhere((c) => c.id == p.comercioId);
          return Reserva(
            id: r.id,
            pista: p.nombre,
            club: c.nombre,
            inicio: r.inicio,
            precio: p.precioHora,
          );
        }(),
    ];
  }

  @override
  Future<void> cancelar(String reservaId) async =>
      _reservas.removeWhere((r) => r.id == reservaId);

  final _pedidos = <Pedido>[];
  int _np = 0;

  @override
  Future<void> solicitar(
    String productoId,
    int cantidad, {
    String? nota,
  }) async {
    final p = _productos.firstWhere((p) => p.id == productoId);
    final c = _comercios.firstWhere((c) => c.id == p.comercioId);
    _pedidos.insert(
      0,
      Pedido(
        id: 'ped${_np++}',
        comercio: c.nombre,
        producto: p.nombre,
        cantidad: cantidad,
        precioUnitario: p.precio,
        estado: EstadoPedido.pendiente,
        creado: DateTime.now(),
        nota: (nota?.trim().isEmpty ?? true) ? null : nota!.trim(),
      ),
    );
  }

  @override
  Future<List<Pedido>> misPedidos() async => [..._pedidos];

  @override
  Future<void> cancelarPedido(String pedidoId) async {
    final i = _pedidos.indexWhere((p) => p.id == pedidoId);
    final p = _pedidos[i];
    if (p.estado != EstadoPedido.pendiente) {
      throw StoreException(l10nActual.errSoloPendientes);
    }
    _pedidos[i] = Pedido(
      id: p.id,
      comercio: p.comercio,
      producto: p.producto,
      cantidad: p.cantidad,
      precioUnitario: p.precioUnitario,
      estado: EstadoPedido.cancelado,
      creado: p.creado,
      nota: p.nota,
    );
  }
}
