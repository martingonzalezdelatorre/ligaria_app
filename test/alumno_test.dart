import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/core/widgets.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/alumno/alumno_home.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

EncuentroVista enc(String id, String liga, String l, String v, {int jornada = 1, String estado = 'programado', int? pl, int? pv}) =>
    EncuentroVista(
        id: id, ligaId: liga, jornada: jornada, estado: estado, localId: 'id-$l', local: l, visitanteId: 'id-$v',
        visitante: v, partidosLocal: pl, partidosVisitante: pv);

FilaClasificacion fila(int pos, String id, String nombre, int pts) => FilaClasificacion(
    posicion: pos, equipoId: id, equipo: nombre, escuela: 'Escuela $nombre', pj: 1, pg: 1, pe: 0, pp: 0, puntos: pts,
    partidosF: 3, partidosC: 0, setsF: 6, setsC: 0, juegosF: 36, juegosC: 20);

Ficha ficha({required String id, required String relacion, DateTime? nac, String? nivel, String? mano}) =>
    Ficha(jugadorId: id, escuelaId: 'e1', escuela: 'Escuela A', nombre: 'Lucía', apellidos: 'García',
        fechaNacimiento: nac, nivel: nivel, manoDominante: mano, relacion: relacion);

late MockRepo repo;

Widget app() => ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: Scaffold(body: AlumnoHome())),
    );

void baseStubs({List<Liga>? ligas}) {
  when(() => repo.misLigas()).thenAnswer((_) async => ligas ?? const [Liga(id: 'l1', nombre: 'Liga 1', estado: 'en_curso')]);
  when(() => repo.misEquipos()).thenAnswer((_) async => const [
        MiEquipo(equipoId: 'id-Eq1', equipo: 'Eq1', escuelaId: 'e1', escuela: 'Escuela A', rol: 'alumno', ligaId: 'l1', liga: 'Liga 1'),
      ]);
  when(() => repo.encuentros(any())).thenAnswer((_) async => const []);
  when(() => repo.descansos(any())).thenAnswer((_) async => const []);
  when(() => repo.clasificacion(any())).thenAnswer((_) async => const []);
  when(() => repo.misFichas()).thenAnswer((_) async => const []);
}

void main() {
  setUp(() {
    repo = MockRepo();
  });

  testWidgets('el selector de ligas solo filtra la vista', (tester) async {
    baseStubs(ligas: const [
      Liga(id: 'l1', nombre: 'Liga 1', estado: 'en_curso'),
      Liga(id: 'l2', nombre: 'Liga 2', estado: 'en_curso'),
    ]);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [enc('a', 'l1', 'Aguilas', 'Bravos')]);
    when(() => repo.encuentros('l2')).thenAnswer((_) async => [enc('b', 'l2', 'Cobras', 'Delfines')]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    expect(find.text('Aguilas'), findsOneWidget);
    expect(find.text('Cobras'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Liga 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    expect(find.text('Cobras'), findsOneWidget);
    expect(find.text('Aguilas'), findsNothing);
    // solo filtra: no se ha escrito nada
    verifyNever(() => repo.registrarResultado(any(), any()));
  });

  testWidgets('con una sola liga no hay selector', (tester) async {
    baseStubs();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Liga 1'), findsOneWidget);
  });

  testWidgets('la clasificación se pinta con mis equipos y puntos', (tester) async {
    baseStubs();
    when(() => repo.clasificacion('l1')).thenAnswer((_) async => [fila(1, 'id-Eq1', 'Eq1', 3), fila(2, 'id-Eq2', 'Eq2', 0)]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clasificación'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(TablaClasificacion), matching: find.text('Eq1')), findsOneWidget);
    expect(find.text('Eq2'), findsOneWidget);
    expect(find.text('Escuela Eq1'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('resultados muestra solo confirmados con marcador', (tester) async {
    baseStubs();
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [
          enc('a', 'l1', 'Aguilas', 'Bravos', estado: 'finalizado', pl: 2, pv: 1),
          enc('b', 'l1', 'Cobras', 'Delfines', jornada: 2),
        ]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resultados'));
    await tester.pumpAndSettle();
    expect(find.text('2 - 1'), findsOneWidget);
    expect(find.text('Cobras'), findsNothing);
  });

  testWidgets('la ficha propia muestra nivel, mano dominante y edad', (tester) async {
    baseStubs();
    when(() => repo.misFichas()).thenAnswer((_) async =>
        [ficha(id: 'p1', relacion: 'propia', nac: DateTime(2000, 1, 1), nivel: 'Intermedio', mano: 'ZURDO')]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    expect(find.text('Escuela A · Mi ficha'), findsOneWidget);
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Zurdo/a'), findsOneWidget);
    expect(find.textContaining('1 ene 2000'), findsOneWidget);
    // ya no hay ajustes de privacidad ni consentimiento en la ficha
    expect(find.byKey(const Key('switch_foto')), findsNothing);
    expect(find.byKey(const Key('switch_consentimiento')), findsNothing);
  });

  testWidgets('el tutor ve la ficha de su tutelado y los datos vacíos se muestran con guion', (tester) async {
    baseStubs();
    when(() => repo.misFichas()).thenAnswer((_) async => [ficha(id: 'p2', relacion: 'tutor')]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    expect(find.text('Escuela A · Tutelado/a'), findsOneWidget);
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsWidgets);
    expect(find.text('Edad'), findsNothing);
  });
}
