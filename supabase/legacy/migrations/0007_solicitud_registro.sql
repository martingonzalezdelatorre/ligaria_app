-- Ligaria · 0007 · Registro público desde la web de presentación
-- La web llama a Supabase Auth (signUp) con nombre/perfil/escuela en los metadatos.
-- Los metadatos NO conceden ningún rol: solo se guardan como solicitud para que la
-- plataforma (superadmin) o una invitación de escuela asignen la pertenencia real.

create table solicitud_registro (
  usuario_id uuid primary key references usuario(id) on delete cascade,
  email text not null,
  nombre text,
  perfil text not null default 'jugador'
    check (perfil in ('escuela','organizador','entrenador','familia','jugador')),
  escuela_texto text,
  estado text not null default 'pendiente' check (estado in ('pendiente','atendida','descartada')),
  created_at timestamptz not null default now()
);
create index solicitud_registro_estado_idx on solicitud_registro (estado, created_at desc);
alter table solicitud_registro enable row level security;
create policy sr_sel on solicitud_registro for select
  using (app.es_superadmin() or usuario_id = auth.uid());
create policy sr_upd on solicitud_registro for update
  using (app.es_superadmin()) with check (app.es_superadmin());
grant select on solicitud_registro to authenticated;
grant update (estado) on solicitud_registro to authenticated;

-- Alta: igual que antes + solicitud de registro (sin fallar nunca por metadatos raros)
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
              case when perfil_in in ('escuela','organizador','entrenador','familia','jugador') then perfil_in else 'jugador' end,
              left(nullif(trim(meta->>'escuela'), ''), 160))
      on conflict (usuario_id) do nothing;
  end if;
  return new;
end $$;
