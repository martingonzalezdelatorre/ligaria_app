import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_ui/ligaria_ui.dart';

void main() {
  testWidgets('Cargando se pinta, anima y se libera sin errores', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: Cargando()))));
    expect(find.byType(Cargando), findsOneWidget);
    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 700));
    // Al quitarlo no debe quedar ningún ticker vivo.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });

  testWidgets('Cargando queda quieto con «reducir movimiento»', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Scaffold(body: Center(child: Cargando()))),
      ),
    );
    // Sin animación en marcha, pumpAndSettle termina en vez de agotar el tiempo.
    await tester.pumpAndSettle();
    expect(find.byType(Cargando), findsOneWidget);
  });

  testWidgets('PantallaCarga dice «Cargando Ligaria Friends» sobre fondo verde', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: temaOscuro(), home: const PantallaCarga(nombre: 'Ligaria Friends')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Cargando Ligaria Friends'), findsOneWidget);
    expect(find.byType(Cargando), findsOneWidget);
    // El fondo es el verde de la app, no el negro del tema.
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, verdeCargaOscuro);
  });

  testWidgets('PantallaCarga admite un mensaje propio', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: temaOscuro(),
        home: const PantallaCarga(nombre: 'Ligaria', mensaje: 'Preparando tu cuenta'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Preparando tu cuenta'), findsOneWidget);
  });

  testWidgets('AppCargaInicial funciona sin nada por encima', (tester) async {
    await tester.pumpWidget(const AppCargaInicial(nombre: 'Ligaria IA'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Cargando Ligaria IA'), findsOneWidget);
  });
}
