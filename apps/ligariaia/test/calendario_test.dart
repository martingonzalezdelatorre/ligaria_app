import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/core/idioma.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/calendario/calendario.dart';
import 'package:ligariaia/features/entrenador/entrenos_tab.dart';
import 'package:ligariaia/features/partido/detalle_partido_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

late MockRepo repo;

Widget envuelve(Widget home) => ProviderScope(
  overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
  child: MaterialApp(
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    locale: const Locale('es'),
    home: Scaffold(body: home),
  ),
);

DateTime manana(int h, int m) {
  final d = DateTime.now().add(const Duration(days: 1));
  return DateTime(d.year, d.month, d.day, h, m);
}

EncuentroVista partido({DateTime? fecha, bool conHora = true}) =>
    EncuentroVista(
      id: 'e1',
      ligaId: 'l1',
      jornada: 3,
      estado: 'programado',
      localId: 'id-Eq1',
      local: 'Águilas',
      visitanteId: 'id-Eq2',
      visitante: 'Bravos',
      fecha: fecha ?? manana(18, 30),
      conHora: conHora,
      sede: 'Polideportivo Norte',
      pista: 'Pista 3',
    );

void main() {
  setUp(() {
    repo = MockRepo();
    when(() => repo.misEquipos()).thenAnswer(
      (_) async => const [
        MiEquipo(
          equipoId: 'id-Eq1',
          equipo: 'Águilas',
          escuelaId: 'o1',
          escuela: 'Escuela A',
          rol: 'alumno',
          ligaId: 'l1',
          liga: 'Liga 1',
        ),
      ],
    );
    when(() => repo.encuentros('l1')).thenAnswer(
      (_) async => [
        partido(),
        // un partido ajeno a mis equipos no sale en mi calendario
        EncuentroVista(
          id: 'e2',
          ligaId: 'l1',
          jornada: 3,
          estado: 'programado',
          localId: 'id-X',
          local: 'Cobras',
          visitanteId: 'id-Y',
          visitante: 'Delfines',
          fecha: manana(10, 0),
          conHora: true,
        ),
      ],
    );
    when(() => repo.misEntrenos()).thenAnswer(
      (_) async => [
        Entreno(
          id: 't1',
          equipoId: 'id-Eq1',
          equipo: 'Águilas',
          fecha: manana(17, 0),
          duracionMin: 90,
          lugar: 'Pista 1',
          notas: 'Traer palas',
        ),
      ],
    );
    when(() => repo.detalleEncuentro('e1')).thenAnswer(
      (_) async => const DetalleEncuentro(
        partidos: [
          PartidoDetalle(
            orden: 1,
            tipo: 'individual',
            local: ['Ana Pérez'],
            visitante: ['Leo G.'],
          ),
        ],
      ),
    );
    when(() => repo.jugadores(any())).thenAnswer((_) async => const []);
  });

  testWidgets('el calendario muestra entrenos y partidos con fecha, hora y lugar', (
    tester,
  ) async {
    await tester.pumpWidget(envuelve(const CalendarioTab()));
    await tester.pumpAndSettle();

    // entreno: hora, duración, lugar y notas
    expect(find.text('Entreno'), findsOneWidget);
    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('90 min'), findsOneWidget);
    expect(find.text('Pista 1'), findsOneWidget);
    expect(find.text('Traer palas'), findsOneWidget);
    // partido: hora, lugar y los dos equipos; el ajeno no aparece
    expect(find.text('Partido'), findsOneWidget);
    expect(find.text('18:30'), findsOneWidget);
    expect(find.text('Polideportivo Norte · Pista 3'), findsOneWidget);
    expect(find.text('Águilas'), findsNWidgets(2)); // entreno y partido
    expect(find.text('Bravos'), findsOneWidget);
    expect(find.text('Cobras'), findsNothing);
    // «Mañana» agrupa los dos
    expect(find.text('MAÑANA'), findsOneWidget);
    // el entreno (17:00) va antes que el partido (18:30)
    expect(
      tester.getTopLeft(find.text('17:00')).dy,
      lessThan(tester.getTopLeft(find.text('18:30')).dy),
    );
  });

  testWidgets('sin entrenos ni partidos se explica', (tester) async {
    when(() => repo.misEntrenos()).thenAnswer((_) async => const []);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(envuelve(const CalendarioTab()));
    await tester.pumpAndSettle();
    expect(
      find.text('Aún no hay entrenos ni partidos en tu calendario.'),
      findsOneWidget,
    );
  });

  testWidgets('si fallan los entrenos, los partidos se siguen viendo', (
    tester,
  ) async {
    when(() => repo.misEntrenos()).thenThrow(Exception('sin vista'));
    await tester.pumpWidget(envuelve(const CalendarioTab()));
    await tester.pumpAndSettle();
    expect(find.text('Bravos'), findsOneWidget);
    expect(find.text('Entreno'), findsNothing);
  });

  testWidgets('tocar un partido abre su detalle: jugadores, fecha, hora y lugar', (
    tester,
  ) async {
    await tester.pumpWidget(envuelve(const CalendarioTab()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bravos'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle del partido'), findsOneWidget);
    // equipos y jugadores arriba
    expect(find.text('Águilas'), findsOneWidget);
    expect(find.text('Bravos'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsWidgets);
    expect(find.text('Leo G.'), findsWidgets);
    // fecha y hora, y lugar
    expect(find.text('Mañana · 18:30'), findsOneWidget);
    expect(find.text('Polideportivo Norte · Pista 3'), findsOneWidget);
    // los jugadores quedan por encima de la fecha
    expect(
      tester.getTopLeft(find.text('Ana Pérez').first).dy,
      lessThan(tester.getTopLeft(find.text('Fecha y hora')).dy),
    );
  });

  testWidgets('un partido sin hora ni lugar lo indica', (tester) async {
    when(() => repo.detalleEncuentro('e1')).thenAnswer(
      (_) async => const DetalleEncuentro(partidos: []),
    );
    final e = EncuentroVista(
      id: 'e1',
      ligaId: 'l1',
      jornada: 1,
      estado: 'programado',
      localId: 'id-Eq1',
      local: 'Águilas',
      visitanteId: 'id-Eq2',
      visitante: 'Bravos',
      fecha: manana(0, 0),
    );
    await tester.pumpWidget(envuelve(DetallePartidoPage(encuentro: e)));
    await tester.pumpAndSettle();
    expect(find.text('Mañana · Hora por confirmar'), findsOneWidget);
    expect(find.text('Lugar por confirmar'), findsOneWidget);
    expect(
      find.text('La alineación se conocerá cuando el entrenador la registre.'),
      findsOneWidget,
    );
  });

  testWidgets('el entrenador asigna un entreno a su equipo', (tester) async {
    when(() => repo.misEntrenos()).thenAnswer((_) async => const []);
    when(() => repo.misEquipos()).thenAnswer(
      (_) async => const [
        MiEquipo(
          equipoId: 'id-Eq1',
          equipo: 'Águilas',
          escuelaId: 'o1',
          escuela: 'Escuela A',
          rol: 'entrenador',
          ligaId: 'l1',
          liga: 'Liga 1',
        ),
      ],
    );
    when(
      () => repo.crearEntreno(
        any(),
        any(),
        duracionMin: any(named: 'duracionMin'),
        lugar: any(named: 'lugar'),
        notas: any(named: 'notas'),
      ),
    ).thenAnswer((_) async {});
    await tester.pumpWidget(envuelve(const EntrenosTab()));
    await tester.pumpAndSettle();
    expect(
      find.text('Aún no has asignado entrenos a tus equipos.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('nuevo-entreno')));
    await tester.pumpAndSettle();
    // sin fecha no se guarda
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verifyNever(
      () => repo.crearEntreno(
        any(),
        any(),
        duracionMin: any(named: 'duracionMin'),
        lugar: any(named: 'lugar'),
        notas: any(named: 'notas'),
      ),
    );
    expect(find.text('Elige la fecha y la hora.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('entreno-fecha')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entreno-lugar')), 'Pista 2');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verify(
      () => repo.crearEntreno(
        'id-Eq1',
        any(),
        duracionMin: 60,
        lugar: 'Pista 2',
        notas: '',
      ),
    ).called(1);
    expect(find.text('Entreno asignado.'), findsOneWidget);
  });
}
