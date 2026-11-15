/// Modelos de Store compartidos por los perfiles Jugador y Tienda.
/// No dependen de ninguna pantalla ni de Supabase.

/// Importe en euros con coma decimal.
String euros(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

enum TipoComercio {
  tienda('TIENDA', 'Tiendas'),
  club('CLUB', 'Clubs');

  const TipoComercio(this.codigo, this.plural);
  final String codigo, plural;

  static TipoComercio desde(String c) =>
      values.firstWhere((t) => t.codigo == c, orElse: () => tienda);
}

/// Empresa que anuncia en Store: una tienda de material o un club que alquila pistas.
class Comercio {
  const Comercio({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.descripcion,
    this.ciudad,
  });
  final String id, nombre;
  final TipoComercio tipo;
  final String? descripcion, ciudad;

  factory Comercio.desdeFila(Map<String, dynamic> f) => Comercio(
    id: f['id'] as String,
    nombre: f['nombre'] as String,
    tipo: TipoComercio.desde(f['tipo'] as String),
    descripcion: f['descripcion'] as String?,
    ciudad: f['ciudad'] as String?,
  );
}

/// Producto en venta de una tienda.
class Producto {
  const Producto({
    required this.id,
    required this.comercioId,
    required this.nombre,
    required this.precio,
    this.categoria,
    this.descripcion,
    this.imagenUrl,
  });
  final String id, comercioId, nombre;
  final double precio;
  final String? categoria, descripcion, imagenUrl;

  factory Producto.desdeFila(Map<String, dynamic> f) => Producto(
    id: f['id'] as String,
    comercioId: f['comercio_id'] as String,
    nombre: f['nombre'] as String,
    precio: (f['precio'] as num).toDouble(),
    categoria: f['categoria'] as String?,
    descripcion: f['descripcion'] as String?,
    imagenUrl: f['imagen_url'] as String?,
  );
}

enum EstadoPedido {
  pendiente('PENDIENTE', 'Pendiente'),
  confirmado('CONFIRMADO', 'Confirmado'),
  rechazado('RECHAZADO', 'Rechazado'),
  entregado('ENTREGADO', 'Entregado'),
  cancelado('CANCELADO', 'Cancelado');

  const EstadoPedido(this.codigo, this.texto);
  final String codigo, texto;

  static EstadoPedido desde(String c) =>
      values.firstWhere((e) => e.codigo == c, orElse: () => pendiente);

  /// Cerrado: ya no admite más cambios.
  bool get cerrado =>
      this == rechazado || this == entregado || this == cancelado;
}

/// Solicitud de un producto a una tienda. [solicitante] solo lo ve la tienda.
class Pedido {
  const Pedido({
    required this.id,
    required this.comercio,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.estado,
    required this.creado,
    this.nota,
    this.solicitante,
    this.email,
  });
  final String id, comercio, producto;
  final int cantidad;
  final double precioUnitario;
  final EstadoPedido estado;
  final DateTime creado;
  final String? nota, solicitante, email;
  double get total => precioUnitario * cantidad;

  factory Pedido.desdeFila(Map<String, dynamic> f) => Pedido(
    id: f['id'] as String,
    comercio:
        (f['comercio_nombre'] ?? (f['comercio'] as Map?)?['nombre']) as String,
    producto: f['producto_nombre'] as String,
    cantidad: (f['cantidad'] as num).toInt(),
    precioUnitario: (f['precio_unitario'] as num).toDouble(),
    estado: EstadoPedido.desde(f['estado'] as String),
    creado: DateTime.parse(f['created_at'] as String).toLocal(),
    nota: f['nota'] as String?,
    solicitante: f['solicitante_nombre'] as String?,
    email: f['solicitante_email'] as String?,
  );
}

class StoreException implements Exception {
  const StoreException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}
