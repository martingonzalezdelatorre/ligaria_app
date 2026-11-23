import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'idioma.dart';

/// Tipos que emite el backend (`public.notificacion.tipo`) y su etiqueta en las preferencias.
Map<String, String> get tiposNotificacion {
  final l = l10nActual;
  return {
    'resultado_por_confirmar': l.notifResultadosPorConfirmar,
    'pedido_nuevo': l.notifPedidoNuevo,
    'pedido_cancelado': l.notifPedidoCancelado,
    'pedido_estado': l.notifPedidoEstado,
    'reserva_nueva': l.notifReservaNueva,
    'mensaje': l.accMensaje,
  };
}

/// Servicio de notificaciones de la sesión actual; `null` en modo demo (sin Supabase).
Future<NotificacionesServicio?> crearServicioNotificaciones() async {
  if (!AppConfig.usaSupabase) return null;
  return NotificacionesServicio(
    repo: NotificacionesSupabase(Supabase.instance.client),
    avisos: AvisosLocales(),
    prefs: await SharedPreferences.getInstance(),
  );
}
