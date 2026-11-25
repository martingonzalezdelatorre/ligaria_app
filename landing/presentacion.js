// Formulario «Solicitar presentación» de las páginas por segmento.
// Envía la solicitud a la función pública solicitar_presentacion de Supabase (tabla solicitud_presentacion).
const C = window.LIGARIA || {};
try { C.supabaseUrl = new URL(C.supabaseUrl).origin; } catch (_) {}
const y = document.getElementById('y'); if (y) y.textContent = new Date().getFullYear();

const f = document.getElementById('form-presentacion');
if (f) {
  const msg = f.querySelector('.msg'), btn = f.querySelector('button[type=submit]');
  const ERROR = 'No hemos podido enviar la solicitud. Inténtalo de nuevo o escríbenos a info@ligaria.es.';
  const set = (t, err) => { msg.textContent = t; msg.classList.toggle('err', !!err); };

  f.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!f.checkValidity()) { f.reportValidity(); return; }
    if (!C.supabaseUrl || !C.supabaseKey) { set('Formulario no configurado todavía.', true); return; }
    const d = Object.fromEntries(new FormData(f));
    if (d.web) return; // honeypot anti-bots
    btn.disabled = true; set('Enviando…');
    try {
      const r = await fetch(`${C.supabaseUrl}/rest/v1/rpc/solicitar_presentacion`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', apikey: C.supabaseKey, Authorization: `Bearer ${C.supabaseKey}` },
        body: JSON.stringify({
          p_segmento: f.dataset.segmento,
          p_nombre: d.nombre.trim(),
          p_email: d.email.trim(),
          p_consentimiento: !!d.ok,
          p_entidad: (d.entidad || '').trim() || null,
          p_telefono: (d.telefono || '').trim() || null,
          p_mensaje: (d.mensaje || '').trim() || null,
          p_origen: location.pathname,
        }),
      });
      if (!r.ok) { console.error('Solicitud fallida', r.status, await r.text().catch(() => '')); set(ERROR, true); return; }
      f.reset();
      set('¡Gracias! Hemos recibido tu solicitud y te contactaremos para concertar la presentación.');
    } catch { set('Error de conexión. Inténtalo de nuevo.', true); }
    finally { btn.disabled = false; }
  });
}
