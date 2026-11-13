import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/organizador/crear_liga_page.dart';
import 'package:ligaria_app/features/organizador/ligas_tab.dart';
import 'package:ligaria_app/features/organizador/organizador_home.dart';
import 'package:ligaria_app/features/organizador/resultado_page.dart';
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

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));
  setUp(() => repo = MockRepo());

  testWidgets('crear liga envía organización, deporte, tipo y nombre', (tester) async {
    _alto(tester);
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    when(() => repo.crearLiga(
          orgId: any(named: 'orgId'), deporteId: any(named: 'deporteId'), nombre: any(named: 'nombre'),
          tipo: any(named: 'tipo'), fechaInicio: any(named: 'fechaInicio'), fechaFin: any(named: 'fechaFin'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo, const CrearLigaPage(escuelaId: 'e1', orgTipo: 'ESCUELA')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '  Liga infantil  ');
    await tester.ensureVisible(find.text('Crear liga'));
    await tester.tap(find.text('Crear liga'));
    await tester.pumpAndSettle();

    verify(() => repo.crearLiga(
          orgId: 'e1', deporteId: deportesDisponibles.first.id, nombre: 'Liga infantil',
          tipo: 'ENTRE_ESCUELAS', fechaInicio: null, fechaFin: null,
        )).called(1);
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

  testWidgets('el área organizador muestra solo las ligas', (tester) async {
    when(() => repo.ligasOrganizadas('e1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(_app(repo, const Scaffold(body: OrganizadorHome(escuelaId: 'e1', escuelaNombre: 'Escuela A'))));
    await tester.pumpAndSettle();
    expect(find.text('Nueva liga'), findsOneWidget);
    expect(find.text('Pendientes'), findsNothing);
    expect(find.text('Correcciones'), findsNothing);
  });
}
