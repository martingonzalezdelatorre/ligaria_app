import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Invitaciones por enlace: `<app>/?codigo=CODIGO`. Quien lo abre se registra (o inicia sesión)
/// y entra solo al grupo. El código pendiente se recuerda por si hay que confirmar el email.
class Invitacion {
  Invitacion._();
  static const _clave = 'invitacion_pendiente';
  static const _clavePor = 'invitacion_por';

  /// Código del grupo al que el usuario fue invitado y aún no se ha unido.
  static String? pendiente;

  /// Id de quien compartió el enlace (queda como su contacto al unirse).
  static String? invitador;

  /// Lee `?codigo=` de la URL (web) o lo recuperado de una visita anterior.
  static Future<void> cargar() async {
    String? c = kIsWeb ? Uri.base.queryParameters['codigo'] : null;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}
    if (c != null && c.trim().isNotEmpty) {
      c = c.trim().toUpperCase();
      try {
        await prefs?.setString(_clave, c);
      } catch (_) {}
    } else {
      c = prefs?.getString(_clave);
    }
    pendiente = c;

    String? por = kIsWeb ? Uri.base.queryParameters['por'] : null;
    if (por != null && por.trim().isNotEmpty) {
      por = por.trim();
      try {
        await prefs?.setString(_clavePor, por);
      } catch (_) {}
    } else if (c != null &&
        kIsWeb &&
        Uri.base.queryParameters['codigo'] != null) {
      por = null; // enlace nuevo sin invitador: no arrastrar uno viejo
      try {
        await prefs?.remove(_clavePor);
      } catch (_) {}
    } else {
      por = prefs?.getString(_clavePor);
    }
    invitador = c == null ? null : por;
  }

  /// Recuerda un código escrito a mano (o `null`/vacío para descartarlo).
  static Future<void> guardar(String? codigo) async {
    final c = codigo?.trim().toUpperCase();
    if (c == null || c.isEmpty) return limpiar();
    pendiente = c;
    try {
      await (await SharedPreferences.getInstance()).setString(_clave, c);
    } catch (_) {}
  }

  static Future<void> limpiar() async {
    pendiente = null;
    invitador = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_clavePor);
      await p.remove(_clave);
    } catch (_) {}
  }

  /// Base del enlace: `--dart-define=APP_URL=https://...` o, en web, el origen actual.
  static String get base {
    const fija = String.fromEnvironment('APP_URL');
    if (fija.isNotEmpty) return fija.endsWith('/') ? fija : '$fija/';
    return kIsWeb ? '${Uri.base.origin}/' : 'https://ligaria.es/';
  }

  /// [por]: id de quien invita, para que lo conserve como amigo.
  static String enlace(String codigo, [String? por]) =>
      '$base?codigo=$codigo${por == null ? '' : '&por=$por'}';

  static String mensaje(String grupo, String codigo, [String? por]) =>
      '¡Únete a mi grupo «$grupo» en Ligaria Friends! Regístrate desde este enlace '
      'y entrarás directamente: ${enlace(codigo, por)}';

  /// Deja solo dígitos; un móvil español de 9 cifras recibe el prefijo 34.
  static String telefono(String entrada) {
    final d = entrada.replaceAll(RegExp(r'[^0-9]'), '');
    final sin00 = d.startsWith('00') ? d.substring(2) : d;
    return sin00.length == 9 ? '34$sin00' : sin00;
  }

  static Future<bool> whatsapp(
    String grupo,
    String codigo,
    String tel, [
    String? por,
  ]) => launchUrl(
    Uri.https('wa.me', '/${telefono(tel)}', {
      'text': mensaje(grupo, codigo, por),
    }),
    mode: LaunchMode.externalApplication,
  );
}
