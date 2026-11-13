-- =====================================================================
-- Ligaria Friends - Esquema base (Supabase / PostgreSQL)
-- Grupos de amigos -> ligas -> participantes (jugador o pareja) -> partidos -> sets.
-- Pensado para un proyecto Supabase NUEVO y propio de Friends.
-- El acceso (RLS, RPC, vistas v_*) está en 0002_acceso_app.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tipos enumerados
-- ---------------------------------------------------------------------
create type deporte_tipo   as enum ('TENIS', 'PADEL');
create type modalidad_tipo as enum ('INDIVIDUAL', 'PAREJAS');
create type liga_formato   as enum ('LIGA', 'ELIMINATORIA');
create type liga_estado    as enum ('BORRADOR', 'EN_CURSO', 'FINALIZADA', 'CANCELADA');
create type partido_estado as enum ('PROPUESTO', 'PROGRAMADO', 'JUGADO', 'CANCELADO', 'NO_PRESENTADO');
create type rol_grupo      as enum ('ADMIN', 'MIEMBRO');
create type lado_tipo      as enum ('LOCAL', 'VISITANTE');
create type mano_tipo      as enum ('DIESTRO', 'ZURDO', 'AMBIDIESTRO');

-- ---------------------------------------------------------------------
-- 2. Utilidades
-- ---------------------------------------------------------------------
create schema if not exists app;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Código de invitación: 10 caracteres hexadecimales en mayúsculas (aleatorio criptográfico).
create or replace function app.generar_codigo()
returns text
language sql
volatile
set search_path = ''
as $$ select upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10)) $$;

