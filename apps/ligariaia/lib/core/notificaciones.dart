import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth.dart';
import 'config.dart';
import 'idioma.dart';

/// Tipos que emite el backend (`public.notificacion.tipo`) y su etiqueta en las preferencias.
Map<String, String> get tiposNotificacion => {
  'resultado_registrado': l10nActual.notifResultados,
  'competicion_en_curso': l10nActual.notifCalendario,
  'inscripcion_estado': l10nActual.notifInscripciones,
  'partido_programacion': l10nActual.notifProgramacion,
};

/// Servicio de notificaciones del usuario con sesión; `null` sin sesión o sin Supabase (demo/tests).
final notificacionesProvider = FutureProvider<NotificacionesServicio?>((
  ref,
) async {
  final uid = ref.watch(sesionProvider).value;
  if (uid == null || !AppConfig.configurada) return null;
  final servicio = NotificacionesServicio(
    repo: NotificacionesSupabase(Supabase.instance.client),
    avisos: AvisosLocales(),
    prefs: await SharedPreferences.getInstance(),
  );
  ref.onDispose(() => unawaited(servicio.liberar()));
  return servicio;
});

/// Va en el `builder` de `MaterialApp.router`: arranca las notificaciones al iniciar sesión y las
/// detiene al cerrarla, sin recrear el navegador.
class NotificacionesRaiz extends ConsumerWidget {
  const NotificacionesRaiz({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => NotificacionesHost(
    servicio: ref.watch(notificacionesProvider).value,
    child: child,
  );
}
