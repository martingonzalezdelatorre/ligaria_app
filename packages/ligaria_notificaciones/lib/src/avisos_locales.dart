import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notificacion.dart';

/// Muestra una notificación del sistema. Separado del servicio para poder probarlo sin plugins.
abstract class MostradorAvisos {
  /// `true` si los avisos salen como notificación del sistema (Android/iOS). En web/escritorio es
  /// `false` y la interfaz debe enseñar un aviso dentro de la app.
  bool get nativo;

  Future<void> iniciar();
  Future<void> mostrar(Notificacion n);

  /// Id de la notificación que el usuario ha tocado.
  Stream<String> get toques;
  Future<void> liberar();
}

/// Sin notificaciones del sistema (web, escritorio y tests).
class AvisosNulos implements MostradorAvisos {
  @override
  bool get nativo => false;
  @override
  Future<void> iniciar() async {}
  @override
  Future<void> mostrar(Notificacion n) async {}
  @override
  Stream<String> get toques => const Stream.empty();
  @override
  Future<void> liberar() async {}
}

/// Notificaciones locales del sistema con `flutter_local_notifications` (sin Firebase).
class AvisosLocales implements MostradorAvisos {
  AvisosLocales({this.iconoAndroid = '@mipmap/ic_launcher'});

  final String iconoAndroid;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _toques = StreamController.broadcast();
  bool _listo = false;

  static bool get _soportada =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get nativo => _soportada;

  @override
  Stream<String> get toques => _toques.stream;

  @override
  Future<void> iniciar() async {
    if (!_soportada || _listo) return;
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(iconoAndroid),
        iOS: const DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null) _toques.add(p);
      },
    );
    // Android 13+ pide permiso en tiempo de ejecución (POST_NOTIFICATIONS).
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _listo = true;
  }

  @override
  Future<void> mostrar(Notificacion n) async {
    if (!_listo) return;
    await _plugin.show(
      id: n.id.hashCode & 0x7fffffff,
      title: n.titulo,
      body: n.cuerpo,
      payload: n.id,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ligaria_avisos',
          'Avisos de Ligaria',
          channelDescription: 'Resultados, pedidos, reservas y calendario',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> liberar() async {
    await _toques.close();
  }
}
