-- =====================================================================
-- Co-organizadores que aún no tienen cuenta
-- Hasta ahora asignar_organizador_liga exigía que el correo ya estuviera registrado. Ahora, si no lo
-- está, se guarda una invitación (tabla invitacion, con competicion_id) que se aplica sola cuando la
-- persona se registra con ese correo: queda como co-organizador de esa liga, sin rol en la organización.
-- Esa invitación también permite el registro por correo (REGISTRO_SOLO_INVITACION).
-- =====================================================================

-- Requisito: las migraciones se aplican en orden.
do $$ begin
  if to_regclass('public.v_organizadores_org') is null then
    raise exception 'Falta la migración 0008 (organizadores invitan). Aplica las migraciones en orden: 0001 … 0009.';
  end if;
end $$;

alter table public.invitacion
  add column competicion_id uuid references public.competicion (id) on delete cascade;
create unique index uq_invitacion_coorganizador
  on public.invitacion (competicion_id, lower(email))
  where competicion_id is not null and aplicada_en is null;

-- Al aplicar una invitación de liga se crea la asignación de co-organizador (competicion_id, sin organización).
create or replace function app.aplicar_invitacion(i invitacion, uid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare cod text;
begin
  select codigo into cod from rol where id = i.rol_id;
  if i.competicion_id is not null then
    if not exists (select 1 from asignacion_rol
                   where usuario_id = uid and rol_id = i.rol_id and competicion_id = i.competicion_id) then
      insert into asignacion_rol (usuario_id, rol_id, competicion_id) values (uid, i.rol_id, i.competicion_id);
    end if;
  else
    insert into asignacion_rol (usuario_id, rol_id, organizacion_id) values (uid, i.rol_id, i.organizacion_id)
      on conflict do nothing;
    if i.jugador_id is not null then
      if cod = 'TUTOR' then
        insert into tutor_jugador (tutor_usuario_id, jugador_id) values (uid, i.jugador_id) on conflict do nothing;
      elsif cod = 'JUGADOR' then
        update jugador set usuario_id = uid where id = i.jugador_id and usuario_id is null;
      end if;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Devuelve 'asignado' (la persona ya tenía cuenta) o 'invitado' (se activará al registrarse).
drop function public.asignar_organizador_liga(uuid, text);
create function public.asignar_organizador_liga(p_competicion uuid, p_email text)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; uid uuid; rid smallint; mail text := lower(btrim(p_email));
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para asignar organizadores' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if mail !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'correo no válido' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'ORGANIZADOR_LIGAS';
  select id into uid from usuario where lower(email) = mail;

  if uid is null then
    -- aún no tiene cuenta: invitación pendiente que se aplica al registrarse
    if exists (select 1 from invitacion
               where competicion_id = c.id and lower(email) = mail and aplicada_en is null) then
      raise exception 'ya está invitado como organizador de esta liga' using errcode = '23505';
    end if;
    insert into invitacion (organizacion_id, email, rol_id, competicion_id)
      values (c.organizacion_id, mail, rid, c.id);
    return 'invitado';
  end if;

  if exists (select 1 from asignacion_rol ar
             where ar.usuario_id = uid and ar.organizacion_id = c.organizacion_id
               and ar.rol_id in (select id from rol where codigo in ('ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS'))) then
    raise exception 'ya organiza las ligas de esta organización' using errcode = '23505';
  end if;
  if exists (select 1 from asignacion_rol where usuario_id = uid and rol_id = rid and competicion_id = c.id) then
    raise exception 'ya es organizador de esta liga' using errcode = '23505';
  end if;
  insert into asignacion_rol (usuario_id, rol_id, competicion_id) values (uid, rid, c.id);
  return 'asignado';
end $$;

-- Retira una invitación de co-organizador que aún no se ha aplicado.
create function public.retirar_invitacion_organizador(p_competicion uuid, p_email text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; n int;
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para quitar organizadores' using errcode = '42501';
  end if;
  delete from invitacion
   where competicion_id = c.id and lower(email) = lower(btrim(p_email)) and aplicada_en is null;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'invitación no encontrada' using errcode = '23514'; end if;
end $$;

-- Co-organizadores de una liga: los que ya tienen cuenta y las invitaciones pendientes (usuario_id nulo).
create or replace view public.v_organizadores_liga as
  select ar.competicion_id, u.id as usuario_id, u.email,
         trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre,
         false as pendiente
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join usuario u on u.id = ar.usuario_id
  where ar.competicion_id is not null and ar.organizacion_id is null
    and app.gestiona_comp(ar.competicion_id)
  union all
  select i.competicion_id, null::uuid, i.email, null::text, true
  from invitacion i
  where i.competicion_id is not null and i.aplicada_en is null and app.gestiona_comp(i.competicion_id);

revoke execute on function public.asignar_organizador_liga(uuid, text) from public;
revoke execute on function public.retirar_invitacion_organizador(uuid, text) from public;
grant execute on function public.asignar_organizador_liga(uuid, text) to authenticated;
grant execute on function public.retirar_invitacion_organizador(uuid, text) to authenticated;
