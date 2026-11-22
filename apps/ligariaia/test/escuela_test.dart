import 'package:ligariaia/core/idioma.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/core/auth.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/escuela/escuela_home.dart';
import 'package:ligariaia/features/escuela/escuela_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

final persona = JugadorLite(
  id: 'p1',
  nombre: 'Ana',
  apellidos: 'López',
  fechaNacimiento: DateTime(2015, 3, 5),
);

MockRepo repoBase() {
  final repo = MockRepo();
  when(() => repo.usuarios('esc1')).thenAnswer((_) async => const []);
  when(() => repo.jugadoresOrg('esc1')).thenAnswer((_) async => [persona]);
  when(() => repo.equipos('esc1')).thenAnswer((_) async => const []);
  when(() => repo.ligasAbiertas()).thenAnswer((_) async => const []);
  when(() => repo.misInvitaciones()).thenAnswer((_) async => const []);
  when(() => repo.categorias(any())).thenAnswer((_) async => const []);
  when(() => repo.deportes()).thenAnswer((_) async => const []);
  return repo;
}

Future<void> abrir(WidgetTester tester, MockRepo repo) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: EscuelaHome(escuelaId: 'esc1', escuelaNombre: 'Escuela A'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder enDialogo(Finder f) =>
    find.descendant(of: find.byType(HojaFormulario), matching: f);

void main() {
  test('mensajeErrorEscuela traduce los errores conocidos', () {
    expect(
      mensajeErrorEscuela(
        Exception('el jugador no pertenece a la organización del equipo'),
      ),
      'El jugador no pertenece a la organización del equipo.',
    );
    expect(
      mensajeErrorEscuela(
        Exception('el deporte del equipo no coincide con la competición'),
      ),
      'El deporte del equipo no coincide con el de la liga.',
    );
    expect(
      mensajeErrorEscuela(Exception('algo raro con stack trace')),
      isNot(contains('stack')),
    );
  });

  test('parseFecha valida dd/mm/aaaa', () {
    expect(parseFecha('05/03/2015'), DateTime(2015, 3, 5));
    expect(parseFecha('31/02/2015'), isNull);
    expect(parseFecha('2015-03-05'), isNull);
  });

  testWidgets(
    'invitar a un entrenador llama a repo.invitar con el rol correcto',
    (tester) async {
      final repo = repoBase();
      when(
        () =>
            repo.invitar('esc1', 'coach@x.es', Rol.entrenador, jugadorId: null),
      ).thenAnswer((_) async {});
      await abrir(tester, repo);

      await tester.tap(find.text('Invitar'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('invitar-email')),
        'coach@x.es',
      );
      await tester.tap(enDialogo(find.text('Enviar invitación')).last);
      await tester.pumpAndSettle();

      verify(
        () =>
            repo.invitar('esc1', 'coach@x.es', Rol.entrenador, jugadorId: null),
      ).called(1);
      expect(find.text('Invitación enviada.'), findsOneWidget);
    },
  );

  testWidgets('invitar a un tutor sin alumno: él añade a sus hijos después', (
    tester,
  ) async {
    final repo = repoBase();
    when(
      () => repo.invitar('esc1', 'madre@x.es', Rol.tutor, jugadorId: null),
    ).thenAnswer((_) async {});
    await abrir(tester, repo);

    // Sin alumno: no exige elegir persona.
    await tester.tap(find.text('Invitar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('invitar-email')),
      'madre@x.es',
    );
    await tester.tap(find.byKey(const Key('invitar-rol-tutor')));
    await tester.pumpAndSettle();
    await tester.tap(enDialogo(find.text('Enviar invitación')).last);
    await tester.pumpAndSettle();
    verify(
      () => repo.invitar('esc1', 'madre@x.es', Rol.tutor, jugadorId: null),
    ).called(1);
  });

  testWidgets('invitar a un tutor eligiendo un alumno envía su ficha', (
    tester,
  ) async {
    final repo = repoBase();
    when(
      () => repo.invitar('esc1', 'padre@x.es', Rol.tutor, jugadorId: 'p1'),
    ).thenAnswer((_) async {});
    await abrir(tester, repo);
    await tester.tap(find.text('Invitar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('invitar-email')),
      'padre@x.es',
    );
    await tester.tap(find.byKey(const Key('invitar-rol-tutor')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('invitar-persona')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana López').last);
    await tester.pumpAndSettle();
    await tester.tap(enDialogo(find.text('Enviar invitación')).last);
    await tester.pumpAndSettle();
    verify(
      () => repo.invitar('esc1', 'padre@x.es', Rol.tutor, jugadorId: 'p1'),
    ).called(1);
  });

  testWidgets('crear persona: valida la fecha y llama a repo.crearJugador', (
    tester,
  ) async {
    final repo = repoBase();
    when(
      () => repo.crearJugador('esc1', 'Luis', 'Pérez', DateTime(2014, 9, 1)),
    ).thenAnswer((_) async {});
    await abrir(tester, repo);

    await tester.tap(find.text('Jugadores y tutores'));
    await tester.pumpAndSettle();
    expect(find.text('Ana López'), findsOneWidget);

    await tester.tap(find.text('Nueva persona'));
    await tester.pumpAndSettle();
    // Paso 1: sin tutor (jugador adulto) y seguimos.
    await tester.tap(find.byTooltip('Quitar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('persona-nombre')), 'Luis');
    await tester.enterText(find.byKey(const Key('persona-apellidos')), 'Pérez');
    await tester.enterText(
      find.byKey(const Key('persona-fecha')),
      '99/99/2014',
    );
    await tester.tap(find.text('Guardar jugador'));
    await tester.pumpAndSettle();
    expect(find.text('Fecha no válida'), findsOneWidget);
    verifyNever(() => repo.crearJugador(any(), any(), any(), any()));

    await tester.enterText(
      find.byKey(const Key('persona-fecha')),
      '01/09/2014',
    );
    await tester.tap(find.text('Guardar jugador'));
    await tester.pumpAndSettle();
    verify(
      () => repo.crearJugador('esc1', 'Luis', 'Pérez', DateTime(2014, 9, 1)),
    ).called(1);
  });

  testWidgets(
    'añadir un jugador de otra organización muestra un mensaje claro',
    (tester) async {
      final repo = repoBase();
      when(() => repo.equipos('esc1')).thenAnswer(
        (_) async => const [
          EquipoLite(id: 'eq1', nombre: 'Sub12', deporteId: 'tenis'),
        ],
      );
      when(() => repo.jugadores('eq1')).thenAnswer((_) async => const []);
      when(() => repo.anadirJugador('eq1', 'p1')).thenAnswer(
        (_) async => throw Exception(
          'el jugador no pertenece a la organización del equipo',
        ),
      );
      await abrir(tester, repo);

      await tester.tap(find.text('Equipos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sub12'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('anadir-jugador')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ana López').last);
      await tester.pumpAndSettle();

      expect(
        find.text('El jugador no pertenece a la organización del equipo.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('inscribir en una liga solo ofrece equipos del mismo deporte', (
    tester,
  ) async {
    final repo = repoBase();
    when(() => repo.ligasAbiertas()).thenAnswer(
      (_) async => const [
        LigaAbierta(
          id: 'L1',
          nombre: 'Liga infantil',
          deporteId: 'tenis',
          deporte: 'Tenis',
          organizadora: 'Escuela B',
        ),
      ],
    );
    when(() => repo.equipos('esc1')).thenAnswer(
      (_) async => const [
        EquipoLite(id: 'eqT', nombre: 'Tenis Sub12', deporteId: 'tenis'),
        EquipoLite(id: 'eqP', nombre: 'Pádel Sub12', deporteId: 'padel'),
      ],
    );
    when(
      () => repo.inscribirEquipo('L1', 'eqT'),
    ).thenAnswer((_) async => 'pendiente');
    await abrir(tester, repo);

    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    expect(find.text('Liga infantil'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inscribir-L1')));
    await tester.pumpAndSettle();
    expect(find.text('Pádel Sub12'), findsNothing);
    await tester.tap(find.text('Tenis Sub12'));
    await tester.pumpAndSettle();

    verify(() => repo.inscribirEquipo('L1', 'eqT')).called(1);
  });

  testWidgets('error de inscripción traducido', (tester) async {
    final repo = repoBase();
    when(() => repo.ligasAbiertas()).thenAnswer(
      (_) async => const [
        LigaAbierta(
          id: 'L1',
          nombre: 'Liga',
          deporteId: 'tenis',
          deporte: 'Tenis',
          organizadora: 'B',
        ),
      ],
    );
    when(() => repo.equipos('esc1')).thenAnswer(
      (_) async => const [
        EquipoLite(id: 'eqT', nombre: 'Eq', deporteId: 'tenis'),
      ],
    );
    when(() => repo.inscribirEquipo(any(), any())).thenAnswer(
      (_) async => throw Exception(
        'el calendario ya está generado; no se admiten más inscripciones',
      ),
    );
    await abrir(tester, repo);
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inscribir-L1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eq'));
    await tester.pumpAndSettle();
    expect(
      find.text('La liga ya tiene calendario; no admite más inscripciones.'),
      findsOneWidget,
    );
  });

  testWidgets('con varias categorías se pide elegir una al inscribir', (
    tester,
  ) async {
    final repo = repoBase();
    when(() => repo.ligasAbiertas()).thenAnswer(
      (_) async => const [
        LigaAbierta(
          id: 'L1',
          nombre: 'Liga por edades',
          deporteId: 'tenis',
          deporte: 'Tenis',
          organizadora: 'Ayto',
        ),
      ],
    );
    when(() => repo.equipos('esc1')).thenAnswer(
      (_) async => const [
        EquipoLite(id: 'eqT', nombre: 'Tenis Sub12', deporteId: 'tenis'),
      ],
    );
    when(() => repo.categorias('L1')).thenAnswer(
      (_) async => const [
        CategoriaLiga(id: 'c1', ligaId: 'L1', nombre: 'General'),
        CategoriaLiga(
          id: 'c2',
          ligaId: 'L1',
          nombre: 'Sub-12',
          genero: 'MIXTO',
          edadMax: 12,
        ),
      ],
    );
    when(
      () => repo.inscribirEquipo('L1', 'eqT', categoriaId: 'c2'),
    ).thenAnswer((_) async => 'pendiente');
    await abrir(tester, repo);
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inscribir-L1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tenis Sub12'));
    await tester.pumpAndSettle();

    expect(find.text('Elige la categoría'), findsOneWidget);
    expect(
      find.text('Mixto · hasta 12 años'),
      findsOneWidget,
    ); // detalle de la categoría
    await tester.tap(find.text('Sub-12'));
    await tester.pumpAndSettle();
    verify(
      () => repo.inscribirEquipo('L1', 'eqT', categoriaId: 'c2'),
    ).called(1);
  });

  test('CategoriaLiga.detalle resume género, edades y nivel', () {
    expect(
      const CategoriaLiga(id: 'c', ligaId: 'l', nombre: 'General').detalle,
      isNull,
    );
    expect(
      const CategoriaLiga(
        id: 'c',
        ligaId: 'l',
        nombre: 'X',
        genero: 'FEMENINO',
        edadMin: 10,
        edadMax: 12,
        nivel: 'Avanzado',
      ).detalle,
      'Femenino · 10-12 años · Avanzado',
    );
    expect(
      const CategoriaLiga(
        id: 'c',
        ligaId: 'l',
        nombre: 'X',
        edadMin: 15,
      ).detalle,
      'desde 15 años',
    );
  });

  test('mensajeErrorEscuela traduce los errores de ligas privadas', () {
    expect(
      mensajeErrorEscuela(
        Exception(
          'la competición es privada: solo participan las escuelas invitadas',
        ),
      ),
      'Esta liga es privada: solo participan las escuelas invitadas.',
    );
  });

  testWidgets('la escuela ve sus invitaciones y puede aceptarlas', (
    tester,
  ) async {
    final repo = repoBase();
    var respondida = false;
    when(() => repo.misInvitaciones()).thenAnswer(
      (_) async => respondida
          ? const []
          : const [
              MiInvitacion(
                ligaId: 'L9',
                escuelaId: 'esc1',
                nombre: 'Copa Municipal',
                deporte: 'Tenis',
                organizadora: 'Ayuntamiento',
              ),
              MiInvitacion(
                ligaId: 'L8',
                escuelaId: 'otra',
                nombre: 'De otra escuela',
                deporte: 'Tenis',
                organizadora: 'X',
              ),
            ],
    );
    when(
      () => repo.responderInvitacion('L9', 'esc1', aceptar: true),
    ).thenAnswer((_) async {
      respondida = true;
    });
    await abrir(tester, repo);
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();

    expect(find.text('Copa Municipal'), findsOneWidget);
    expect(
      find.text('De otra escuela'),
      findsNothing,
    ); // solo las de esta escuela
    await tester.tap(find.byKey(const Key('aceptar-invitacion-L9')));
    await tester.pumpAndSettle();

    verify(
      () => repo.responderInvitacion('L9', 'esc1', aceptar: true),
    ).called(1);
    expect(find.text('Copa Municipal'), findsNothing);
  });

  testWidgets('rechazar una invitación llama al repo con aceptar: false', (
    tester,
  ) async {
    final repo = repoBase();
    when(() => repo.misInvitaciones()).thenAnswer(
      (_) async => const [
        MiInvitacion(
          ligaId: 'L9',
          escuelaId: 'esc1',
          nombre: 'Copa Municipal',
          deporte: 'Tenis',
          organizadora: 'Ayuntamiento',
        ),
      ],
    );
    when(
      () => repo.responderInvitacion('L9', 'esc1', aceptar: false),
    ).thenAnswer((_) async {});
    await abrir(tester, repo);
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rechazar-invitacion-L9')));
    await tester.pumpAndSettle();
    verify(
      () => repo.responderInvitacion('L9', 'esc1', aceptar: false),
    ).called(1);
  });

  testWidgets(
    'una liga privada a la que fui invitada se marca «por invitación»',
    (tester) async {
      final repo = repoBase();
      when(() => repo.ligasAbiertas()).thenAnswer(
        (_) async => const [
          LigaAbierta(
            id: 'L1',
            nombre: 'Copa cerrada',
            deporteId: 'tenis',
            deporte: 'Tenis',
            organizadora: 'Ayto',
            visibilidad: 'PRIVADA',
          ),
        ],
      );
      await abrir(tester, repo);
      await tester.tap(find.text('Ligas'));
      await tester.pumpAndSettle();
      expect(find.textContaining('por invitación'), findsOneWidget);
    },
  );
}
