import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/tienda/tienda_repositorio.dart';

void main() {
  test('la tienda gestiona su catálogo', () async {
    final repo = TiendaDemo();
    final antes = (await repo.productos()).length;
    await repo.guardarProducto(
      nombre: ' Grip ',
      precio: 3.5,
      categoria: 'Accesorios',
    );
    var lista = await repo.productos();
    expect(lista.length, antes + 1);
    final nuevo = lista.firstWhere((p) => p.nombre == 'Grip');

    await repo.guardarProducto(id: nuevo.id, nombre: 'Grip Pro', precio: 4);
    lista = await repo.productos();
    expect(lista.length, antes + 1);
    expect(lista.firstWhere((p) => p.id == nuevo.id).precio, 4);

    await repo.eliminarProducto(nuevo.id);
    expect((await repo.productos()).length, antes);
  });

  test('la tienda responde a los pedidos recibidos', () async {
    final repo = TiendaDemo();
    final p = (await repo.pedidosRecibidos()).first;
    expect(p.estado, EstadoPedido.pendiente);
    await repo.cambiarEstado(p.id, EstadoPedido.confirmado);
    await repo.cambiarEstado(p.id, EstadoPedido.entregado);
    expect(
      (await repo.pedidosRecibidos()).first.estado,
      EstadoPedido.entregado,
    );
    expect(
      () => repo.cambiarEstado(p.id, EstadoPedido.rechazado),
      throwsA(isA<StoreException>()),
    );
  });
}
