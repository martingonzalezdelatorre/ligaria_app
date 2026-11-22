import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/core/idioma.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/organizador/liga_detalle_page.dart';
import 'package:ligariaia/features/organizador/resultado_page.dart';
import 'package:ligariaia/features/organizador/resumen_liga_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

EncuentroVista _enc(
  String id, {
  String estado = 'finalizado',
  int? pl = 2,
  int? pv = 1,
  String fase = 'liga',
  int jornada = 1,
  int? llaves,
  String local = 'A',
  String visitante = 'B',
}) => EncuentroVista(
  id: id,
  ligaId: 'l1',
  jornada: jornada,
  estado: estado,
  localId: local,
  local: local,
  visitanteId: visitante,
  visitante: visitante,
  partidosLocal: pl,
  partidosVisitante: pv,
  fase: fase,
  llaves: llaves,
  categoria: 'General',
);

FilaClasificacion _fila(int pos, String equipo) => FilaClasificacion(
  posicion: pos,
  equipoId: equipo,
  equipo: equipo,
  escuela: 'E',
  pj: 1,
  pg: 1,
  pe: 0,
  pp: 0,
  puntos: 3,
  partidosF: 2,
  partidosC: 1,
  setsF: 4,
  setsC: 2,
  juegosF: 20,
  juegosC: 10,
  categoria: 'General',
);

Widget _app(MockRepo repo, Widget home) => ProviderScope(
  overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
  child: MaterialApp(
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    locale: const Locale('es'),
    home: home,
  ),
);

