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

Ficha ficha({required String id, required String relacion, required DateTime nac, bool menor14 = false,
        bool consentimiento = false, Visibilidad vis = Visibilidad.soloEscuela}) =>
    Ficha(personaId: id, escuelaId: 'e1', escuela: 'Escuela A', nombre: 'Lucía', apellidos: 'García',
        fechaNacimiento: nac, visibilidad: vis, mostrarFoto: false, menor14: menor14, consentimiento: consentimiento,
        relacion: relacion);

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
  when(() => repo.accesosFicha(any())).thenAnswer((_) async => const []);
  when(() => repo.registrarAccesoFicha(any(), contexto: any(named: 'contexto'))).thenAnswer((_) async {});
}

void main() {
  setUp(() {
    repo = MockRepo();
    registerFallbackValue(Visibilidad.soloEscuela);
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
    verifyNever(() => repo.crearLiga(
        escuelaId: any(named: 'escuelaId'), temporadaId: any(named: 'temporadaId'),
        deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre')));
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
          enc('a', 'l1', 'Aguilas', 'Bravos', estado: 'confirmado', pl: 2, pv: 1),
          enc('b', 'l1', 'Cobras', 'Delfines', jornada: 2),
        ]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resultados'));
    await tester.pumpAndSettle();
    expect(find.text('2 - 1'), findsOneWidget);
    expect(find.text('Cobras'), findsNothing);
  });

  testWidgets('privacidad: al elegir «Iniciales» se llama al repositorio con los argumentos correctos', (tester) async {
    baseStubs();
    when(() => repo.misFichas()).thenAnswer((_) async => [ficha(id: 'p1', relacion: 'propia', nac: DateTime(2000, 1, 1))]);
    when(() => repo.actualizarPrivacidad(any(), any(), any())).thenAnswer((_) async {});
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciales'));
    await tester.pumpAndSettle();
    verify(() => repo.actualizarPrivacidad('p1', Visibilidad.iniciales, false)).called(1);
    verifyNever(() => repo.registrarAccesoFicha(any(), contexto: any(named: 'contexto'))); // adulto: sin registro de acceso
  });

  testWidgets('tutor de un menor de 14: consentimiento, registro de acceso y accesos', (tester) async {
    baseStubs();
    final nac = DateTime.now().subtract(const Duration(days: 365 * 10));
    when(() => repo.misFichas()).thenAnswer((_) async => [ficha(id: 'p2', relacion: 'tutor', nac: nac, menor14: true)]);
    when(() => repo.registrarConsentimiento(any(), any())).thenAnswer((_) async {});
    when(() => repo.accesosFicha('p2')).thenAnswer((_) async => [AccesoMenor(fecha: DateTime(2026, 10, 3), contexto: 'ficha')]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    verify(() => repo.registrarAccesoFicha('p2', contexto: 'ficha')).called(1);
    expect(find.text('Accesos a la ficha'), findsOneWidget);
    expect(find.text('Falta el consentimiento: sin él no puede participar en equipos.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('switch_consentimiento')));
    await tester.pumpAndSettle();
    verify(() => repo.registrarConsentimiento('p2', true)).called(1);
  });

  testWidgets('alumno de 16 años no ve el interruptor de consentimiento y puede editar su privacidad', (tester) async {
    baseStubs();
    final nac = DateTime.now().subtract(const Duration(days: 365 * 16));
    when(() => repo.misFichas()).thenAnswer((_) async => [ficha(id: 'p3', relacion: 'propia', nac: nac)]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('switch_consentimiento')), findsNothing);
    expect(find.text('Consentimiento del tutor'), findsNothing);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('switch_foto'))).onChanged, isNotNull);
  });

  testWidgets('menor de 14 viendo su propia ficha: controles deshabilitados y sin interruptor de consentimiento', (tester) async {
    baseStubs();
    final nac = DateTime.now().subtract(const Duration(days: 365 * 10));
    when(() => repo.misFichas()).thenAnswer((_) async => [ficha(id: 'p4', relacion: 'propia', nac: nac, menor14: true)]);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucía García'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('switch_consentimiento')), findsNothing);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('switch_foto'))).onChanged, isNull);
  });
}
