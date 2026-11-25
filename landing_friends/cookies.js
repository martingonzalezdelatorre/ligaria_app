// Gestor de cookies de Ligaria Friends (LSSI art. 22.2 + guía de la AEPD).
// - Google Analytics 4 NO se carga hasta que el usuario lo acepta.
// - "Aceptar" y "Rechazar" tienen el mismo peso visual.
// - La decisión se guarda 12 meses; después se vuelve a preguntar.
// - Si FRIENDS.gaId está vacío, no hay cookies opcionales y no se muestra el banner.
(function () {
  var C = window.FRIENDS || {};
  var GTM = (C.gtmId || '').trim();   // contenedor de Google Tag Manager (GTM-XXXXXXX)
  var ID = (C.gaId || '').trim();     // alternativa: GA4 directo (G-XXXXXXXXXX)
  if (!GTM && !ID) return;

  var KEY = 'lf_cookies';
  var MESES = 12;

  function leer() {
    try {
      var d = JSON.parse(localStorage.getItem(KEY));
      if (d && typeof d.analiticas === 'boolean' && Date.now() - d.t < MESES * 30.44 * 864e5) return d;
    } catch (e) {}
    return null;
  }
  function guardar(analiticas) {
    try { localStorage.setItem(KEY, JSON.stringify({ analiticas: analiticas, t: Date.now() })); } catch (e) {}
  }

  var cargado = false;
  function cargarGA() {
    if (cargado) return;
    cargado = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    var s = document.createElement('script');
    s.async = true;
    if (GTM) {
      window.dataLayer.push({ 'gtm.start': Date.now(), event: 'gtm.js' });
      s.src = 'https://www.googletagmanager.com/gtm.js?id=' + encodeURIComponent(GTM);
    } else {
      window.gtag('js', new Date());
      window.gtag('config', ID, { anonymize_ip: true });
      s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(ID);
    }
    document.head.appendChild(s);
  }
  function borrarGA() {
    // Borra las cookies _ga* de este dominio (y del dominio padre) al retirar el consentimiento.
    var partes = location.hostname.split('.');
    var dominios = ['', location.hostname];
    if (partes.length > 2) dominios.push('.' + partes.slice(-2).join('.'));
    else dominios.push('.' + location.hostname);
    document.cookie.split(';').forEach(function (c) {
      var n = c.split('=')[0].trim();
      if (n === '_ga' || n.indexOf('_ga_') === 0 || n === '_gid') {
        dominios.forEach(function (d) {
          document.cookie = n + '=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/' + (d ? '; domain=' + d : '');
        });
      }
    });
    if (ID) window['ga-disable-' + ID] = true;
  }

  function aplicar(analiticas) {
    if (analiticas) { if (ID) window['ga-disable-' + ID] = false; cargarGA(); }
    else if (cargado || document.cookie.indexOf('_ga') !== -1) {
      var estabaCargado = cargado;
      borrarGA();
      // Con GTM no se puede "descargar" el contenedor: recargamos para que deje de ejecutarse.
      if (estabaCargado) location.reload();
    }
  }

  var el;
  function cerrar() { if (el) { el.remove(); el = null; } }

  function mostrar(abrirConfig) {
    cerrar();
    var actual = leer();
    el = document.createElement('div');
    el.className = 'ck';
    el.setAttribute('role', 'dialog');
    el.setAttribute('aria-modal', 'false');
    el.setAttribute('aria-label', 'Preferencias de cookies');
    el.innerHTML =
      '<div class="ck-box">' +
        '<div class="ck-main"' + (abrirConfig ? ' hidden' : '') + '>' +
          '<h2>Tu privacidad, tu decisión</h2>' +
          '<p>Usamos cookies técnicas necesarias para que la web funcione y, solo si lo aceptas, cookies de analítica de Google Analytics para entender cómo se usa la web y mejorarla. Más información en la <a href="cookies.html">política de cookies</a>.</p>' +
          '<div class="ck-btns">' +
            '<button type="button" class="ck-b" data-a="rechazar">Rechazar</button>' +
            '<button type="button" class="ck-b" data-a="config">Configurar</button>' +
            '<button type="button" class="ck-b" data-a="aceptar">Aceptar</button>' +
          '</div>' +
        '</div>' +
        '<div class="ck-cfg"' + (abrirConfig ? '' : ' hidden') + '>' +
          '<h2>Configurar cookies</h2>' +
          '<label class="ck-row"><span><b>Necesarias</b><small>Imprescindibles para el funcionamiento de la web. Siempre activas.</small></span><input type="checkbox" checked disabled></label>' +
          '<label class="ck-row"><span><b>Analítica (Google Analytics)</b><small>Estadísticas de uso agregadas para mejorar la web. Proveedor: Google.</small></span><input type="checkbox" id="ck-an"' + (actual && actual.analiticas ? ' checked' : '') + '></label>' +
          '<div class="ck-btns">' +
            '<button type="button" class="ck-b" data-a="rechazar">Rechazar todo</button>' +
            '<button type="button" class="ck-b" data-a="guardar">Guardar selección</button>' +
            '<button type="button" class="ck-b" data-a="aceptar">Aceptar todo</button>' +
          '</div>' +
        '</div>' +
      '</div>';
    el.addEventListener('click', function (e) {
      var a = e.target && e.target.getAttribute && e.target.getAttribute('data-a');
      if (!a) return;
      if (a === 'config') {
        el.querySelector('.ck-main').hidden = true;
        el.querySelector('.ck-cfg').hidden = false;
        return;
      }
      var v = a === 'aceptar' ? true : a === 'rechazar' ? false : el.querySelector('#ck-an').checked;
      guardar(v); aplicar(v); cerrar();
    });
    document.body.appendChild(el);
    var b = el.querySelector('.ck-b'); if (b) b.focus({ preventScroll: true });
  }

  function init() {
    var d = leer();
    if (d) aplicar(d.analiticas); else mostrar(false);
    document.addEventListener('click', function (e) {
      var t = e.target.closest && e.target.closest('[data-cookies-config]');
      if (t) { e.preventDefault(); mostrar(true); }
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
