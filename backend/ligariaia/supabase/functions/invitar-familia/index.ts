// Envía por SMTP propio la invitación para crear cuenta a una madre, padre o tutor que la escuela ha
// añadido a sus hijos. El correo lleva a la página de registro de familias con el email ya escrito; al
// registrarse con ese correo, el disparador de alta (handle_new_user) aplica las invitaciones pendientes
// y deja a los hijos asociados a su cuenta.
//
// Solo puede invocarla quien administra la organización: se comprueba leyendo, con la sesión del propio
// usuario, la vista v_tutores_jugador (que solo devuelve filas a los administradores de la organización).
//
// Secretos (supabase secrets set ...): SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM, SMTP_SECURE,
//   FAMILIAS_URL (opcional; por defecto https://ligaria.app/familias.html), APP_NOMBRE (opcional)
import { createClient } from "npm:@supabase/supabase-js@2";
import nodemailer from "npm:nodemailer@6.9.16";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const responder = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), { status, headers: { ...cors, "Content-Type": "application/json" } });
const esc = (s: string) =>
  s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);

function cuerpoCorreo(app: string, escuela: string, nombre: string, hijos: string[], enlace: string) {
  const lista = hijos.map((h) => `<li>${esc(h)}</li>`).join("");
  return `<!doctype html><html><body style="margin:0;background:#06110e;font-family:Arial,Helvetica,sans-serif">
<div style="max-width:520px;margin:24px auto;background:#101d19;border:1px solid #26372f;border-radius:20px;padding:32px;color:#a9bbb4">
<p style="margin:0 0 16px;font-size:20px;font-weight:900;color:#fff"><span style="color:#c6ff3d">${esc(app)}</span></p>
<h1 style="margin:0 0 12px;font-size:24px;color:#fff">Te han invitado a crear tu cuenta</h1>
<p style="margin:0 0 12px;font-size:15px;line-height:1.6">Hola${nombre ? " " + esc(nombre) : ""}: <strong style="color:#fff">${esc(escuela)}</strong> te ha dado de alta como madre, padre o tutor de:</p>
<ul style="margin:0 0 20px;padding-left:20px;font-size:15px;color:#fff">${lista}</ul>
<p style="margin:0 0 24px;font-size:15px;line-height:1.6">Crea tu cuenta con <strong style="color:#fff">este mismo correo</strong> y quedarán asociados a ella: podrás seguir sus equipos, calendario y resultados.</p>
<p style="margin:0"><a href="${esc(enlace)}" style="display:inline-block;background:#c6ff3d;color:#06110e;font-weight:800;text-decoration:none;padding:14px 30px;border-radius:999px">Crear mi cuenta</a></p>
<p style="margin:24px 0 0;font-size:12px;color:#7f938b">Si el botón no funciona, copia este enlace: <a href="${esc(enlace)}" style="color:#14c79a;word-break:break-all">${esc(enlace)}</a></p>
</div></body></html>`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const authz = req.headers.get("Authorization");
    if (!authz) return responder({ error: "Debes iniciar sesión." }, 401);
    const usuario = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authz } },
    });
    const { data: { user } } = await usuario.auth.getUser();
    if (!user) return responder({ error: "Debes iniciar sesión." }, 401);

    const { org_id, emails } = await req.json();
    const lista: string[] = [
      ...new Set((Array.isArray(emails) ? emails : []).map((e) => String(e).trim().toLowerCase())),
    ].slice(0, 10);
    if (!org_id || lista.length === 0) return responder({ error: "Faltan datos." }, 400);

    // Hijos de esta organización (la RLS limita a los que el usuario administra).
    const { data: jugadores } = await usuario
      .from("jugador").select("id, nombre, apellidos").eq("organizacion_id", org_id);
    const porId = new Map((jugadores ?? []).map((j) => [j.id, `${j.nombre} ${j.apellidos ?? ""}`.trim()]));
    const { data: org } = await usuario.from("organizacion").select("nombre").eq("id", org_id).maybeSingle();
    if (!org || porId.size === 0) return responder({ error: "Sin permiso." }, 403);

    const { data: filas } = await usuario
      .from("v_tutores_jugador").select("jugador_id, nombre, email, estado")
      .in("jugador_id", [...porId.keys()]).eq("estado", "pendiente");

    const app = Deno.env.get("APP_NOMBRE") ?? "Ligaria";
    const base = Deno.env.get("FAMILIAS_URL") ?? "https://ligaria.app/familias.html";
    const transporte = nodemailer.createTransport({
      host: Deno.env.get("SMTP_HOST"),
      port: Number(Deno.env.get("SMTP_PORT") ?? 587),
      secure: Deno.env.get("SMTP_SECURE") === "true",
      auth: { user: Deno.env.get("SMTP_USER"), pass: Deno.env.get("SMTP_PASS") },
    });
    const remitente = Deno.env.get("SMTP_FROM") ?? Deno.env.get("SMTP_USER");

    const enviados: string[] = [];
    const fallidos: string[] = [];
    for (const correo of lista) {
      const suyas = (filas ?? []).filter((f) => String(f.email).toLowerCase() === correo);
      // Sin invitación pendiente (ya tiene cuenta o no es de esta organización): no se envía nada.
      if (suyas.length === 0) continue;
      const hijos = [...new Set(suyas.map((f) => porId.get(f.jugador_id)!).filter(Boolean))];
      const enlace = `${base}${base.includes("?") ? "&" : "?"}email=${encodeURIComponent(correo)}`;
      try {
        await transporte.sendMail({
          from: remitente,
          to: correo,
          subject: `${org.nombre} te invita a ${app}`,
          html: cuerpoCorreo(app, org.nombre, suyas[0].nombre === correo ? "" : suyas[0].nombre, hijos, enlace),
        });
        enviados.push(correo);
      } catch (e) {
        console.error("SMTP: no se pudo enviar a", correo, e);
        fallidos.push(correo);
      }
    }
    return responder({ enviados, fallidos });
  } catch (e) {
    console.error("invitar-familia", e);
    return responder({ error: "No se pudo enviar la invitación." }, 500);
  }
});
