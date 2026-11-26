import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ligariaia/core/idioma.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/escuela/escuela_home.dart';

class MockRepo extends Mock implements LigaRepository {}

final _ana = JugadorLite(
  id: 'p1',
  nombre: 'Ana',
  apellidos: 'López',
  fechaNacimiento: DateTime(2015, 3, 5),
);

/// Escuela con [jugadores] y [equipos] dados, y el resto vacío salvo lo que se indique.
MockRepo _repo({
  bool jugadores = true,
  bool equipos = false,
  bool entrenador = false,
  bool invitado = false,
  bool inscrita = false,
}) {
  final repo = MockRepo();
  when(
    () => repo.jugadoresOrg('esc1'),
  ).thenAnswer((_) async => jugadores ? [_ana] : const []);
  when(() => repo.equipos('esc1')).thenAnswer(
    (_) async => equipos
        ? [const EquipoLite(id: 'e1', nombre: 'Sub-12', deporteId: 'TENIS')]
        : const [],
  );
  when(() => repo.usuarios('esc1')).thenAnswer(
    (_) async => entrenador
        ? [
            const UsuarioEscuela(
              usuarioId: 'u2',
              email: 'coach@x.es',
              nombre: 'Coach',
              rol: 'ENTRENADOR',
            ),
          ]
        : const [],
  );
  when(
    () => repo.tieneInvitacionEntrenador('esc1'),
  ).thenAnswer((_) async => invitado);
  when(() => repo.tieneInscripciones('esc1')).thenAnswer((_) async => inscrita);
  when(() => repo.ligasAbiertas()).thenAnswer((_) async => const []);
  when(() => repo.misInvitaciones()).thenAnswer((_) async => const []);
  when(() => repo.categorias(any())).thenAnswer((_) async => const []);
  when(() => repo.deportes()).thenAnswer((_) async => const []);
  return repo;
}

Future<void> _abrir(WidgetTester tester, MockRepo repo) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        locale: Locale('es'),
        home: Scaffold(
          body: EscuelaHome(escuelaId: 'esc1', escuelaNombre: 'Escuela A'),
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

  testWidgets('escuela nueva: la guía está abierta y todo pendiente', (
    tester,
  ) async {
    await _abrir(tester, _repo(jugadores: false));

    expect(_tarjeta, findsOneWidget);
    expect(find.text('0 de 4 completados'), findsOneWidget);
    expect(find.text('1. Añade jugadores'), findsOneWidget);
    expect(find.text('2. Crea equipos'), findsOneWidget);
    expect(find.text('3. Invita al entrenador'), findsOneWidget);
    expect(find.text('4. Apúntate a una liga'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('los pasos se marcan solos según lo que ya hay', (tester) async {
    await _abrir(tester, _repo(equipos: true)); // hay jugadores y equipos

    expect(find.text('2 de 4 completados'), findsOneWidget);
    // Con progreso la guía arranca plegada; se abre al tocar la cabecera.
    expect(_paso('jugadores'), findsNothing);
    await tester.tap(find.byKey(const Key('primeros-pasos-cabecera')));
    await tester.pumpAndSettle();

    expect(_hecho('jugadores'), findsOneWidget);
    expect(_hecho('equipos'), findsOneWidget);
    expect(_hecho('entrenador'), findsNothing);
    expect(_hecho('liga'), findsNothing);
  });

  testWidgets('invitar al entrenador cuenta aunque aún no se haya registrado', (
    tester,
  ) async {
    await _abrir(tester, _repo(invitado: true));

    await tester.tap(find.byKey(const Key('primeros-pasos-cabecera')));
    await tester.pumpAndSettle();
    expect(_hecho('entrenador'), findsOneWidget);
    expect(find.text('2 de 4 completados'), findsOneWidget);
  });

  testWidgets('un entrenador ya registrado también completa el paso', (
    tester,
  ) async {
    await _abrir(tester, _repo(entrenador: true));
    expect(find.text('2 de 4 completados'), findsOneWidget);
  });

  testWidgets('con un equipo inscrito se completa el paso de la liga', (
    tester,
  ) async {
    await _abrir(tester, _repo(inscrita: true));
    expect(find.text('2 de 4 completados'), findsOneWidget);
  });

  testWidgets('si falla la consulta de inscripciones el paso queda pendiente', (
    tester,
  ) async {
    final repo = _repo();
    when(() => repo.tieneInscripciones('esc1')).thenThrow(Exception('red'));
    await _abrir(tester, repo);
    expect(_tarjeta, findsOneWidget);
    expect(find.text('1 de 4 completados'), findsOneWidget);
  });

  testWidgets('cada paso lleva a su pestaña', (tester) async {
    await _abrir(tester, _repo(jugadores: false));
    expect(find.text('Aún no hay usuarios en esta escuela.'), findsOneWidget);

    await tester.tap(_paso('equipos'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay equipos. Crea el primero.'), findsOneWidget);

    // Se puede volver a pedir el mismo salto tras moverse a mano.
    await tester.tap(_paso('entrenador'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay usuarios en esta escuela.'), findsOneWidget);
    await tester.tap(_paso('equipos'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay equipos. Crea el primero.'), findsOneWidget);
  });

  testWidgets(
    'el paso de la liga deja a la vista su pestaña, aunque quede lejos',
    (tester) async {
      await _abrir(tester, _repo(jugadores: false));
      await tester.tap(_paso('liga'));
      await tester.pumpAndSettle();

      // Con nombres largos la barra de pestañas desborda en 800 px: debe desplazarse hasta la elegida.
      expect(
        tester.getCenter(find.text('Inscribirme en ligas')).dx,
        lessThan(800),
      );
      expect(
        tester.getCenter(find.text('Inscribirme en ligas')).dx,
        greaterThan(0),
      );
    },
  );

  testWidgets('con los cuatro pasos hechos la guía desaparece', (tester) async {
    await _abrir(
      tester,
      _repo(equipos: true, entrenador: true, inscrita: true),
    );
    expect(_tarjeta, findsNothing);
  });

  testWidgets('se puede ocultar y no vuelve a salir en esa escuela', (
    tester,
  ) async {
    await _abrir(tester, _repo(jugadores: false));
    expect(_tarjeta, findsOneWidget);

    await tester.tap(find.byKey(const Key('primeros-pasos-ocultar')));
    await tester.pumpAndSettle();
    expect(_tarjeta, findsNothing);

    // Otra «sesión»: se vuelve a montar la pantalla y la preferencia sigue.
    await tester.pumpWidget(const SizedBox());
    await _abrir(tester, _repo(jugadores: false));
    expect(_tarjeta, findsNothing);
  });
}
