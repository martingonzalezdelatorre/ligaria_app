import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AvisosFalsos extends AvisosNulos {
  final List<Notificacion> mostradas = [];
  final StreamController<String> toquesCtrl = StreamController.broadcast();
  @override
  Future<void> mostrar(Notificacion n) async => mostradas.add(n);
  @override
  Stream<String> get toques => toquesCtrl.stream;
}

Future<void> _ticks() => Future<void>.delayed(Duration.zero);

void main() {
  late NotificacionesDemo repo;
  late _AvisosFalsos avisos;
  late SharedPreferences prefs;

  Future<NotificacionesServicio> servicio() async =>
      NotificacionesServicio(repo: repo, avisos: avisos, prefs: prefs);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = NotificacionesDemo();
    avisos = _AvisosFalsos();
  });

  test('tiempo real: muestra el aviso, suma al contador y no duplica', () async {
    final s = await servicio();
    await s.iniciar();
    final n = repo.emitir('Pedido nuevo', cuerpo: 'Pala x1');
    await _ticks();
    expect(avisos.mostradas.map((x) => x.id), [n.id]);
    expect(s.noLeidas.value, 1);

    // El mismo id otra vez (p. ej. reconexión de Realtime) no se repite.
    await s.refrescar();
    expect(avisos.mostradas.length, 1);
    expect(s.noLeidas.value, 1);
    await s.detener();
  });

  test('primer uso: no avisa del histórico pero lo cuenta como no leído', () async {
    repo.emitir('Antigua', alStream: false);
    final s = await servicio();
    await s.iniciar();
    expect(avisos.mostradas, isEmpty);
    expect(s.noLeidas.value, 1);
    await s.detener();
  });

  test('recupera las llegadas con la app cerrada (desde la última vista)', () async {
    var s = await servicio();
    await s.iniciar();
    repo.emitir('Vista', creada: DateTime.now().subtract(const Duration(hours: 2)));
    await _ticks();
    await s.detener(); // la app se cierra

    final perdida = repo.emitir('Mientras estabas fuera', alStream: false);
    avisos.mostradas.clear();
    s = await servicio();
    await s.iniciar();
    expect(avisos.mostradas.map((x) => x.id), [perdida.id]);
    await s.detener();
  });

  test('si son muchas, un único aviso resumen', () async {
    var s = await servicio();
    await s.iniciar();
    await s.detener();
    for (var i = 0; i < 5; i++) {
      repo.emitir('N$i', alStream: false);
    }
    avisos.mostradas.clear();
    s = await servicio();
    await s.iniciar();
    expect(avisos.mostradas.length, 1);
    expect(avisos.mostradas.single.titulo, contains('5 notificaciones'));
    await s.detener();
  });

  test('marcar leídas baja el contador', () async {
    final s = await servicio();
    await s.iniciar();
    final a = repo.emitir('A');
    repo.emitir('B');
    await _ticks();
    expect(s.noLeidas.value, 2);
    await s.marcarLeida(a.id);
    expect(s.noLeidas.value, 1);
    await s.marcarLeida(a.id); // idempotente
    expect(s.noLeidas.value, 1);
    await s.marcarTodasLeidas();
    expect(s.noLeidas.value, 0);
    await s.detener();
  });

  test('detener (logout) deja de escuchar', () async {
    final s = await servicio();
    await s.iniciar();
    await s.detener();
    repo.emitir('Tras el logout');
    await _ticks();
    expect(avisos.mostradas, isEmpty);
    expect(s.noLeidas.value, 0);
  });

  test('tocar la notificación del sistema emite la apertura', () async {
    final s = await servicio();
    await s.iniciar();
    final n = repo.emitir('Toca');
    await _ticks();
    final abierta = s.aperturas.first;
    avisos.toquesCtrl.add(n.id);
    expect((await abierta).id, n.id);
    await s.detener();
  });

  test('la última vista es independiente por usuario', () async {
    final otro = NotificacionesDemo(usuarioId: 'otro');
    final s1 = await servicio();
    await s1.iniciar();
    repo.emitir('Del primero');
    await _ticks();
    await s1.detener();
    final s2 = NotificacionesServicio(repo: otro, avisos: avisos, prefs: prefs);
    await s2.iniciar();
    otro.emitir('Antigua', creada: DateTime(2020), alStream: false);
    expect(prefs.getString('notif_ultima_vista_otro'), isNotNull);
    expect(prefs.getString('notif_ultima_vista_demo'), isNotNull);
    await s2.detener();
  });
}
