import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'avisos_locales.dart';
import 'notificacion.dart';
import 'repositorio.dart';

/// Recibe las notificaciones del usuario (Realtime) y las enseña como notificación local.
///
/// - Con la app abierta o en segundo plano reciente llegan por Realtime.
/// - Al abrir la app (o volver a primer plano) [refrescar] recupera las que llegaron mientras
///   estaba cerrada, usando la marca de «última vista» guardada por usuario.
class NotificacionesServicio {
  NotificacionesServicio({
    required this.repo,
    MostradorAvisos? avisos,
    required SharedPreferences prefs,
    this.maxIndividuales = 3,
  }) : avisos = avisos ?? AvisosNulos(),
       _prefs = prefs;

  final NotificacionesRepositorio repo;
  final MostradorAvisos avisos;
  final SharedPreferences _prefs;

  /// Si al recuperar hay más de estas, se muestra un único aviso resumen.
  final int maxIndividuales;

  /// Nº de notificaciones sin leer (para la insignia de la campana).
  final ValueNotifier<int> noLeidas = ValueNotifier(0);

  final StreamController<Notificacion> _recibidas = StreamController.broadcast();
  final StreamController<Notificacion> _aperturas = StreamController.broadcast();
  final Set<String> _vistas = {};
  final Map<String, Notificacion> _cache = {};
  StreamSubscription<Notificacion>? _subNuevas;
  StreamSubscription<String>? _subToques;
  bool _activo = false;

  String get _clave => 'notif_ultima_vista_${repo.usuarioId}';

  /// Cada notificación nueva (tiempo real o recuperada), para banners dentro de la app.
  Stream<Notificacion> get recibidas => _recibidas.stream;

  /// Notificaciones del sistema que el usuario ha tocado.
  Stream<Notificacion> get aperturas => _aperturas.stream;

  bool get activo => _activo;

  Future<void> iniciar() async {
    if (_activo) return;
    _activo = true;
    await avisos.iniciar();
    _subToques = avisos.toques.listen(_alTocar);
    // Primero la suscripción, luego la recuperación: así no se pierde nada entre ambas.
    _subNuevas = repo.nuevas().listen(_alLlegar);
    await refrescar();
  }

  /// Recupera lo que llegó mientras la app no escuchaba y actualiza el contador.
  Future<void> refrescar() async {
    if (!_activo) return;
    final lista = await repo.listar();
    if (!_activo) return;
    for (final n in lista) {
      _cache[n.id] = n;
    }
    noLeidas.value = lista.where((n) => !n.leida).length;

    final ultima = _ultimaVista();
    final pendientes =
        lista
            .where(
              (n) =>
                  !n.leida &&
                  !_vistas.contains(n.id) &&
                  ultima != null &&
                  n.creada.isAfter(ultima),
            )
            .toList()
          ..sort((a, b) => a.creada.compareTo(b.creada));
    for (final n in lista) {
      _vistas.add(n.id);
    }
    if (lista.isNotEmpty) {
      await _guardarVista(lista.first.creada);
    } else if (ultima == null) {
      // Primer uso sin histórico: todo lo que llegue después se avisará. Se usa el origen de
      // tiempos (no el reloj del móvil) para no depender de desajustes con el del servidor.
      await _guardarVista(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
    }
    if (ultima == null) return; // primer uso: no se avisa del histórico

    if (pendientes.length > maxIndividuales) {
      final resumen = Notificacion(
        id: 'resumen-${DateTime.now().microsecondsSinceEpoch}',
        tipo: 'resumen',
        titulo: 'Tienes ${pendientes.length} notificaciones nuevas',
        cuerpo: 'Ábrelas en la bandeja de Ligaria.',
        creada: DateTime.now(),
      );
      await avisos.mostrar(resumen);
      _recibidas.add(resumen);
    } else {
      for (final n in pendientes) {
        await avisos.mostrar(n);
        _recibidas.add(n);
      }
    }
  }

  Future<void> _alLlegar(Notificacion n) async {
    if (!_activo || !_vistas.add(n.id)) return;
    _cache[n.id] = n;
    if (!n.leida) noLeidas.value++;
    await _guardarVista(n.creada);
    // Notificación que el usuario ya tiene desactivada en la app: llega leída, no se muestra.
    if (n.leida) return;
    await avisos.mostrar(n);
    _recibidas.add(n);
  }

  void _alTocar(String id) {
    final n = _cache[id];
    if (n != null) _aperturas.add(n);
  }

  Future<void> marcarLeida(String id) async {
    final n = _cache[id];
    if (n == null || n.leida) return;
    await repo.marcarLeida(id);
    _cache[id] = n.copiarLeida();
    if (noLeidas.value > 0) noLeidas.value--;
  }

  Future<void> marcarTodasLeidas() async {
    await repo.marcarTodasLeidas();
    for (final e in _cache.entries.toList()) {
      _cache[e.key] = e.value.copiarLeida();
    }
    noLeidas.value = 0;
  }

  /// Para la bandeja: lista actual (y actualiza la caché y el contador).
  Future<List<Notificacion>> listar() async {
    final l = await repo.listar();
    for (final n in l) {
      _cache[n.id] = n;
    }
    noLeidas.value = l.where((n) => !n.leida).length;
    return l;
  }

  /// Cierra la suscripción (al cerrar sesión o salir de la pantalla raíz).
  Future<void> detener() async {
    if (!_activo) return;
    _activo = false;
    await _subNuevas?.cancel();
    await _subToques?.cancel();
    _subNuevas = null;
    _subToques = null;
    _vistas.clear();
    _cache.clear();
    noLeidas.value = 0;
  }

  Future<void> liberar() async {
    await detener();
    await avisos.liberar();
    await _recibidas.close();
    await _aperturas.close();
    noLeidas.dispose();
  }

  DateTime? _ultimaVista() {
    final s = _prefs.getString(_clave);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> _guardarVista(DateTime t) async {
    final actual = _ultimaVista();
    if (actual == null || t.isAfter(actual)) {
      await _prefs.setString(_clave, t.toUtc().toIso8601String());
    }
  }
}
