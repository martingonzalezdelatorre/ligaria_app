-- Ligaria · 0009 · Ayuntamientos (tenant municipal con subdominio propio)
-- Un ayuntamiento agrupa a las escuelas de su municipio y se sirve en <slug>.ligaria.es.
-- Sus administradores ven (solo lectura) las escuelas vinculadas y sus ligas, calendarios y clasificaciones.
-- Altas/vínculos: superadmin. El ayuntamiento solo puede cambiar su nombre y su subdominio.

-- ───────── Tablas ─────────
create table ayuntamiento (
  id uuid primary key default gen_random_uuid(),
  nombre text not null check (length(trim(nombre)) between 2 and 120),
  slug text not null unique,           -- subdominio: <slug>.ligaria.es
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

-- Validación del subdominio: minúsculas/números/guiones, 3-40 caracteres y no reservado
create function app.slug_valido(s text) returns boolean
language sql immutable as $$
  select s ~ '^[a-z0-9]([a-z0-9-]{1,38})[a-z0-9]$'
     and s !~ '--'
     and s <> all (array['www','app','api','admin','mail','correo','ligaria','soporte','ayuda','web','static',
                         'cdn','dev','staging','test','demo','blog','docs','status','auth','login'])
$$;
alter table ayuntamiento add constraint ayuntamiento_slug_valido check (app.slug_valido(slug));

alter table escuela add column ayuntamiento_id uuid references ayuntamiento(id) on delete set null;
create index escuela_ayuntamiento_idx on escuela (ayuntamiento_id);

create table ayuntamiento_miembro (
  usuario_id uuid not null references usuario(id) on delete cascade,
  ayuntamiento_id uuid not null references ayuntamiento(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (usuario_id, ayuntamiento_id)
);

-- Administrador asignado por email antes de que la persona se registre
create table ayuntamiento_invitacion (
  id uuid primary key default gen_random_uuid(),
  ayuntamiento_id uuid not null references ayuntamiento(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now(),
  aplicada_en timestamptz
);
create index ayuntamiento_inv_email_idx on ayuntamiento_invitacion (lower(email)) where aplicada_en is null;

-- ───────── Helpers ─────────
create function app.es_admin_ayto(ayto uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select ayto is not null and exists (
    select 1 from ayuntamiento_miembro where usuario_id = auth.uid() and ayuntamiento_id = ayto)
$$;

-- ¿Es una escuela de un ayuntamiento que administro?
create function app.ve_escuela_ayto(esc uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from escuela e where e.id = esc and app.es_admin_ayto(e.ayuntamiento_id))
$$;

-- La administración municipal ve las ligas organizadas por sus escuelas o donde participan
create or replace function app.ve_competicion(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      app.es_miembro(c.organization_id)
      or app.ve_escuela_ayto(c.organization_id)
      or exists (select 1 from inscripcion_equipo i
                 where i.competicion_id = c.id and (app.es_miembro(i.escuela_id) or app.ve_escuela_ayto(i.escuela_id)))))
$$;

-- ───────── RLS ─────────
alter table ayuntamiento enable row level security;
alter table ayuntamiento_miembro enable row level security;
alter table ayuntamiento_invitacion enable row level security;

create policy ayto_sel on ayuntamiento for select using (app.es_superadmin() or app.es_admin_ayto(id));
create policy aytom_sel on ayuntamiento_miembro for select
  using (app.es_superadmin() or usuario_id = auth.uid() or app.es_admin_ayto(ayuntamiento_id));
create policy aytoi_sel on ayuntamiento_invitacion for select using (app.es_superadmin());
grant select on ayuntamiento, ayuntamiento_miembro, ayuntamiento_invitacion to authenticated;
-- Sin permisos de escritura directos: todo pasa por las RPC de abajo.

drop policy escuela_sel on escuela;
create policy escuela_sel on escuela for select
  using (app.es_superadmin() or app.es_miembro(id) or app.es_admin_ayto(ayuntamiento_id));

-- ───────── Alta de usuario: aplica también administraciones municipales pendientes ─────────
create or replace function app.alta_usuario() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare i invitacion; ai ayuntamiento_invitacion; mail text; meta jsonb; perfil_in text;
begin
  mail := lower(coalesce(to_jsonb(new)->>'email', ''));
  meta := coalesce(to_jsonb(new)->'raw_user_meta_data', '{}'::jsonb);
  insert into usuario (id, email, nombre)
    values (new.id, mail, left(coalesce(nullif(trim(meta->>'nombre'), ''), split_part(mail, '@', 1)), 120))
    on conflict (id) do nothing;
  for i in select * from invitacion where lower(email) = mail and aplicada_en is null loop
    perform app.aplicar_invitacion(i, new.id);
  end loop;
  for ai in select * from ayuntamiento_invitacion where lower(email) = mail and aplicada_en is null loop
    insert into ayuntamiento_miembro (usuario_id, ayuntamiento_id) values (new.id, ai.ayuntamiento_id)
      on conflict do nothing;
    update ayuntamiento_invitacion set aplicada_en = now() where id = ai.id;
  end loop;
  perfil_in := meta->>'perfil';
  if perfil_in is not null then
    insert into solicitud_registro (usuario_id, email, nombre, perfil, escuela_texto)
      values (new.id, mail, left(nullif(trim(meta->>'nombre'), ''), 120),
              case when perfil_in in ('escuela','ayuntamiento','organizador','entrenador','familia','jugador') then perfil_in else 'jugador' end,
              left(nullif(trim(meta->>'escuela'), ''), 160))
      on conflict (usuario_id) do nothing;
  end if;
  return new;
end $$;

-- ───────── RPC ─────────
-- Superadmin: crear ayuntamiento
create function public.crear_ayuntamiento(p_nombre text, p_slug text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare nuevo uuid; s text := lower(trim(p_slug));
begin
  if not app.es_superadmin() then raise exception 'sin permiso' using errcode = '42501'; end if;
  if not app.slug_valido(s) then
    raise exception 'subdominio no válido: usa 3-40 letras minúsculas, números o guiones' using errcode = '22023';
  end if;
  insert into ayuntamiento (nombre, slug) values (trim(p_nombre), s) returning id into nuevo;
  return nuevo;
end $$;

-- Superadmin: asignar administrador por email (aplica ya si existe, o al registrarse)
create function public.asignar_admin_ayuntamiento(p_ayuntamiento uuid, p_email text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare uid uuid; mail text := lower(trim(p_email));
begin
  if not app.es_superadmin() then raise exception 'sin permiso' using errcode = '42501'; end if;
  if not exists (select 1 from ayuntamiento where id = p_ayuntamiento) then raise exception 'ayuntamiento inexistente'; end if;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then
    insert into ayuntamiento_miembro (usuario_id, ayuntamiento_id) values (uid, p_ayuntamiento) on conflict do nothing;
  else
    insert into ayuntamiento_invitacion (ayuntamiento_id, email) values (p_ayuntamiento, mail);
  end if;
end $$;

-- Superadmin: vincular (o desvincular con null) una escuela a un ayuntamiento
create function public.vincular_escuela_ayuntamiento(p_escuela uuid, p_ayuntamiento uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if not app.es_superadmin() then raise exception 'sin permiso' using errcode = '42501'; end if;
  update escuela set ayuntamiento_id = p_ayuntamiento where id = p_escuela;
end $$;

-- Administración municipal (o superadmin): cambiar nombre y subdominio
create function public.configurar_ayuntamiento(p_id uuid, p_nombre text, p_slug text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare s text := lower(trim(p_slug));
begin
  if not (app.es_superadmin() or app.es_admin_ayto(p_id)) then
    raise exception 'sin permiso' using errcode = '42501';
  end if;
  if not app.slug_valido(s) then
    raise exception 'subdominio no válido: usa 3-40 letras minúsculas, números o guiones' using errcode = '22023';
  end if;
  update ayuntamiento set nombre = trim(p_nombre), slug = s where id = p_id;
end $$;

-- Público (también sin sesión): nombre del ayuntamiento de un subdominio, para personalizar el login
create function public.ayuntamiento_por_slug(p_slug text) returns table (nombre text, slug text)
language sql stable security definer set search_path = public, pg_temp as $$
  select a.nombre, a.slug from ayuntamiento a where a.slug = lower(trim(p_slug)) and a.activo
$$;

revoke execute on function public.crear_ayuntamiento(text, text), public.asignar_admin_ayuntamiento(uuid, text),
  public.vincular_escuela_ayuntamiento(uuid, uuid), public.configurar_ayuntamiento(uuid, text, text) from public;
grant execute on function public.crear_ayuntamiento(text, text), public.asignar_admin_ayuntamiento(uuid, text),
  public.vincular_escuela_ayuntamiento(uuid, uuid), public.configurar_ayuntamiento(uuid, text, text) to authenticated;
grant execute on function public.ayuntamiento_por_slug(text) to anon, authenticated;

-- Mis ayuntamientos (para el cliente)
create view v_mis_ayuntamientos as
  select a.id, a.nombre, a.slug
  from ayuntamiento a join ayuntamiento_miembro m on m.ayuntamiento_id = a.id
  where m.usuario_id = auth.uid() and a.activo;
grant select on v_mis_ayuntamientos to authenticated;
