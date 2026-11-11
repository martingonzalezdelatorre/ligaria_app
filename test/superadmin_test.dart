import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/superadmin/superadmin_home.dart';
import 'package:ligaria_app/features/superadmin/superadmin_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

Widget _app(MockRepo repo) => ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: Scaffold(body: SuperadminHome())),
    );

void _vacios(MockRepo repo) {
  when(() => repo.temporadas()).thenAnswer((_) async => const []);
  when(() => repo.misLigas()).thenAnswer((_) async => const []);
  when(() => repo.registroCambios(limite: any(named: 'limite'))).thenAnswer((_) async => const []);
}

void main() {
  late MockRepo repo;
  setUp(() => repo = MockRepo());

  test('slugDe normaliza acentos y símbolos', () {
    expect(slugDe('Escuela Ñandú Norte'), 'escuela-nandu-norte');
    expect(slugDe('  Club  Tenis & Pádel! '), 'club-tenis-padel');
  });

  testWidgets('activar el módulo competiciones de una escuela llama al repo', (tester) async {
    _vacios(repo);
    when(() => repo.escuelas()).thenAnswer((_) async => const [
          EscuelaAdmin(id: 'e1', nombre: 'Escuela A', slug: 'a', activa: true, modulos: {'competiciones': false}),
        ]);
    when(() => repo.setModulo('e1', 'competiciones', true)).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    verify(() => repo.setModulo('e1', 'competiciones', true)).called(1);
  });

  testWidgets('crear escuela envía nombre y slug sugerido', (tester) async {
    _vacios(repo);
    when(() => repo.escuelas()).thenAnswer((_) async => const []);
    when(() => repo.crearEscuela(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva escuela'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Escuela Norte');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    verify(() => repo.crearEscuela('Escuela Norte', 'escuela-norte')).called(1);
  });

  testWidgets('crear temporada envía nombre y fechas por defecto', (tester) async {
    _vacios(repo);
    when(() => repo.escuelas()).thenAnswer((_) async => const []);
    when(() => repo.crearTemporada(any(), any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Temporadas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva temporada'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2026-27');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    final y = DateTime.now().year;
    verify(() => repo.crearTemporada('2026-27', DateTime(y, 9, 1), DateTime(y + 1, 6, 30))).called(1);
  });

  testWidgets('ligas y registro: lista ligas y filtra el registro por tabla', (tester) async {
    when(() => repo.escuelas()).thenAnswer((_) async => const []);
    when(() => repo.temporadas()).thenAnswer((_) async => const []);
    when(() => repo.misLigas()).thenAnswer((_) async => const [Liga(id: 'l1', nombre: 'Liga infantil', estado: 'en_curso', deporte: 'Tenis')]);
    when(() => repo.registroCambios(limite: any(named: 'limite'))).thenAnswer((_) async => [
          RegistroCambio(id: 1, tabla: 'competicion', accion: 'INSERT', fecha: DateTime(2026, 10, 1, 9, 30)),
          RegistroCambio(id: 2, tabla: 'encuentro', accion: 'UPDATE', fecha: DateTime(2026, 10, 2, 18, 5)),
        ]);

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    expect(find.text('Liga infantil'), findsOneWidget);
    expect(find.text('Tenis · En curso'), findsOneWidget);

    await tester.tap(find.text('Registro'));
    await tester.pumpAndSettle();
    expect(find.text('Alta · competicion'), findsOneWidget);
    expect(find.text('Modificación · encuentro'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('encuentro').last);
    await tester.pumpAndSettle();
    expect(find.text('Alta · competicion'), findsNothing);
    expect(find.text('Modificación · encuentro'), findsOneWidget);
  });
}
