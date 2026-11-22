-- =====================================================================
-- Padres, madres y tutores del jugador.
-- Se asocian al dar de alta al alumno (o después) con nombre, parentesco, email y teléfono.
-- Si ya tienen cuenta se vinculan al momento; si no, queda una invitación pendiente que se
-- aplica sola cuando se registran con ese email (mecanismo de invitaciones existente).
-- =====================================================================
alter table public.invitacion
  add column parentesco         text,
  add column nombre_contacto    text,
  add column telefono_contacto  text;

-- Igual que la versión de 0009, pero el tutor conserva el parentesco indicado en la invitación.
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
        insert into tutor_jugador (tutor_usuario_id, jugador_id, parentesco)
          values (uid, i.jugador_id, i.parentesco)
          on conflict (tutor_usuario_id, jugador_id)
          do update set parentesco = coalesce(excluded.parentesco, public.tutor_jugador.parentesco);
        -- Si la cuenta aún no tiene teléfono, se aprovecha el de la invitación.
        update usuario set telefono = i.telefono_contacto where id = uid and telefono is null and i.telefono_contacto is not null;
      elsif cod = 'JUGADOR' then
        update jugador set usuario_id = uid where id = i.jugador_id and usuario_id is null;
      end if;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Núcleo compartido (sin comprobar permisos: lo llaman las funciones públicas de abajo).
create or replace function app.anadir_tutor_int(
  p_jugador uuid, p_nombre text, p_parentesco text, p_email text, p_telefono text)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare
  org uuid := app.org_de_jugador(p_jugador);
  mail text := lower(btrim(coalesce(p_email, '')));
  par text := nullif(btrim(coalesce(p_parentesco, '')), '');
  inv invitacion; uid uuid; rid smallint;
begin
  if org is null then raise exception 'el jugador no pertenece a ninguna organización' using errcode = '23514'; end if;
  if mail !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'el email del tutor no es válido' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'TUTOR';
  -- Una misma persona no se asocia dos veces al mismo jugador.
  if exists (select 1 from invitacion where jugador_id = p_jugador and lower(email) = mail
             and rol_id = rid and aplicada_en is null)
     or exists (select 1 from tutor_jugador tj join usuario u on u.id = tj.tutor_usuario_id
                where tj.jugador_id = p_jugador and lower(u.email) = mail) then
    raise exception 'ese tutor ya está asociado al jugador' using errcode = '23505';
  end if;
  insert into invitacion (organizacion_id, email, rol_id, jugador_id, parentesco, nombre_contacto, telefono_contacto)
    values (org, mail, rid, p_jugador, par, left(nullif(btrim(coalesce(p_nombre, '')), ''), 160),
            left(nullif(btrim(coalesce(p_telefono, '')), ''), 40))
    returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); return 'vinculado'; end if;
  return 'pendiente';
end $$;
revoke execute on function app.anadir_tutor_int(uuid, text, text, text, text) from public, anon, authenticated;

-- Asocia un padre/madre/tutor a un jugador ya existente. Devuelve 'vinculado' o 'pendiente'.
create or replace function public.anadir_tutor(
  p_jugador uuid, p_nombre text, p_parentesco text, p_email text, p_telefono text default null)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare org uuid := app.org_de_jugador(p_jugador);
begin
  if org is null or not app.admin_org(org) then
    raise exception 'sin permiso para asociar tutores a este jugador' using errcode = '42501';
  end if;
  return app.anadir_tutor_int(p_jugador, p_nombre, p_parentesco, p_email, p_telefono);
end $$;

-- Da de alta al jugador y asocia a sus tutores en una sola operación (todo o nada).
-- p_tutores: [{"nombre":"…","parentesco":"Madre","email":"…","telefono":"…"}, …]
create or replace function public.crear_jugador_con_tutores(
  p_org uuid, p_nombre text, p_apellidos text, p_fecha_nacimiento date, p_tutores jsonb default '[]')
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare jid uuid; t jsonb;
begin
  if not app.admin_org(p_org) then
    raise exception 'sin permiso para dar de alta jugadores' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'el nombre es obligatorio' using errcode = '23514'; end if;
  if p_fecha_nacimiento is null or p_fecha_nacimiento > current_date then
    raise exception 'fecha de nacimiento no válida' using errcode = '23514';
  end if;
  insert into jugador (organizacion_id, nombre, apellidos, fecha_nacimiento)
    values (p_org, btrim(p_nombre), nullif(btrim(coalesce(p_apellidos, '')), ''), p_fecha_nacimiento)
    returning id into jid;
  for t in select * from jsonb_array_elements(coalesce(p_tutores, '[]'::jsonb)) loop
    perform app.anadir_tutor_int(jid, t ->> 'nombre', t ->> 'parentesco', t ->> 'email', t ->> 'telefono');
  end loop;
  return jid;
end $$;

-- Tutores de los jugadores que la organización administra: vinculados (con cuenta) y pendientes (invitados).
create or replace view public.v_tutores_jugador as
  select tj.jugador_id, u.id as usuario_id,
         coalesce(nullif(btrim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')), ''), u.email) as nombre,
         u.email, u.telefono, tj.parentesco, 'vinculado'::text as estado
  from tutor_jugador tj
  join usuario u on u.id = tj.tutor_usuario_id
  where app.admin_org(app.org_de_jugador(tj.jugador_id))
  union all
  select i.jugador_id, null::uuid, coalesce(i.nombre_contacto, i.email), i.email, i.telefono_contacto,
         i.parentesco, 'pendiente'::text
  from invitacion i
  join rol r on r.id = i.rol_id and r.codigo = 'TUTOR'
  where i.jugador_id is not null and i.aplicada_en is null and app.admin_org(i.organizacion_id);

grant select on public.v_tutores_jugador to authenticated;
revoke execute on function public.anadir_tutor(uuid, text, text, text, text) from public, anon;
grant execute on function public.anadir_tutor(uuid, text, text, text, text) to authenticated;
revoke execute on function public.crear_jugador_con_tutores(uuid, text, text, date, jsonb) from public, anon;
grant execute on function public.crear_jugador_con_tutores(uuid, text, text, date, jsonb) to authenticated;
