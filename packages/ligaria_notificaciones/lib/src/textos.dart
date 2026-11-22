/// Textos de la interfaz de notificaciones. Por defecto en español; la app puede sustituir [actual]
/// por otro idioma (el contenido de cada aviso lo genera el servidor y no se traduce aquí).
class TextosNotificaciones {
  const TextosNotificaciones({
    this.ver = 'Ver',
    this.notificaciones = 'Notificaciones',
    this.marcarLeidas = 'Marcar todas como leídas',
    this.preferencias = 'Preferencias',
    this.errorCargarReintentar = 'No se pudieron cargar. Reintentar',
    this.sinNotificaciones = 'No tienes notificaciones.',
    this.errorGuardar = 'No se pudo guardar el cambio.',
    this.preferenciasAvisos = 'Preferencias de avisos',
    this.errorCargarPreferencias = 'No se pudieron cargar las preferencias.',
    this.enLaApp = 'En la app',
    this.porEmail = 'Por email',
    this.ahora = 'ahora',
    this.haceMin = 'hace {n} min',
    this.haceHoras = 'hace {n} h',
    this.haceDias = 'hace {n} d',
  });

  final String ver,
      notificaciones,
      marcarLeidas,
      preferencias,
      errorCargarReintentar,
      sinNotificaciones,
      errorGuardar,
      preferenciasAvisos,
      errorCargarPreferencias,
      enLaApp,
      porEmail,
      ahora,
      haceMin,
      haceHoras,
      haceDias;

  static TextosNotificaciones actual = const TextosNotificaciones();
}
