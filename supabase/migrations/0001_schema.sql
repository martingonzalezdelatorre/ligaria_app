-- =====================================================================
-- Gestión de ligas de pádel y tenis - Esquema para Supabase (PostgreSQL)
-- Ejecutar completo en: Supabase > SQL Editor > New query > Run
-- Pensado para un proyecto nuevo (sin tablas con estos nombres).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tipos enumerados
-- ---------------------------------------------------------------------
create type organizacion_tipo    as enum ('AYUNTAMIENTO', 'ESCUELA', 'GRUPO_AMIGOS');
create type deporte_tipo         as enum ('TENIS', 'PADEL');
create type equipo_tipo          as enum ('EQUIPO', 'PAREJA', 'INDIVIDUAL');
create type competicion_tipo     as enum ('MUNICIPAL', 'ENTRE_ESCUELAS', 'ESCUELA', 'AMIGOS');
create type competicion_formato  as enum ('LIGA', 'ELIMINATORIA', 'MIXTO');
create type competicion_estado   as enum ('BORRADOR', 'INSCRIPCION_ABIERTA', 'EN_CURSO', 'FINALIZADA', 'CANCELADA');
create type inscripcion_estado   as enum ('PENDIENTE', 'ACEPTADA', 'RECHAZADA', 'RETIRADA');
create type invitacion_estado    as enum ('PENDIENTE', 'ACEPTADA', 'RECHAZADA');
create type encuentro_estado     as enum ('PROGRAMADO', 'EN_JUEGO', 'FINALIZADO', 'APLAZADO', 'SUSPENDIDO', 'NO_PRESENTADO');
create type partido_tipo         as enum ('INDIVIDUAL', 'DOBLES');
create type lado_tipo            as enum ('LOCAL', 'VISITANTE');
create type genero_tipo          as enum ('MASCULINO', 'FEMENINO', 'MIXTO');
create type mano_tipo            as enum ('DIESTRO', 'ZURDO', 'AMBIDIESTRO');

