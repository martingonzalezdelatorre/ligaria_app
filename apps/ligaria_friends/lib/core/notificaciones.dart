import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

/// Tipos que emite el backend (`public.notificacion.tipo`) y su etiqueta en las preferencias.
const tiposNotificacion = {
  'resultado_por_confirmar': 'Resultados por confirmar',
  'pedido_nuevo': 'Pedidos nuevos (tienda)',
  'pedido_cancelado': 'Pedidos cancelados (tienda)',
  'pedido_estado': 'Estado de tus pedidos',
  'reserva_nueva': 'Reservas de pista (club)',
};

/// Servicio de notificaciones de la sesión actual; `null` en modo demo (sin Supabase).
Future<NotificacionesServicio?> crearServicioNotificaciones() async {
  if (!AppConfig.usaSupabase) return null;
  return NotificacionesServicio(
    repo: NotificacionesSupabase(Supabase.instance.client),
    avisos: AvisosLocales(),
    prefs: await SharedPreferences.getInstance(),
  );
}