-- ---------------------------------------------------------------------
-- 3. Perfiles (uno por cuenta de Supabase Auth)
-- ---------------------------------------------------------------------
create table public.perfil (
  id              uuid primary key references auth.users (id) on delete cascade,
  email           text,
  nombre          text,
  apodo           text,
  avatar_url      text,
  mano_dominante  mano_tipo,
  nivel           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index idx_perfil_email on public.perfil (lower(email));

create trigger trg_perfil_updated_at
  before update on public.perfil
  for each row execute function public.set_updated_at();

-- Crea el perfil al registrarse. La app envía el nombre en raw_user_meta_data ('nombre').
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.perfil (id, email, nombre)
  values (new.id, new.email, nullif(btrim(new.raw_user_meta_data ->> 'nombre'), ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 4. Grupos de amigos
-- ---------------------------------------------------------------------
create table public.grupo (
  id                 uuid primary key default gen_random_uuid(),
  nombre             text not null check (char_length(btrim(nombre)) between 2 and 60),
  descripcion        text,
  codigo_invitacion  text not null unique default app.generar_codigo(),
  creado_por         uuid references public.perfil (id) on delete set null,
  created_at         timestamptz not null default now()
);

create table public.grupo_miembro (
  grupo_id    uuid not null references public.grupo (id) on delete cascade,
  usuario_id  uuid not null references public.perfil (id) on delete cascade,
  rol         rol_grupo not null default 'MIEMBRO',
  alias       text,
  created_at  timestamptz not null default now(),
  primary key (grupo_id, usuario_id)
);
create index idx_grupo_miembro_usuario on public.grupo_miembro (usuario_id);

-- Un grupo nunca puede quedarse sin administrador.
create or replace function public.grupo_miembro_conservar_admin()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.rol = 'ADMIN'
     and (tg_op = 'DELETE' or new.rol <> 'ADMIN' or new.grupo_id <> old.grupo_id)
     and exists (select 1 from public.grupo g where g.id = old.grupo_id)  -- no al borrar el grupo entero
     and not exists (
       select 1 from public.grupo_miembro m
       where m.grupo_id = old.grupo_id and m.rol = 'ADMIN' and m.usuario_id <> old.usuario_id)
  then
    raise exception 'El grupo debe conservar al menos un administrador.' using errcode = 'P0001';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_grupo_miembro_conservar_admin
  before update or delete on public.grupo_miembro
  for each row execute function public.grupo_miembro_conservar_admin();

-- ---------------------------------------------------------------------
-- 5. Ligas
-- ---------------------------------------------------------------------
create table public.liga (
  id               uuid primary key default gen_random_uuid(),
  grupo_id         uuid not null references public.grupo (id) on delete cascade,
  nombre           text not null check (char_length(btrim(nombre)) between 2 and 80),
  deporte          deporte_tipo not null,
  modalidad        modalidad_tipo not null default 'INDIVIDUAL',
  formato          liga_formato not null default 'LIGA',
  estado           liga_estado not null default 'BORRADOR',
  sets_para_ganar  smallint not null default 2 check (sets_para_ganar between 1 and 3),
  puntos_victoria  smallint not null default 3 check (puntos_victoria >= 0),
  fecha_inicio     date,
  fecha_fin        date,
  creado_por       uuid not null default auth.uid() references public.perfil (id) on delete restrict,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  check (fecha_fin is null or fecha_inicio is null or fecha_fin >= fecha_inicio)
);
create index idx_liga_grupo on public.liga (grupo_id);
create index idx_liga_creado_por on public.liga (creado_por);

create trigger trg_liga_updated_at
  before update on public.liga
  for each row execute function public.set_updated_at();

-- Participante = un jugador (INDIVIDUAL) o una pareja (PAREJAS) dentro de una liga.
create table public.participante (
  id          uuid primary key default gen_random_uuid(),
  liga_id     uuid not null references public.liga (id) on delete cascade,
  nombre      text not null check (char_length(btrim(nombre)) between 1 and 60),
  created_at  timestamptz not null default now(),
  unique (liga_id, nombre),
  unique (id, liga_id)             -- permite claves foráneas compuestas (mismo liga_id)
);

create table public.participante_jugador (
  participante_id  uuid not null,
  liga_id          uuid not null,
  usuario_id       uuid not null references public.perfil (id) on delete cascade,
  primary key (participante_id, usuario_id),
  unique (liga_id, usuario_id),    -- nadie juega en dos participantes de la misma liga
  foreign key (participante_id, liga_id)
    references public.participante (id, liga_id) on delete cascade
);
create index idx_participante_jugador_usuario on public.participante_jugador (usuario_id);

-- Solo se inscribe con la liga en BORRADOR, el jugador debe ser miembro del grupo y
-- el nº de jugadores respeta la modalidad (1 individual, 2 pareja).
create or replace function public.participante_jugador_validar()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  l public.liga%rowtype;
  maximo int;
begin
  select * into l from public.liga where id = new.liga_id;
  if l.estado <> 'BORRADOR' then
    raise exception 'La liga ya ha empezado: no se pueden cambiar los participantes.' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.grupo_miembro m where m.grupo_id = l.grupo_id and m.usuario_id = new.usuario_id) then
    raise exception 'El jugador no pertenece al grupo.' using errcode = 'P0001';
  end if;
  maximo := case l.modalidad when 'INDIVIDUAL' then 1 else 2 end;
  if (select count(*) from public.participante_jugador x where x.participante_id = new.participante_id) >= maximo then
    raise exception 'Este participante ya está completo (% jugador/es).', maximo using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger trg_participante_jugador_validar
  before insert on public.participante_jugador
  for each row execute function public.participante_jugador_validar();

-- ---------------------------------------------------------------------
-- 6. Partidos y sets
-- ---------------------------------------------------------------------
create table public.partido (
  id            uuid primary key default gen_random_uuid(),
  liga_id       uuid not null references public.liga (id) on delete cascade,
  ronda         smallint not null default 1 check (ronda >= 1),
  local_id      uuid not null,
  visitante_id  uuid not null,
  fecha_hora    timestamptz,
  lugar         text,
  estado        partido_estado not null default 'PROGRAMADO',
  ganador       lado_tipo,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  foreign key (local_id, liga_id)     references public.participante (id, liga_id) on delete restrict,
  foreign key (visitante_id, liga_id) references public.participante (id, liga_id) on delete restrict,
  check (local_id <> visitante_id),
  check (ganador is null or estado in ('JUGADO', 'NO_PRESENTADO'))
);
create index idx_partido_liga on public.partido (liga_id);
create index idx_partido_local on public.partido (local_id);
create index idx_partido_visitante on public.partido (visitante_id);

create trigger trg_partido_updated_at
  before update on public.partido
  for each row execute function public.set_updated_at();

create table public.set_partido (
  partido_id          uuid not null references public.partido (id) on delete cascade,
  numero              smallint not null check (numero between 1 and 5),
  juegos_local        smallint not null check (juegos_local between 0 and 99),
  juegos_visitante    smallint not null check (juegos_visitante between 0 and 99),
  tiebreak_local      smallint check (tiebreak_local >= 0),
  tiebreak_visitante  smallint check (tiebreak_visitante >= 0),
  primary key (partido_id, numero)
);

-- ---------------------------------------------------------------------
-- 7. Clasificación de cada liga (vista calculada; respeta RLS del usuario)
-- Orden recomendado en el cliente: puntos desc, dif_sets desc, dif_juegos desc.
-- ---------------------------------------------------------------------
create view public.clasificacion
with (security_invoker = true)
as
with sets_p as (
  select partido_id,
         count(*) filter (where juegos_local > juegos_visitante) as sets_local,
         count(*) filter (where juegos_local < juegos_visitante) as sets_visitante,
         sum(juegos_local)     as juegos_local,
         sum(juegos_visitante) as juegos_visitante
  from public.set_partido
  group by partido_id
),
resultados as (
  select p.liga_id, p.local_id as participante_id, (p.ganador = 'LOCAL') as gana,
         coalesce(s.sets_local, 0) as sf, coalesce(s.sets_visitante, 0) as sc,
         coalesce(s.juegos_local, 0) as jf, coalesce(s.juegos_visitante, 0) as jc
  from public.partido p
  left join sets_p s on s.partido_id = p.id
  where p.ganador is not null
  union all
  select p.liga_id, p.visitante_id, (p.ganador = 'VISITANTE'),
         coalesce(s.sets_visitante, 0), coalesce(s.sets_local, 0),
         coalesce(s.juegos_visitante, 0), coalesce(s.juegos_local, 0)
  from public.partido p
  left join sets_p s on s.partido_id = p.id
  where p.ganador is not null
)
select pa.liga_id,
       pa.id     as participante_id,
       pa.nombre,
       count(r.participante_id)                          as pj,
       count(*) filter (where r.gana)                    as pg,
       count(*) filter (where r.gana is false)           as pp,
       coalesce(sum(r.sf), 0)                            as sets_favor,
       coalesce(sum(r.sc), 0)                            as sets_contra,
       coalesce(sum(r.sf), 0) - coalesce(sum(r.sc), 0)   as dif_sets,
       coalesce(sum(r.jf), 0)                            as juegos_favor,
       coalesce(sum(r.jc), 0)                            as juegos_contra,
       coalesce(sum(r.jf), 0) - coalesce(sum(r.jc), 0)   as dif_juegos,
       count(*) filter (where r.gana) * l.puntos_victoria as puntos
from public.participante pa
join public.liga l on l.id = pa.liga_id
left join resultados r on r.participante_id = pa.id
group by pa.liga_id, pa.id, pa.nombre, l.puntos_victoria;

-- ---------------------------------------------------------------------
-- 8. Row Level Security: activada en todas las tablas.
-- Sin políticas la API no puede leer ni escribir: lo abre 0002_acceso_app.sql.
-- ---------------------------------------------------------------------
alter table public.perfil               enable row level security;
alter table public.grupo                enable row level security;
alter table public.grupo_miembro        enable row level security;
alter table public.liga                 enable row level security;
alter table public.participante         enable row level security;
alter table public.participante_jugador enable row level security;
alter table public.partido              enable row level security;
alter table public.set_partido          enable row level security;
