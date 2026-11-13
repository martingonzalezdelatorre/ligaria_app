-- Ligaria · 0008 · El registro web admite el perfil «ayuntamiento»
alter table solicitud_registro drop constraint if exists solicitud_registro_perfil_check;
alter table solicitud_registro add constraint solicitud_registro_perfil_check
  check (perfil in ('escuela','ayuntamiento','organizador','entrenador','familia','jugador'));

create or replace function app.alta_usuario() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare i invitacion; mail text; meta jsonb; perfil_in text;
begin
  mail := lower(coalesce(to_jsonb(new)->>'email', ''));
  meta := coalesce(to_jsonb(new)->'raw_user_meta_data', '{}'::jsonb);
  insert into usuario (id, email, nombre)
    values (new.id, mail, left(coalesce(nullif(trim(meta->>'nombre'), ''), split_part(mail, '@', 1)), 120))
    on conflict (id) do nothing;
  for i in select * from invitacion where lower(email) = mail and aplicada_en is null loop
    perform app.aplicar_invitacion(i, new.id);
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
