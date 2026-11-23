-- =====================================================================
-- Social: buscar jugadores (por nombre / zona), añadirlos como amigos,
-- WhatsApp y mensajes internos.
-- Todo es opt-in: solo aparecen en la búsqueda quienes lo activan en Ajustes
-- (perfil.buscable) y el teléfono solo se comparte si el dueño lo permite.
-- =====================================================================

alter table public.perfil
  add column if not exists telefono         text check (telefono is null or char_length(telefono) between 6 and 20),
  add column if not exists telefono_visible boolean not null default false,
  add column if not exists buscable         boolean not null default false;

grant update (telefono, telefono_visible, buscable) on public.perfil to authenticated;

-- ¿Puedo tratar con esta persona (mensaje, WhatsApp, añadirla)?
-- Sí si es amigo (en cualquier sentido), comparte grupo o se ha hecho buscable.
create function app.puede_tratar(u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select u is not null
     and u <> (select auth.uid())
     and (app.comparte_grupo(u)
          or app.es_contacto(u)
          or exists (select 1 from public.contacto c
                     where c.usuario_id = u and c.contacto_id = (select auth.uid()))
          or exists (select 1 from public.perfil p where p.id = u and p.buscable))
$$;
revoke execute on function app.puede_tratar(uuid) from public, anon;
grant execute on function app.puede_tratar(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Búsqueda de jugadores: solo los que se han hecho buscables.
-- ---------------------------------------------------------------------
create function public.buscar_jugadores(
  p_texto text default null, p_provincia text default null,
  p_localidad text default null, p_limite int default 50)
returns table (id uuid, nombre text, provincia text, localidad text,
               es_amigo boolean, tiene_whatsapp boolean)
language sql stable security definer set search_path = '' as $$
  select pf.id,
         coalesce(nullif(btrim(pf.apodo), ''),
                  nullif(btrim(coalesce(pf.nombre, '') || ' ' || coalesce(pf.apellidos, '')), ''),
                  'Jugador'),
         pf.provincia,
         pf.localidad,
         (app.es_contacto(pf.id) or app.comparte_grupo(pf.id)),
         (pf.telefono_visible and nullif(btrim(coalesce(pf.telefono, '')), '') is not null)
  from public.perfil pf
  where (select auth.uid()) is not null
    and pf.id <> (select auth.uid())
    and pf.buscable
    and (nullif(btrim(coalesce(p_texto, '')), '') is null
         or (coalesce(pf.apodo, '') || ' ' || coalesce(pf.nombre, '') || ' ' || coalesce(pf.apellidos, ''))
            ilike '%' || btrim(p_texto) || '%')
    and (nullif(btrim(coalesce(p_provincia, '')), '') is null
         or lower(btrim(coalesce(pf.provincia, ''))) = lower(btrim(p_provincia)))
    and (nullif(btrim(coalesce(p_localidad, '')), '') is null
         or lower(btrim(coalesce(pf.localidad, ''))) like '%' || lower(btrim(p_localidad)) || '%')
  order by 5 desc, 2
  limit least(greatest(coalesce(p_limite, 50), 1), 100)
$$;
revoke execute on function public.buscar_jugadores(text, text, text, int) from public, anon;
grant execute on function public.buscar_jugadores(text, text, text, int) to authenticated;

-- Añade a alguien a tus amigos (contactos).
create function public.anadir_amigo(p_usuario uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not app.puede_tratar(p_usuario) then
    raise exception 'No puedes añadir a esa persona.' using errcode = '42501';
  end if;
  insert into public.contacto (usuario_id, contacto_id)
  values ((select auth.uid()), p_usuario) on conflict do nothing;
end;
$$;
revoke execute on function public.anadir_amigo(uuid) from public, anon;
grant execute on function public.anadir_amigo(uuid) to authenticated;

-- Teléfono para WhatsApp: solo si su dueño lo comparte y puedes tratar con él.
create function public.whatsapp_de(p_usuario uuid) returns text
language sql stable security definer set search_path = '' as $$
  select nullif(btrim(pf.telefono), '')
  from public.perfil pf
  where pf.id = p_usuario and pf.telefono_visible and app.puede_tratar(p_usuario)
$$;
revoke execute on function public.whatsapp_de(uuid) from public, anon;
grant execute on function public.whatsapp_de(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Mensajes internos entre dos personas.
-- ---------------------------------------------------------------------
create table public.mensaje (
  id         uuid primary key default gen_random_uuid(),
  de         uuid not null references public.perfil (id) on delete cascade,
  para       uuid not null references public.perfil (id) on delete cascade,
  texto      text not null check (char_length(btrim(texto)) between 1 and 1000),
  created_at timestamptz not null default now(),
  leido_at   timestamptz,
  check (de <> para)
);
create index idx_mensaje_para on public.mensaje (para, created_at desc);
create index idx_mensaje_de   on public.mensaje (de, created_at desc);

alter table public.mensaje enable row level security;
create policy mensaje_sel on public.mensaje for select to authenticated
  using (de = (select auth.uid()) or para = (select auth.uid()));
grant select on public.mensaje to authenticated;   -- se escribe solo con enviar_mensaje()

do $$ begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.mensaje;
  end if;
end $$;

create function public.enviar_mensaje(p_para uuid, p_texto text) returns void
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid()); quien text;
begin
  if not app.puede_tratar(p_para) then
    raise exception 'No puedes escribir a esa persona.' using errcode = '42501';
  end if;
  insert into public.mensaje (de, para, texto) values (uid, p_para, btrim(p_texto));
  select coalesce(nullif(btrim(apodo), ''), nullif(btrim(nombre), ''), 'Jugador')
    into quien from public.perfil where id = uid;
  perform app.notificar(p_para, 'mensaje', quien, left(btrim(p_texto), 140),
                        jsonb_build_object('de', uid), uid);
end;
$$;
revoke execute on function public.enviar_mensaje(uuid, text) from public, anon;
grant execute on function public.enviar_mensaje(uuid, text) to authenticated;

create function public.marcar_leidos(p_con uuid) returns void
language sql security definer set search_path = '' as $$
  update public.mensaje set leido_at = now()
  where para = (select auth.uid()) and de = p_con and leido_at is null
$$;
revoke execute on function public.marcar_leidos(uuid) from public, anon;
grant execute on function public.marcar_leidos(uuid) to authenticated;

-- Bandeja: una fila por conversación, con el último mensaje y los no leídos.
create function public.mis_conversaciones()
returns table (con_id uuid, nombre text, ultimo text, fecha timestamptz, sin_leer bigint)
language sql stable security definer set search_path = '' as $$
  with m as (
    select case when de = (select auth.uid()) then para else de end as con,
           texto, created_at, (para = (select auth.uid()) and leido_at is null) as nuevo
    from public.mensaje
    where de = (select auth.uid()) or para = (select auth.uid())
  )
  select distinct on (m.con) m.con,
         coalesce(nullif(btrim(pf.apodo), ''),
                  nullif(btrim(coalesce(pf.nombre, '') || ' ' || coalesce(pf.apellidos, '')), ''),
                  'Jugador'),
         m.texto, m.created_at,
         (select count(*) from m m2 where m2.con = m.con and m2.nuevo)
  from m join public.perfil pf on pf.id = m.con
  order by m.con, m.created_at desc
$$;
revoke execute on function public.mis_conversaciones() from public, anon;
grant execute on function public.mis_conversaciones() to authenticated;
