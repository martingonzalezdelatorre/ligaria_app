import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ligariaia/data/liga_repository.dart';
import 'package:ligariaia/core/auth.dart';
import 'package:ligariaia/features/auth/login_page.dart';
import 'package:ligariaia/features/auth/recuperar_pages.dart';
import 'package:ligariaia/features/cuenta/cuenta_page.dart';
import 'package:ligariaia/features/home/home_page.dart';

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
  String? emailRecuperacion;
  @override
  Stream<void> get recuperacion => const Stream.empty();
  @override
  Future<void> enviarRecuperacion(String email) async => emailRecuperacion = email;
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

MockLigas ligasMock() => MockLigas();

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
    await tester.pump(const Duration(seconds: 1)); // el fondo animado nunca se asienta
    expect(repo.ultimoEmail, 'ana@x.es');
  });

  testWidgets('login muestra error si las credenciales fallan', (tester) async {
    await tester.pumpWidget(app(FakeAuth(falla: true), const LoginPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@x.es');
    await tester.enterText(find.byType(TextFormField).at(1), 'mala');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(seconds: 1)); // el fondo animado nunca se asienta
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('recuperar contraseña: valida el correo y lo envía', (tester) async {
    final repo = FakeAuth();
    await tester.pumpWidget(app(repo, const RecuperarPasswordPage()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Enviar enlace'));
    await tester.pump();
    expect(find.text('Introduce un correo válido'), findsOneWidget);
    expect(repo.emailRecuperacion, isNull);

    await tester.enterText(find.byType(TextFormField), 'ana@x.es');
    await tester.tap(find.text('Enviar enlace'));
    await tester.pump(const Duration(seconds: 1));
    expect(repo.emailRecuperacion, 'ana@x.es');
    expect(find.text('Revisa tu correo'), findsOneWidget);
  });

  testWidgets('nueva contraseña: exige 8 caracteres, que coincidan, y la guarda', (tester) async {
    final repo = FakeAuth();
    await tester.pumpWidget(app(repo, const NuevaPasswordPage()));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextFormField).at(0), 'corta');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pump();
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'una-larga-123');
    await tester.enterText(find.byType(TextFormField).at(1), 'otra-distinta');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(repo.nuevaPass, isNull);

    await tester.enterText(find.byType(TextFormField).at(1), 'una-larga-123');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pump(const Duration(seconds: 1));
    expect(repo.nuevaPass, 'una-larga-123');
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
    expect(find.textContaining('no está asociada a ninguna organización'), findsOneWidget);
  });

  testWidgets('mi cuenta: exige 8 caracteres y cambia la contraseña', (tester) async {
    final repo = FakeAuth();
    await tester.pumpWidget(app(repo, const CuentaPage()));
    await tester.scrollUntilVisible(find.text('Actualizar'), 200, scrollable: find.byType(Scrollable).first);
    await tester.enterText(find.byType(TextFormField), 'corta');
    await tester.tap(find.text('Actualizar'));
    await tester.pump();
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(repo.nuevaPass, isNull);

    await tester.enterText(find.byType(TextFormField), 'una-larga-123');
    await tester.ensureVisible(find.text('Actualizar'));
    await tester.pump();
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();
    expect(repo.nuevaPass, 'una-larga-123');
    expect(find.text('Contraseña actualizada.'), findsOneWidget);
  });

  test('rolDesdeDb mapea todos los roles', () {
    for (final r in ['ADMINISTRADOR', 'ORGANIZADOR_LIGAS', 'ADMIN_ESCUELAS', 'ENTRENADOR', 'JUGADOR', 'TUTOR']) {
      expect(() => rolDesdeDb(r), returnsNormally);
    }
    expect(() => rolDesdeDb('OTRO'), throwsArgumentError);
  });
}
