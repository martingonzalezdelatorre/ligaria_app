const C = window.FRIENDS || {};
document.getElementById('y').textContent = new Date().getFullYear();
const f = document.getElementById('form'), msg = f.querySelector('.msg'), btn = f.querySelector('button');

f.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!f.checkValidity()) { f.reportValidity(); return; }
  const d = Object.fromEntries(new FormData(f));
  if (d.web) return; // honeypot anti-bots
  const datos = { nombre: d.nombre.trim(), email: d.email.trim(), deporte: d.deporte, grupo: d.grupo || '' };

  if (!C.waitlistUrl) { // sin backend: correo prellenado
    const cuerpo = `Nombre: ${datos.nombre}\nEmail: ${datos.email}\nDeporte: ${datos.deporte}\nGrupo: ${datos.grupo}`;
    location.href = `mailto:${C.contactEmail}?subject=${encodeURIComponent('Lista de espera Ligaria Friends')}&body=${encodeURIComponent(cuerpo)}`;
    msg.textContent = 'Abrimos tu correo para enviar la solicitud.';
    return;
  }
  btn.disabled = true; msg.textContent = 'Apuntándote…';
  try {
    const r = await fetch(C.waitlistUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify(datos),
    });
    if (!r.ok) throw new Error();
    f.reset();
    msg.textContent = '¡Listo! Te avisaremos en cuanto Ligaria Friends esté disponible.';
  } catch { msg.textContent = 'No hemos podido apuntarte. Inténtalo de nuevo en un momento.'; }
  finally { btn.disabled = false; }
});
