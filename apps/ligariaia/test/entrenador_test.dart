import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/entrenador/entrenador_home.dart';
import 'package:ligariaia/features/entrenador/resultado_form_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

EncuentroVista enc(String id, int jornada, String lid, String l, String vid, String v, {String estado = 'programado'}) =>
    EncuentroVista(
        id: id, ligaId: 'L1', jornada: jornada, estado: estado, localId: lid, local: l, visitanteId: vid, visitante: v);

Widget app(MockRepo repo, Widget home) => ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: Scaffold(body: home)),
    );

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  group('Próxima jornada', () {
    testWidgets('filtra los encuentros de mis equipos y muestra el estado', (tester) async {
      final repo = MockRepo();
      when(() => repo.misEquipos()).thenAnswer((_) async => const [
            MiEquipo(equipoId: 'A', equipo: 'Tenis A', escuelaId: 's', escuela: 'Escuela A', rol: 'entrenador', ligaId: 'L1', liga: 'Liga infantil'),
            MiEquipo(equipoId: 'Z', equipo: 'Otro', escuelaId: 's', escuela: 'Escuela A', rol: 'alumno', ligaId: 'L1', liga: 'Liga infantil'),
          ]);
      when(() => repo.jugadores(any())).thenAnswer((_) async => const [Jugador(jugadorId: 'p1', nombre: 'Ana', apellidos: 'López')]);
      when(() => repo.encuentros('L1')).thenAnswer((_) async => [
            enc('e1', 1, 'A', 'Tenis A', 'B', 'Tenis B', estado: 'finalizado'),
            enc('e2', 2, 'C', 'Tenis C', 'A', 'Tenis A', estado: 'programado'),
            enc('e3', 2, 'B', 'Tenis B', 'C', 'Tenis C'), // no es de mis equipos
            enc('e4', 3, 'Z', 'Otro', 'B', 'Tenis B'), // equipo en que solo soy jugador
          ]);
      await tester.pumpWidget(app(repo, const EntrenadorHome()));
      await tester.pumpAndSettle();

      // Mis equipos: solo el que entreno, con plantilla y liga
      expect(find.text('Tenis A'), findsOneWidget);
      expect(find.text('Otro'), findsNothing);
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Liga infantil'), findsOneWidget);

      await tester.tap(find.text('Próxima jornada'));
      await tester.pumpAndSettle();
      expect(find.text('Siguiente encuentro'), findsOneWidget);
      expect(find.text('Tenis C'), findsOneWidget); // solo e2; e3 (B vs C) filtrado
      expect(find.text('Tenis B'), findsOneWidget); // solo e1
      expect(find.text('Programado'), findsWidgets);
      expect(find.text('Finalizado'), findsOneWidget);
      expect(find.text('Otro'), findsNothing); // e4 filtrado
    });
  });

  group('Formulario rápido de resultado', () {
    late MockRepo repo;
    final e = enc('e1', 1, 'A', 'Local', 'B', 'Visita');

    setUp(() {
      repo = MockRepo();
      when(() => repo.detalleEncuentro('e1')).thenAnswer((_) async => const DetalleEncuentro(partidos: [
            PartidoDetalle(orden: 1, tipo: 'individual'),
            PartidoDetalle(orden: 2, tipo: 'individual'),
            PartidoDetalle(orden: 3, tipo: 'dobles'),
          ]));
      when(() => repo.jugadores('A')).thenAnswer((_) async => const [
            Jugador(jugadorId: 'j1', nombre: 'Uno', apellidos: ''),
            Jugador(jugadorId: 'j2', nombre: 'Dos', apellidos: ''),
            Jugador(jugadorId: 'j3', nombre: 'Tres', apellidos: ''),
          ]);
      when(() => repo.jugadores('B')).thenAnswer((_) async => const []); // el rival no se puede leer
      when(() => repo.registrarResultado(any(), any())).thenAnswer((_) async {});
    });

    Future<void> abrir(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: ResultadoFormPage(encuentro: e)),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> set(WidgetTester tester, int p, int s, String l, String v) async {
      await tester.enterText(find.byKey(Key('set-$p-$s-l')), l);
      await tester.enterText(find.byKey(Key('set-$p-$s-v')), v);
      await tester.pump();
    }

    testWidgets('construye el JSON correcto: jugadores preseleccionados, sets y partido sin jugar omitido', (tester) async {
      await abrir(tester);
      await set(tester, 0, 0, '6', '4');
      await tester.tap(find.byKey(const Key('mas-set-0')));
      await tester.pump();
      await set(tester, 0, 1, '6', '3');
      await set(tester, 1, 0, '3', '6');
      expect(find.text('Sets 2 - 0'), findsOneWidget); // marcador en vivo

      await tester.tap(find.text('Guardar resultado'));
      await tester.pumpAndSettle();

      final r = verify(() => repo.registrarResultado('e1', captureAny())).captured.single as Map<String, dynamic>;
      expect(r, {
        'incomparecencia': null,
        'partidos': [
          {'orden': 1, 'local': ['j1'], 'visitante': <String>[], 'sets': [[6, 4], [6, 3]]},
          {'orden': 2, 'local': ['j2'], 'visitante': <String>[], 'sets': [[3, 6]]},
        ],
      });
    });

    testWidgets('el dobles preselecciona dos jugadores distintos', (tester) async {
      await abrir(tester);
      await set(tester, 2, 0, '7', '5');
      await tester.tap(find.text('Guardar resultado'));
      await tester.pumpAndSettle();
      final r = verify(() => repo.registrarResultado('e1', captureAny())).captured.single as Map<String, dynamic>;
      final p = (r['partidos'] as List).single as Map<String, dynamic>;
      expect(p['orden'], 3);
      expect(p['local'], ['j3', 'j1']);
    });

    testWidgets('valida: sin sets y set empatado no se envían', (tester) async {
      await abrir(tester);
      await tester.tap(find.text('Guardar resultado'));
      await tester.pump();
      expect(find.text('Añade al menos un set para guardar el resultado.'), findsOneWidget);

      await set(tester, 0, 0, '6', '6');
      await tester.tap(find.text('Guardar resultado'));
      await tester.pump();
      expect(find.textContaining('no puede haber empate'), findsOneWidget);

      await set(tester, 0, 0, '6', '');
      await tester.tap(find.text('Guardar resultado'));
      await tester.pump();
      expect(find.textContaining('Completa los dos marcadores'), findsOneWidget);
      verifyNever(() => repo.registrarResultado(any(), any()));
    });

    testWidgets('incomparecencia: exige elegir equipo y envía el lado ausente', (tester) async {
      await abrir(tester);
      await tester.tap(find.text('Incomparecencia'));
      await tester.pump();
      expect(find.byKey(const Key('set-0-0-l')), findsNothing); // oculta el resto

      await tester.tap(find.text('Guardar resultado'));
      await tester.pump();
      expect(find.text('Indica qué equipo no se presentó.'), findsOneWidget);

      await tester.tap(find.text('No se presenta Visita'));
      await tester.pump();
      await tester.tap(find.text('Guardar resultado'));
      await tester.pumpAndSettle();
      final r = verify(() => repo.registrarResultado('e1', captureAny())).captured.single as Map<String, dynamic>;
      expect(r, {'incomparecencia': 'visitante', 'partidos': <Map<String, dynamic>>[]});
    });

    testWidgets('si el servidor rechaza, muestra un mensaje claro y no cierra', (tester) async {
      when(() => repo.registrarResultado(any(), any()))
          .thenAnswer((_) async => throw Exception('el resultado ya está registrado; solicita una corrección'));
      await abrir(tester);
      await set(tester, 0, 0, '6', '4');
      await tester.tap(find.text('Guardar resultado'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ya está registrado'), findsOneWidget);
      expect(find.byType(ResultadoFormPage), findsOneWidget);
    });

    testWidgets('precarga un resultado ya registrado', (tester) async {
      when(() => repo.detalleEncuentro('e1')).thenAnswer((_) async => const DetalleEncuentro(partidos: [
            PartidoDetalle(orden: 1, tipo: 'individual', local: ['Uno'], localIds: ['j1'], sets: [[6, 2], [6, 1]]),
          ]));
      await abrir(tester);
      expect(find.text('Sets 2 - 0'), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('set-0-0-l'))).controller!.text, '6');
    });
  });
}
