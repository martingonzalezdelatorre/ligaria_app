-- Ligaria · 0012 · Alta en autoservicio de escuelas y ayuntamientos
-- Hasta ahora el registro solo dejaba una solicitud y el usuario quedaba «sin escuela».
-- Ahora, si el perfil es «escuela» o «ayuntamiento», el alta crea la entidad con el nombre
-- indicado y convierte al usuario en su administrador. El resto de perfiles (jugador, familia,
-- entrenador, organizador) siguen necesitando una invitación de su escuela.
-- Los metadatos siguen sin poder conceder superadmin ni acceso a entidades ya existentes.

-- «Club Deportivo Peña» → «club-deportivo-pena»; valida y desambigua según la tabla indicada
create or replace function app.slug_desde_nombre(p_nombre text, p_tabla text) returns text
language plpgsql stable set search_path = public, pg_temp as $$
declare base text; cand text; n int := 1; libre boolean;
begin
  base := lower(translate(btrim(p_nombre), 'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ', 'aaaaaeeeeiiiiooooouuuuncAAAAAEEEEIIIIOOOOOUUUUNC'));
  base := regexp_replace(base, '[^a-z0-9]+', '-', 'g');
  base := regexp_replace(base, '(^-+|-+$)', '', 'g');
  base := left(base, 34);
  base := regexp_replace(base, '-+$', '', 'g');
  if length(base) < 3 then base := 'entidad'; end if;
  cand := base;
  loop
    if p_tabla = 'ayuntamiento' then
      libre := app.slug_valido(cand) and not exists (select 1 from ayuntamiento where slug = cand);
    else
      libre := not exists (select 1 from escuela where slug = cand);
    end if;
    exit when libre;
    n := n + 1;
    cand := base || '-' || n;
  end loop;
  return cand;
end $$;

-- Crea la entidad de una solicitud de escuela/ayuntamiento y hace administrador a su autor
create or replace function app.aprovisionar_solicitud(p_usuario uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare s solicitud_registro; eid uuid; aid uuid;
begin
  select * into s from solicitud_registro where usuario_id = p_usuario and estado = 'pendiente';
  if not found or nullif(btrim(coalesce(s.escuela_texto, '')), '') is null then return; end if;
  if s.perfil = 'escuela' then
    insert into escuela (nombre, slug)
      values (btrim(s.escuela_texto), app.slug_desde_nombre(s.escuela_texto, 'escuela')) returning id into eid;
    insert into escuela_modulo (escuela_id, modulo, activo) values (eid, 'competiciones', true);
    insert into pertenencia (usuario_id, escuela_id, rol) values (p_usuario, eid, 'admin_escuela') on conflict do nothing;
  elsif s.perfil = 'ayuntamiento' then
    insert into ayuntamiento (nombre, slug)
      values (btrim(s.escuela_texto), app.slug_desde_nombre(s.escuela_texto, 'ayuntamiento')) returning id into aid;
    perform app.dar_acceso_ayto(p_usuario, aid);
  else
    return;
  end if;
  update solicitud_registro set estado = 'atendida' where usuario_id = p_usuario;
end $$;
revoke all on function app.aprovisionar_solicitud(uuid) from public;

create or replace function app.alta_usuario() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  i invitacion; ai ayuntamiento_invitacion; mail text; meta jsonb; perfil_in text;
  esc text; conflicto text;
begin
  mail := lower(coalesce(to_jsonb(new)->>'email', ''));
  meta := coalesce(to_jsonb(new)->'raw_user_meta_data', '{}'::jsonb);
  perfil_in := meta->>'perfil';
  esc := nullif(btrim(coalesce(meta->>'escuela', '')), '');

  if perfil_in is not null and perfil_in not in ('escuela','ayuntamiento','organizador','entrenador','familia','jugador') then
    raise exception 'PERFIL_INVALIDO: perfil no permitido' using errcode = '23514';
  end if;
  if perfil_in in ('escuela','ayuntamiento') and esc is null then
    raise exception 'ESCUELA_REQUERIDA: falta el nombre de la escuela' using errcode = '23514';
  end if;

  conflicto := app.alta_conflicto(mail, perfil_in, esc, new.id);
  if conflicto is not null then
    raise exception '%: el alta ya existe', conflicto using errcode = '23505';
  end if;

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
  if perfil_in is not null then
    insert into solicitud_registro (usuario_id, email, nombre, perfil, escuela_texto)
      values (new.id, mail, left(nullif(trim(meta->>'nombre'), ''), 120), perfil_in, left(esc, 160))
      on conflict (usuario_id) do nothing;
    perform app.aprovisionar_solicitud(new.id);
  end if;
  return new;
end $$;

-- Cuentas ya registradas que se quedaron en «sin escuela»
do $$
declare r record;
begin
  for r in select usuario_id from solicitud_registro
           where estado = 'pendiente' and perfil in ('escuela','ayuntamiento') loop
    perform app.aprovisionar_solicitud(r.usuario_id);
  end loop;
end $$;
