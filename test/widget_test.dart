import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ligaria_app/data/liga_repository.dart';
import 'package:ligaria_app/data/models.dart';
import 'package:ligaria_app/core/auth.dart';
import 'package:ligaria_app/features/auth/login_page.dart';
import 'package:ligaria_app/features/cuenta/cuenta_page.dart';
import 'package:ligaria_app/features/home/home_page.dart';

class FakeAuth implements AuthRepository {
  FakeAuth({this.falla = false, this.perts = const []});
  final bool falla;
  final List<Pertenencia> perts;
  String? ultimoEmail;
  String? nuevaPass;
  final _c = StreamController<String?>.broadcast();

  @override
  String? get userId => 'u1';
  @override
  String? get email => 'ana@x.es';
  @override
  Stream<String?> get cambios => _c.stream;
  @override
  Future<void> iniciarSesion(String email, String password) async {
    ultimoEmail = email;
    if (falla) throw Exception('credenciales');
  }

  @override
  Future<void> cerrarSesion() async {}
  @override
  Future<void> cambiarPassword(String nueva) async => nuevaPass = nueva;
  @override
  Future<List<Pertenencia>> misPertenencias() async => perts;
}

class MockLigas extends Mock implements LigaRepository {}

MockLigas ligasMock({Map<String, bool> prefs = const {'resultados': true, 'calendario': true}, List<NotificacionApp> notifs = const []}) {
  final m = MockLigas();
  when(() => m.prefsNotificacion()).thenAnswer((_) async => prefs);
  when(() => m.notificaciones()).thenAnswer((_) async => notifs);
  when(() => m.guardarPrefsNotificacion(any())).thenAnswer((_) async {});
  when(() => m.marcarNotificacionLeida(any())).thenAnswer((_) async {});
  return m;
}

Widget app(FakeAuth repo, Widget home, {LigaRepository? ligas}) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        ligaRepositoryProvider.overrideWithValue(ligas ?? ligasMock()),
      ],
      child: MaterialApp(home: home),
    );

void main() {
  testWidgets('login valida campos y llama al repositorio', (tester) async {
    final repo = FakeAuth();
    await tester.pumpWidget(app(repo, const LoginPage()));
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Introduce un correo válido'), findsOneWidget);
    expect(repo.ultimoEmail, isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@x.es');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreta');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(repo.ultimoEmail, 'ana@x.es');
  });

  testWidgets('login muestra error si las credenciales fallan', (tester) async {
    await tester.pumpWidget(app(FakeAuth(falla: true), const LoginPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@x.es');
    await tester.enterText(find.byType(TextFormField).at(1), 'mala');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  test('áreas por rol: cada rol abre su área y una persona con varios roles ve varias', () {
    expect(areasDe(const []), isEmpty);
    expect(areasDe(const [Pertenencia(escuelaId: 'a', escuela: 'A', rol: Rol.tutor)]).map((a) => a.id), ['familia']);
    final varias = areasDe(const [
      Pertenencia(escuelaId: 'a', escuela: 'A', rol: Rol.entrenador),
      Pertenencia(escuelaId: 'b', escuela: 'B', rol: Rol.tutor),
      Pertenencia(escuelaId: 'a', escuela: 'A', rol: Rol.organizadorLiga),
      Pertenencia(escuelaId: 'a', escuela: 'A', rol: Rol.adminEscuela),
      Pertenencia(escuelaId: null, escuela: null, rol: Rol.superadmin),
    ]);
    expect(varias.map((a) => a.id), ['familia', 'entrenador', 'escuela-a', 'org-a', 'plataforma']);
  });

  testWidgets('inicio sin escuela explica qué hacer', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuth()),
        sesionProvider.overrideWith((ref) => Stream.value('u1')),
      ],
      child: const MaterialApp(home: HomePage()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('no está asociada a ninguna escuela'), findsOneWidget);
  });

  testWidgets('mi cuenta: guarda preferencias de notificación', (tester) async {
    final ligas = ligasMock(prefs: const {'resultados': true, 'calendario': true});
    await tester.pumpWidget(app(FakeAuth(), const CuentaPage(), ligas: ligas));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    verify(() => ligas.guardarPrefsNotificacion({'resultados': true, 'calendario': false})).called(1);
  });

  testWidgets('mi cuenta: exige 8 caracteres y cambia la contraseña', (tester) async {
    final repo = FakeAuth();
    await tester.pumpWidget(app(repo, const CuentaPage()));
    await tester.enterText(find.byType(TextFormField), 'corta');
    await tester.tap(find.text('Actualizar'));
    await tester.pump();
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(repo.nuevaPass, isNull);

    await tester.enterText(find.byType(TextFormField), 'una-larga-123');
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();
    expect(repo.nuevaPass, 'una-larga-123');
    expect(find.text('Contraseña actualizada.'), findsOneWidget);
  });

  test('rolDesdeDb mapea todos los roles', () {
    for (final r in ['superadmin', 'organizador_liga', 'admin_escuela', 'entrenador', 'alumno', 'tutor']) {
      expect(() => rolDesdeDb(r), returnsNormally);
    }
    expect(() => rolDesdeDb('otro'), throwsArgumentError);
  });
}
