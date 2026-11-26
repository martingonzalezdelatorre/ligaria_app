import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ligariaia/core/idioma.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/organizador/crear_liga_page.dart';
import 'package:ligariaia/features/organizador/liga_detalle_page.dart';
import 'package:ligariaia/features/organizador/organizador_home.dart';

class MockRepo extends Mock implements LigaRepository {}

Liga _liga(String id, String estado) => Liga(
  id: id,
  nombre: 'Liga $id',
  estado: estado,
  deporte: 'Tenis',
  deporteId: 'TENIS',
  tipo: 'MUNICIPAL',
);

InscripcionVista _insc(String liga, String estado) => InscripcionVista(
  id: 'i-$liga-$estado',
  ligaId: liga,
  equipoId: 'eq1',
  equipo: 'Tenis A',
  escuelaId: 'esc1',
  escuela: 'Escuela A',
  estado: estado,
);

MockRepo _repo(
  List<Liga> ligas, {
  Map<String, List<InscripcionVista>> inscripciones = const {},
}) {
  final repo = MockRepo();
  when(() => repo.ligasOrganizadas('ay')).thenAnswer((_) async => ligas);
  when(() => repo.organizadoresOrg('ay')).thenAnswer((_) async => const []);
  for (final l in ligas) {
    when(
      () => repo.inscripciones(l.id),
    ).thenAnswer((_) async => inscripciones[l.id] ?? const []);
    when(() => repo.encuentros(l.id)).thenAnswer((_) async => const []);
    when(() => repo.clasificacion(l.id)).thenAnswer((_) async => const []);
  }
  return repo;
}

Future<void> _abrir(
  WidgetTester tester,
  MockRepo repo, {
  bool coorganizador = false,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: OrganizadorHome(
            escuelaId: 'ay',
            escuelaNombre: 'Ayuntamiento',
            orgTipo: 'AYUNTAMIENTO',
            coorganizador: coorganizador,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _tarjeta = find.byKey(const Key('primeros-pasos'));
Finder _paso(String clave) => find.byKey(Key('paso-$clave'));
Finder _hecho(String clave) => find.descendant(
  of: _paso(clave),
  matching: find.byIcon(Icons.check_circle),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'organización nueva: guía abierta con los cuatro pasos pendientes',
    (tester) async {
      await _abrir(tester, _repo(const []));
      expect(_tarjeta, findsOneWidget);
      expect(find.text('0 de 4 completados'), findsOneWidget);
      expect(find.text('1. Crea tu primera liga'), findsOneWidget);
      expect(find.text('2. Ábrela a la inscripción'), findsOneWidget);
      expect(find.text('3. Reúne equipos'), findsOneWidget);
      expect(find.text('4. Genera el calendario'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    },
  );

  testWidgets('sin ligas, cualquier paso lleva a crear la primera', (
    tester,
  ) async {
    await _abrir(tester, _repo(const []));
    await tester.tap(_paso('calendario'));
    await tester.pumpAndSettle();
    expect(find.byType(CrearLigaPage), findsOneWidget);
  });

  testWidgets(
    'una liga en borrador completa solo el primer paso y el siguiente la abre',
    (tester) async {
      await _abrir(tester, _repo([_liga('l1', 'borrador')]));
      expect(find.text('1 de 4 completados'), findsOneWidget);
      // Con progreso la guía arranca plegada.
      await tester.tap(find.byKey(const Key('primeros-pasos-cabecera')));
      await tester.pumpAndSettle();
      expect(_hecho('crear'), findsOneWidget);
      expect(_hecho('publicar'), findsNothing);

      await tester.tap(_paso('publicar'));
      await tester.pumpAndSettle();
      final detalle = tester.widget<LigaDetallePage>(
        find.byType(LigaDetallePage),
      );
      expect(detalle.liga.id, 'l1');
    },
  );

  testWidgets('cada paso abre la liga que le corresponde', (tester) async {
    await _abrir(
      tester,
      _repo([_liga('publi', 'publicada'), _liga('borra', 'borrador')]),
    );
    await tester.tap(find.byKey(const Key('primeros-pasos-cabecera')));
    await tester.pumpAndSettle();
    await tester.tap(_paso('equipos'));
    await tester.pumpAndSettle();
    // «Reúne equipos» lleva a la liga ya publicada.
    expect(
      tester.widget<LigaDetallePage>(find.byType(LigaDetallePage)).liga.id,
      'publi',
    );

    // «Ábrela a la inscripción» lleva a la que sigue en borrador.
    Navigator.of(tester.element(find.byType(LigaDetallePage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(_paso('publicar'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LigaDetallePage>(find.byType(LigaDetallePage)).liga.id,
      'borra',
    );
  });

  testWidgets('publicada con un equipo aceptado: faltan solo las jornadas', (
    tester,
  ) async {
    await _abrir(
      tester,
      _repo(
        [_liga('l1', 'publicada')],
        inscripciones: {
          'l1': [_insc('l1', 'aceptada')],
        },
      ),
    );
    expect(find.text('3 de 4 completados'), findsOneWidget);
    await tester.tap(find.byKey(const Key('primeros-pasos-cabecera')));
    await tester.pumpAndSettle();
    expect(_hecho('equipos'), findsOneWidget);
    expect(_hecho('calendario'), findsNothing);
  });

  testWidgets(
    'una inscripción pendiente todavía no cuenta como equipo reunido',
    (tester) async {
      await _abrir(
        tester,
        _repo(
          [_liga('l1', 'publicada')],
          inscripciones: {
            'l1': [_insc('l1', 'pendiente'), _insc('l1', 'rechazada')],
          },
        ),
      );
      expect(find.text('2 de 4 completados'), findsOneWidget);
    },
  );

  testWidgets('si falla la consulta de inscripciones el paso queda pendiente', (
    tester,
  ) async {
    final repo = _repo([_liga('l1', 'publicada')]);
    when(() => repo.inscripciones('l1')).thenThrow(Exception('red'));
    await _abrir(tester, repo);
    expect(_tarjeta, findsOneWidget);
    expect(find.text('2 de 4 completados'), findsOneWidget);
  });

  testWidgets('con la liga en marcha todo está hecho y la guía desaparece', (
    tester,
  ) async {
    await _abrir(tester, _repo([_liga('l1', 'en_curso')]));
    expect(_tarjeta, findsNothing);
  });

  testWidgets('una liga cancelada no cuenta como publicada', (tester) async {
    await _abrir(tester, _repo([_liga('l1', 'cancelada')]));
    expect(find.text('1 de 4 completados'), findsOneWidget);
  });

  testWidgets('un co-organizador no ve la guía', (tester) async {
    await _abrir(tester, _repo([_liga('l1', 'borrador')]), coorganizador: true);
    expect(_tarjeta, findsNothing);
  });

  testWidgets('se puede ocultar y no vuelve a salir en esa organización', (
    tester,
  ) async {
    await _abrir(tester, _repo(const []));
    await tester.tap(find.byKey(const Key('primeros-pasos-ocultar')));
    await tester.pumpAndSettle();
    expect(_tarjeta, findsNothing);

    await tester.pumpWidget(const SizedBox());
    await _abrir(tester, _repo(const []));
    expect(_tarjeta, findsNothing);
  });
}
