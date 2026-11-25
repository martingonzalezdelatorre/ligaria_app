-- =====================================================================
-- Entrenos: sesiones de entrenamiento que el entrenador asigna a su equipo.
-- · entreno: fecha y hora, duración, lugar y notas de una sesión de un equipo.
--   Lo crean, editan y borran el entrenador del equipo y la administración de la escuela.
-- · Lo ven el entrenador, la administración de la escuela, los jugadores del equipo con cuenta y sus
--   tutores (madres/padres): es lo que alimenta el calendario de la app.
-- · v_entrenos: lectura para la app, con el nombre del equipo.
-- Requisito: las migraciones se aplican en orden.
-- =====================================================================
create table public.entreno (
  id            uuid primary key default gen_random_uuid(),
  equipo_id     uuid not null references public.equipo (id) on delete cascade,
  creado_por    uuid references public.usuario (id) on delete set null default auth.uid(),
  fecha_hora    timestamptz not null,
  duracion_min  smallint check (duracion_min is null or duracion_min between 5 and 600),
  lugar         text check (lugar is null or char_length(lugar) <= 120),
  notas         text check (notas is null or char_length(notas) <= 1000),
  created_at    timestamptz not null default now()
);
create index entreno_equipo_fecha_idx on public.entreno (equipo_id, fecha_hora);

-- ¿Soy jugador del equipo o tutor de uno de sus jugadores?
create function app.participa_en_equipo(eq uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from equipo_miembro em
    where em.equipo_id = eq and (app.es_yo(em.jugador_id) or app.es_tutor_de(em.jugador_id)))
$$;

-- Quien asigna entrenos: el entrenador del equipo o la administración de su escuela.
create function app.gestiona_entrenos(eq uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or app.entrena_equipo(eq) or app.admin_org(app.org_de_equipo(eq))
$$;

alter table public.entreno enable row level security;
create policy entreno_sel on public.entreno for select to authenticated
  using (app.gestiona_entrenos(equipo_id) or app.participa_en_equipo(equipo_id));
create policy entreno_mod on public.entreno for all to authenticated
  using (app.gestiona_entrenos(equipo_id))
  with check (app.gestiona_entrenos(equipo_id));

revoke all on public.entreno from anon;
grant select, insert, update, delete on public.entreno to authenticated;
grant execute on function app.participa_en_equipo(uuid), app.gestiona_entrenos(uuid) to authenticated;
revoke execute on function app.participa_en_equipo(uuid), app.gestiona_entrenos(uuid) from public;

-- Entrenos que puedo ver (los de mis equipos, o los de la escuela si la administro).
create view public.v_entrenos as
  select en.id as entreno_id, en.equipo_id, e.nombre as equipo, e.organizacion_id,
         en.fecha_hora as fecha, en.duracion_min::int as duracion_min, en.lugar, en.notas
  from entreno en
  join equipo e on e.id = en.equipo_id
  where app.gestiona_entrenos(en.equipo_id) or app.participa_en_equipo(en.equipo_id);
grant select on public.v_entrenos to authenticated;
