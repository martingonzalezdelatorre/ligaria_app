import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_app/core/auth.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/features/superadmin/superadmin_home.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements LigaRepository {}

Widget _app(MockRepo repo) => ProviderScope(
      overrides: [ligaRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: Scaffold(body: SuperadminHome())),
    );

void main() {
  late MockRepo repo;
  setUp(() => repo = MockRepo());

  testWidgets('lista organizaciones con su tipo y administradores', (tester) async {
    when(() => repo.organizaciones()).thenAnswer((_) async => const [
          OrganizacionAdmin(id: 'o1', nombre: 'Escuela A', tipo: 'ESCUELA', ciudad: 'Sevilla', activa: true, administradores: 1),
          OrganizacionAdmin(id: 'o2', nombre: 'Ayto B', tipo: 'AYUNTAMIENTO', activa: true),
        ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.text('Escuela A'), findsOneWidget);
    expect(find.textContaining('Sevilla'), findsOneWidget);
    expect(find.textContaining('1 admin.'), findsOneWidget);
    expect(find.textContaining('sin administrador'), findsOneWidget);
  });

  testWidgets('crear organización envía nombre, tipo y ciudad', (tester) async {
    when(() => repo.organizaciones()).thenAnswer((_) async => const []);
    when(() => repo.crearOrganizacion(any(), any(), ciudad: any(named: 'ciudad'))).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva organización'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Escuela Norte');
    await tester.enterText(find.widgetWithText(TextField, 'Ciudad (opcional)'), 'Cádiz');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    verify(() => repo.crearOrganizacion('Escuela Norte', 'ESCUELA', ciudad: 'Cádiz')).called(1);
  });

  testWidgets('asignar administrador invita con el rol de administrador de escuela', (tester) async {
    when(() => repo.organizaciones()).thenAnswer((_) async => const [
          OrganizacionAdmin(id: 'o1', nombre: 'Escuela A', tipo: 'ESCUELA', activa: true),
        ]);
    when(() => repo.invitar('o1', 'admin@x.es', Rol.adminEscuela)).thenAnswer((_) async {});

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin-o1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invitar-email')), 'admin@x.es');
    await tester.tap(find.text('Enviar invitación').last);
    await tester.pumpAndSettle();
    verify(() => repo.invitar('o1', 'admin@x.es', Rol.adminEscuela)).called(1);
  });

  testWidgets('la pestaña Ligas lista las ligas', (tester) async {
    when(() => repo.organizaciones()).thenAnswer((_) async => const []);
    when(() => repo.misLigas()).thenAnswer(
        (_) async => const [Liga(id: 'l1', nombre: 'Liga infantil', estado: 'en_curso', deporte: 'Tenis')]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ligas'));
    await tester.pumpAndSettle();
    expect(find.text('Liga infantil'), findsOneWidget);
    expect(find.text('Tenis · En curso'), findsOneWidget);
  });
}
