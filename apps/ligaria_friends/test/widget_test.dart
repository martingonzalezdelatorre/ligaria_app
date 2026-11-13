import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/auth/auth_repositorio.dart';
import 'package:ligaria_friends/features/auth/nueva_password_page.dart';
import 'package:ligaria_friends/main.dart';
import 'package:ligaria_ui/ligaria_ui.dart';

/// El fondo aurora anima en bucle, así que `pumpAndSettle` nunca termina.
Future<void> avanzar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  pruebasRecuperacion();
  testWidgets('arranca en el login con recuperar y registro', (tester) async {
    await tester.pumpWidget(LigariaFriendsApp(auth: AuthDemo()));
    await avanzar(tester);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('login correcto lleva al inicio', (tester) async {
    await tester.pumpWidget(LigariaFriendsApp(auth: AuthDemo()));
    await avanzar(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'demo@ligaria.es');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
    await tester.tap(find.text('Iniciar sesión'));
    await avanzar(tester);
    await avanzar(tester);
    expect(find.textContaining('Aún no tienes grupos'), findsOneWidget);
  });

  testWidgets('credenciales incorrectas muestran error', (tester) async {
    await tester.pumpWidget(LigariaFriendsApp(auth: AuthDemo()));
    await avanzar(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'demo@ligaria.es');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta1');
    await tester.tap(find.text('Iniciar sesión'));
    await avanzar(tester);
    await avanzar(tester);
    expect(find.text('Email o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('abre recuperación y registro (pantalla ancha)', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(LigariaFriendsApp(auth: AuthDemo()));
    await avanzar(tester);
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await avanzar(tester);
    expect(find.text('Recupera tu contraseña'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await avanzar(tester);
    await tester.tap(find.text('Crear cuenta'));
    await avanzar(tester);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('móvil sin desbordes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(LigariaFriendsApp(auth: AuthDemo()));
    await avanzar(tester);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void pruebasRecuperacion() {
  testWidgets('pantalla de contraseña nueva valida y guarda', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var terminado = false;
    await tester.pumpWidget(MaterialApp(
      theme: temaOscuro(),
      home: NuevaPasswordPage(auth: AuthDemo(), onTerminar: () => terminado = true),
    ));
    await avanzar(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'nuevaclave1');
    await tester.enterText(find.byType(TextFormField).at(1), 'distinta99');
    await tester.tap(find.text('Guardar contraseña'));
    await avanzar(tester);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(terminado, isFalse);
    await tester.enterText(find.byType(TextFormField).at(1), 'nuevaclave1');
    await tester.tap(find.text('Guardar contraseña'));
    await avanzar(tester);
    await avanzar(tester);
    expect(terminado, isTrue);
  });
}
