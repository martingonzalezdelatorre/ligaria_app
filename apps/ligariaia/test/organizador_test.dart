import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/core/auth.dart';
import 'package:ligariaia/core/widgets.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/organizador/crear_liga_page.dart';
import 'package:ligariaia/features/organizador/liga_detalle_page.dart';
import 'package:ligariaia/features/organizador/ligas_tab.dart';
import 'package:ligariaia/features/organizador/organizador_home.dart';
import 'package:ligariaia/features/organizador/organizador_providers.dart' show mensajeError;
import 'package:ligariaia/features/organizador/resultado_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

const _enc = EncuentroVista(
  id: 'enc1', ligaId: 'l1', jornada: 2, estado: 'finalizado',
  localId: 'eqA', local: 'Tenis A', visitanteId: 'eqB', visitante: 'Tenis B',
  partidosLocal: 2, partidosVisitante: 1,
);

const _pendiente = EncuentroVista(
  id: 'enc2', ligaId: 'l1', jornada: 3, estado: 'programado',
  localId: 'eqA', local: 'Tenis A', visitanteId: 'eqB', visitante: 'Tenis B',
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
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(puntuacionPorDefecto); // mocktail necesita un valor de reserva para el tipo registro
    registerFallbackValue(Rol.alumno);
  });
  setUp(() => repo = MockRepo());

  testWidgets('crear liga envía organización, deporte, tipo y nombre', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '  Liga infantil  ');
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'e1', deporteId: deportesDisponibles.first.id, nombre: 'Liga infantil',
          tipo: 'ENTRE_ESCUELAS', fechaInicio: null, fechaFin: null, visibilidad: 'PUBLICA',
          puntuacion: puntuacionPorDefecto, formato: 'LIGA',
        )).called(1);
  });

  testWidgets('la puntuación se puede personalizar al crear la liga', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Liga 2-1-0');
    await tester.enterText(find.byKey(const Key('puntos-victoria')), '2');
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'e1', deporteId: deportesDisponibles.first.id, nombre: 'Liga 2-1-0',
          tipo: 'ENTRE_ESCUELAS', fechaInicio: null, fechaFin: null, visibilidad: 'PUBLICA',
          puntuacion: (victoria: 2, empate: 1, derrota: 0), formato: 'LIGA',
        )).called(1);
  });

  testWidgets('una puntuación incoherente se rechaza antes de enviar', (tester) async {
    _alto(tester);
    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Liga rara');
    await tester.enterText(find.byKey(const Key('puntos-victoria')), '1');
    await tester.enterText(find.byKey(const Key('puntos-empate')), '2'); // empate > victoria
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    expect(find.textContaining('victoria ≥ empate ≥ derrota'), findsOneWidget);
    verifyNever(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        ));
  });

  testWidgets('crear una liga por invitación envía visibilidad PRIVADA', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'ay', orgTipo: 'AYUNTAMIENTO')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Copa municipal');
    await tester.tap(find.text('Por invitación'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'ay', deporteId: deportesDisponibles.first.id, nombre: 'Copa municipal',
          tipo: 'MUNICIPAL', fechaInicio: null, fechaFin: null, visibilidad: 'PRIVADA',
          puntuacion: puntuacionPorDefecto, formato: 'LIGA',
        )).called(1);
  });

  testWidgets('una liga interna de escuela no ofrece elegir visibilidad', (tester) async {
    _alto(tester);
    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    // por defecto ENTRE_ESCUELAS: sí aparece; al cambiar a interna desaparece
    expect(find.byKey(const Key('liga-visibilidad')), findsOneWidget);
    await tester.tap(find.text('Interna de la escuela'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('liga-visibilidad')), findsNothing);
  });

  testWidgets('el organizador invita a una escuela y puede retirar la invitación', (tester) async {
    _alto(tester);
    const liga = Liga(
        id: 'l1', nombre: 'Copa', estado: 'publicada', deporte: 'Tenis', deporteId: 'TENIS',
        tipo: 'ENTRE_ESCUELAS', visibilidad: 'PRIVADA');
    var invitada = false;
    when(() => repo.encuentros('l1')).thenAnswer((_) async => const []);
    when(() => repo.clasificacion('l1')).thenAnswer((_) async => const []);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);
    when(() => repo.invitacionesLiga('l1')).thenAnswer((_) async => invitada
        ? const [InvitacionLiga(ligaId: 'l1', escuelaId: 'eB', escuela: 'Escuela B', ciudad: 'Getafe', estado: 'pendiente')]
        : const []);
    when(() => repo.escuelasInvitables()).thenAnswer((_) async => const [
          EscuelaInvitable(id: 'e1', nombre: 'Escuela A'), // la propia: no se ofrece
          EscuelaInvitable(id: 'eB', nombre: 'Escuela B', ciudad: 'Getafe'),
        ]);
    when(() => repo.invitarEscuela('l1', 'eB')).thenAnswer((_) async {
      invitada = true;
    });
    when(() => repo.retirarInvitacion('l1', 'eB')).thenAnswer((_) async {
      invitada = false;
    });

    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuelas'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no has invitado a ninguna escuela.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('invitar-escuela')));
    await tester.pumpAndSettle();
    expect(find.text('Escuela A'), findsNothing);
    await tester.tap(find.text('Escuela B'));
    await tester.pumpAndSettle();
    verify(() => repo.invitarEscuela('l1', 'eB')).called(1);
    expect(find.textContaining('Pendiente de respuesta'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retirar-eB')));
    await tester.pumpAndSettle();
    verify(() => repo.retirarInvitacion('l1', 'eB')).called(1);
    expect(find.text('Aún no has invitado a ninguna escuela.'), findsOneWidget);
  });

  testWidgets('una liga interna de escuela no muestra la pestaña de escuelas invitadas', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Interna', estado: 'publicada', deporteId: 'TENIS', tipo: 'ESCUELA');
    when(() => repo.encuentros('l1')).thenAnswer((_) async => const []);
    when(() => repo.clasificacion('l1')).thenAnswer((_) async => const []);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    expect(find.text('Escuelas'), findsNothing);
  });

  testWidgets('una liga en borrador se puede editar y guarda los cambios', (tester) async {
    _alto(tester);
    final liga = Liga(
      id: 'l1', nombre: 'Liga vieja', estado: 'borrador', deporte: 'Tenis', deporteId: 'TENIS', tipo: 'ESCUELA',
      fechaInicio: DateTime(2026, 10, 3), fechaFin: DateTime(2027, 5, 31),
    );
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => [liga]);
    when(() => repo.editarLiga('l1',
        nombre: any(named: 'nombre'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1', orgTipo: 'ESCUELA'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editar-l1')));
    await tester.pumpAndSettle();

    expect(find.text('Editar liga'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Liga nueva');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    verify(() => repo.editarLiga('l1',
        nombre: 'Liga nueva', fechaInicio: DateTime(2026, 10, 3), fechaFin: DateTime(2027, 5, 31))).called(1);
  });

  testWidgets('una liga publicada no ofrece editar', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga', estado: 'publicada', deporte: 'Tenis')]);
    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editar-l1')), findsNothing);
  });

  testWidgets('generar calendario llama al repo con la fecha elegida y avisa del nº de encuentros', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga infantil', estado: 'publicada', deporte: 'Tenis')]);
    when(() => repo.generarCalendario('l1',
        inicio: any(named: 'inicio'), diasEntreJornadas: any(named: 'diasEntreJornadas'), vueltas: any(named: 'vueltas')))
        .thenAnswer((_) async => 15);

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    expect(find.text('Tenis · Abierta a inscripción'), findsOneWidget);

    await tester.tap(find.text('Generar calendario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();

    final h = DateTime.now();
    verify(() => repo.generarCalendario('l1', inicio: DateTime(h.year, h.month, h.day), diasEntreJornadas: 7, vueltas: 1))
        .called(1);
    expect(find.text('Calendario generado: 15 encuentros.'), findsOneWidget);
  });

  testWidgets('generar calendario traduce los errores del servidor', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga', estado: 'en_curso')]);
    when(() => repo.generarCalendario('l1',
        inicio: any(named: 'inicio'), diasEntreJornadas: any(named: 'diasEntreJornadas'), vueltas: any(named: 'vueltas')))
        .thenThrow(Exception('ya hay resultados registrados; no se puede regenerar'));

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

  testWidgets('un encuentro finalizado muestra el detalle y permite corregir', (tester) async {
    _alto(tester);
    when(() => repo.detalleEncuentro('enc1')).thenAnswer((_) async => _detalle);
    await tester.pumpWidget(_app(repo, const ResultadoPage(escuelaId: 'e1', encuentro: _enc)));
    await tester.pumpAndSettle();
    expect(find.textContaining('6-3', skipOffstage: false), findsOneWidget);
    expect(find.text('Corregir resultado'), findsOneWidget);
  });

  testWidgets('un encuentro programado ofrece registrar el resultado', (tester) async {
    when(() => repo.detalleEncuentro('enc2')).thenAnswer((_) async => const DetalleEncuentro(partidos: []));
    await tester.pumpWidget(_app(repo, const ResultadoPage(escuelaId: 'e1', encuentro: _pendiente)));
    await tester.pumpAndSettle();
    expect(find.text('Registrar resultado'), findsOneWidget);
    expect(find.byKey(const Key('editar-resultado')), findsOneWidget);
  });

  testWidgets('el organizador acepta o rechaza las solicitudes pendientes de inscripción', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Liga', estado: 'publicada', deporte: 'Tenis', deporteId: 'TENIS', tipo: 'ENTRE_ESCUELAS');
    InscripcionVista insc(String id, String estado) => InscripcionVista(
        id: id, ligaId: 'l1', equipoId: 'eq$id', equipo: 'Equipo $id', escuelaId: 'eB', escuela: 'Escuela B', estado: estado);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => const []);
    when(() => repo.clasificacion('l1')).thenAnswer((_) async => const []);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => [insc('i1', 'pendiente'), insc('i2', 'pendiente'), insc('i3', 'aceptada')]);
    when(() => repo.resolverInscripcion(any(), aceptar: any(named: 'aceptar'))).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    expect(find.text('Solicitudes (2)'), findsOneWidget);
    await tester.tap(find.text('Solicitudes (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Equipo i3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('aceptar-i1')));
    await tester.pumpAndSettle();
    verify(() => repo.resolverInscripcion('i1', aceptar: true)).called(1);
    await tester.tap(find.byKey(const Key('rechazar-i2')));
    await tester.pumpAndSettle();
    verify(() => repo.resolverInscripcion('i2', aceptar: false)).called(1);
  });

  testWidgets('editar la puntuación de una liga en borrador la guarda', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Liga', estado: 'borrador', deporte: 'Tenis', deporteId: 'TENIS', tipo: 'ESCUELA');
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const [liga]);
    when(() => repo.editarLiga('l1',
        nombre: any(named: 'nombre'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin')))
        .thenAnswer((_) async {});
    when(() => repo.configurarPuntuacion('l1', any())).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1', orgTipo: 'ESCUELA'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editar-l1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('puntos-victoria')), '2');
    await tester.enterText(find.byKey(const Key('puntos-empate')), '0');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    verify(() => repo.configurarPuntuacion('l1', (victoria: 2, empate: 0, derrota: 0))).called(1);
  });

  testWidgets('con varias categorías el calendario y la clasificación se separan', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Liga', estado: 'en_curso', deporteId: 'TENIS', tipo: 'ESCUELA');
    EncuentroVista enc(String id, String cat, String a, String b) => EncuentroVista(
        id: id, ligaId: 'l1', jornada: 1, estado: 'programado', localId: 'x$id', local: a,
        visitanteId: 'y$id', visitante: b, categoria: cat);
    FilaClasificacion fila(String cat, int pos, String eq) => FilaClasificacion(
        posicion: pos, equipoId: eq, equipo: eq, escuela: 'Esc', pj: 0, pg: 0, pe: 0, pp: 0, puntos: 0,
        partidosF: 0, partidosC: 0, setsF: 0, setsC: 0, juegosF: 0, juegosC: 0, categoria: cat);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [enc('1', 'General', 'A', 'B'), enc('2', 'Sub-10', 'C', 'D')]);
    when(() => repo.clasificacion('l1')).thenAnswer(
        (_) async => [fila('General', 1, 'A'), fila('General', 2, 'B'), fila('Sub-10', 1, 'C'), fila('Sub-10', 2, 'D')]);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);

    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('General · Jornada 1'), findsOneWidget);
    expect(find.textContaining('Sub-10 · Jornada 1'), findsOneWidget);

    await tester.tap(find.text('Clasificación'));
    await tester.pumpAndSettle();
    expect(find.text('General'), findsOneWidget); // título de categoría
    expect(find.text('Sub-10'), findsOneWidget);
    expect(find.byType(TablaClasificacion), findsNWidgets(2));
  });

  Future<void> abrirAjustes(WidgetTester tester, Liga liga, {bool coorganizador = false}) async {
    _alto(tester);
    when(() => repo.encuentros(liga.id)).thenAnswer((_) async => const []);
    when(() => repo.clasificacion(liga.id)).thenAnswer((_) async => const []);
    when(() => repo.inscripciones(liga.id)).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, LigaDetallePage(liga: liga, escuelaId: 'e1', coorganizador: coorganizador)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
  }

  const ligaAjustes = Liga(
      id: 'l1', nombre: 'Liga', estado: 'borrador', deporteId: 'TENIS', tipo: 'ESCUELA',
      puntuacion: (victoria: 2, empate: 1, derrota: 0));

  testWidgets('ajustes: muestra la puntuación y permite crear y eliminar categorías', (tester) async {
    var cats = const [CategoriaLiga(id: 'c1', ligaId: 'l1', nombre: 'General')];
    when(() => repo.categorias('l1')).thenAnswer((_) async => cats);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => const []);
    when(() => repo.crearCategoria('l1', 'Sub-12', genero: 'FEMENINO', edadMin: null, edadMax: 12, nivel: null))
        .thenAnswer((_) async {
      cats = [...cats, const CategoriaLiga(id: 'c2', ligaId: 'l1', nombre: 'Sub-12', genero: 'FEMENINO', edadMax: 12)];
    });
    when(() => repo.eliminarCategoria('c2')).thenAnswer((_) async {
      cats = cats.where((c) => c.id != 'c2').toList();
    });

    await abrirAjustes(tester, ligaAjustes);
    expect(find.text('Victoria 2 · Empate 1 · Derrota 0'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nueva-categoria')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoria-nombre')), 'Sub-12');
    await tester.tap(find.byKey(const Key('categoria-genero')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Femenino').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoria-edad-max')), '12');
    await tester.tap(find.text('Crear categoría'));
    await tester.pumpAndSettle();
    verify(() => repo.crearCategoria('l1', 'Sub-12', genero: 'FEMENINO', edadMin: null, edadMax: 12, nivel: null)).called(1);
    expect(find.text('Sub-12'), findsOneWidget);
    expect(find.text('Femenino · hasta 12 años'), findsOneWidget);

    await tester.tap(find.byKey(const Key('eliminar-categoria-c2')));
    await tester.pumpAndSettle();
    verify(() => repo.eliminarCategoria('c2')).called(1);
    expect(find.text('Sub-12'), findsNothing);
  });

  testWidgets('ajustes: el nombre de la categoría es obligatorio y los errores del servidor se traducen', (tester) async {
    when(() => repo.categorias('l1')).thenAnswer((_) async => const [CategoriaLiga(id: 'c1', ligaId: 'l1', nombre: 'General')]);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => const []);
    when(() => repo.eliminarCategoria('c1')).thenAnswer((_) async => throw Exception('la liga necesita al menos una categoría'));

    await abrirAjustes(tester, ligaAjustes);
    await tester.tap(find.byKey(const Key('nueva-categoria')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear categoría'));
    await tester.pumpAndSettle();
    expect(find.text('Introduce el nombre'), findsOneWidget);
    verifyNever(() => repo.crearCategoria(any(), any(),
        genero: any(named: 'genero'), edadMin: any(named: 'edadMin'), edadMax: any(named: 'edadMax'), nivel: any(named: 'nivel')));
    await tester.tapAt(const Offset(5, 5)); // cierra la hoja
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('eliminar-categoria-c1')));
    await tester.pumpAndSettle();
    expect(find.text('La liga necesita al menos una categoría.'), findsOneWidget);
  });

  testWidgets('ajustes: se añade y se quita un co-organizador', (tester) async {
    var orgs = const <OrganizadorLiga>[];
    when(() => repo.categorias('l1')).thenAnswer((_) async => const []);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => orgs);
    when(() => repo.asignarOrganizador('l1', 'ana@x.es')).thenAnswer((_) async {
      orgs = const [OrganizadorLiga(usuarioId: 'u7', email: 'ana@x.es', nombre: 'Ana Gil')];
      return 'asignado';
    });
    when(() => repo.quitarOrganizador('l1', 'u7')).thenAnswer((_) async {
      orgs = const [];
    });

    await abrirAjustes(tester, ligaAjustes);
    expect(find.text('Todavía no hay co-organizadores.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nuevo-organizador')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('organizador-email')), 'ana@x.es');
    await tester.tap(find.text('Añadir').last);
    await tester.pumpAndSettle();
    verify(() => repo.asignarOrganizador('l1', 'ana@x.es')).called(1);
    expect(find.text('Ana Gil · ana@x.es'), findsOneWidget);
    expect(find.text('Organizador añadido.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quitar-organizador-u7')));
    await tester.pumpAndSettle();
    verify(() => repo.quitarOrganizador('l1', 'u7')).called(1);
    expect(find.text('Todavía no hay co-organizadores.'), findsOneWidget);
  });

  testWidgets('ajustes: un correo sin cuenta queda como invitación pendiente y se puede retirar', (tester) async {
    var orgs = const <OrganizadorLiga>[];
    when(() => repo.categorias('l1')).thenAnswer((_) async => const []);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => orgs);
    when(() => repo.asignarOrganizador('l1', 'nuevo@x.es')).thenAnswer((_) async {
      orgs = const [OrganizadorLiga(email: 'nuevo@x.es', pendiente: true)];
      return 'invitado';
    });
    when(() => repo.retirarInvitacionOrganizador('l1', 'nuevo@x.es')).thenAnswer((_) async {
      orgs = const [];
    });

    await abrirAjustes(tester, ligaAjustes);
    await tester.tap(find.byKey(const Key('nuevo-organizador')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('organizador-email')), 'nuevo@x.es');
    await tester.tap(find.text('Añadir').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('cuando se registre con ese correo'), findsWidgets); // aviso (y texto de ayuda)
    expect(find.text('nuevo@x.es'), findsOneWidget);
    expect(find.text('Pendiente de registrarse'), findsOneWidget);
    // no se quita por usuario (aún no existe): se retira la invitación por correo
    expect(find.byKey(const Key('quitar-organizador-null')), findsNothing);
    await tester.tap(find.byKey(const Key('retirar-invitacion-nuevo@x.es')));
    await tester.pumpAndSettle();
    verify(() => repo.retirarInvitacionOrganizador('l1', 'nuevo@x.es')).called(1);
    verifyNever(() => repo.quitarOrganizador(any(), any()));
    expect(find.text('Todavía no hay co-organizadores.'), findsOneWidget);
  });

  testWidgets('ajustes: errores de correo se traducen', (tester) async {
    when(() => repo.categorias('l1')).thenAnswer((_) async => const []);
    when(() => repo.organizadores('l1')).thenAnswer((_) async => const []);
    when(() => repo.asignarOrganizador('l1', 'dup@x.es'))
        .thenAnswer((_) async => throw Exception('ya está invitado como organizador de esta liga'));
    await abrirAjustes(tester, ligaAjustes);
    await tester.tap(find.byKey(const Key('nuevo-organizador')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('organizador-email')), 'dup@x.es');
    await tester.tap(find.text('Añadir').last);
    await tester.pumpAndSettle();
    expect(find.text('Esa persona ya está invitada a esta liga.'), findsOneWidget);
  });

  // ───────── Formatos: eliminatoria y grupos + playoff ─────────
  EncuentroVista encF(String id, String a, String b,
          {String fase = 'liga', int jornada = 1, int? grupo, int? llaves, int? llave, String? categoria}) =>
      EncuentroVista(
          id: id, ligaId: 'l1', jornada: jornada, estado: 'programado', localId: 'x$a', local: a,
          visitanteId: 'x$b', visitante: b, fase: fase, grupo: grupo, llaves: llaves, llave: llave, categoria: categoria);

  test('nombres de ronda y de grupo', () {
    expect(nombreRonda(1, 3), 'Final');
    expect(nombreRonda(2, 2), 'Semifinales');
    expect(nombreRonda(4, 1), 'Cuartos de final');
    expect(nombreRonda(8, 1), 'Octavos de final');
    expect(nombreRonda(16, 1), 'Ronda de 32');
    expect(nombreRonda(null, 2), 'Ronda 2');
    expect(nombreGrupo(1), 'Grupo A');
    expect(nombreGrupo(3), 'Grupo C');
    expect(encF('1', 'A', 'B', fase: 'eliminatoria', llaves: 1).etiquetaJornada, 'Final');
    expect(encF('1', 'A', 'B', jornada: 4).etiquetaJornada, 'Jornada 4');
  });

  test('agruparEncuentros separa grupos y fases aunque repitan número de jornada', () {
    final g = agruparEncuentros([
      encF('1', 'A', 'B', grupo: 1),
      encF('2', 'C', 'D', grupo: 2),
      encF('3', 'A', 'C', fase: 'eliminatoria', llaves: 1),
      encF('4', 'B', 'A', grupo: 1, jornada: 2),
    ]);
    expect(g.map((x) => x.titulo), ['Grupo A · Jornada 1', 'Grupo A · Jornada 2', 'Grupo B · Jornada 1', 'Final']);
    expect(g.first.equiposDelGrupo, {'xA', 'xB'}); // para asignar los descansos al grupo correcto
  });

  test('mensajeError traduce los errores de eliminatoria', () {
    expect(mensajeError(Exception('en eliminatoria no puede haber empate: se necesita un ganador')),
        'En una eliminatoria no puede haber empate: debe haber un ganador.');
    expect(mensajeError(Exception('el playoff ya tiene resultados; no se puede regenerar')),
        'El playoff ya tiene resultados: no se puede regenerar.');
    expect(mensajeError(Exception('la fase de grupos no ha terminado')), 'La fase de grupos aún no ha terminado.');
  });

  testWidgets('crear una eliminatoria: no pide puntuación y envía el formato', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('puntos-victoria')), findsOneWidget); // en liga sí
    await tester.enterText(find.byType(TextFormField).first, 'Copa de primavera');
    await tester.tap(find.text('Eliminatoria'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('puntos-victoria')), findsNothing);
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'e1', deporteId: deportesDisponibles.first.id, nombre: 'Copa de primavera',
          tipo: 'ENTRE_ESCUELAS', fechaInicio: null, fechaFin: null, visibilidad: 'PUBLICA',
          puntuacion: puntuacionPorDefecto, formato: 'ELIMINATORIA',
        )).called(1);
  });

  testWidgets('crear una liga de grupos y playoff conserva la puntuación', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
          visibilidad: any(named: 'visibilidad'), puntuacion: any(named: 'puntuacion'),
          formato: any(named: 'formato'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Torneo por grupos');
    await tester.tap(find.text('Grupos y playoff'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('puntos-victoria')), findsOneWidget);
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'e1', deporteId: deportesDisponibles.first.id, nombre: 'Torneo por grupos',
          tipo: 'ENTRE_ESCUELAS', fechaInicio: null, fechaFin: null, visibilidad: 'PUBLICA',
          puntuacion: puntuacionPorDefecto, formato: 'MIXTO',
        )).called(1);
  });

  testWidgets('eliminatoria: «Generar cuadro» llama a generarEliminatoria', (tester) async {
    final liga = Liga(id: 'l1', nombre: 'Copa', estado: 'publicada', deporte: 'Tenis', formato: 'ELIMINATORIA',
        fechaInicio: DateTime(2026, 10, 3));
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => [liga]);
    when(() => repo.generarEliminatoria('l1', inicio: any(named: 'inicio'))).thenAnswer((_) async => 2);

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    expect(find.text('Tenis · Abierta a inscripción · Eliminatoria'), findsOneWidget);
    expect(find.text('Generar calendario'), findsNothing);
    await tester.tap(find.text('Generar cuadro'));
    await tester.pumpAndSettle();
    expect(find.text('Días entre jornadas'), findsNothing); // no aplica a una eliminatoria
    expect(find.text('Ida y vuelta'), findsNothing);
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();

    verify(() => repo.generarEliminatoria('l1', inicio: DateTime(2026, 10, 3))).called(1);
    expect(find.text('Cuadro generado: 2 encuentros en la primera ronda.'), findsOneWidget);
  });

  testWidgets('grupos y playoff: genera la fase de grupos con N grupos y después el playoff', (tester) async {
    final liga = Liga(id: 'l1', nombre: 'Torneo', estado: 'en_curso', deporte: 'Tenis', formato: 'MIXTO',
        fechaInicio: DateTime(2026, 10, 3));
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => [liga]);
    when(() => repo.generarCalendario('l1',
        inicio: any(named: 'inicio'), diasEntreJornadas: any(named: 'diasEntreJornadas'),
        vueltas: any(named: 'vueltas'), grupos: any(named: 'grupos'))).thenAnswer((_) async => 12);
    when(() => repo.generarPlayoff('l1', clasifican: any(named: 'clasifican'), inicio: any(named: 'inicio')))
        .thenAnswer((_) async => 2);

    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar grupos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('generar-grupos')), '3');
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();
    verify(() => repo.generarCalendario('l1', inicio: DateTime(2026, 10, 3), diasEntreJornadas: 7, vueltas: 1, grupos: 3))
        .called(1);
    expect(find.text('Fase de grupos generada: 12 encuentros.'), findsOneWidget);

    await tester.tap(find.text('Generar playoff'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('playoff-clasifican')), '1');
    await tester.tap(find.text('Generar'));
    await tester.pumpAndSettle();
    verify(() => repo.generarPlayoff('l1', clasifican: 1, inicio: DateTime(2026, 10, 3))).called(1);
    expect(find.text('Playoff generado: 2 encuentros en la primera ronda.'), findsOneWidget);
  });

  testWidgets('el botón de playoff solo aparece en una liga de grupos en curso', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const [
          Liga(id: 'l1', nombre: 'Aún en inscripción', estado: 'publicada', formato: 'MIXTO'),
          Liga(id: 'l2', nombre: 'Liga normal', estado: 'en_curso'),
        ]);
    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1'))));
    await tester.pumpAndSettle();
    expect(find.text('Generar playoff'), findsNothing);
  });

  testWidgets('el cuadro de una eliminatoria muestra rondas, pases directos y no tiene clasificación', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Copa', estado: 'en_curso', deporteId: 'TENIS', tipo: 'ESCUELA', formato: 'ELIMINATORIA');
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [
          encF('1', 'T4', 'T5', fase: 'eliminatoria', llaves: 4, llave: 2),
          encF('2', 'T1', 'T4', fase: 'eliminatoria', jornada: 2, llaves: 2, llave: 1),
          encF('3', 'T2', 'T3', fase: 'eliminatoria', jornada: 2, llaves: 2, llave: 2),
        ]);
    when(() => repo.pasanDirecto('l1')).thenAnswer((_) async => const [
          Descanso(jornada: 1, equipoId: 'xT1', equipo: 'T1', llave: 1),
          Descanso(jornada: 1, equipoId: 'xT2', equipo: 'T2', llave: 3),
          Descanso(jornada: 1, equipoId: 'xT3', equipo: 'T3', llave: 4),
        ]);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);

    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    expect(find.text('Cuadro'), findsOneWidget); // la pestaña
    expect(find.text('Clasificación'), findsNothing);
    // vista inicial: el cuadro dibujado, con una columna por ronda (la final aún por determinar)
    expect(find.text('Cuartos de final'), findsOneWidget);
    expect(find.text('Semifinales'), findsOneWidget);
    expect(find.text('Final'), findsOneWidget);
    expect(find.text('Pase directo'), findsNWidgets(3));
    expect(find.text('Por determinar'), findsNWidgets(2));

    // la lista sigue disponible y conserva las cabeceras y los pases directos
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cuartos de final · '), findsOneWidget);
    expect(find.textContaining('Semifinales · '), findsOneWidget);
    expect(find.text('Pasa directo: T1'), findsOneWidget);
    expect(find.text('Pasa directo: T2'), findsOneWidget);
    expect(find.text('Por determinar'), findsNothing);

    await tester.tap(find.text('Llaves'));
    await tester.pumpAndSettle();
    expect(find.text('Por determinar'), findsNWidgets(2));
  });

  testWidgets('grupos y playoff: calendario por grupo y ronda, y clasificación por grupo', (tester) async {
    _alto(tester);
    const liga = Liga(id: 'l1', nombre: 'Torneo', estado: 'en_curso', deporteId: 'TENIS', tipo: 'ESCUELA', formato: 'MIXTO');
    FilaClasificacion fila(int grupo, int pos, String eq) => FilaClasificacion(
        posicion: pos, equipoId: eq, equipo: eq, escuela: 'Esc', pj: 0, pg: 0, pe: 0, pp: 0, puntos: 0,
        partidosF: 0, partidosC: 0, setsF: 0, setsC: 0, juegosF: 0, juegosC: 0, grupo: grupo);
    when(() => repo.encuentros('l1')).thenAnswer((_) async => [
          encF('1', 'A', 'B', grupo: 1),
          encF('2', 'C', 'D', grupo: 2),
          encF('3', 'A', 'C', fase: 'eliminatoria', llaves: 1),
        ]);
    when(() => repo.pasanDirecto('l1')).thenAnswer((_) async => const []);
    when(() => repo.clasificacion('l1')).thenAnswer(
        (_) async => [fila(1, 1, 'A'), fila(1, 2, 'B'), fila(2, 1, 'C'), fila(2, 2, 'D')]);
    when(() => repo.inscripciones('l1')).thenAnswer((_) async => const []);

    await tester.pumpWidget(_app(repo, const LigaDetallePage(liga: liga, escuelaId: 'e1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Grupo A · Jornada 1'), findsOneWidget);
    expect(find.textContaining('Grupo B · Jornada 1'), findsOneWidget);
    expect(find.textContaining('Final'), findsWidgets); // sección «Final» (y la insignia de la tarjeta)

    await tester.tap(find.text('Clasificación'));
    await tester.pumpAndSettle();
    expect(find.text('Grupo A'), findsOneWidget);
    expect(find.text('Grupo B'), findsOneWidget);
    expect(find.byType(TablaClasificacion), findsNWidgets(2));
  });

  testWidgets('ajustes: un co-organizador ve la lista pero no puede añadir ni quitar', (tester) async {
    when(() => repo.categorias('l1')).thenAnswer((_) async => const []);
    when(() => repo.organizadores('l1')).thenAnswer(
        (_) async => const [OrganizadorLiga(usuarioId: 'u7', email: 'ana@x.es')]);

    await abrirAjustes(tester, ligaAjustes, coorganizador: true);
    expect(find.text('ana@x.es'), findsOneWidget);
    expect(find.byKey(const Key('nuevo-organizador')), findsNothing);
    expect(find.byKey(const Key('quitar-organizador-u7')), findsNothing);
  });

  testWidgets('un co-organizador no ve «Nueva liga»', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, const Scaffold(body: LigasTab(escuelaId: 'e1', coorganizador: true))));
    await tester.pumpAndSettle();
    expect(find.text('Nueva liga'), findsNothing);
    expect(find.text('Aún no tienes ligas asignadas.'), findsOneWidget);
  });

  // ───────── Equipo: el organizador invita a otros organizadores ─────────
  const ana = UsuarioEscuela(usuarioId: 'u1', email: 'ana@x.es', nombre: 'Ana Gil', rol: 'ORGANIZADOR_LIGAS');

  Future<void> abrirEquipo(WidgetTester tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, const Scaffold(body: OrganizadorHome(escuelaId: 'e1', escuelaNombre: 'Ayuntamiento'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
  }

  testWidgets('la pestaña Equipo lista a los organizadores de la organización', (tester) async {
    when(() => repo.organizadoresOrg('e1')).thenAnswer((_) async => const [
          ana,
          UsuarioEscuela(usuarioId: 'u2', email: 'luis@x.es', rol: 'ORGANIZADOR_LIGAS'),
        ]);
    await abrirEquipo(tester);
    expect(find.text('Ana Gil'), findsOneWidget);
    expect(find.text('ana@x.es'), findsOneWidget);
    expect(find.text('luis@x.es'), findsOneWidget); // sin nombre se muestra el correo
  });

  testWidgets('invitar a un organizador: solo pide el correo y envía el rol de organizador', (tester) async {
    var lista = const <UsuarioEscuela>[];
    when(() => repo.organizadoresOrg('e1')).thenAnswer((_) async => lista);
    when(() => repo.invitar('e1', 'ana@x.es', Rol.organizadorLiga, jugadorId: null)).thenAnswer((_) async {
      lista = const [ana];
    });
    await abrirEquipo(tester);
    expect(find.text('Todavía no hay organizadores.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('invitar-organizador')));
    await tester.pumpAndSettle();
    // el rol está fijado: no se ofrece elegir otro (no puede dar más poder del que tiene)
    expect(find.byKey(const Key('invitar-rol-entrenador')), findsNothing);
    expect(find.byKey(const Key('invitar-rol-adminEscuela')), findsNothing);
    await tester.enterText(find.byKey(const Key('invitar-email')), 'ana@x.es');
    await tester.tap(find.text('Enviar invitación'));
    await tester.pumpAndSettle();

    verify(() => repo.invitar('e1', 'ana@x.es', Rol.organizadorLiga, jugadorId: null)).called(1);
    expect(find.text('Ana Gil'), findsOneWidget); // la lista se refresca
  });

  testWidgets('si el servidor deniega la invitación se muestra un mensaje claro', (tester) async {
    when(() => repo.organizadoresOrg('e1')).thenAnswer((_) async => const []);
    when(() => repo.invitar(any(), any(), any(), jugadorId: any(named: 'jugadorId')))
        .thenAnswer((_) async => throw Exception('sin permiso para invitar'));
    await abrirEquipo(tester);
    await tester.tap(find.byKey(const Key('invitar-organizador')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invitar-email')), 'x@x.es');
    await tester.tap(find.text('Enviar invitación'));
    await tester.pumpAndSettle();
    expect(find.text('No tienes permiso para hacer esto.'), findsOneWidget);
  });

  testWidgets('un co-organizador no ve la pestaña Equipo', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo,
        const Scaffold(body: OrganizadorHome(escuelaId: 'e1', escuelaNombre: 'Ayuntamiento', coorganizador: true))));
    await tester.pumpAndSettle();
    expect(find.text('Equipo'), findsNothing);
    expect(find.text('Nueva liga'), findsNothing);
  });

  testWidgets('el área organizador muestra solo las ligas', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, const Scaffold(body: OrganizadorHome(escuelaId: 'e1', escuelaNombre: 'Escuela A'))));
    await tester.pumpAndSettle();
    expect(find.text('Nueva liga'), findsOneWidget);
    expect(find.text('Pendientes'), findsNothing);
    expect(find.text('Correcciones'), findsNothing);
  });
}
