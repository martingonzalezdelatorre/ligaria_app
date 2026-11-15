import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/store/store_repositorio.dart';

void main() {
  test(
    'reservar ocupa la hora, evita duplicados y se puede cancelar',
    () async {
      final repo = StoreDemo();
      final manana = DateTime.now().add(const Duration(days: 1));
      final inicio = DateTime(manana.year, manana.month, manana.day, 18);

      await repo.reservar('k1', inicio);
      expect(await repo.ocupadas('k1', inicio), {inicio});
      expect(await repo.ocupadas('k2', inicio), isEmpty);
      expect(() => repo.reservar('k1', inicio), throwsA(isA<StoreException>()));

      final mias = await repo.misReservas();
      expect(mias.single.club, 'Club Pádel Centro');
      await repo.cancelar(mias.single.id);
      expect(await repo.ocupadas('k1', inicio), isEmpty);
    },
  );

  test('no se reservan horas pasadas', () async {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    expect(
      () => StoreDemo().reservar(
        'k1',
        DateTime(ayer.year, ayer.month, ayer.day, 10),
      ),
      throwsA(isA<StoreException>()),
    );
  });

  test(
    'un pedido del jugador se puede cancelar solo mientras está pendiente',
    () async {
      final repo = StoreDemo();
      await repo.solicitar('p1', 2, nota: 'Talla M');
      final p = (await repo.misPedidos()).single;
      expect(p.total, closeTo(259.8, .001));
      await repo.cancelarPedido(p.id);
      expect((await repo.misPedidos()).single.estado, EstadoPedido.cancelado);
      expect(() => repo.cancelarPedido(p.id), throwsA(isA<StoreException>()));
    },
  );
}
