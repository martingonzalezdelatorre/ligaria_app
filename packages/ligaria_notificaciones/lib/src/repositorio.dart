import 'dart:async';

import 'notificacion.dart';

/// Acceso a las notificaciones del usuario con sesión iniciada.
abstract class NotificacionesRepositorio {
  /// Id de la cuenta (el email es su nombre de usuario).
  String get usuarioId;

  /// Notificaciones que llegan en tiempo real. Se suscribe al escuchar y se libera al cancelar.
  Stream<Notificacion> nuevas();

  Future<List<Notificacion>> listar({int limite = 50});
  Future<void> marcarLeida(String id);
  Future<void> marcarTodasLeidas();

  /// Preferencias por tipo; los tipos sin fila valen «todo activado».
  Future<Map<String, PreferenciaNotificacion>> preferencias();
  Future<void> guardarPreferencia(String tipo, PreferenciaNotificacion pref);
}

/// Implementación en memoria para el modo demo (sin Supabase) y para los tests.
class NotificacionesDemo implements NotificacionesRepositorio {
  NotificacionesDemo({this.usuarioId = 'demo'});

  @override
  final String usuarioId;

  final List<Notificacion> _todas = [];
  final Map<String, PreferenciaNotificacion> _prefs = {};
  final StreamController<Notificacion> _ctrl = StreamController.broadcast();
  int _n = 0;

  /// Simula una notificación nueva. Con [alStream] falso solo queda guardada (como si se
  /// hubiera recibido con la app cerrada).
  Notificacion emitir(
    String titulo, {
    String cuerpo = '',
    String tipo = 'demo',
    Map<String, dynamic> datos = const {},
    DateTime? creada,
    bool alStream = true,
  }) {
    final n = Notificacion(
      id: 'demo-${_n++}',
      tipo: tipo,
      titulo: titulo,
      cuerpo: cuerpo,
      datos: datos,
      creada: creada ?? DateTime.now(),
    );
    _todas.insert(0, n);
    if (alStream) _ctrl.add(n);
    return n;
  }

  @override
  Stream<Notificacion> nuevas() => _ctrl.stream;

  @override
  Future<List<Notificacion>> listar({int limite = 50}) async {
    final l = [..._todas]..sort((a, b) => b.creada.compareTo(a.creada));
    return l.take(limite).toList();
  }

  @override
  Future<void> marcarLeida(String id) async {
    final i = _todas.indexWhere((n) => n.id == id);
    if (i >= 0) _todas[i] = _todas[i].copiarLeida();
  }

  @override
  Future<void> marcarTodasLeidas() async {
    for (var i = 0; i < _todas.length; i++) {
      _todas[i] = _todas[i].copiarLeida();
    }
  }

  @override
  Future<Map<String, PreferenciaNotificacion>> preferencias() async =>
      Map.of(_prefs);

  @override
  Future<void> guardarPreferencia(
    String tipo,
    PreferenciaNotificacion pref,
  ) async => _prefs[tipo] = pref;
}
