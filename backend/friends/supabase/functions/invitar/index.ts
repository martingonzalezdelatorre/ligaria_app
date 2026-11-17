// Envía la invitación a un grupo por email con la plantilla "Invite user" de Supabase Auth.
// Solo puede invitar quien es miembro del grupo. El enlace del correo lleva el código del grupo.
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const responder = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const authz = req.headers.get("Authorization");
    if (!authz) return responder({ error: "Debes iniciar sesión." }, 401);

    const url = Deno.env.get("SUPABASE_URL")!;
    const usuario = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authz } },
    });
    const { data: { user } } = await usuario.auth.getUser();
    if (!user) return responder({ error: "Debes iniciar sesión." }, 401);

    const { grupo_id, email, redirect_to } = await req.json();
    const correo = String(email ?? "").trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(correo)) return responder({ error: "Email no válido." }, 400);

    // La vista aplica la RLS del usuario: si no es miembro, no hay fila.
    const { data: grupo } = await usuario
      .from("v_mis_grupos").select("nombre, codigo_invitacion").eq("id", grupo_id).maybeSingle();
    if (!grupo) return responder({ error: "No perteneces a este grupo." }, 403);

    const { data: perfil } = await usuario.from("perfil").select("nombre").eq("id", user.id).maybeSingle();
    const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const destino = `${String(redirect_to ?? "").replace(/\/$/, "")}/?codigo=${grupo.codigo_invitacion}&por=${user.id}`;
    const { error } = await admin.auth.admin.inviteUserByEmail(correo, {
      redirectTo: destino,
      data: {
        nombre: correo.split("@")[0],
        invitado_por: perfil?.nombre ?? "Un amigo",
        grupo: grupo.nombre,
      },
    });
    if (error) {
      const yaExiste = /already|registered|exists/i.test(error.message);
      return responder(
        {
          error: yaExiste
            ? "Ese email ya tiene cuenta. Compártele el enlace o el código del grupo."
            : "No se pudo enviar la invitación.",
        },
        yaExiste ? 409 : 500,
      );
    }
    return responder({ ok: true });
  } catch (_) {
    return responder({ error: "No se pudo enviar la invitación." }, 500);
  }
});
