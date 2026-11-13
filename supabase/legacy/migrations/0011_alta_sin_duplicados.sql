-- Ligaria · 0011 · El alta (registro) rechaza duplicados
-- Se bloquea el registro cuando:
--   1. el correo ya existe,
--   2. la escuela (o ayuntamiento) ya existe o ya tiene una solicitud de alta,
--   3. el par correo + escuela ya existe.
-- Los errores usan SQLSTATE 23505 y un mensaje estable (prefijo EMAIL_EXISTE,
-- ESCUELA_EXISTE, EMAIL_ESCUELA_EXISTE) solo para logs/diagnóstico. Los clientes NO
-- deben mostrarlos: siempre enseñan un mensaje genérico (evita enumeración de cuentas).

-- Red de seguridad frente a carreras (dos altas simultáneas)
create unique index if not exists usuario_email_lower_uq
  on usuario (lower(email)) where email is not null and email <> '';
create unique index if not exists solicitud_escuela_texto_uq
  on solicitud_registro (lower(btrim(escuela_texto)))
  where perfil in ('escuela','ayuntamiento') and estado <> 'descartada' and escuela_texto is not null;

-- Detecta el conflicto de un alta (null = sin conflicto). Lo usan el trigger y la
-- comprobación previa que hace la web antes de llamar a Auth.
create or replace function app.alta_conflicto(p_email text, p_perfil text, p_escuela text, p_id uuid default null)
returns text language plpgsql stable security definer set search_path = public, pg_temp as $$
declare mail text := lower(btrim(coalesce(p_email, ''))); esc text := nullif(btrim(coalesce(p_escuela, '')), '');
        email_dup boolean; escuela_dup boolean := false;
begin
  email_dup := mail <> '' and exists (
    select 1 from usuario u where lower(u.email) = mail and (p_id is null or u.id <> p_id));
  if esc is not null and p_perfil in ('escuela','ayuntamiento') then
    escuela_dup :=
      exists (select 1 from escuela e where lower(btrim(e.nombre)) = lower(esc))
      or exists (select 1 from ayuntamiento a where lower(btrim(a.nombre)) = lower(esc))
      or exists (select 1 from solicitud_registro s
                 where s.perfil in ('escuela','ayuntamiento') and s.estado <> 'descartada'
                   and lower(btrim(s.escuela_texto)) = lower(esc));
  end if;
  return case when email_dup and escuela_dup then 'EMAIL_ESCUELA_EXISTE'
              when email_dup then 'EMAIL_EXISTE'
              when escuela_dup then 'ESCUELA_EXISTE' end;
end $$;

revoke all on function app.alta_conflicto(text, text, text, uuid) from public;

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

  -- Rol (perfil): si se indica, debe ser uno válido; escuela y ayuntamiento exigen nombre
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
    insert into ayuntamiento_miembro (usuario_id, ayuntamiento_id) values (new.id, ai.ayuntamiento_id)
      on conflict do nothing;
    update ayuntamiento_invitacion set aplicada_en = now() where id = ai.id;
  end loop;
  if perfil_in is not null then
    insert into solicitud_registro (usuario_id, email, nombre, perfil, escuela_texto)
      values (new.id, mail, left(nullif(trim(meta->>'nombre'), ''), 120),
              perfil_in,
              left(esc, 160))
      on conflict (usuario_id) do nothing;
  end if;
  return new;
end $$;
