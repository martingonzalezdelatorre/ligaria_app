-- =====================================================================
-- Avisos al programar, reprogramar, aplazar o suspender un partido.
-- Se notifica (app + email, según sus preferencias) a todas las cuentas ligadas a los dos equipos:
-- jugadores con cuenta, madres/padres/tutores y entrenadores. No se avisa a quien hace el cambio.
-- Tipo de notificación: 'partido_programacion'.
-- programar_encuentro admite ahora el estado en la misma llamada, para que un cambio de fecha y de
-- estado genere un único aviso.
-- Requisito: las migraciones se aplican en orden.
-- =====================================================================
drop function if exists public.programar_encuentro(uuid, timestamptz, text, text);
create or replace function public.programar_encuentro(
  p_encuentro uuid, p_fecha_hora timestamptz, p_sede text default null, p_pista text default null,
  p_estado encuentro_estado default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if p_estado is not null and p_estado not in ('PROGRAMADO', 'APLAZADO', 'SUSPENDIDO') then
    raise exception 'estado no permitido: el resultado se registra con registrar_resultado' using errcode = '23514';
  end if;
  perform app.encuentro_editable(p_encuentro);
  update encuentro set fecha_hora = p_fecha_hora,
         sede = left(nullif(btrim(coalesce(p_sede, '')), ''), 120),
         pista = left(nullif(btrim(coalesce(p_pista, '')), ''), 60),
         estado = coalesce(p_estado, estado)
   where id = p_encuentro;
end $$;
revoke execute on function public.programar_encuentro(uuid, timestamptz, text, text, encuentro_estado) from public, anon;
grant execute on function public.programar_encuentro(uuid, timestamptz, text, text, encuentro_estado) to authenticated;

create or replace function public.notif_encuentro_programacion() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  v_local uuid; v_visit uuid; v_nom_l text; v_nom_v text; u uuid;
  v_titulo text; v_cuerpo text; v_cuando text; v_lugar text;
begin
  if new.visitante_inscripcion_id is null
     or new.estado not in ('PROGRAMADO', 'APLAZADO', 'SUSPENDIDO')
     or not (old.fecha_hora is distinct from new.fecha_hora or old.sede is distinct from new.sede
             or old.pista is distinct from new.pista or old.estado is distinct from new.estado) then
    return null;
  end if;
  select i.equipo_id, q.nombre into v_local, v_nom_l
    from public.inscripcion i join public.equipo q on q.id = i.equipo_id
    where i.id = new.local_inscripcion_id;
  select i.equipo_id, q.nombre into v_visit, v_nom_v
    from public.inscripcion i join public.equipo q on q.id = i.equipo_id
    where i.id = new.visitante_inscripcion_id;
  v_cuando := case when new.fecha_hora is null then null
                   else to_char(new.fecha_hora at time zone 'Europe/Madrid', 'DD/MM/YYYY "a las" HH24:MI') end;
  v_lugar := nullif(concat_ws(' · ', new.sede, new.pista), '');
  if new.estado = 'APLAZADO' then
    v_titulo := 'Partido aplazado';
    v_cuerpo := format('%s - %s se ha aplazado.%s', v_nom_l, v_nom_v,
                       case when v_cuando is not null then ' Nueva fecha: ' || v_cuando || '.' else ' Se avisará de la nueva fecha.' end);
  elsif new.estado = 'SUSPENDIDO' then
    v_titulo := 'Partido suspendido';
    v_cuerpo := format('%s - %s se ha suspendido.', v_nom_l, v_nom_v);
  elsif new.fecha_hora is null and v_lugar is null then
    return null;   -- se ha quitado la programación: nada que comunicar
  else
    v_titulo := case when old.fecha_hora is null or old.estado <> 'PROGRAMADO' and old.fecha_hora is null
                     then 'Partido programado' else 'Partido reprogramado' end;
    v_cuerpo := format('%s - %s: %s%s.', v_nom_l, v_nom_v,
                       coalesce(v_cuando, 'fecha por confirmar'),
                       case when v_lugar is not null then ' · ' || v_lugar else '' end);
  end if;
  for u in
    select distinct d from (
      select app.destinatarios_equipo(v_local) as d
      union all select app.destinatarios_equipo(v_visit)) x
  loop
    perform app.notificar(u, 'partido_programacion', v_titulo, v_cuerpo,
      jsonb_build_object('ruta', 'encuentro', 'encuentro_id', new.id), uid);
  end loop;
  return null;
end;
$$;
create trigger trg_notif_encuentro_programacion after update on public.encuentro
  for each row execute function public.notif_encuentro_programacion();
revoke execute on function public.notif_encuentro_programacion() from public, anon, authenticated;
