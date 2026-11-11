import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/core/auth.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/escuela/escuela_home.dart';
import 'package:ligaria_app/features/escuela/escuela_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

final persona = PersonaLite(id: 'p1', nombre: 'Ana', apellidos: 'López', fechaNacimiento: DateTime(2015, 3, 5));

MockRepo repoBase() {
  final repo = MockRepo();
  when(() => repo.usuarios('esc1')).thenAnswer((_) async => const []);
  when(() => repo.personas('esc1')).thenAnswer((_) async => [persona]);
  when(() => repo.equipos('esc1')).thenAnswer((_) async => const []);
  when(() => repo.ligasAbiertas()).thenAnswer((_) async => const []);
  when(() => repo.deportes()).thenAnswer((_) async => const []);
  return repo;
}

Future<void> abrir(WidgetTester tester, MockRepo repo) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: Scaffold(body: EscuelaHome(escuelaId: 'esc1', escuelaNombre: 'Escuela A'))),
  ));
  await tester.pumpAndSettle();
}

Finder enDialogo(Finder f) => find.descendant(of: find.byType(AlertDialog), matching: f);

void main() {
  test('mensajeErrorEscuela traduce los errores conocidos', () {
    expect(mensajeErrorEscuela(Exception('menor de 14 años sin consentimiento del tutor')), 'Falta el consentimiento del tutor.');
    expect(mensajeErrorEscuela(Exception('el deporte del equipo no coincide con la competición')),
        'El deporte del equipo no coincide con el de la liga.');
    expect(mensajeErrorEscuela(Exception('algo raro con stack trace')), isNot(contains('stack')));
  });

  test('parseFecha valida dd/mm/aaaa', () {
    expect(parseFecha('05/03/2015'), DateTime(2015, 3, 5));
    expect(parseFecha('31/02/2015'), isNull);
    expect(parseFecha('2015-03-05'), isNull);
  });

  testWidgets('invitar a un entrenador llama a repo.invitar con el rol correcto', (tester) async {
    final repo = repoBase();
    when(() => repo.invitar('esc1', 'coach@x.es', Rol.entrenador, personaId: null)).thenAnswer((_) async {});
    await abrir(tester, repo);

    await tester.tap(find.text('Invitar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invitar-email')), 'coach@x.es');
    await tester.tap(enDialogo(find.text('Invitar')).last);
    await tester.pumpAndSettle();

    verify(() => repo.invitar('esc1', 'coach@x.es', Rol.entrenador, personaId: null)).called(1);
    expect(find.text('Invitación enviada.'), findsOneWidget);
  });

  testWidgets('invitar a un tutor exige elegir persona y la envía', (tester) async {
    final repo = repoBase();
    when(() => repo.invitar('esc1', 'madre@x.es', Rol.tutor, personaId: 'p1')).thenAnswer((_) async {});
    await abrir(tester, repo);

    await tester.tap(find.text('Invitar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invitar-email')), 'madre@x.es');
    await tester.tap(find.byKey(const Key('invitar-rol')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutor').last);
    await tester.pumpAndSettle();

    await tester.tap(enDialogo(find.text('Invitar')).last);
    await tester.pumpAndSettle();
    expect(find.text('Elige una persona'), findsOneWidget);

    await tester.tap(find.byKey(const Key('invitar-persona')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana López').last);
    await tester.pumpAndSettle();
    await tester.tap(enDialogo(find.text('Invitar')).last);
    await tester.pumpAndSettle();

    verify(() => repo.invitar('esc1', 'madre@x.es', Rol.tutor, personaId: 'p1')).called(1);
  });

  testWidgets('crear persona: valida la fecha y llama a repo.crearPersona', (tester) async {
    final repo = repoBase();
    when(() => repo.crearPersona('esc1', 'Luis', 'Pérez', DateTime(2014, 9, 1))).thenAnswer((_) async {});
    await abrir(tester, repo);

    await tester.tap(find.text('Jugadores y tutores'));
    await tester.pumpAndSettle();
    expect(find.text('Ana López'), findsOneWidget);
    expect(find.textContaining('Menor de 14'), findsOneWidget);

    await tester.tap(find.text('Nueva persona'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('persona-nombre')), 'Luis');
    await tester.enterText(find.byKey(const Key('persona-apellidos')), 'Pérez');
    await tester.enterText(find.byKey(const Key('persona-fecha')), '99/99/2014');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Fecha no válida'), findsOneWidget);
    verifyNever(() => repo.crearPersona(any(), any(), any(), any()));

    await tester.enterText(find.byKey(const Key('persona-fecha')), '01/09/2014');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verify(() => repo.crearPersona('esc1', 'Luis', 'Pérez', DateTime(2014, 9, 1))).called(1);
  });

  testWidgets('añadir un menor de 14 sin consentimiento muestra un mensaje claro', (tester) async {
    final repo = repoBase();
    when(() => repo.equipos('esc1')).thenAnswer((_) async => const [EquipoLite(id: 'eq1', nombre: 'Sub12', deporteId: 'tenis')]);
    when(() => repo.jugadores('eq1')).thenAnswer((_) async => const []);
    when(() => repo.anadirJugador('eq1', 'esc1', 'p1'))
        .thenAnswer((_) async => throw Exception('menor de 14 años sin consentimiento del tutor'));
    await abrir(tester, repo);

    await tester.tap(find.text('Equipos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sub12'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('anadir-jugador')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana López').last);
    await tester.pumpAndSettle();

    expect(find.text('Falta el consentimiento del tutor.'), findsOneWidget);
  });

  testWidgets('inscribir en una liga solo ofrece equipos del mismo deporte', (tester) async {
    final repo = repoBase();
    when(() => repo.ligasAbiertas()).thenAnswer((_) async => const [
          LigaAbierta(id: 'L1', nombre: 'Liga infantil', deporteId: 'tenis', deporte: 'Tenis', organizadora: 'Escuela B'),
        ]);
    when(() => repo.equipos('esc1')).thenAnswer((_) async => const [
          EquipoLite(id: 'eqT', nombre: 'Tenis Sub12', deporteId: 'tenis'),
          EquipoLite(id: 'eqP', nombre: 'Pádel Sub12', deporteId: 'padel'),
        ]);
    when(() => repo.inscribirEquipo('L1', 'eqT', 'esc1')).thenAnswer((_) async {});
    await abrir(tester, repo);

    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    expect(find.text('Liga infantil'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inscribir-L1')));
    await tester.pumpAndSettle();
    expect(find.text('Pádel Sub12'), findsNothing);
    await tester.tap(find.text('Tenis Sub12'));
    await tester.pumpAndSettle();

    verify(() => repo.inscribirEquipo('L1', 'eqT', 'esc1')).called(1);
  });

  testWidgets('error de inscripción traducido', (tester) async {
    final repo = repoBase();
    when(() => repo.ligasAbiertas()).thenAnswer((_) async => const [
          LigaAbierta(id: 'L1', nombre: 'Liga', deporteId: 'tenis', deporte: 'Tenis', organizadora: 'B'),
        ]);
    when(() => repo.equipos('esc1')).thenAnswer((_) async => const [EquipoLite(id: 'eqT', nombre: 'Eq', deporteId: 'tenis')]);
    when(() => repo.inscribirEquipo(any(), any(), any()))
        .thenAnswer((_) async => throw Exception('el calendario ya está generado; no se admiten más inscripciones'));
    await abrir(tester, repo);
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inscribir-L1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eq'));
    await tester.pumpAndSettle();
    expect(find.text('La liga ya tiene calendario; no admite más inscripciones.'), findsOneWidget);
  });
}