void _alto(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  late MockRepo repo;
  setUp(() => repo = MockRepo());

  test(
    'resumen: campeón por clasificación solo con todos los partidos jugados',
    () {
      final r = resumenLiga([_enc('1')], [_fila(1, 'A'), _fila(2, 'B')]);
      expect(r.jugados, 1);
      expect(r.categorias.single.campeon, 'A');
      expect(r.categorias.single.subcampeon, 'B');
      final p = resumenLiga(
        [_enc('1'), _enc('2', estado: 'programado', pl: null, pv: null)],
        [_fila(1, 'A'), _fila(2, 'B')],
      );
      expect(p.pendientes, 1);
      expect(p.categorias.single.campeon, isNull);
    },
  );

  test('resumen: en eliminatoria el campeón es el ganador de la final', () {
    final r = resumenLiga([
      _enc('s', fase: 'eliminatoria', jornada: 1, llaves: 2),
      _enc(
        'f',
        fase: 'eliminatoria',
        jornada: 2,
        llaves: 1,
        local: 'C',
        visitante: 'D',
        pl: 0,
        pv: 3,
      ),
    ], const []);
    expect(r.categorias.single.campeon, 'D');
    expect(r.categorias.single.subcampeon, 'C');
  });

  testWidgets('programar un partido: sede, pista y estado aplazado', (
    tester,
  ) async {
    _alto(tester);
    final pendiente = _enc('p1', estado: 'programado', pl: null, pv: null);
    when(
      () => repo.detalleEncuentro('p1'),
    ).thenAnswer((_) async => const DetalleEncuentro(partidos: []));
    when(
      () => repo.programarEncuentro(
        any(),
        fechaHora: any(named: 'fechaHora'),
        sede: any(named: 'sede'),
        pista: any(named: 'pista'),
        estado: any(named: 'estado'),
      ),
    ).thenAnswer((_) async {});
    await tester.pumpWidget(
      _app(repo, ResultadoPage(escuelaId: 'e1', encuentro: pendiente)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('programar-partido')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('programar-sede')),
      'Polideportivo Norte',
    );
    await tester.enterText(find.byKey(const Key('programar-pista')), 'Pista 1');
    await tester.tap(find.byKey(const Key('programar-estado')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplazado').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verify(
      () => repo.programarEncuentro(
        'p1',
        fechaHora: null,
        sede: 'Polideportivo Norte',
        pista: 'Pista 1',
        estado: 'APLAZADO',
      ),
    ).called(1);
  });

  testWidgets('un partido jugado no se puede programar', (tester) async {
    _alto(tester);
    when(
      () => repo.detalleEncuentro('1'),
    ).thenAnswer((_) async => const DetalleEncuentro(partidos: []));
    await tester.pumpWidget(
      _app(repo, ResultadoPage(escuelaId: 'e1', encuentro: _enc('1'))),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('programar-partido')), findsNothing);
  });

  Future<void> abrirAjustes(WidgetTester tester, Liga liga) async {
    _alto(tester);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [_enc('1')]);
    when(
      () => repo.clasificacion('l1'),
    ).thenAnswer((_) async => [_fila(1, 'A'), _fila(2, 'B')]);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);
    when(() => repo.categorias('l1')).thenAnswer((_) async => const []);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => const []);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => [liga]);
    await tester.pumpWidget(
      _app(repo, LigaDetallePage(liga: liga, escuelaId: 'e1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
  }

  const enCurso = Liga(
    id: 'l1',
    nombre: 'Liga',
    estado: 'en_curso',
    organizationId: 'e1',
  );

  testWidgets('ajustes: desempates actuales y edición del orden', (
    tester,
  ) async {
    when(() => repo.fijarDesempate('l1', any())).thenAnswer((_) async {});
    await abrirAjustes(tester, enCurso);
    expect(
      find.text(
        '1. Diferencia de partidos\n2. Diferencia de sets\n3. Diferencia de juegos',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('editar-desempate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('desempate-DIF_SETS')));
    await tester.tap(find.byKey(const Key('desempate-ENFRENTAMIENTO')));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verify(
      () => repo.fijarDesempate('l1', [
        'DIF_PARTIDOS',
        'DIF_JUEGOS',
        'ENFRENTAMIENTO',
      ]),
    ).called(1);
  });

  testWidgets(
    'ajustes: finalizar la liga pide confirmación y muestra el resumen',
    (tester) async {
      when(() => repo.finalizarLiga('l1')).thenAnswer((_) async {});
      await abrirAjustes(tester, enCurso);
      await tester.scrollUntilVisible(
        find.byKey(const Key('finalizar-liga')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Partidos jugados: 1 de 1'), findsOneWidget);
      expect(find.text('Campeón: A'), findsOneWidget);
      await tester.tap(find.byKey(const Key('finalizar-liga')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmar-finalizar')));
      await tester.pumpAndSettle();
      verify(() => repo.finalizarLiga('l1')).called(1);
    },
  );

  testWidgets('ajustes: una liga finalizada se puede reabrir', (tester) async {
    when(() => repo.reabrirLiga('l1')).thenAnswer((_) async {});
    await abrirAjustes(
      tester,
      const Liga(
        id: 'l1',
        nombre: 'Liga',
        estado: 'finalizada',
        organizationId: 'e1',
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('reabrir-liga')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const Key('finalizar-liga')), findsNothing);
    await tester.tap(find.byKey(const Key('reabrir-liga')));
    await tester.pumpAndSettle();
    verify(() => repo.reabrirLiga('l1')).called(1);
  });

  testWidgets(
    'pantalla de resumen: progreso, campeón, clasificación y partidos',
    (tester) async {
      _alto(tester);
      when(() => repo.encuentros('l1')).thenAnswer(
        (_) async => [
          _enc('1'),
          _enc(
            '2',
            estado: 'aplazado',
            pl: null,
            pv: null,
            local: 'C',
            visitante: 'D',
          ),
        ],
      );
      when(
        () => repo.clasificacion('l1'),
      ).thenAnswer((_) async => [_fila(1, 'A'), _fila(2, 'B')]);
      when(() => repo.inscripciones('l1')).thenAnswer(
        (_) async => const [
          InscripcionVista(
            id: 'i1',
            ligaId: 'l1',
            equipoId: 'A',
            equipo: 'A',
            escuelaId: 'e',
            escuela: 'E',
            estado: 'aceptada',
          ),
          InscripcionVista(
            id: 'i2',
            ligaId: 'l1',
            equipoId: 'B',
            equipo: 'B',
            escuelaId: 'e',
            escuela: 'E',
            estado: 'aceptada',
          ),
          InscripcionVista(
            id: 'i3',
            ligaId: 'l1',
            equipoId: 'C',
            equipo: 'C',
            escuelaId: 'e',
            escuela: 'E',
            estado: 'pendiente',
          ),
        ],
      );
      when(
        () => repo.ligasOrganizadas('e1'),
      ).thenAnswer((_) async => [enCurso]);
      await tester.pumpWidget(
        _app(repo, const ResumenLigaPage(liga: enCurso, escuelaId: 'e1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Partidos jugados: 1 de 2'), findsOneWidget);
      expect(find.text('Equipos'), findsOneWidget);
      expect(find.byKey(const Key('kpi-equipos')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('kpi-equipos'))).data,
        '2',
      );
      expect(find.text('Aún sin campeón'), findsOneWidget); // queda un partido
      expect(find.text('Próximos partidos'), findsOneWidget);
      expect(find.text('C - D'), findsOneWidget);
      expect(find.text('A 2 - 1 B'), findsOneWidget);
      expect(find.byKey(const Key('finalizar-liga')), findsOneWidget);
    },
  );

  testWidgets('desde la pantalla de liga se abre el resumen', (tester) async {
    await abrirAjustes(tester, enCurso);
    await tester.tap(find.byKey(const Key('abrir-resumen')));
    await tester.pumpAndSettle();
    expect(find.text('Resumen de la liga'), findsOneWidget);
  });
}
