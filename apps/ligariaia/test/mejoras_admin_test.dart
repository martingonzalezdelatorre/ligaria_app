import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ligariaia/core/auth.dart';
import 'package:ligariaia/core/config.dart';
import 'package:ligariaia/core/enlaces.dart';
import 'package:ligariaia/core/idioma.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/data/tutores_repository.dart';
import 'package:ligariaia/features/escuela/escuela_home.dart';
import 'package:ligariaia/features/escuela/importar_dialog.dart';
import 'package:ligariaia/features/escuela/importar_jugadores.dart';
import 'package:ligariaia/features/escuela/invitar_bloque.dart';
import 'package:ligariaia/features/organizador/crear_liga_page.dart';
import 'package:ligariaia/features/organizador/plantillas_liga.dart';

class MockRepo extends Mock implements LigaRepository {}

class MockTutores extends Mock implements TutoresRepository {}

Widget _app(
  Widget home, {
  required MockRepo repo,
  MockTutores? tutores,
  List<Override> extra = const [],
}) => ProviderScope(
  overrides: [
    ligaRepositoryProvider.overrideWithValue(repo),
    if (tutores != null) tutoresRepositoryProvider.overrideWithValue(tutores),
    ...extra,
  ],
  child: MaterialApp(
    localizationsDelegates: const [
      AppL10n.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppL10n.supportedLocales,
    locale: const Locale('es'),
    home: Scaffold(body: SingleChildScrollView(child: home)),
  ),
);

void _tamano(WidgetTester t, [double ancho = 800, double alto = 2400]) {
  t.view.physicalSize = Size(ancho, alto);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<TutorNuevo>[]);
    registerFallbackValue(Rol.tutor);
    registerFallbackValue(puntuacionPorDefecto);
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ejecutarImportacion', () {
    late MockRepo repo;
    late MockTutores tut;
    final hoy = DateTime(2026, 11, 26);

    setUp(() {
      repo = MockRepo();
      tut = MockTutores();
      when(
        () => repo.crearJugador(any(), any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => tut.crearJugador(any(), any(), any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => tut.enviarInvitaciones(any(), any()),
      ).thenAnswer((_) async => true);
    });

    List<FilaImport> filas(String t) => leerJugadores(t, hoy: hoy);

    test(
      'menor con tutor: se asocia y se invita; mayor o sin tutor: alta simple',
      () async {
        final r = await ejecutarImportacion(
          liga: repo,
          tutores: tut,
          orgId: 'o1',
          hoy: hoy,
          filas: filas(
            'Ana;López;05/03/2015;María;maria@x.es;madre\n'
            'Pedro;Gil;01/01/1990;Luisa;luisa@x.es\n' // mayor de edad: no se asocia
            'Bea;Ruiz;02/02/2016',
          ),
        );
        expect(r.creados, 3);
        expect(r.fallos, isEmpty);
        final t =
            verify(
                  () => tut.crearJugador(
                    'o1',
                    'Ana',
                    'López',
                    DateTime(2015, 3, 5),
                    captureAny(),
                  ),
                ).captured.single
                as List<TutorNuevo>;
        expect(t.single.email, 'maria@x.es');
        expect(t.single.nombre, 'María');
        expect(t.single.parentesco, 'Madre');
        verify(
          () => repo.crearJugador('o1', 'Pedro', 'Gil', DateTime(1990, 1, 1)),
        ).called(1);
        verify(
          () => repo.crearJugador('o1', 'Bea', 'Ruiz', DateTime(2016, 2, 2)),
        ).called(1);
        verify(() => tut.enviarInvitaciones('o1', ['maria@x.es'])).called(1);
        expect(r.correosOk, isTrue);
      },
    );

    test(
      'si una fila falla se sigue con las demás y se cuenta el fallo',
      () async {
        when(
          () => repo.crearJugador(any(), 'Mala', any(), any()),
        ).thenThrow(Exception('boom'));
        final r = await ejecutarImportacion(
          liga: repo,
          tutores: tut,
          orgId: 'o1',
          hoy: hoy,
          filas: filas('Mala;X;05/03/2015\nBuena;Y;05/03/2015'),
        );
        expect(r.creados, 1);
        expect(r.fallos, hasLength(1));
        expect(r.fallos.single.$1.nombre, 'Mala');
        expect(r.correosOk, isNull); // no había familias a las que escribir
      },
    );

    test(
      'las filas con error no se envían y los correos van de 10 en 10',
      () async {
        final texto = StringBuffer('nombre;fecha;correo\n');
        for (var i = 0; i < 12; i++) {
          texto.writeln('Jugador$i;05/03/2015;fam$i@x.es');
        }
        texto.writeln(';05/03/2015;'); // sin nombre
        final r = await ejecutarImportacion(
          liga: repo,
          tutores: tut,
          orgId: 'o1',
          hoy: hoy,
          filas: filas(texto.toString()),
        );
        expect(r.creados, 12);
        final lotes = verify(
          () => tut.enviarInvitaciones('o1', captureAny()),
        ).captured.cast<List<String>>();
        expect(lotes.map((l) => l.length), [10, 2]);
      },
    );

    test('si un lote de correos falla se avisa', () async {
      when(
        () => tut.enviarInvitaciones(any(), any()),
      ).thenAnswer((_) async => false);
      final r = await ejecutarImportacion(
        liga: repo,
        tutores: tut,
        orgId: 'o1',
        hoy: hoy,
        filas: filas('Ana;López;05/03/2015;M;m@x.es'),
      );
      expect(r.correosOk, isFalse);
    });
  });

  group('diálogo de importar jugadores', () {
    late MockRepo repo;
    late MockTutores tut;

    setUp(() {
      repo = MockRepo();
      tut = MockTutores();
      when(() => repo.jugadoresOrg('esc1')).thenAnswer((_) async => const []);
      when(
        () => repo.crearJugador(any(), any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => tut.crearJugador(any(), any(), any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => tut.enviarInvitaciones(any(), any()),
      ).thenAnswer((_) async => true);
    });

    Future<void> abrir(WidgetTester t, {String? archivo}) async {
      _tamano(t);
      await t.pumpWidget(
        _app(
          const ImportarJugadoresDialog(escuelaId: 'esc1'),
          repo: repo,
          tutores: tut,
          extra: [
            leerArchivoListaProvider.overrideWithValue(() async => archivo),
          ],
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('pegar, revisar y importar', (t) async {
      await abrir(t);
      await t.enterText(
        find.byKey(const Key('imp-texto')),
        'Ana;López;05/03/2015;María;maria@x.es\n'
        'Pedro;Gil;01/01/1990\n'
        'Mal;Fila;nunca',
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Revisar'));
      await t.pumpAndSettle();

      expect(find.text('Listos para importar: 2'), findsOneWidget);
      expect(find.text('Con errores (se omiten): 1'), findsOneWidget);
      expect(
        find.text('Familias que recibirán un correo para crear su cuenta: 1'),
        findsOneWidget,
      );
      expect(
        find.text('Fila 3: Mal Fila — fecha de nacimiento no válida'),
        findsOneWidget,
      );

      await t.tap(find.text('Importar 2 jugadores'));
      await t.pumpAndSettle();

      expect(find.text('Jugadores dados de alta: 2'), findsOneWidget);
      expect(
        find.text('Las familias han recibido el correo para crear su cuenta.'),
        findsOneWidget,
      );
      verify(() => tut.enviarInvitaciones('esc1', ['maria@x.es'])).called(1);
    });

    testWidgets(
      'el botón Revisar no se activa sin datos y avisa si no hay filas',
      (t) async {
        await abrir(t);
        await t.enterText(find.byKey(const Key('imp-texto')), ' ; ; ');
        await t.pumpAndSettle();
        await t.tap(find.text('Revisar'));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('imp-error')), findsOneWidget);
        expect(
          find.text('No se ha encontrado ninguna fila con datos.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('un archivo elegido rellena el cuadro de texto', (t) async {
      await abrir(t, archivo: 'Ana;López;05/03/2015');
      await t.tap(find.byKey(const Key('imp-archivo')));
      await t.pumpAndSettle();
      expect(find.text('Ana;López;05/03/2015'), findsOneWidget);
    });

    testWidgets('lo que la escuela ya tiene se omite', (t) async {
      when(() => repo.jugadoresOrg('esc1')).thenAnswer(
        (_) async => [
          JugadorLite(
            id: 'j1',
            nombre: 'Ana',
            apellidos: 'López',
            fechaNacimiento: DateTime(2015, 3, 5),
          ),
        ],
      );
      await abrir(t);
      await t.enterText(
        find.byKey(const Key('imp-texto')),
        'Ana;López;05/03/2015\nLuis;Pérez;01/02/2014',
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Revisar'));
      await t.pumpAndSettle();
      expect(find.text('Listos para importar: 1'), findsOneWidget);
      expect(
        find.text('Ya existen en tu escuela (se omiten): 1'),
        findsOneWidget,
      );
    });

    testWidgets('copiar el modelo lo deja en el portapapeles', (t) async {
      String? copiado;
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (c) async {
          if (c.method == 'Clipboard.setData') {
            copiado = (c.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await abrir(t);
      await t.tap(find.byKey(const Key('imp-modelo')));
      await t.pumpAndSettle();
      expect(copiado, modeloImportacion);
      // El modelo que se copia es una lista válida.
      expect(
        leerJugadores(
          modeloImportacion,
          hoy: DateTime(2026, 11, 26),
        ).single.valida,
        isTrue,
      );
    });
  });

  group('invitar en bloque', () {
    test(
      'correosDeTexto: separadores, formato Outlook, repetidos e inválidos',
      () {
        final l = correosDeTexto(
          'a@x.es, B@x.es; "Luis Pérez" <c@x.es>\n'
          'a@x.es malo@ otra palabra suelta@@x',
        );
        expect(l.validos, ['a@x.es', 'b@x.es', 'c@x.es']);
        expect(l.repetidos, 1);
        expect(l.invalidos, ['malo@', 'suelta@@x']);
      },
    );

    test('correosDeTexto: vacío', () {
      final l = correosDeTexto('  \n ');
      expect(l.validos, isEmpty);
      expect(l.repetidos, 0);
      expect(l.invalidos, isEmpty);
    });

    test('mailtoCopiaOculta codifica destinatarios, asunto y cuerpo', () {
      final u = Uri.parse(
        mailtoCopiaOculta(['a@x.es', 'b@x.es'], 'Hola mundo', 'Texto & más'),
      );
      expect(u.scheme, 'mailto');
      expect(u.queryParameters['bcc'], 'a@x.es,b@x.es');
      expect(u.queryParameters['subject'], 'Hola mundo');
      expect(u.queryParameters['body'], 'Texto & más');
    });

    test('invitarEnBloque sigue con las demás si una falla', () async {
      final repo = MockRepo();
      when(() => repo.invitar('o1', any(), any())).thenAnswer((_) async {});
      when(
        () => repo.invitar('o1', 'mal@x.es', any()),
      ).thenThrow(Exception('sin permiso'));
      final r = await invitarEnBloque(
        repo: repo,
        orgId: 'o1',
        rol: Rol.entrenador,
        correos: ['a@x.es', 'mal@x.es', 'b@x.es'],
      );
      expect(r.enviadas, ['a@x.es', 'b@x.es']);
      expect(r.fallidas.map((f) => f.$1), ['mal@x.es']);
    });

    testWidgets('pegar correos, invitar y avisarles', (t) async {
      final repo = MockRepo();
      when(() => repo.invitar('esc1', any(), any())).thenAnswer((_) async {});
      final abiertas = <Uri>[];
      _tamano(t);
      await t.pumpWidget(
        _app(
          const InvitarBloqueDialog(escuelaId: 'esc1'),
          repo: repo,
          extra: [
            abrirUrlProvider.overrideWithValue((u) async {
              abiertas.add(u);
              return true;
            }),
          ],
        ),
      );
      await t.pumpAndSettle();

      await t.enterText(
        find.byKey(const Key('bloque-texto')),
        'a@x.es, b@x.es\nc@x.es a@x.es malo@',
      );
      await t.pumpAndSettle();
      expect(find.text('Correos válidos: 3'), findsOneWidget);
      expect(find.text('Repetidos (se ignoran): 1'), findsOneWidget);
      expect(find.text('No válidos: malo@'), findsOneWidget);

      await t.tap(find.text('Invitar a 3'));
      await t.pumpAndSettle();

      verify(() => repo.invitar('esc1', 'a@x.es', Rol.tutor)).called(1);
      verify(() => repo.invitar('esc1', 'b@x.es', Rol.tutor)).called(1);
      verify(() => repo.invitar('esc1', 'c@x.es', Rol.tutor)).called(1);
      expect(find.text('Invitaciones guardadas: 3'), findsOneWidget);

      await t.tap(find.byKey(const Key('bloque-correo')));
      await t.pumpAndSettle();
      expect(abiertas.single.scheme, 'mailto');
      expect(abiertas.single.queryParameters['bcc'], 'a@x.es,b@x.es,c@x.es');
      expect(
        abiertas.single.queryParameters['body'],
        contains(AppConfig.familiasUrl),
      );
    });

    testWidgets('el rol elegido es el que se envía', (t) async {
      final repo = MockRepo();
      when(() => repo.invitar(any(), any(), any())).thenAnswer((_) async {});
      _tamano(t);
      await t.pumpWidget(
        _app(const InvitarBloqueDialog(escuelaId: 'esc1'), repo: repo),
      );
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('bloque-texto')), 'coach@x.es');
      await t.tap(find.byKey(const Key('bloque-rol-entrenador')));
      await t.pumpAndSettle();
      await t.tap(find.text('Invitar a 1'));
      await t.pumpAndSettle();
      verify(
        () => repo.invitar('esc1', 'coach@x.es', Rol.entrenador),
      ).called(1);
    });

    testWidgets(
      'sin correos válidos no se puede invitar y lo que falla se lista',
      (t) async {
        final repo = MockRepo();
        when(
          () => repo.invitar('esc1', 'ok@x.es', any()),
        ).thenAnswer((_) async {});
        when(
          () => repo.invitar('esc1', 'mal@x.es', any()),
        ).thenThrow(Exception('sin permiso'));
        _tamano(t);
        await t.pumpWidget(
          _app(const InvitarBloqueDialog(escuelaId: 'esc1'), repo: repo),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Invitar a 0'), warnIfMissed: false);
        await t.pumpAndSettle();
        verifyNever(() => repo.invitar(any(), any(), any()));

        await t.enterText(
          find.byKey(const Key('bloque-texto')),
          'ok@x.es mal@x.es',
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Invitar a 2'));
        await t.pumpAndSettle();
        expect(find.text('Invitaciones guardadas: 1'), findsOneWidget);
        expect(find.text('No se pudieron invitar: 1'), findsOneWidget);
      },
    );
  });

  group('plantillas de liga', () {
    test('temporada: antes, dentro y después de la temporada', () {
      // Antes de empezar: usa las fechas de la plantilla.
      expect(temporada(DateTime(2026, 7, 1), (9, 15), (12, 15)), (
        DateTime(2026, 9, 15),
        DateTime(2026, 12, 15),
      ));
      // Dentro de la temporada: empieza hoy.
      expect(temporada(DateTime(2026, 10, 20), (9, 15), (12, 15)), (
        DateTime(2026, 10, 20),
        DateTime(2026, 12, 15),
      ));
      // Ya terminó este año: la del año siguiente.
      expect(temporada(DateTime(2026, 12, 20), (9, 15), (12, 15)), (
        DateTime(2027, 9, 15),
        DateTime(2027, 12, 15),
      ));
    });

    test('proximoFinDeSemana nunca es hoy', () {
      // 26/11/2026 es jueves.
      expect(proximoFinDeSemana(DateTime(2026, 11, 26)), (
        DateTime(2026, 11, 28),
        DateTime(2026, 11, 29),
      ));
      // Sábado: el de la semana siguiente.
      expect(proximoFinDeSemana(DateTime(2026, 11, 28)), (
        DateTime(2026, 12, 5),
        DateTime(2026, 12, 6),
      ));
      // Domingo.
      expect(proximoFinDeSemana(DateTime(2026, 11, 29)), (
        DateTime(2026, 12, 5),
        DateTime(2026, 12, 6),
      ));
    });

    test('hay una plantilla de cada formato', () {
      expect(
        {for (final p in plantillasLiga) p.formato},
        {'LIGA', 'ELIMINATORIA', 'MIXTO'},
      );
    });

    Future<MockRepo> abrirCrear(WidgetTester t, {bool conStub = true}) async {
      final repo = MockRepo();
      when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
      when(
        () => repo.crearLiga(
          orgId: any(named: 'orgId'),
          deporteId: any(named: 'deporteId'),
          nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'),
          fechaInicio: any(named: 'fechaInicio'),
          fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'),
          puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        ),
      ).thenAnswer((_) async {});
      _tamano(t);
      await t.pumpWidget(
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
            home: CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA'),
          ),
        ),
      );
      await t.pumpAndSettle();
      return repo;
    }

    testWidgets(
      'el torneo exprés rellena nombre, formato eliminatoria y el fin de semana',
      (t) async {
        final repo = await abrirCrear(t);
        await t.ensureVisible(find.byKey(const Key('plantilla-torneo')));
        await t.tap(find.byKey(const Key('plantilla-torneo')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('plantilla-descripcion')), findsOneWidget);

        await t.ensureVisible(find.text('Crear liga'));
        await t.tap(find.text('Crear liga'));
        await t.pumpAndSettle();

        final c = verify(
          () => repo.crearLiga(
            orgId: 'e1',
            deporteId: any(named: 'deporteId'),
            nombre: captureAny(named: 'nombre'),
            tipo: any(named: 'tipo'),
            fechaInicio: captureAny(named: 'fechaInicio'),
            fechaFin: captureAny(named: 'fechaFin'),
            visibilidad: any(named: 'visibilidad'),
            puntuacion: any(named: 'puntuacion'),
            formato: 'ELIMINATORIA',
          ),
        ).captured;
        expect(c[0], startsWith('Torneo exprés'));
        final ini = c[1] as DateTime, fin = c[2] as DateTime;
        expect(ini.weekday, DateTime.saturday);
        expect(fin.difference(ini).inDays, 1);
        expect(ini.isAfter(DateTime.now()), isTrue);
      },
    );

    testWidgets(
      'la liga de otoño es una liga con fechas de temporada, y se puede retocar',
      (t) async {
        final repo = await abrirCrear(t);
        await t.ensureVisible(find.byKey(const Key('plantilla-otono')));
        await t.tap(find.byKey(const Key('plantilla-otono')));
        await t.pumpAndSettle();
        // Retoca el nombre que puso la plantilla.
        await t.enterText(find.byType(TextFormField).first, 'Liga Sub-12');

        await t.ensureVisible(find.text('Crear liga'));
        await t.tap(find.text('Crear liga'));
        await t.pumpAndSettle();

        final c = verify(
          () => repo.crearLiga(
            orgId: 'e1',
            deporteId: any(named: 'deporteId'),
            nombre: captureAny(named: 'nombre'),
            tipo: any(named: 'tipo'),
            fechaInicio: captureAny(named: 'fechaInicio'),
            fechaFin: captureAny(named: 'fechaFin'),
            visibilidad: any(named: 'visibilidad'),
            puntuacion: any(named: 'puntuacion'),
            formato: 'LIGA',
          ),
        ).captured;
        expect(c[0], 'Liga Sub-12');
        final ini = c[1] as DateTime, fin = c[2] as DateTime;
        expect(fin.month, 12);
        expect(fin.day, 15);
        expect(ini.isBefore(fin), isTrue);
      },
    );

    testWidgets('al elegir una plantilla de grupos el formato es mixto', (
      t,
    ) async {
      final repo = await abrirCrear(t);
      await t.ensureVisible(find.byKey(const Key('plantilla-grupos')));
      await t.tap(find.byKey(const Key('plantilla-grupos')));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Crear liga'));
      await t.tap(find.text('Crear liga'));
      await t.pumpAndSettle();
      verify(
        () => repo.crearLiga(
          orgId: 'e1',
          deporteId: any(named: 'deporteId'),
          nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'),
          fechaInicio: any(named: 'fechaInicio'),
          fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'),
          puntuacion: any(named: 'puntuacion'),
          formato: 'MIXTO',
        ),
      ).called(1);
    });
  });

  group('área de escuela', () {
    MockRepo repoEscuela() {
      final repo = MockRepo();
      when(() => repo.jugadoresOrg('esc1')).thenAnswer((_) async => const []);
      when(() => repo.equipos('esc1')).thenAnswer((_) async => const []);
      when(() => repo.usuarios('esc1')).thenAnswer((_) async => const []);
      when(
        () => repo.tieneInvitacionEntrenador('esc1'),
      ).thenAnswer((_) async => false);
      when(
        () => repo.tieneInscripciones('esc1'),
      ).thenAnswer((_) async => false);
      when(() => repo.ligasAbiertas()).thenAnswer((_) async => const []);
      when(() => repo.misInvitaciones()).thenAnswer((_) async => const []);
      return repo;
    }

    Future<void> abrir(
      WidgetTester t,
      MockRepo repo, {
      double ancho = 800,
    }) async {
      _tamano(t, ancho, 1600);
      await t.pumpWidget(
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
      await t.pumpAndSettle();
    }

    testWidgets('las pestañas de ligas ya no se confunden', (t) async {
      await abrir(t, repoEscuela());
      expect(find.text('Inscribirme en ligas'), findsOneWidget);
      expect(find.text('Ligas que organizo'), findsOneWidget);
      expect(find.text('Mis ligas'), findsNothing);
    });

    testWidgets('en un móvil estrecho los nombres largos no desbordan', (
      t,
    ) async {
      await abrir(t, repoEscuela(), ancho: 360);
      expect(t.takeException(), isNull);
      expect(find.text('Inscribirme en ligas'), findsOneWidget);
    });

    testWidgets('Usuarios ofrece invitar en bloque', (t) async {
      await abrir(t, repoEscuela());
      await t.tap(find.byKey(const Key('invitar-bloque')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('bloque-texto')), findsOneWidget);
    });

    testWidgets('Jugadores y tutores ofrece importar una lista', (t) async {
      await abrir(t, repoEscuela());
      await t.tap(find.text('Jugadores y tutores'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('importar-lista')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('imp-texto')), findsOneWidget);
      expect(find.text('Importar jugadores'), findsOneWidget);
    });
  });
}
