import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/core/cuadro.dart';
import 'package:ligariaia/data/models.dart';

EncuentroVista m(String id, String l, String v, int jornada, int llaves, int llave,
        {String estado = 'programado', int? pl, int? pv, String? categoria}) =>
    EncuentroVista(
        id: id, ligaId: 'l1', jornada: jornada, estado: estado, localId: 'id-$l', local: l, visitanteId: 'id-$v',
        visitante: v, partidosLocal: pl, partidosVisitante: pv, fase: 'eliminatoria', llaves: llaves, llave: llave,
        categoria: categoria);

Widget app(Widget hijo) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: hijo)));

void main() {
  void pantalla(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('un cuadro de 8 equipos dibuja cuartos, semifinales y final con sus marcadores', (tester) async {
    pantalla(tester);
    final encs = [
      m('1', 'A', 'H', 1, 4, 1, estado: 'finalizado', pl: 2, pv: 1),
      m('2', 'D', 'E', 1, 4, 2, estado: 'finalizado', pl: 0, pv: 3),
      m('3', 'B', 'G', 1, 4, 3),
      m('4', 'C', 'F', 1, 4, 4),
      m('5', 'A', 'E', 2, 2, 1),
    ];
    await tester.pumpWidget(app(CuadroEliminatoria(encuentros: encs)));

    expect(find.text('Cuartos de final'), findsOneWidget);
    expect(find.text('Semifinales'), findsOneWidget);
    expect(find.text('Final'), findsOneWidget);
    for (final e in ['A', 'H', 'D', 'E', 'B', 'G', 'C', 'F']) {
      expect(find.text(e), findsWidgets);
    }
    // marcadores solo en los encuentros jugados
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // la semifinal 2 y la final aún no tienen equipos
    expect(find.text('Por determinar'), findsNWidgets(4));
    // las llaves se dibujan entre columnas
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los pases directos ocupan su posición y el resto del cuadro aparece por determinar', (tester) async {
    pantalla(tester);
    // 5 equipos: 4 emparejamientos en la primera ronda, 3 son pases directos
    final encs = [m('1', 'T4', 'T5', 1, 4, 2)];
    const byes = [
      Descanso(jornada: 1, equipoId: 'id-T1', equipo: 'T1', llave: 1),
      Descanso(jornada: 1, equipoId: 'id-T2', equipo: 'T2', llave: 3),
      Descanso(jornada: 1, equipoId: 'id-T3', equipo: 'T3', llave: 4),
    ];
    await tester.pumpWidget(app(CuadroEliminatoria(encuentros: encs, byes: byes)));
    expect(find.text('Pase directo'), findsNWidgets(3));
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('T4'), findsOneWidget);
    // semifinales (2 casillas) y final (1 casilla): 3 × 2 filas
    expect(find.text('Por determinar'), findsNWidgets(6));
    // la casilla de T1 (llave 1) queda por encima de la de T4/T5 (llave 2)
    expect(tester.getTopLeft(find.text('T1')).dy, lessThan(tester.getTopLeft(find.text('T4')).dy));
  });

  testWidgets('pulsar un encuentro lo devuelve; los pases directos y los huecos no', (tester) async {
    pantalla(tester);
    EncuentroVista? pulsado;
    final encs = [m('1', 'A', 'B', 1, 2, 1), m('2', 'C', 'D', 1, 2, 2)];
    await tester.pumpWidget(app(CuadroEliminatoria(encuentros: encs, onTap: (e) => pulsado = e)));
    await tester.tap(find.text('C'));
    expect(pulsado?.id, '2');
    pulsado = null;
    await tester.tap(find.text('Por determinar').first); // la final todavía no existe
    expect(pulsado, isNull);
  });

  testWidgets('mis equipos se resaltan y el ganador se marca', (tester) async {
    pantalla(tester);
    final encs = [m('1', 'A', 'B', 1, 1, 1, estado: 'finalizado', pl: 1, pv: 2)];
    await tester.pumpWidget(app(CuadroEliminatoria(encuentros: encs, destacados: const {'id-A'})));
    final ganador = tester.widget<Text>(find.text('B'));
    final perdedor = tester.widget<Text>(find.text('A'));
    expect(ganador.style?.fontWeight, FontWeight.w800);
    expect(perdedor.style?.fontWeight, FontWeight.w800); // «A» es mío: va en negrita aunque pierda
    expect(find.text('Final'), findsOneWidget);
  });

  testWidgets('con varias categorías se dibuja un cuadro por categoría con su título', (tester) async {
    pantalla(tester);
    final encs = [
      m('1', 'A', 'B', 1, 1, 1, categoria: 'General'),
      m('2', 'C', 'D', 1, 1, 1, categoria: 'Sub-10'),
    ];
    await tester.pumpWidget(app(CuadrosEliminatoria(encuentros: encs)));
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Sub-10'), findsOneWidget);
    expect(find.text('Final'), findsNWidgets(2));
  });

  testWidgets('sin encuentros de eliminatoria no dibuja nada', (tester) async {
    await tester.pumpWidget(app(const CuadrosEliminatoria(encuentros: [])));
    expect(find.byType(CuadroEliminatoria), findsNothing);
  });

  testWidgets('el selector alterna entre llaves y lista', (tester) async {
    var cuadro = true;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: StatefulBuilder(
                builder: (_, set) => SelectorVistaCuadro(cuadro: cuadro, onCambio: (v) => set(() => cuadro = v))))));
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(cuadro, isFalse);
    await tester.tap(find.text('Llaves'));
    await tester.pumpAndSettle();
    expect(cuadro, isTrue);
  });
}
