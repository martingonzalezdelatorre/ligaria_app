import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/store/producto_page.dart';
import 'package:ligaria_friends/features/jugador/store/store_repositorio.dart';
import 'package:ligaria_friends/core/idioma.dart';

void main() {
  testWidgets('el detalle muestra nombre, descripción y precio', (t) async {
    const p = Producto(
      id: 'p1',
      comercioId: 'c1',
      nombre: 'Pala Test',
      precio: 99.5,
      categoria: 'Palas',
      descripcion: 'Una pala muy buena',
    );
    await t.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: ProductoPage(producto: p, repo: StoreDemo()),
      ),
    );
    expect(find.text('Pala Test'), findsWidgets);
    expect(find.text('Una pala muy buena'), findsOneWidget);
    expect(find.text('Palas'), findsOneWidget);
    expect(find.text('Solicitar'), findsOneWidget);
  });
}
