import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/organizador/correccion_page.dart';
import 'package:ligaria_app/features/organizador/ligas_tab.dart';
import 'package:ligaria_app/features/organizador/organizador_home.dart';
import 'package:ligaria_app/features/organizador/crear_liga_page.dart';
import 'package:ligaria_app/features/organizador/resultado_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

const _enc = EncuentroVista(
  id: 'enc1', ligaId: 'l1', jornada: 2, estado: 'propuesto',
  localId: 'eqA', local: 'Tenis A', visitanteId: 'eqB', visitante: 'Tenis B',
  partidosLocal: 2, partidosVisitante: 1,
);

const _detalle = DetalleEncuentro(partidos: [
  PartidoDetalle(orden: 1, tipo: 'individual', local: ['Ana'], visitante: ['Pedro'], localIds: ['pl1'], visitanteIds: ['pv1'], sets: [[6, 3], [6, 4]]),
  PartidoDetalle(orden: 2, tipo: 'dobles', local: ['Ana', 'Eva'], visitante: ['Pedro', 'Leo'], localIds: ['pl1', 'pl2'], visitanteIds: ['pv1', 'pv2'], sets: [[3, 6], [4, 6]]),
]);

Widget _app(MockRepo repo, Widget home) => ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: home),
    );

void _alto(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  late MockRepo repo;

  setUpAll(() {
    registerFallbackValue(const ReglasLiga());
    registerFallbackValue(<String, dynamic>{});
  });
  setUp(() => repo = MockRepo());

  testWidgets('crear liga envía las reglas configuradas', (tester) async {
    _alto(tester);
    when(() => repo.temporadas()).thenAnswer((_) async => [
          Temporada(id: 't1', nombre: '2026-27', inicio: DateTime(2026, 9, 1), fin: DateTime(2027, 6, 30)),
        ]);
    when(() => repo.deportes()).thenAnswer((_) async => const [Deporte(id: 'd1', nombre: 'Tenis')]);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          escuelaId: any(named: 'escuelaId'), temporadaId: any(named: 'temporadaId'),
          deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'), reglas: any(named: 'reglas'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '  Liga infantil  ');
    await tester.tap(find.text('2 vueltas'));
    await tester.tap(find.byTooltip('Más Puntos por empate'));
    await tester.tap(find.byTooltip('Subir').at(1)); // «diferencia de partidos» sube al primer puesto
    await tester.pump();
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    final r = verify(() => repo.crearLiga(
          escuelaId: 'e1', temporadaId: 't1', deporteId: 'd1', nombre: 'Liga infantil',
          reglas: captureAny(named: 'reglas'),
        )).captured.single as ReglasLiga;
    expect(r.toJson(), const ReglasLiga(
      vueltas: 2, puntosEmpate: 2,
      desempates: ['diferencia_partidos', 'enfrentamiento_directo', 'diferencia_sets', 'diferencia_juegos'],
    ).toJson());
    expect(r.toJson()['partidos_por_encuentro'], {'individuales': 2, 'dobles': 1});
  });

  testWidgets('generar calendario llama al repo con la fecha elegida y avisa del nº de encuentros', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga infantil', estado: 'publicada', deporte: 'Tenis')]);
    when(() => repo.generarCalendario('l1', inicio: any(named: 'inicio'), diasEntreJornadas: any(named: 'diasEntreJornadas')))
        .thenAnswer((_) async => 15);

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    expect(find.text('Abierta a inscripción', findRichText: true), findsNothing); // el estado va junto al deporte
    expect(find.text('Tenis · Abierta a inscripción'), findsOneWidget);

    await tester.tap(find.text('Generar calendario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();

    final h = DateTime.now();
    verify(() => repo.generarCalendario('l1', inicio: DateTime(h.year, h.month, h.day), diasEntreJornadas: 7)).called(1);
    expect(find.text('Calendario generado: 15 encuentros.'), findsOneWidget);
  });

  testWidgets('generar calendario traduce los errores del servidor', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga', estado: 'en_curso')]);
    when(() => repo.generarCalendario('l1', inicio: any(named: 'inicio'), diasEntreJornadas: any(named: 'diasEntreJornadas')))
        .thenThrow(Exception('ya hay resultados propuestos o confirmados; no se puede regenerar'));

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar calendario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('no se puede regenerar el calendario'), findsOneWidget);
  });

  testWidgets('publicar una liga en borrador llama al repo', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga', estado: 'borrador')]);
    when(() => repo.publicarLiga('l1')).thenAnswer((_) async {});
    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    verify(() => repo.publicarLiga('l1')).called(1);
  });

  testWidgets('confirmar un resultado pendiente llama al repo', (tester) async {
    when(() => repo.detalleEncuentro('enc1')).thenAnswer((_) async => _detalle);
    when(() => repo.correcciones('enc1')).thenAnswer((_) async => const []);
    when(() => repo.confirmarResultado('enc1')).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const ResultadoPage(escuelaId: 'e1', encuentro: _enc)));
    await tester.pumpAndSettle();
    expect(find.text('6-3   ·   6-4'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    verify(() => repo.confirmarResultado('enc1')).called(1);
  });

  testWidgets('rechazar exige motivo y lo envía', (tester) async {
    when(() => repo.detalleEncuentro('enc1')).thenAnswer((_) async => _detalle);
    when(() => repo.correcciones('enc1')).thenAnswer((_) async => const []);
    when(() => repo.rechazarResultado('enc1', 'Faltan jugadores')).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const ResultadoPage(escuelaId: 'e1', encuentro: _enc)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar'));
    await tester.pump();
    expect(find.text('Indica el motivo'), findsOneWidget);
    verifyNever(() => repo.rechazarResultado(any(), any()));

    await tester.enterText(find.byType(TextField), 'Faltan jugadores');
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar'));
    await tester.pumpAndSettle();
    verify(() => repo.rechazarResultado('enc1', 'Faltan jugadores')).called(1);
  });

  testWidgets('corregir exige motivo y envía el JSON con los jugadores conservados', (tester) async {
    _alto(tester);
    when(() => repo.corregirResultado(any(), any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CorreccionPage(escuelaId: 'e1', encuentro: _enc, detalle: _detalle)));
    await tester.pumpAndSettle();

    // sin motivo: no se llama al repo
    await tester.ensureVisible(find.text('Guardar corrección'));
    await tester.tap(find.text('Guardar corrección'));
    await tester.pump();
    expect(find.text('Indica el motivo de la corrección'), findsOneWidget);
    verifyNever(() => repo.corregirResultado(any(), any(), any()));

    // se corrige el set 2 del partido 1 y se añade el motivo
    await tester.enterText(find.byKey(const ValueKey('Local P1 S2')), '3');
    await tester.enterText(find.byKey(const ValueKey('Visitante P1 S2')), '6');
    await tester.enterText(find.widgetWithText(TextField, 'Motivo de la corrección'), 'Acta mal pasada');
    await tester.ensureVisible(find.text('Guardar corrección'));
    await tester.tap(find.text('Guardar corrección'));
    await tester.pumpAndSettle();

    final c = verify(() => repo.corregirResultado('enc1', captureAny(), captureAny())).captured;
    expect(c[1], 'Acta mal pasada');
    expect(c[0], {
      'incomparecencia': null,
      'partidos': [
        {'orden': 1, 'local': ['pl1'], 'visitante': ['pv1'], 'sets': [[6, 3], [3, 6]]},
        {'orden': 2, 'local': ['pl1', 'pl2'], 'visitante': ['pv1', 'pv2'], 'sets': [[3, 6], [4, 6]]},
      ],
    });
  });

  testWidgets('corregir con incomparecencia envía el lado y ningún partido', (tester) async {
    _alto(tester);
    when(() => repo.corregirResultado(any(), any(), any())).thenAnswer((_) async {});
    await tester.pumpWidget(_app(repo, const CorreccionPage(escuelaId: 'e1', encuentro: _enc, detalle: _detalle)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('No se presenta Tenis A'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Motivo de la corrección'), 'No se presentó');
    await tester.ensureVisible(find.text('Guardar corrección'));
    await tester.tap(find.text('Guardar corrección'));
    await tester.pumpAndSettle();
    verify(() => repo.corregirResultado('enc1', {'incomparecencia': 'local', 'partidos': <Map<String, dynamic>>[]}, 'No se presentó')).called(1);
  });

  testWidgets('un set con empate se rechaza sin llamar al repo', (tester) async {
    _alto(tester);
    await tester.pumpWidget(_app(repo, const CorreccionPage(escuelaId: 'e1', encuentro: _enc, detalle: _detalle)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('Local P1 S1')), '6');
    await tester.enterText(find.byKey(const ValueKey('Visitante P1 S1')), '6');
    await tester.enterText(find.widgetWithText(TextField, 'Motivo de la corrección'), 'x');
    await tester.ensureVisible(find.text('Guardar corrección'));
    await tester.tap(find.text('Guardar corrección'));
    await tester.pump();
    expect(find.textContaining('Revisa los marcadores'), findsOneWidget);
    verifyNever(() => repo.corregirResultado(any(), any(), any()));
  });

  testWidgets('el área organizador muestra las tres pestañas y los pendientes', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.pendientes('e1')).thenAnswer((_) async => [_enc]);
    await tester.pumpWidget(_app(repo, const Scaffold(body: OrganizadorHome(escuelaId: 'e1', escuelaNombre: 'Escuela A'))));
    await tester.pumpAndSettle();
    expect(find.text('Ligas'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Correcciones'), findsOneWidget);
    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Tenis A'), findsOneWidget);
    expect(find.text('Pendiente de confirmar'), findsOneWidget);
  });
}
