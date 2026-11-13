-- Ligaria · 0010 · El ayuntamiento puede crear y organizar ligas de su municipio
-- Cada ayuntamiento tiene una «entidad organizadora» interna (una fila de escuela marcada es_ayuntamiento).
-- Así reutiliza sin cambios todo el motor de ligas (calendario, resultados, clasificación, RLS).
-- Sus administradores son organizador_liga de esa entidad. Las ligas municipales solo admiten
-- equipos de las escuelas vinculadas al ayuntamiento.

alter table escuela add column es_ayuntamiento boolean not null default false;
alter table ayuntamiento add column escuela_id uuid unique references escuela(id);

-- Crea la entidad organizadora del ayuntamiento (con el módulo de competiciones activo)
create function app.crear_entidad_ayuntamiento(p_ayto uuid) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare a ayuntamiento; e uuid;
begin
  select * into a from ayuntamiento where id = p_ayto;
  if a.escuela_id is not null then return a.escuela_id; end if;
  insert into escuela (nombre, slug, es_ayuntamiento)
    values (a.nombre, 'ayto-' || left(a.id::text, 8), true) returning id into e;
  insert into escuela_modulo (escuela_id, modulo, activo) values (e, 'competiciones', true);
  update ayuntamiento set escuela_id = e where id = p_ayto;
  return e;
end $$;

-- Da acceso de administración municipal: miembro + organizador de la entidad organizadora
create function app.dar_acceso_ayto(uid uuid, p_ayto uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e uuid;
begin
  e := app.crear_entidad_ayuntamiento(p_ayto);
  insert into ayuntamiento_miembro (usuario_id, ayuntamiento_id) values (uid, p_ayto) on conflict do nothing;
  insert into pertenencia (usuario_id, escuela_id, rol) values (uid, e, 'organizador_liga') on conflict do nothing;
end $$;

-- Datos ya existentes (ayuntamientos creados con la 0009)
do $$
declare a record; m record;
begin
  for a in select id from ayuntamiento where escuela_id is null loop
    perform app.crear_entidad_ayuntamiento(a.id);
  end loop;
  for m in select usuario_id, ayuntamiento_id from ayuntamiento_miembro loop
    perform app.dar_acceso_ayto(m.usuario_id, m.ayuntamiento_id);
  end loop;
end $$;

-- ───────── Alta de usuario: la administración municipal pendiente recibe también el rol organizador ─────────
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
    perform app.dar_acceso_ayto(new.id, ai.ayuntamiento_id);
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

-- ───────── RPC actualizadas ─────────
create or replace function public.crear_ayuntamiento(p_nombre text, p_slug text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare nuevo uuid; s text := lower(trim(p_slug));
begin
  if not app.es_superadmin() then raise exception 'sin permiso' using errcode = '42501'; end if;
  if not app.slug_valido(s) then
    raise exception 'subdominio no válido: usa 3-40 letras minúsculas, números o guiones' using errcode = '22023';
  end if;
  insert into ayuntamiento (nombre, slug) values (trim(p_nombre), s) returning id into nuevo;
  perform app.crear_entidad_ayuntamiento(nuevo);
  return nuevo;
end $$;

create or replace function public.asignar_admin_ayuntamiento(p_ayuntamiento uuid, p_email text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare uid uuid; mail text := lower(trim(p_email));
begin
  if not app.es_superadmin() then raise exception 'sin permiso' using errcode = '42501'; end if;
  if not exists (select 1 from ayuntamiento where id = p_ayuntamiento) then raise exception 'ayuntamiento inexistente'; end if;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then
    perform app.dar_acceso_ayto(uid, p_ayuntamiento);
  else
    insert into ayuntamiento_invitacion (ayuntamiento_id, email) values (p_ayuntamiento, mail);
  end if;
end $$;

create or replace function public.configurar_ayuntamiento(p_id uuid, p_nombre text, p_slug text) returns void
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
  update escuela set nombre = trim(p_nombre) where id = (select escuela_id from ayuntamiento where id = p_id);
end $$;

-- ───────── Inscripción: las ligas municipales solo admiten escuelas del municipio ─────────
create or replace function app.validar_inscripcion() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; ayto uuid;
begin
  select * into c from competicion where id = new.competicion_id;
  select * into e from equipo where id = new.equipo_id;
  if c.tipo <> 'liga' then raise exception 'solo se implementan ligas'; end if;
  if c.deporte_id <> e.deporte_id then
    raise exception 'el deporte del equipo no coincide con la competición' using errcode = '23514';
  end if;
  if c.categoria_id is not null and e.categoria_id is distinct from c.categoria_id then
    raise exception 'la categoría del equipo no coincide con la competición' using errcode = '23514';
  end if;
  select a.id into ayto from ayuntamiento a where a.escuela_id = c.organization_id;
  if ayto is not null and not exists (
       select 1 from escuela s where s.id = e.escuela_id and s.ayuntamiento_id = ayto) then
    raise exception 'esta liga es solo para escuelas del municipio' using errcode = '23514';
  end if;
  if exists (select 1 from jornada where competicion_id = c.id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  return new;
end $$;

-- ───────── Vistas ─────────
-- La entidad organizadora no es una escuela «real»: se oculta de «mis pertenencias» (su área es la del ayuntamiento)
create or replace view v_mis_pertenencias as
  select p.id, p.escuela_id, s.nombre as escuela, p.rol
  from pertenencia p left join escuela s on s.id = p.escuela_id
  where p.usuario_id = auth.uid() and coalesce(s.es_ayuntamiento, false) = false;

-- Se añade la entidad organizadora para que la app cree ligas con ella
create or replace view v_mis_ayuntamientos as
  select a.id, a.nombre, a.slug, a.escuela_id
  from ayuntamiento a join ayuntamiento_miembro m on m.ayuntamiento_id = a.id
  where m.usuario_id = auth.uid() and a.activo;

-- Ligas abiertas: las municipales solo las ven las escuelas del municipio (y el superadmin)
create or replace view v_ligas_abiertas as
select c.id as competicion_id, c.nombre, c.deporte_id, d.nombre as deporte, c.categoria_id,
       c.organization_id, s.nombre as organizadora
from competicion c join deporte d on d.id = c.deporte_id join escuela s on s.id = c.organization_id
where auth.uid() is not null and c.tipo = 'liga' and c.estado = 'publicada'
  and not exists (select 1 from jornada j where j.competicion_id = c.id)
  and (
    not exists (select 1 from ayuntamiento a where a.escuela_id = c.organization_id)
    or app.es_superadmin()
    or exists (select 1 from ayuntamiento a
               join escuela e on e.ayuntamiento_id = a.id
               join pertenencia p on p.escuela_id = e.id and p.usuario_id = auth.uid()
               where a.escuela_id = c.organization_id));
