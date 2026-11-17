-- =====================================================================
-- Disparo de la Edge Function `enviar-notificaciones` (ejecutar a mano en el SQL Editor,
-- una vez por proyecto, NO es una migración: lleva URL y secreto propios).
--
-- Requisitos: extensiones pg_net y pg_cron (Database > Extensions) y estos secretos:
--   supabase secrets set NOTIF_WEBHOOK_SECRET=... SMTP_HOST=... SMTP_PORT=587 \
--     SMTP_USER=... SMTP_PASS=... SMTP_FROM="Ligaria <avisos@tudominio.es>"
--   supabase functions deploy enviar-notificaciones --no-verify-jwt
--
-- Sustituye <PROYECTO> y <SECRETO>.
-- =====================================================================

-- 1) Al insertar una notificación con email pendiente, avisa a la función (casi inmediato).
create or replace function public.notif_disparar_email() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.email_estado = 'pendiente' then
    perform net.http_post(
      url := 'https://<PROYECTO>.supabase.co/functions/v1/enviar-notificaciones',
      headers := jsonb_build_object('Content-Type', 'application/json',
                                    'x-webhook-secret', '<SECRETO>'),
      body := '{}'::jsonb);
  end if;
  return null;
end;
$$;
revoke execute on function public.notif_disparar_email() from public, anon, authenticated;
drop trigger if exists trg_notif_disparar_email on public.notificacion;
create trigger trg_notif_disparar_email after insert on public.notificacion
  for each row execute function public.notif_disparar_email();

-- 2) Red de seguridad: cada 5 minutos reintenta pendientes y errores.
select cron.schedule('enviar-notificaciones', '*/5 * * * *', $$
  select net.http_post(
    url := 'https://<PROYECTO>.supabase.co/functions/v1/enviar-notificaciones',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'x-webhook-secret', '<SECRETO>'),
    body := '{}'::jsonb)
$$);
