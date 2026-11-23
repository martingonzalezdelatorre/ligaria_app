-- =====================================================================
-- Enviar un mensaje no debe fallar si las notificaciones no están disponibles
-- (p. ej. falta public.notificacion_preferencia en esa base). El aviso es un extra.
-- =====================================================================

create or replace function public.enviar_mensaje(p_para uuid, p_texto text) returns void
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid()); quien text;
begin
  if not app.puede_tratar(p_para) then
    raise exception 'No puedes escribir a esa persona.' using errcode = '42501';
  end if;
  insert into public.mensaje (de, para, texto) values (uid, p_para, btrim(p_texto));
  begin
    select coalesce(nullif(btrim(apodo), ''), nullif(btrim(nombre), ''), 'Jugador')
      into quien from public.perfil where id = uid;
    perform app.notificar(p_para, 'mensaje', quien, left(btrim(p_texto), 140),
                          jsonb_build_object('de', uid), uid);
  exception when others then
    null;  -- sin notificación, pero el mensaje ya está guardado
  end;
end;
$$;
revoke execute on function public.enviar_mensaje(uuid, text) from public, anon;
grant execute on function public.enviar_mensaje(uuid, text) to authenticated;
