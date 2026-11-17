// Envía por SMTP propio las notificaciones pendientes (public.notificacion.email_estado).
// La invoca un Database Webhook (INSERT en notificacion) o pg_cron como red de seguridad;
// ver ../../notificaciones_programacion.sql. No es pública: exige el secreto compartido.
//
// Secretos (supabase secrets set ...):
//   NOTIF_WEBHOOK_SECRET  cabecera x-webhook-secret que debe llevar la llamada
//   SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM, SMTP_SECURE (true para 465)
//   APP_NOMBRE (opcional), APP_URL (opcional, enlace del pie del correo)
import { createClient } from "npm:@supabase/supabase-js@2";
import nodemailer from "npm:nodemailer@6.9.16";

const LOTE = 50;
const MAX_INTENTOS = 5;

const esc = (s: string) =>
  s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);

function html(nombreApp: string, titulo: string, cuerpo: string, url?: string) {
  const enlace = url
    ? `<p style="margin:24px 0 0"><a href="${esc(url)}" style="color:#0a7d5a">Abrir ${esc(nombreApp)}</a></p>`
    : "";
  return `<!doctype html><html><body style="margin:0;background:#f4f6f5;font-family:Arial,Helvetica,sans-serif">
<div style="max-width:480px;margin:24px auto;background:#fff;border-radius:12px;padding:28px;color:#1b2b24">
<p style="margin:0 0 4px;font-size:12px;color:#6b7c74;letter-spacing:.08em;text-transform:uppercase">${esc(nombreApp)}</p>
<h1 style="margin:0 0 12px;font-size:20px">${esc(titulo)}</h1>
<p style="margin:0;font-size:15px;line-height:1.5">${esc(cuerpo)}</p>${enlace}
<p style="margin:28px 0 0;font-size:12px;color:#6b7c74">Puedes desactivar estos avisos por email en los ajustes de notificaciones de la app.</p>
</div></body></html>`;
}

Deno.serve(async (req) => {
  const secreto = Deno.env.get("NOTIF_WEBHOOK_SECRET");
  if (!secreto || req.headers.get("x-webhook-secret") !== secreto) {
    return new Response(JSON.stringify({ error: "No autorizado." }), { status: 401 });
  }

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const nombreApp = Deno.env.get("APP_NOMBRE") ?? "Ligaria";
  const urlApp = Deno.env.get("APP_URL") ?? undefined;

  const { data: pendientes, error } = await admin
    .from("notificacion")
    .select("id, usuario_id, titulo, cuerpo, email_intentos")
    .in("email_estado", ["pendiente", "error"])
    .lt("email_intentos", MAX_INTENTOS)
    .order("created_at", { ascending: true })
    .limit(LOTE);
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  if (!pendientes?.length) return new Response(JSON.stringify({ enviados: 0, errores: 0 }));

  const transporte = nodemailer.createTransport({
    host: Deno.env.get("SMTP_HOST"),
    port: Number(Deno.env.get("SMTP_PORT") ?? 587),
    secure: Deno.env.get("SMTP_SECURE") === "true",
    auth: { user: Deno.env.get("SMTP_USER"), pass: Deno.env.get("SMTP_PASS") },
  });
  const remitente = Deno.env.get("SMTP_FROM") ?? Deno.env.get("SMTP_USER");

  let enviados = 0;
  let errores = 0;
  for (const n of pendientes) {
    // Reserva la fila (optimista) para que dos ejecuciones simultáneas no envíen dos veces.
    const { data: reservada } = await admin
      .from("notificacion")
      .update({ email_intentos: n.email_intentos + 1 })
      .eq("id", n.id)
      .eq("email_intentos", n.email_intentos)
      .in("email_estado", ["pendiente", "error"])
      .select("id");
    if (!reservada?.length) continue;

    try {
      const { data: u, error: eu } = await admin.auth.admin.getUserById(n.usuario_id);
      const destino = u?.user?.email;
      if (eu || !destino) throw new Error("Usuario sin email.");
      await transporte.sendMail({
        from: remitente,
        to: destino,
        subject: n.titulo,
        text: `${n.cuerpo}${urlApp ? `\n\n${urlApp}` : ""}`,
        html: html(nombreApp, n.titulo, n.cuerpo, urlApp),
      });
      await admin.from("notificacion")
        .update({ email_estado: "enviado", email_enviado_at: new Date().toISOString() })
        .eq("id", n.id);
      enviados++;
    } catch (_) {
      await admin.from("notificacion").update({ email_estado: "error" }).eq("id", n.id);
      errores++;
    }
  }
  return new Response(JSON.stringify({ enviados, errores }), {
    headers: { "Content-Type": "application/json" },
  });
});
