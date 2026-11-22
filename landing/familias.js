// Registro de madres, padres y tutores: /familias.html
// El alta (Supabase Auth, signUp) solo prospera si la escuela ha invitado antes a ese correo
// (lo valida el disparador de la base de datos). Al entrar en la app, el tutor añade a sus hijos.
const C = window.LIGARIA || {};
try { C.supabaseUrl = new URL(C.supabaseUrl).origin; } catch (_) {}
document.getElementById('y').textContent = new Date().getFullYear();
document.getElementById('app').href = C.appUrl || '/';
const f = document.getElementById('form'), msg = f.querySelector('.msg'), btn = f.querySelector('button');

// El correo de invitación trae el email ya escrito (?email=…): debe ser el mismo con el que se registre.
const correoInvitado = (new URLSearchParams(location.search).get('email') || '').trim();
if (correoInvitado) f.email.value = correoInvitado;

// Mensaje único a propósito: no revelar si un correo tiene invitación o ya tiene cuenta.
const ERROR_ALTA = 'No se puede crear la cuenta. Usa el mismo correo al que te escribió tu escuela o pídele una invitación nueva.';

f.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!f.checkValidity()) { f.reportValidity(); return; }
  if (!C.supabaseUrl || !C.supabaseKey) { msg.textContent = 'Registro no configurado todavía.'; return; }
  const d = Object.fromEntries(new FormData(f));
  if (d.web) return; // honeypot anti-bots
  btn.disabled = true; msg.textContent = 'Creando tu cuenta…';
  try {
    const r = await fetch(`${C.supabaseUrl}/auth/v1/signup?redirect_to=${encodeURIComponent(location.origin + '/confirmado.html')}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', apikey: C.supabaseKey },
      body: JSON.stringify({ email: d.email.trim(), password: d.password, data: { nombre: d.nombre.trim() } }),
    });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) { console.error('Alta fallida', r.status, j); msg.textContent = ERROR_ALTA; return; }
    // Con confirmación por email, Auth simula éxito para un correo ya registrado (sin identidades).
    const ident = (j.user || j).identities;
    if (Array.isArray(ident) && ident.length === 0) { msg.textContent = ERROR_ALTA; return; }
    f.reset();
    if (j.access_token) {
      msg.textContent = '¡Cuenta creada! Te llevamos a la app…';
      setTimeout(() => { location.href = C.appUrl || '/'; }, 900);
    } else {
      msg.textContent = 'Cuenta creada. Revisa tu email para confirmarla y luego entra en la app para añadir a tus hijos.';
    }
  } catch { msg.textContent = 'Error de conexión. Inténtalo de nuevo.'; }
  finally { btn.disabled = false; }
});
