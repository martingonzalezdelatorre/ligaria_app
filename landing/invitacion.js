// Página de invitación: /invitacion.html?t=<GUID>[&c=<CÓDIGO>]
// Seguridad:
//  · El GUID (v4, 122 bits aleatorios) es la credencial del enlace; el código corto de grupo es un
//    segundo factor que puede ir en el enlace o dictarse aparte (p. ej. por WhatsApp).
//  · La validación REAL (existencia, caducidad, un solo uso, coincidencia del código) la hace Supabase
//    en las funciones de abajo. Lo que hace esta página es solo comodidad.
//  · Errores genéricos: no se revela si el GUID existe, caducó o se usó.
//  · El GUID se guarda en memoria y se borra de la barra de direcciones (historial, capturas).
//
// Contrato que debe ofrecer la base de datos (aún por crear, nombres acordados):
//  · rpc  invitacion_consultar(p_token uuid) → { grupo text, detalle text, requiere_codigo bool }
//        (ejecutable por anon; devuelve una fila o error genérico; limitar intentos por IP)
//  · el alta (auth signUp) recibe en data: { nombre, invitacion: <uuid>, codigo }; el disparador de
//    alta valida token + código y crea la pertenencia al grupo, marcando la invitación como usada.
//  · para quien ya tiene cuenta, la app aplica la invitación tras el login (#invitacion=<uuid>&c=<codigo>).
(function () {
  const C = window.LIGARIA || {};
  try { C.supabaseUrl = new URL(C.supabaseUrl).origin; } catch (_) {}
  const $ = (id) => document.getElementById(id);
  const GUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const ERROR_ALTA = 'No se puede completar el alta. Revisa los datos o pide una invitación nueva.';

  const q = new URLSearchParams(location.search);
  const token = (q.get('t') || '').trim().toLowerCase();
  const codigoEnlace = (q.get('c') || '').trim().toUpperCase().slice(0, 12);
  history.replaceState(null, '', location.pathname); // fuera de la URL

  const mostrar = (id) => {
    ['cargando', 'invalida', 'valida', 'hecho'].forEach((s) => { $(s).hidden = s !== id; });
  };
  const headers = { 'Content-Type': 'application/json', apikey: C.supabaseKey };

  async function consultar() {
    if (!GUID.test(token) || !C.supabaseUrl || !C.supabaseKey) return null;
    try {
      const r = await fetch(`${C.supabaseUrl}/rest/v1/rpc/invitacion_consultar`, {
        method: 'POST', headers, body: JSON.stringify({ p_token: token }),
      });
      if (!r.ok) return null;
      const j = await r.json();
      const fila = Array.isArray(j) ? j[0] : j;
      return fila && fila.grupo ? fila : null;
    } catch { return null; }
  }

  const f = $('form'), msg = f.querySelector('.msg'), btn = f.querySelector('button[type=submit]');

  f.addEventListener('submit', async (e) => {
    e.preventDefault();
    msg.className = 'msg';
    if (f.web.value) return; // honeypot: un bot rellenó el campo oculto
    if (!f.checkValidity()) { f.reportValidity(); return; }
    const d = Object.fromEntries(new FormData(f));
    btn.disabled = true; msg.textContent = 'Creando tu cuenta…';
    try {
      const r = await fetch(`${C.supabaseUrl}/auth/v1/signup?redirect_to=${encodeURIComponent(location.origin + '/confirmado.html')}`, {
        method: 'POST', headers,
        body: JSON.stringify({
          email: d.email.trim(), password: d.password,
          data: { nombre: d.nombre.trim(), invitacion: token, codigo: d.codigo.trim().toUpperCase() },
        }),
      });
      const j = await r.json().catch(() => ({}));
      const ident = (j.user || j).identities;
      if (!r.ok || (Array.isArray(ident) && ident.length === 0)) { msg.className = 'msg err'; msg.textContent = ERROR_ALTA; return; }
      f.reset();
      if (j.access_token) $('hechoTxt').textContent = 'Cuenta creada y unida al grupo. Ya puedes entrar en la app.';
      mostrar('hecho');
    } catch { msg.className = 'msg err'; msg.textContent = 'Error de conexión. Inténtalo de nuevo.'; }
    finally { btn.disabled = false; }
  });

  (async () => {
    $('app').href = C.appUrl || '/';
    const inv = await consultar();
    if (!inv) { mostrar('invalida'); return; }
    $('grupo').textContent = inv.grupo;
    $('detalle').textContent = inv.detalle || '';
    if (inv.requiere_codigo === false) { $('lcodigo').hidden = true; f.codigo.required = false; }
    else f.codigo.value = codigoEnlace;
    $('login').href = (C.appUrl || '/') + '#invitacion=' + encodeURIComponent(token) +
      (codigoEnlace ? '&c=' + encodeURIComponent(codigoEnlace) : '');
    mostrar('valida');
  })();
})();