-- ---------------------------------------------------------------------
-- 2. Función auxiliar para updated_at
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- 3. Usuarios, roles y permisos
-- ---------------------------------------------------------------------
-- "usuario" es el perfil de la cuenta de Supabase Auth (auth.users).
create table public.usuario (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text not null unique,
  nombre      text,
  apellidos   text,
  telefono    text,
  activo      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger trg_usuario_updated_at
  before update on public.usuario
  for each row execute function public.set_updated_at();

-- Crea automáticamente el perfil al registrarse un usuario en Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.usuario (id, email, nombre, apellidos)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'nombre',
    new.raw_user_meta_data ->> 'apellidos'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create table public.rol (
  id      smallint generated always as identity primary key,
  codigo  text not null unique,
  nombre  text not null
);

create table public.permiso (
  id           int generated always as identity primary key,
  codigo       text not null unique,
  descripcion  text
);

create table public.rol_permiso (
  rol_id      smallint not null references public.rol (id) on delete cascade,
  permiso_id  int      not null references public.permiso (id) on delete cascade,
  primary key (rol_id, permiso_id)
);

-- ---------------------------------------------------------------------
-- 4. Organizaciones (ayuntamientos, escuelas, grupos de amigos)
-- ---------------------------------------------------------------------
create table public.organizacion (
  id          uuid primary key default gen_random_uuid(),
  tipo        organizacion_tipo not null,
  nombre      text not null,
  ciudad      text,
  activa      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table public.sede (
  id               uuid primary key default gen_random_uuid(),
  organizacion_id  uuid not null references public.organizacion (id) on delete cascade,
  nombre           text not null,
  direccion        text
);

create table public.pista (
  id          uuid primary key default gen_random_uuid(),
  sede_id     uuid not null references public.sede (id) on delete cascade,
  nombre      text not null,
  superficie  text,
  deporte     deporte_tipo not null
);

-- ---------------------------------------------------------------------
-- 5. Jugadores, tutores y equipos
-- ---------------------------------------------------------------------
-- usuario_id es opcional: un menor puede existir sin cuenta propia.
create table public.jugador (
  id                uuid primary key default gen_random_uuid(),
  usuario_id        uuid unique references public.usuario (id) on delete set null,
  nombre            text not null,
  apellidos         text,
  fecha_nacimiento  date,
  genero            genero_tipo,
  nivel             text,
  mano_dominante    mano_tipo,
  created_at        timestamptz not null default now()
);

create table public.tutor_jugador (
  tutor_usuario_id  uuid not null references public.usuario (id) on delete cascade,
  jugador_id        uuid not null references public.jugador (id) on delete cascade,
  parentesco        text,
  primary key (tutor_usuario_id, jugador_id)
);

-- Un "equipo" puede ser un equipo, una pareja (pádel) o un jugador individual.
create table public.equipo (
  id               uuid primary key default gen_random_uuid(),
  organizacion_id  uuid not null references public.organizacion (id) on delete cascade,
  nombre           text not null,
  tipo             equipo_tipo not null default 'EQUIPO',
  deporte          deporte_tipo not null,
  created_at       timestamptz not null default now(),
  unique (organizacion_id, nombre)
);

create table public.equipo_miembro (
  equipo_id   uuid not null references public.equipo (id) on delete cascade,
  jugador_id  uuid not null references public.jugador (id) on delete cascade,
  capitan     boolean not null default false,
  fecha_alta  date not null default current_date,
  primary key (equipo_id, jugador_id)
);

create table public.entrenador_equipo (
  equipo_id   uuid not null references public.equipo (id) on delete cascade,
  usuario_id  uuid not null references public.usuario (id) on delete cascade,
  primary key (equipo_id, usuario_id)
);

-- ---------------------------------------------------------------------
-- 6. Competiciones
-- ---------------------------------------------------------------------
create table public.competicion (
  id               uuid primary key default gen_random_uuid(),
  organizacion_id  uuid not null references public.organizacion (id) on delete restrict,
  organizador_id   uuid not null references public.usuario (id) on delete restrict,
  nombre           text not null,
  tipo             competicion_tipo not null,
  deporte          deporte_tipo not null,
  formato          competicion_formato not null default 'LIGA',
  estado           competicion_estado not null default 'BORRADOR',
  fecha_inicio     date,
  fecha_fin        date,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  check (fecha_fin is null or fecha_inicio is null or fecha_fin >= fecha_inicio)
);

create trigger trg_competicion_updated_at
  before update on public.competicion
  for each row execute function public.set_updated_at();

-- Organizaciones que participan (ligas entre escuelas, municipales, etc.)
create table public.competicion_org (
  competicion_id     uuid not null references public.competicion (id) on delete cascade,
  organizacion_id    uuid not null references public.organizacion (id) on delete cascade,
  estado_invitacion  invitacion_estado not null default 'PENDIENTE',
  primary key (competicion_id, organizacion_id)
);

-- Asignación de roles con ámbito (organización y/o competición).
create table public.asignacion_rol (
  id               uuid primary key default gen_random_uuid(),
  usuario_id       uuid not null references public.usuario (id) on delete cascade,
  rol_id           smallint not null references public.rol (id) on delete restrict,
  organizacion_id  uuid references public.organizacion (id) on delete cascade,
  competicion_id   uuid references public.competicion (id) on delete cascade,
  created_at       timestamptz not null default now()
);

create unique index uq_asignacion_rol
  on public.asignacion_rol (
    usuario_id,
    rol_id,
    coalesce(organizacion_id, '00000000-0000-0000-0000-000000000000'::uuid),
    coalesce(competicion_id,  '00000000-0000-0000-0000-000000000000'::uuid)
  );

create table public.categoria (
  id              uuid primary key default gen_random_uuid(),
  competicion_id  uuid not null references public.competicion (id) on delete cascade,
  nombre          text not null,
  genero          genero_tipo,
  edad_min        smallint,
  edad_max        smallint,
  nivel           text,
  check (edad_max is null or edad_min is null or edad_max >= edad_min),
  unique (competicion_id, nombre)
);

create table public.inscripcion (
  id            uuid primary key default gen_random_uuid(),
  categoria_id  uuid not null references public.categoria (id) on delete cascade,
  equipo_id     uuid not null references public.equipo (id) on delete cascade,
  estado        inscripcion_estado not null default 'PENDIENTE',
  fecha         timestamptz not null default now(),
  unique (categoria_id, equipo_id)
);

create table public.jornada (
  id            uuid primary key default gen_random_uuid(),
  categoria_id  uuid not null references public.categoria (id) on delete cascade,
  numero        smallint not null,
  fecha         date,
  unique (categoria_id, numero)
);

-- ---------------------------------------------------------------------
-- 7. Encuentros, partidos y resultados
-- ---------------------------------------------------------------------
-- puntos_local / puntos_visitante: partidos ganados por cada lado en el encuentro.
create table public.encuentro (
  id                          uuid primary key default gen_random_uuid(),
  jornada_id                  uuid not null references public.jornada (id) on delete cascade,
  local_inscripcion_id        uuid not null references public.inscripcion (id) on delete restrict,
  visitante_inscripcion_id    uuid not null references public.inscripcion (id) on delete restrict,
  pista_id                    uuid references public.pista (id) on delete set null,
  fecha_hora                  timestamptz,
  estado                      encuentro_estado not null default 'PROGRAMADO',
  puntos_local                smallint not null default 0,
  puntos_visitante            smallint not null default 0,
  updated_at                  timestamptz not null default now(),
  check (local_inscripcion_id <> visitante_inscripcion_id)
);

create trigger trg_encuentro_updated_at
  before update on public.encuentro
  for each row execute function public.set_updated_at();

create table public.partido (
  id            uuid primary key default gen_random_uuid(),
  encuentro_id  uuid not null references public.encuentro (id) on delete cascade,
  orden         smallint not null,
  tipo          partido_tipo not null,
  lado_ganador  lado_tipo,
  unique (encuentro_id, orden)
);

create table public.partido_jugador (
  partido_id  uuid not null references public.partido (id) on delete cascade,
  jugador_id  uuid not null references public.jugador (id) on delete restrict,
  lado        lado_tipo not null,
  primary key (partido_id, jugador_id)
);

create table public.set_partido (
  id                  uuid primary key default gen_random_uuid(),
  partido_id          uuid not null references public.partido (id) on delete cascade,
  numero              smallint not null,
  juegos_local        smallint not null default 0,
  juegos_visitante    smallint not null default 0,
  tiebreak_local      smallint,
  tiebreak_visitante  smallint,
  unique (partido_id, numero)
);

-- ---------------------------------------------------------------------
-- 8. Índices sobre claves foráneas
-- ---------------------------------------------------------------------
create index idx_asignacion_rol_usuario      on public.asignacion_rol (usuario_id);
create index idx_asignacion_rol_organizacion on public.asignacion_rol (organizacion_id);
create index idx_asignacion_rol_competicion  on public.asignacion_rol (competicion_id);
create index idx_tutor_jugador_jugador       on public.tutor_jugador (jugador_id);
create index idx_equipo_organizacion         on public.equipo (organizacion_id);
create index idx_equipo_miembro_jugador      on public.equipo_miembro (jugador_id);
create index idx_entrenador_equipo_usuario   on public.entrenador_equipo (usuario_id);
create index idx_sede_organizacion           on public.sede (organizacion_id);
create index idx_pista_sede                  on public.pista (sede_id);
create index idx_competicion_organizacion    on public.competicion (organizacion_id);
create index idx_competicion_organizador     on public.competicion (organizador_id);
create index idx_competicion_org_org         on public.competicion_org (organizacion_id);
create index idx_categoria_competicion       on public.categoria (competicion_id);
create index idx_inscripcion_equipo          on public.inscripcion (equipo_id);
create index idx_jornada_categoria           on public.jornada (categoria_id);
create index idx_encuentro_jornada           on public.encuentro (jornada_id);
create index idx_encuentro_local             on public.encuentro (local_inscripcion_id);
create index idx_encuentro_visitante         on public.encuentro (visitante_inscripcion_id);
create index idx_encuentro_pista             on public.encuentro (pista_id);
create index idx_partido_jugador_jugador     on public.partido_jugador (jugador_id);

-- ---------------------------------------------------------------------
-- 9. Clasificación (vista calculada)
-- Puntuación provisional: 3 por victoria, 1 por empate. Ajustar más adelante.
-- ---------------------------------------------------------------------
create view public.clasificacion
with (security_invoker = true)
as
with resultados as (
  select e.id as encuentro_id,
         e.local_inscripcion_id as inscripcion_id,
         e.puntos_local as pf,
         e.puntos_visitante as pc
  from public.encuentro e
  where e.estado = 'FINALIZADO'
  union all
  select e.id,
         e.visitante_inscripcion_id,
         e.puntos_visitante,
         e.puntos_local
  from public.encuentro e
  where e.estado = 'FINALIZADO'
)
select i.categoria_id,
       i.id as inscripcion_id,
       i.equipo_id,
       count(r.encuentro_id)                         as pj,
       count(*) filter (where r.pf > r.pc)           as pg,
       count(*) filter (where r.pf = r.pc)           as pe,
       count(*) filter (where r.pf < r.pc)           as pp,
       coalesce(sum(r.pf), 0)                        as favor,
       coalesce(sum(r.pc), 0)                        as contra,
       count(*) filter (where r.pf > r.pc) * 3
         + count(*) filter (where r.pf = r.pc)       as puntos
from public.inscripcion i
left join resultados r on r.inscripcion_id = i.id
where i.estado = 'ACEPTADA'
group by i.categoria_id, i.id, i.equipo_id;

-- ---------------------------------------------------------------------
-- 10. Datos iniciales: roles
-- ---------------------------------------------------------------------
insert into public.rol (codigo, nombre) values
  ('ADMINISTRADOR',      'Administrador'),
  ('ADMIN_ESCUELAS',     'Administrador de escuelas'),
  ('ENTRENADOR',         'Entrenador'),
  ('TUTOR',              'Padre/Madre o tutor'),
  ('JUGADOR',            'Jugador'),
  ('ORGANIZADOR_LIGAS',  'Organizador de ligas');

-- ---------------------------------------------------------------------
-- 11. Row Level Security
-- Se activa en todas las tablas. Sin políticas, la API de Supabase
-- (anon / authenticated) no puede leer ni escribir: es el valor seguro
-- por defecto hasta definir los permisos de cada rol.
-- ---------------------------------------------------------------------
alter table public.usuario            enable row level security;
alter table public.rol                enable row level security;
alter table public.permiso            enable row level security;
alter table public.rol_permiso        enable row level security;
alter table public.organizacion       enable row level security;
alter table public.sede               enable row level security;
alter table public.pista              enable row level security;
alter table public.jugador            enable row level security;
alter table public.tutor_jugador      enable row level security;
alter table public.equipo             enable row level security;
alter table public.equipo_miembro     enable row level security;
alter table public.entrenador_equipo  enable row level security;
alter table public.competicion        enable row level security;
alter table public.competicion_org    enable row level security;
alter table public.asignacion_rol     enable row level security;
alter table public.categoria          enable row level security;
alter table public.inscripcion        enable row level security;
alter table public.jornada            enable row level security;
alter table public.encuentro          enable row level security;
alter table public.partido            enable row level security;
alter table public.partido_jugador    enable row level security;
alter table public.set_partido        enable row level security;

-- Políticas mínimas
create policy "usuario_lee_su_perfil"
  on public.usuario for select to authenticated
  using (id = (select auth.uid()));

create policy "usuario_edita_su_perfil"
  on public.usuario for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "roles_visibles_para_autenticados"
  on public.rol for select to authenticated
  using (true);

create policy "ve_sus_asignaciones_de_rol"
  on public.asignacion_rol for select to authenticated
  using (usuario_id = (select auth.uid()));
