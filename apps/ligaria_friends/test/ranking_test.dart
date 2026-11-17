import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/auth/auth_repositorio.dart';
import 'package:ligaria_friends/features/jugador/ajustes/ajustes_page.dart';
import 'package:ligaria_friends/features/jugador/ajustes/ajustes_repositorio.dart';
import 'package:ligaria_friends/features/jugador/grupos/grupos_repositorio.dart';
import 'package:ligaria_friends/features/jugador/ranking/ranking_page.dart';
import 'package:ligaria_friends/features/jugador/ranking/ranking_repositorio.dart';

/// Varios pasos: los `Future` y las animaciones de entrada necesitan más de un frame.
Future<void> _pump(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Ventana alta para que la lista construya todos los elementos.
void _ventanaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets(
    'Ajustes: muestra los datos, el email está bloqueado y se guardan',
    (tester) async {
      _ventanaAlta(tester);
      final repo = AjustesDemo();
      await tester.pumpWidget(
        MaterialApp(
          home: AjustesPage(repo: repo, auth: AuthDemo()),
        ),
      );
      await _pump(tester);

      expect(find.text('Tus datos'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Recibir notificaciones'), findsOneWidget);
      // El email es el usuario registrado: el campo está deshabilitado.
      final email = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'demo@ligaria.es'),
      );
      expect(email.enabled, isFalse);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Demo'),
        'Marta',
      );
      await tester.tap(find.text('Guardar datos'));
      await _pump(tester);
      expect((await repo.perfil()).nombre, 'Marta');
      expect((await repo.perfil()).email, 'demo@ligaria.es');
    },
  );

  testWidgets('Ajustes: los interruptores guardan cada preferencia', (
    tester,
  ) async {
    _ventanaAlta(tester);
    final repo = AjustesDemo();
    await tester.pumpWidget(MaterialApp(home: AjustesPage(repo: repo)));
    await _pump(tester);
    expect((await repo.perfil()).rankingGlobal, isFalse);
    expect((await repo.perfil()).notificaciones, isTrue);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Ranking global'));
    await _pump(tester);
    expect((await repo.perfil()).rankingGlobal, isTrue);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Recibir notificaciones'),
    );
    await _pump(tester);
    expect((await repo.perfil()).notificaciones, isFalse);
  });

  testWidgets('Ranking: Global, Provincia, Localidad y Mis grupos', (
    tester,
  ) async {
    _ventanaAlta(tester);
    final grupos = GruposDemo();
    await grupos.crear(nombre: 'Viernes');
    AjustesRepositorio.instancia = AjustesDemo();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RankingPage(repo: RankingDemo(), grupos: grupos),
        ),
      ),
    );
    await _pump(tester);
    expect(find.text('Lucía'), findsOneWidget); // global
    expect(find.text('No apareces en este ranking'), findsOneWidget);

    await tester.tap(find.text('Provincia'));
    await _pump(tester);
    expect(find.text('Carlos'), findsOneWidget);
    expect(find.text('Lucía'), findsNothing);

    await tester.tap(find.text('Localidad'));
    await _pump(tester);
    expect(find.text('Carlos'), findsNothing);
    expect(find.text('Demo'), findsOneWidget);

    await tester.tap(find.text('Mis grupos'));
    await _pump(tester);
    expect(find.text('Amigo 1'), findsOneWidget);
  });
}
