-- ============================================
-- migrations/0001_schema.sql
-- ============================================
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

-- ============================================
-- migrations/0002_acceso_app.sql
-- ============================================
-- Ligaria · 0002 · Capa de acceso de la app sobre el esquema 0001
-- Añade: extensiones mínimas al esquema, funciones auxiliares, políticas RLS por rol,
-- vistas de lectura para la app y RPC (alta, invitaciones, calendario, resultados).
--
-- Extensiones al esquema base (únicas modificaciones de tablas):
--   · jugador.organizacion_id  → organización (escuela, club…) a la que pertenece el jugador.
--   · tabla invitacion         → para dar acceso por email antes de que la persona se registre.
--   · vista clasificacion      → cuenta también los encuentros NO_PRESENTADO (incomparecencias).
--
-- Mapeo de roles (asignacion_rol):
--   ADMINISTRADOR      (sin organización)        → superadministrador de la plataforma
--   ADMIN_ESCUELAS     (en una ESCUELA)          → administra su organización (personas, equipos, usuarios)
--   ORGANIZADOR_LIGAS  (ESCUELA o AYUNTAMIENTO)  → crea y gestiona las competiciones de la organización
--   ENTRENADOR / TUTOR / JUGADOR (en organización) → perfiles de uso; el detalle va en
--                                                     entrenador_equipo, tutor_jugador y jugador.usuario_id

create schema if not exists app;

-- ───────── Extensiones del esquema ─────────
alter table public.jugador
  add column organizacion_id uuid references public.organizacion (id) on delete set null;
create index idx_jugador_organizacion on public.jugador (organizacion_id);

create table public.invitacion (
  id               uuid primary key default gen_random_uuid(),
  organizacion_id  uuid not null references public.organizacion (id) on delete cascade,
  email            text not null,
  rol_id           smallint not null references public.rol (id) on delete restrict,
  jugador_id       uuid references public.jugador (id) on delete cascade, -- tutor→menor, jugador→su ficha
  created_at       timestamptz not null default now(),
  aplicada_en      timestamptz
);
create index idx_invitacion_email on public.invitacion (lower(email)) where aplicada_en is null;
alter table public.invitacion enable row level security;

-- Las incomparecencias (NO_PRESENTADO) también puntúan en la clasificación.
create or replace view public.clasificacion
with (security_invoker = true)
as
with resultados as (
  select e.id as encuentro_id,
         e.local_inscripcion_id as inscripcion_id,
         e.puntos_local as pf,
         e.puntos_visitante as pc
  from public.encuentro e
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO')
  union all
  select e.id,
         e.visitante_inscripcion_id,
         e.puntos_visitante,
         e.puntos_local
  from public.encuentro e
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO')
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

-- ───────── Funciones auxiliares (security definer: evitan recursión de RLS) ─────────
create function app.es_admin() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                 where ar.usuario_id = auth.uid() and r.codigo = 'ADMINISTRADOR')
$$;

create function app.tiene_rol(org uuid, cods text[]) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                 where ar.usuario_id = auth.uid() and ar.organizacion_id = org and r.codigo = any (cods))
$$;

create function app.es_miembro(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from asignacion_rol where usuario_id = auth.uid() and organizacion_id = org)
$$;

-- Administra la organización (personas, equipos, usuarios): ADMIN_ESCUELAS o ADMINISTRADOR
create function app.admin_org(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or app.tiene_rol(org, array['ADMIN_ESCUELAS'])
$$;

-- Gestiona la organización y sus competiciones: administrador de escuelas u organizador de ligas
create function app.gestiona(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or app.tiene_rol(org, array['ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS'])
$$;

create function app.gestiona_comp(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      c.organizador_id = auth.uid()
      or app.gestiona(c.organizacion_id)
      or exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                 where ar.usuario_id = auth.uid() and ar.competicion_id = c.id and r.codigo = 'ORGANIZADOR_LIGAS')))
$$;

-- ¿Puede el usuario ver la competición? Quien la gestiona, su organización, las organizaciones
-- participantes (por competicion_org o por tener equipos inscritos) y el administrador.
create function app.ve_competicion(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      c.organizador_id = auth.uid()
      or app.es_miembro(c.organizacion_id)
      or exists (select 1 from competicion_org co
                 where co.competicion_id = c.id and co.estado_invitacion = 'ACEPTADA' and app.es_miembro(co.organizacion_id))
      or exists (select 1 from categoria ca
                 join inscripcion i on i.categoria_id = ca.id
                 join equipo e on e.id = i.equipo_id
                 where ca.competicion_id = c.id and app.es_miembro(e.organizacion_id))))
$$;

create function app.es_yo(j uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from jugador where id = j and usuario_id = auth.uid())
$$;

create function app.es_tutor_de(j uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from tutor_jugador where jugador_id = j and tutor_usuario_id = auth.uid())
$$;

create function app.entrena_equipo(eq uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from entrenador_equipo where equipo_id = eq and usuario_id = auth.uid())
$$;

create function app.entrena_a(j uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from equipo_miembro em
    join entrenador_equipo ee on ee.equipo_id = em.equipo_id
    where em.jugador_id = j and ee.usuario_id = auth.uid())
$$;

create function app.org_de_equipo(eq uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select organizacion_id from equipo where id = eq
$$;

create function app.org_de_jugador(j uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select organizacion_id from jugador where id = j
$$;

create function app.comp_de_categoria(cat uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select competicion_id from categoria where id = cat
$$;

create function app.comp_de_jornada(jor uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select ca.competicion_id from jornada j join categoria ca on ca.id = j.categoria_id where j.id = jor
$$;

create function app.comp_de_encuentro(enc uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select ca.competicion_id from encuentro e
  join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id where e.id = enc
$$;

create function app.comp_de_partido(par uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select app.comp_de_encuentro(encuentro_id) from partido where id = par
$$;

create function app.es_entrenador_de_org(usr uuid, org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                 where ar.usuario_id = usr and ar.organizacion_id = org and r.codigo = 'ENTRENADOR')
$$;

-- ───────── Políticas RLS ─────────
-- (usuario, rol y asignacion_rol ya tienen sus políticas mínimas en 0001; aquí se amplían)

create policy usuario_ve_su_org on public.usuario for select to authenticated using (
  app.es_admin() or exists (
    select 1 from asignacion_rol ar
    where ar.usuario_id = usuario.id and ar.organizacion_id is not null and app.admin_org(ar.organizacion_id)));

create policy permiso_sel on public.permiso for select to authenticated using (true);
create policy rol_permiso_sel on public.rol_permiso for select to authenticated using (true);

create policy asignacion_ve_su_org on public.asignacion_rol for select to authenticated using (
  app.es_admin() or (organizacion_id is not null and app.admin_org(organizacion_id)));

-- organizaciones: las ve su gente y el administrador; solo el administrador las crea o edita
create policy org_sel on public.organizacion for select to authenticated
  using (app.es_admin() or app.es_miembro(id));
create policy org_mod on public.organizacion for all to authenticated
  using (app.es_admin()) with check (app.es_admin());

create policy sede_sel on public.sede for select to authenticated
  using (app.es_admin() or app.es_miembro(organizacion_id));
create policy sede_mod on public.sede for all to authenticated
  using (app.admin_org(organizacion_id)) with check (app.admin_org(organizacion_id));
create policy pista_sel on public.pista for select to authenticated using (
  app.es_admin() or exists (select 1 from sede s where s.id = sede_id and app.es_miembro(s.organizacion_id)));
create policy pista_mod on public.pista for all to authenticated
  using (exists (select 1 from sede s where s.id = sede_id and app.admin_org(s.organizacion_id)))
  with check (exists (select 1 from sede s where s.id = sede_id and app.admin_org(s.organizacion_id)));

-- jugadores: fichas visibles para su organización (admin/organizador), el propio jugador, su tutor y su entrenador
create policy jugador_sel on public.jugador for select to authenticated using (
  app.es_admin() or (organizacion_id is not null and app.gestiona(organizacion_id))
  or app.es_yo(id) or app.es_tutor_de(id) or app.entrena_a(id));
create policy jugador_mod on public.jugador for all to authenticated
  using (app.es_admin() or (organizacion_id is not null and app.admin_org(organizacion_id)))
  with check (app.es_admin() or (organizacion_id is not null and app.admin_org(organizacion_id)));

create policy tutor_sel on public.tutor_jugador for select to authenticated using (
  tutor_usuario_id = auth.uid() or app.es_admin()
  or (app.org_de_jugador(jugador_id) is not null and app.admin_org(app.org_de_jugador(jugador_id))));
create policy tutor_mod on public.tutor_jugador for all to authenticated
  using (app.es_admin() or (app.org_de_jugador(jugador_id) is not null and app.admin_org(app.org_de_jugador(jugador_id))))
  with check (app.es_admin() or (app.org_de_jugador(jugador_id) is not null and app.admin_org(app.org_de_jugador(jugador_id))));

-- equipos
create policy equipo_sel on public.equipo for select to authenticated
  using (app.es_admin() or app.es_miembro(organizacion_id));
create policy equipo_mod on public.equipo for all to authenticated
  using (app.admin_org(organizacion_id)) with check (app.admin_org(organizacion_id));

create policy eqm_sel on public.equipo_miembro for select to authenticated using (
  app.es_admin() or app.admin_org(app.org_de_equipo(equipo_id)) or app.entrena_equipo(equipo_id)
  or app.es_yo(jugador_id) or app.es_tutor_de(jugador_id));
create policy eqm_mod on public.equipo_miembro for all to authenticated
  using (app.admin_org(app.org_de_equipo(equipo_id)))
  with check (app.admin_org(app.org_de_equipo(equipo_id)));

create policy eqe_sel on public.entrenador_equipo for select to authenticated
  using (usuario_id = auth.uid() or app.es_admin() or app.es_miembro(app.org_de_equipo(equipo_id)));
create policy eqe_mod on public.entrenador_equipo for all to authenticated
  using (app.admin_org(app.org_de_equipo(equipo_id)))
  with check (app.admin_org(app.org_de_equipo(equipo_id))
              and app.es_entrenador_de_org(usuario_id, app.org_de_equipo(equipo_id)));

-- competiciones y calendario: visibles para participantes; editables por quien las gestiona
create policy comp_sel on public.competicion for select to authenticated using (app.ve_competicion(id));
create policy comp_ins on public.competicion for insert to authenticated
  with check (app.gestiona(organizacion_id) and organizador_id = auth.uid());
create policy comp_upd on public.competicion for update to authenticated
  using (app.gestiona_comp(id)) with check (app.gestiona_comp(id));
create policy comp_del on public.competicion for delete to authenticated using (app.gestiona_comp(id));

create policy compo_sel on public.competicion_org for select to authenticated using (app.ve_competicion(competicion_id));
create policy compo_mod on public.competicion_org for all to authenticated
  using (app.gestiona_comp(competicion_id)) with check (app.gestiona_comp(competicion_id));

create policy cat_sel on public.categoria for select to authenticated using (app.ve_competicion(competicion_id));
create policy cat_mod on public.categoria for all to authenticated
  using (app.gestiona_comp(competicion_id)) with check (app.gestiona_comp(competicion_id));

create policy insc_sel on public.inscripcion for select to authenticated
  using (app.ve_competicion(app.comp_de_categoria(categoria_id)));
create policy insc_ins on public.inscripcion for insert to authenticated
  with check (app.gestiona_comp(app.comp_de_categoria(categoria_id)));
create policy insc_upd on public.inscripcion for update to authenticated
  using (app.gestiona_comp(app.comp_de_categoria(categoria_id)))
  with check (app.gestiona_comp(app.comp_de_categoria(categoria_id)));
-- la organización del equipo puede retirar su inscripción
create policy insc_del on public.inscripcion for delete to authenticated using (
  app.gestiona_comp(app.comp_de_categoria(categoria_id)) or app.admin_org(app.org_de_equipo(equipo_id)));

create policy jor_sel on public.jornada for select to authenticated
  using (app.ve_competicion(app.comp_de_categoria(categoria_id)));
create policy jor_mod on public.jornada for all to authenticated
  using (app.gestiona_comp(app.comp_de_categoria(categoria_id)))
  with check (app.gestiona_comp(app.comp_de_categoria(categoria_id)));

create policy enc_sel on public.encuentro for select to authenticated
  using (app.ve_competicion(app.comp_de_jornada(jornada_id)));
create policy enc_mod on public.encuentro for all to authenticated
  using (app.gestiona_comp(app.comp_de_jornada(jornada_id)))
  with check (app.gestiona_comp(app.comp_de_jornada(jornada_id)));

create policy par_sel on public.partido for select to authenticated
  using (app.ve_competicion(app.comp_de_encuentro(encuentro_id)));
create policy par_mod on public.partido for all to authenticated
  using (app.gestiona_comp(app.comp_de_encuentro(encuentro_id)))
  with check (app.gestiona_comp(app.comp_de_encuentro(encuentro_id)));

create policy pj_sel on public.partido_jugador for select to authenticated
  using (app.ve_competicion(app.comp_de_partido(partido_id)));
create policy pj_mod on public.partido_jugador for all to authenticated
  using (app.gestiona_comp(app.comp_de_partido(partido_id)))
  with check (app.gestiona_comp(app.comp_de_partido(partido_id)));

create policy set_sel on public.set_partido for select to authenticated
  using (app.ve_competicion(app.comp_de_partido(partido_id)));
create policy set_mod on public.set_partido for all to authenticated
  using (app.gestiona_comp(app.comp_de_partido(partido_id)))
  with check (app.gestiona_comp(app.comp_de_partido(partido_id)));

create policy inv_sel on public.invitacion for select to authenticated using (app.admin_org(organizacion_id));
create policy inv_del on public.invitacion for delete to authenticated using (app.admin_org(organizacion_id));

-- ───────── Validaciones por trigger ─────────
-- Un jugador solo entra en equipos de su propia organización.
create function app.validar_miembro() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if app.org_de_jugador(new.jugador_id) is distinct from app.org_de_equipo(new.equipo_id) then
    raise exception 'el jugador no pertenece a la organización del equipo' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger eqm_validar before insert on public.equipo_miembro
  for each row execute function app.validar_miembro();

-- Inscripción: mismo deporte, competición abierta y calendario aún sin generar.
create function app.validar_inscripcion() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo;
begin
  select co.* into c from competicion co join categoria ca on ca.competicion_id = co.id where ca.id = new.categoria_id;
  select * into e from equipo where id = new.equipo_id;
  if c.deporte <> e.deporte then
    raise exception 'el deporte del equipo no coincide con la competición' using errcode = '23514';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite inscripciones' using errcode = '23514';
  end if;
  if exists (select 1 from jornada where categoria_id = new.categoria_id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger insc_validar before insert on public.inscripcion
  for each row execute function app.validar_inscripcion();

-- ───────── Alta de usuarios e invitaciones ─────────
create function app.aplicar_invitacion(i invitacion, uid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare cod text;
begin
  select codigo into cod from rol where id = i.rol_id;
  insert into asignacion_rol (usuario_id, rol_id, organizacion_id) values (uid, i.rol_id, i.organizacion_id)
    on conflict do nothing;
  if i.jugador_id is not null then
    if cod = 'TUTOR' then
      insert into tutor_jugador (tutor_usuario_id, jugador_id) values (uid, i.jugador_id) on conflict do nothing;
    elsif cod = 'JUGADOR' then
      update jugador set usuario_id = uid where id = i.jugador_id and usuario_id is null;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Sustituye el trigger de alta de 0001. Hay dos formas de registrarse en la web (Supabase Auth, signUp):
--  1) AUTOSERVICIO, con raw_user_meta_data.perfil ∈ {escuela, ayuntamiento, organizador}:
--       escuela      → organización ESCUELA        + rol ADMIN_ESCUELAS
--       ayuntamiento → organización AYUNTAMIENTO   + rol ORGANIZADOR_LIGAS
--       organizador  → organización GRUPO_AMIGOS   + rol ORGANIZADOR_LIGAS (organizador independiente)
--     Nombre de la entidad: metadato `entidad` (o `escuela`); en `organizador` es opcional.
--  2) POR INVITACIÓN (entrenador, jugador, tutor, y también más administradores/organizadores): sin `perfil`;
--     el correo debe tener una invitación pendiente (tabla invitacion, creada con invitar_usuario) y al
--     registrarse se le asignan los roles invitados. Sin invitación el alta se rechaza (REGISTRO_SOLO_INVITACION).
-- Los metadatos nunca conceden ADMINISTRADOR ni acceso a organizaciones ya existentes.
-- Herramientas internas (seed, tests, soporte) pueden saltarse la regla con: set app.alta_libre = 'on'.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  mail text := lower(coalesce(new.email, ''));
  perfil text := nullif(btrim(coalesce(meta ->> 'perfil', '')), '');
  nombre_usr text := nullif(btrim(coalesce(meta ->> 'nombre', '')), '');
  ent text := nullif(btrim(coalesce(meta ->> 'entidad', meta ->> 'escuela', '')), '');
  inv invitacion; org uuid; tipo_org organizacion_tipo; cod_rol text;
begin
  if perfil is not null and perfil not in ('escuela', 'ayuntamiento', 'organizador') then
    raise exception 'PERFIL_INVALIDO: solo escuelas, ayuntamientos y organizadores se registran en la web; el resto, por invitación'
      using errcode = '23514';
  end if;

  if perfil is null then
    if coalesce(current_setting('app.alta_libre', true), '') <> 'on'
       and not exists (select 1 from invitacion where lower(email) = mail and aplicada_en is null) then
      raise exception 'REGISTRO_SOLO_INVITACION: no hay ninguna invitación para este correo' using errcode = '23514';
    end if;
  else
    tipo_org := case perfil when 'escuela' then 'ESCUELA' when 'ayuntamiento' then 'AYUNTAMIENTO' else 'GRUPO_AMIGOS' end::organizacion_tipo;
    if ent is null and perfil = 'organizador' then
      ent := 'Ligas de ' || coalesce(nombre_usr, split_part(mail, '@', 1));
    end if;
    if ent is null then
      raise exception 'ESCUELA_REQUERIDA: falta el nombre de la entidad' using errcode = '23514';
    end if;
    if exists (select 1 from organizacion where tipo = tipo_org and lower(btrim(nombre)) = lower(ent)) then
      raise exception 'ESCUELA_EXISTE: la entidad ya existe' using errcode = '23505';
    end if;
  end if;

  insert into usuario (id, email, nombre, apellidos)
  values (new.id, mail, left(nombre_usr, 120), left(nullif(trim(meta ->> 'apellidos'), ''), 120));

  for inv in select * from invitacion where lower(email) = mail and aplicada_en is null loop
    perform app.aplicar_invitacion(inv, new.id);
  end loop;

  if perfil is not null then
    insert into organizacion (tipo, nombre) values (tipo_org, left(ent, 160)) returning id into org;
    cod_rol := case perfil when 'escuela' then 'ADMIN_ESCUELAS' else 'ORGANIZADOR_LIGAS' end;
    insert into asignacion_rol (usuario_id, rol_id, organizacion_id)
      select new.id, r.id, org from rol r where r.codigo = cod_rol;
  end if;
  return new;
end;
$$;

-- ───────── Vistas de lectura para la app ─────────
-- Corren con los permisos del propietario y filtran por usuario / ve_competicion.

create view public.v_mis_pertenencias as
  select ar.id, ar.organizacion_id, o.nombre as organizacion, o.tipo::text as org_tipo, r.codigo as rol
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id
  left join organizacion o on o.id = ar.organizacion_id
  where ar.usuario_id = auth.uid() and (r.codigo = 'ADMINISTRADOR' or ar.organizacion_id is not null);

create view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at
  from competicion c
  where app.ve_competicion(c.id);

-- Competiciones a las que mi organización puede inscribir equipos
create view public.v_ligas_abiertas as
  select c.id as competicion_id, c.nombre, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         o.nombre as organizadora
  from competicion c
  join organizacion o on o.id = c.organizacion_id
  where c.estado = 'INSCRIPCION_ABIERTA'
    and (c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') or app.es_miembro(c.organizacion_id) or app.es_admin())
    and (app.es_admin() or exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                                   where ar.usuario_id = auth.uid() and r.codigo = 'ADMIN_ESCUELAS'));

create view public.v_mis_equipos as
  with mis as (
    select ee.equipo_id, 'entrenador'::text as rol from entrenador_equipo ee where ee.usuario_id = auth.uid()
    union
    select em.equipo_id, 'alumno' from equipo_miembro em
      join jugador j on j.id = em.jugador_id where j.usuario_id = auth.uid()
    union
    select em.equipo_id, 'tutor' from equipo_miembro em
      join tutor_jugador tj on tj.jugador_id = em.jugador_id where tj.tutor_usuario_id = auth.uid()
  )
  select m.equipo_id, e.nombre as equipo, e.organizacion_id, o.nombre as organizacion, m.rol,
         c.id as competicion_id, c.nombre as competicion
  from mis m
  join equipo e on e.id = m.equipo_id
  join organizacion o on o.id = e.organizacion_id
  left join inscripcion i on i.equipo_id = e.id and i.estado = 'ACEPTADA'
  left join categoria ca on ca.id = i.categoria_id
  left join competicion c on c.id = ca.competicion_id and c.estado <> 'CANCELADA';

create view public.v_encuentros_competicion as
  select en.id as encuentro_id, ca.competicion_id, ca.id as categoria_id,
         j.numero::int as jornada, j.fecha as jornada_fecha, en.fecha_hora as fecha,
         lower(en.estado::text) as estado,
         el.id as local_equipo_id, el.nombre as local,
         ev.id as visitante_equipo_id, ev.nombre as visitante,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_local::int end as partidos_local,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_visitante::int end as partidos_visitante,
         case when en.estado = 'NO_PRESENTADO'
              then case when en.puntos_local < en.puntos_visitante then 'local' else 'visitante' end end as incomparecencia
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

-- Equipos que descansan en una jornada (número impar de equipos)
create view public.v_descansos_competicion as
  select ca.competicion_id, j.numero::int as jornada, e.id as equipo_id, e.nombre as equipo
  from jornada j
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.categoria_id = ca.id and i.estado = 'ACEPTADA'
  join equipo e on e.id = i.equipo_id
  where app.ve_competicion(ca.competicion_id)
    and not exists (select 1 from encuentro en
                    where en.jornada_id = j.id and i.id in (en.local_inscripcion_id, en.visitante_inscripcion_id));

-- Clasificación con nombres, posición y desempates (partidos, sets y juegos)
create view public.v_clasificacion_competicion as
  with lados as (
    select e.local_inscripcion_id as inscripcion_id, s.juegos_local as jf, s.juegos_visitante as jc
    from encuentro e
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
    union all
    select e.visitante_inscripcion_id, s.juegos_visitante, s.juegos_local
    from encuentro e
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
  ), sets as (
    select inscripcion_id,
           count(*) filter (where jf > jc) as sf, count(*) filter (where jf < jc) as sc,
           sum(jf) as jf, sum(jc) as jc
    from lados group by inscripcion_id
  )
  select ca.competicion_id, c.categoria_id,
         (row_number() over (
            partition by c.categoria_id
            order by c.puntos desc, (c.favor - c.contra) desc,
                     coalesce(s.sf, 0) - coalesce(s.sc, 0) desc, coalesce(s.jf, 0) - coalesce(s.jc, 0) desc, eq.nombre))::int as posicion,
         c.equipo_id, eq.nombre as equipo, o.nombre as escuela,
         c.pj::int as pj, c.pg::int as pg, c.pe::int as pe, c.pp::int as pp, c.puntos::int as puntos,
         c.favor::int as partidos_f, c.contra::int as partidos_c,
         coalesce(s.sf, 0)::int as sets_f, coalesce(s.sc, 0)::int as sets_c,
         coalesce(s.jf, 0)::int as juegos_f, coalesce(s.jc, 0)::int as juegos_c
  from public.clasificacion c
  join categoria ca on ca.id = c.categoria_id
  join equipo eq on eq.id = c.equipo_id
  join organizacion o on o.id = eq.organizacion_id
  left join sets s on s.inscripcion_id = c.inscripcion_id
  where app.ve_competicion(ca.competicion_id);

-- Plantilla de un equipo (visible para su organización y su entrenador)
create view public.v_jugadores_equipo as
  select em.equipo_id, j.id as jugador_id, j.nombre, coalesce(j.apellidos, '') as apellidos
  from equipo_miembro em
  join equipo e on e.id = em.equipo_id
  join jugador j on j.id = em.jugador_id
  where app.es_admin() or app.es_miembro(e.organizacion_id) or app.entrena_equipo(e.id);

-- Jugadores de un partido. La organización del jugador ve el nombre completo; el resto de
-- participantes de la competición solo ve nombre e inicial del apellido (protege a los menores).
create view public.v_jugadores_competicion as
  select pj.partido_id, ca.competicion_id, lower(pj.lado::text) as lado, j.id as jugador_id,
         case when app.es_admin() or (j.organizacion_id is not null and app.es_miembro(j.organizacion_id))
                   or app.es_yo(j.id) or app.es_tutor_de(j.id)
              then trim(j.nombre || ' ' || coalesce(j.apellidos, ''))
              else trim(j.nombre || ' ' || coalesce(upper(left(nullif(j.apellidos, ''), 1)) || '.', ''))
         end as nombre_mostrado
  from partido_jugador pj
  join partido p on p.id = pj.partido_id
  join encuentro en on en.id = p.encuentro_id
  join jornada jo on jo.id = en.jornada_id
  join categoria ca on ca.id = jo.categoria_id
  join jugador j on j.id = pj.jugador_id
  where app.ve_competicion(ca.competicion_id);

-- Mis fichas: la mía (si soy jugador) y las de mis tutelados
create view public.v_mis_fichas as
  select j.id as jugador_id, j.organizacion_id, o.nombre as organizacion, j.nombre, coalesce(j.apellidos, '') as apellidos,
         j.fecha_nacimiento, j.genero::text as genero, j.nivel, j.mano_dominante::text as mano_dominante,
         case when j.usuario_id = auth.uid() then 'propia' else 'tutor' end as relacion
  from jugador j
  left join organizacion o on o.id = j.organizacion_id
  where j.usuario_id = auth.uid()
     or exists (select 1 from tutor_jugador tj where tj.jugador_id = j.id and tj.tutor_usuario_id = auth.uid());

-- Usuarios con acceso a una organización (para su administrador)
create view public.v_usuarios_org as
  select ar.organizacion_id, u.id as usuario_id, u.email, trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre,
         r.codigo as rol
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id
  join usuario u on u.id = ar.usuario_id
  where ar.organizacion_id is not null and app.admin_org(ar.organizacion_id);

-- Todas las organizaciones (solo ADMINISTRADOR)
create view public.v_organizaciones_admin as
  select o.id, o.nombre, o.tipo::text as tipo, o.ciudad, o.activa,
         (select count(*)::int from asignacion_rol ar join rol r on r.id = ar.rol_id
          where ar.organizacion_id = o.id and r.codigo in ('ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS')) as administradores
  from organizacion o
  where app.es_admin();

-- ───────── RPC ─────────
-- Crea una competición (liga) en borrador con su categoría única «General».
create function public.crear_competicion(
  p_organizacion uuid, p_nombre text, p_deporte deporte_tipo, p_tipo competicion_tipo,
  p_fecha_inicio date default null, p_fecha_fin date default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare cid uuid;
begin
  if not app.gestiona(p_organizacion) then
    raise exception 'sin permiso para crear competiciones en esta organización' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la competición'; end if;
  insert into competicion (organizacion_id, organizador_id, nombre, tipo, deporte, fecha_inicio, fecha_fin)
    values (p_organizacion, auth.uid(), btrim(p_nombre), p_tipo, p_deporte, p_fecha_inicio, p_fecha_fin)
    returning id into cid;
  insert into categoria (competicion_id, nombre) values (cid, 'General');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (cid, p_organizacion, 'ACEPTADA');
  return cid;
end $$;

-- La organización de un equipo lo inscribe en una competición abierta (queda ACEPTADA).
create function public.inscribir_equipo(p_competicion uuid, p_equipo uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; cat uuid;
begin
  select * into c from competicion where id = p_competicion;
  select * into e from equipo where id = p_equipo;
  if c.id is null or e.id is null then raise exception 'competición o equipo no encontrado'; end if;
  if not (app.admin_org(e.organizacion_id) or app.gestiona_comp(c.id)) then
    raise exception 'sin permiso para inscribir este equipo' using errcode = '42501';
  end if;
  if c.estado <> 'INSCRIPCION_ABIERTA' then
    raise exception 'la competición no está abierta a inscripción' using errcode = '23514';
  end if;
  if not (c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') or e.organizacion_id = c.organizacion_id) then
    raise exception 'la competición es privada de su organización' using errcode = '42501';
  end if;
  select id into cat from categoria where competicion_id = c.id order by nombre limit 1;
  insert into inscripcion (categoria_id, equipo_id, estado) values (cat, e.id, 'ACEPTADA');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (c.id, e.organizacion_id, 'ACEPTADA')
    on conflict (competicion_id, organizacion_id) do update set estado_invitacion = 'ACEPTADA';
end $$;

-- Invita (o asigna directamente, si ya existe) a un usuario con un rol en una organización.
-- p_rol: código de rol (p. ej. 'ENTRENADOR'); p_jugador: ficha a la que se vincula (tutor/jugador).
create function public.invitar_usuario(
  p_organizacion uuid, p_email text, p_rol text, p_jugador uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(btrim(p_email)); rid smallint;
begin
  if not app.admin_org(p_organizacion) then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if p_rol = 'ADMINISTRADOR' then raise exception 'rol no invitable'; end if;
  select id into rid from rol where codigo = p_rol;
  if rid is null then raise exception 'rol desconocido'; end if;
  if p_jugador is not null and app.org_de_jugador(p_jugador) is distinct from p_organizacion then
    raise exception 'el jugador no pertenece a la organización';
  end if;
  insert into invitacion (organizacion_id, email, rol_id, jugador_id)
    values (p_organizacion, mail, rid, p_jugador) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;

-- Calendario todos contra todos por categoría (método del círculo; con número impar, descansa uno cada jornada).
-- Devuelve el número de encuentros creados. Se puede regenerar mientras no haya resultados.
create function public.generar_calendario(
  p_competicion uuid, p_fecha_inicio date default null, p_dias_entre_jornadas int default 7,
  p_vueltas int default 1, p_individuales int default 2, p_dobles int default 1)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria;
  equipos uuid[]; t uuid[]; m int; n int;
  r int; i int; k int; v int;
  pos uuid[]; a uuid; b uuid; tmp uuid;
  bal jsonb; orient jsonb;
  clave text; ba int; bb int;
  jid uuid; eid uuid;
  num int; creados int := 0; orden int; alguna boolean := false;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el calendario' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if p_vueltas not in (1, 2) then raise exception 'vueltas debe ser 1 o 2'; end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and e.estado <> 'PROGRAMADO') then
    raise exception 'ya hay resultados registrados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    select array_agg(id order by fecha, id) into equipos
      from inscripcion where categoria_id = cat.id and estado = 'ACEPTADA';
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id;   -- cascada: encuentros y partidos
    bal := '{}'::jsonb; orient := '{}'::jsonb; num := 0;
    t := equipos;
    if n % 2 = 1 then t := t || array[null::uuid]; end if;
    m := array_length(t, 1);

    for v in 1..p_vueltas loop
      for r in 0..m - 2 loop
        num := num + 1;
        insert into jornada (categoria_id, numero, fecha)
          values (cat.id, num, case when p_fecha_inicio is null then null
                                    else p_fecha_inicio + (num - 1) * p_dias_entre_jornadas end)
          returning id into jid;

        pos := array[t[1]];
        for k in 2..m loop
          pos := pos || t[2 + ((k - 2 - r) % (m - 1) + (m - 1)) % (m - 1)];
        end loop;

        for i in 1..m / 2 loop
          a := pos[i]; b := pos[m + 1 - i];
          if a is null or b is null then continue; end if;   -- descanso: no hay encuentro
          -- Localía: 1ª vuelta equilibrada de forma voraz; 2ª vuelta invierte la 1ª.
          clave := least(a::text, b::text) || '|' || greatest(a::text, b::text);
          if v = 1 then
            ba := coalesce((bal ->> a::text)::int, 0);
            bb := coalesce((bal ->> b::text)::int, 0);
            if ba > bb or (ba = bb and (r + i) % 2 = 1) then tmp := a; a := b; b := tmp; end if;
            bal := bal || jsonb_build_object(a::text, coalesce((bal ->> a::text)::int, 0) + 1,
                                             b::text, coalesce((bal ->> b::text)::int, 0) - 1);
            orient := orient || jsonb_build_object(clave, a::text);
          else
            if (orient ->> clave)::uuid = a then tmp := a; a := b; b := tmp; end if;
          end if;

          insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id)
            values (jid, a, b) returning id into eid;
          creados := creados + 1;

          orden := 0;
          for k in 1..p_individuales loop
            orden := orden + 1;
            insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'INDIVIDUAL');
          end loop;
          for k in 1..p_dobles loop
            orden := orden + 1;
            insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'DOBLES');
          end loop;
        end loop;
      end loop;
    end loop;
  end loop;

  if not alguna then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;
  update competicion set estado = 'EN_CURSO' where id = c.id and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  return creados;
end $$;

-- Escribe el resultado de un encuentro (reemplaza lo anterior). Formato:
-- {"incomparecencia": null|"local"|"visitante",
--  "partidos":[{"orden":1,"local":[uuid],"visitante":[uuid],"sets":[[6,4],[3,6],[10,8]]}]}
-- puntos_local / puntos_visitante = partidos ganados; un partido empatado a sets no puntúa.
create function app.escribir_resultado(p_enc uuid, p_res jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  e encuentro; part jsonb; pa partido; lado_x text; pid text; st record;
  esperados int; total_sets int := 0; inc text; jl int; jv int; eq uuid; nj int;
  npart int; sl int; sv int; wl int := 0; wv int := 0;
begin
  select * into e from encuentro where id = p_enc for update;
  inc := nullif(p_res ->> 'incomparecencia', '');
  if inc is not null and inc not in ('local', 'visitante') then raise exception 'incomparecencia no válida'; end if;

  delete from set_partido where partido_id in (select id from partido where encuentro_id = p_enc);
  delete from partido_jugador where partido_id in (select id from partido where encuentro_id = p_enc);
  update partido set lado_ganador = null where encuentro_id = p_enc;
  select count(*) into npart from partido where encuentro_id = p_enc;

  if inc is not null then
    update encuentro set estado = 'NO_PRESENTADO',
           puntos_local = case when inc = 'local' then 0 else npart end,
           puntos_visitante = case when inc = 'visitante' then 0 else npart end
      where id = p_enc;
    return;
  end if;

  for part in select value from jsonb_array_elements(coalesce(p_res -> 'partidos', '[]'::jsonb)) loop
    select * into pa from partido where encuentro_id = p_enc and orden = (part ->> 'orden')::int;
    if not found then raise exception 'el partido % no existe en el encuentro', part ->> 'orden'; end if;
    esperados := case pa.tipo when 'DOBLES' then 2 else 1 end;

    foreach lado_x in array array['local', 'visitante'] loop
      select i.equipo_id into eq from inscripcion i
        where i.id = case lado_x when 'local' then e.local_inscripcion_id else e.visitante_inscripcion_id end;
      nj := 0;
      for pid in select value from jsonb_array_elements_text(coalesce(part -> lado_x, '[]'::jsonb)) loop
        nj := nj + 1;
        if not exists (select 1 from equipo_miembro where equipo_id = eq and jugador_id = pid::uuid) then
          raise exception 'el jugador % no pertenece al equipo %', pid, lado_x;
        end if;
        insert into partido_jugador (partido_id, jugador_id, lado) values (pa.id, pid::uuid, upper(lado_x)::lado_tipo);
      end loop;
      if nj > esperados then raise exception 'demasiados jugadores en el partido %', pa.orden; end if;
    end loop;

    sl := 0; sv := 0;
    for st in select value, ordinality as n from jsonb_array_elements(coalesce(part -> 'sets', '[]'::jsonb)) with ordinality loop
      if jsonb_typeof(st.value) <> 'array' or jsonb_array_length(st.value) <> 2 then
        raise exception 'set con formato incorrecto';
      end if;
      jl := (st.value ->> 0)::int; jv := (st.value ->> 1)::int;
      if jl < 0 or jv < 0 or jl = jv then raise exception 'marcador de set no válido: %-%', jl, jv; end if;
      insert into set_partido (partido_id, numero, juegos_local, juegos_visitante) values (pa.id, st.n, jl, jv);
      total_sets := total_sets + 1;
      if jl > jv then sl := sl + 1; else sv := sv + 1; end if;
    end loop;
    if sl > sv then update partido set lado_ganador = 'LOCAL' where id = pa.id; wl := wl + 1;
    elsif sv > sl then update partido set lado_ganador = 'VISITANTE' where id = pa.id; wv := wv + 1;
    end if;
  end loop;

  if total_sets = 0 then raise exception 'el resultado no contiene ningún set'; end if;
  update encuentro set estado = 'FINALIZADO', puntos_local = wl, puntos_visitante = wv where id = p_enc;
end $$;

-- El entrenador de uno de los dos equipos, o quien gestiona la competición, registra el resultado.
-- Un resultado ya registrado solo puede corregirlo la organización de la competición.
create function public.registrar_resultado(p_encuentro uuid, p_resultado jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro; comp uuid; eq_l uuid; eq_v uuid; est competicion_estado;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  comp := app.comp_de_encuentro(e.id);
  select equipo_id into eq_l from inscripcion where id = e.local_inscripcion_id;
  select equipo_id into eq_v from inscripcion where id = e.visitante_inscripcion_id;
  if not (app.gestiona_comp(comp) or app.entrena_equipo(eq_l) or app.entrena_equipo(eq_v)) then
    raise exception 'sin permiso para registrar el resultado' using errcode = '42501';
  end if;
  select estado into est from competicion where id = comp;
  if est = 'CANCELADA' then raise exception 'la competición está cancelada' using errcode = '23514'; end if;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') and not app.gestiona_comp(comp) then
    raise exception 'el resultado ya está registrado; solicita una corrección a la organización' using errcode = '23514';
  end if;
  perform app.escribir_resultado(p_encuentro, p_resultado);
  update competicion set estado = 'EN_CURSO' where id = comp and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  -- cierre automático: todos los encuentros jugados
  if not exists (select 1 from encuentro x
                 join jornada j on j.id = x.jornada_id join categoria ca on ca.id = j.categoria_id
                 where ca.competicion_id = comp and x.estado not in ('FINALIZADO', 'NO_PRESENTADO')) then
    update competicion set estado = 'FINALIZADA' where id = comp and estado = 'EN_CURSO';
  end if;
end $$;

-- ───────── Permisos ─────────
grant usage on schema public, app to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
revoke execute on all functions in schema app from public;
grant execute on all functions in schema app to authenticated;
revoke execute on function app.aplicar_invitacion(invitacion, uuid) from authenticated;
revoke execute on function app.escribir_resultado(uuid, jsonb) from authenticated;

revoke execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date) from public;
revoke execute on function public.inscribir_equipo(uuid, uuid) from public;
revoke execute on function public.invitar_usuario(uuid, text, text, uuid) from public;
revoke execute on function public.generar_calendario(uuid, date, int, int, int, int) from public;
revoke execute on function public.registrar_resultado(uuid, jsonb) from public;
grant execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date) to authenticated;
grant execute on function public.inscribir_equipo(uuid, uuid) to authenticated;
grant execute on function public.invitar_usuario(uuid, text, text, uuid) to authenticated;
grant execute on function public.generar_calendario(uuid, date, int, int, int, int) to authenticated;
grant execute on function public.registrar_resultado(uuid, jsonb) to authenticated;


-- ============================================
-- migrations/0003_notificaciones.sql
-- ============================================
-- =====================================================================
-- Ligaria IA - Notificaciones (bandeja en la app + cola de email).
-- `notificacion` es la fuente de verdad: la app la recibe por Realtime y la muestra como
-- notificación local; la Edge Function `enviar-notificaciones` envía por SMTP las filas con
-- email_estado = 'pendiente'. Se escribe solo desde triggers / app.notificar().
-- =====================================================================

create table public.notificacion (
  id                uuid primary key default gen_random_uuid(),
  usuario_id        uuid not null references public.usuario (id) on delete cascade,
  tipo              text not null,
  titulo            text not null,
  cuerpo            text not null default '',
  datos             jsonb not null default '{}'::jsonb,
  leida_at          timestamptz,
  email_estado      text not null default 'pendiente'
                    check (email_estado in ('pendiente', 'enviado', 'error', 'omitido')),
  email_intentos    smallint not null default 0,
  email_enviado_at  timestamptz,
  created_at        timestamptz not null default now()
);
create index idx_notificacion_usuario on public.notificacion (usuario_id, created_at desc);
create index idx_notificacion_email_pendiente on public.notificacion (created_at)
  where email_estado in ('pendiente', 'error');

create table public.notificacion_preferencia (
  usuario_id  uuid not null references public.usuario (id) on delete cascade,
  tipo        text not null,
  app         boolean not null default true,
  email       boolean not null default true,
  primary key (usuario_id, tipo)
);

alter table public.notificacion enable row level security;
alter table public.notificacion_preferencia enable row level security;

create policy notificacion_sel on public.notificacion for select to authenticated
  using (usuario_id = (select auth.uid()));
-- Solo se puede marcar como leída (columna leida_at) una notificación propia.
create policy notificacion_upd on public.notificacion for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));

create policy notif_pref_sel on public.notificacion_preferencia for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy notif_pref_ins on public.notificacion_preferencia for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy notif_pref_upd on public.notificacion_preferencia for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));

-- 0002 concede permisos amplios sobre todas las tablas: aquí se acota a lo necesario.
revoke all on public.notificacion, public.notificacion_preferencia from authenticated;
grant select on public.notificacion to authenticated;
grant update (leida_at) on public.notificacion to authenticated;
grant select, insert, update on public.notificacion_preferencia to authenticated;

-- ---------------------------------------------------------------------
-- app.notificar: crea la notificación respetando las preferencias del destinatario.
-- App desactivada => queda ya leída (no aparece en la bandeja). Email desactivado => 'omitido'.
-- Ambos desactivados => no se crea fila. Nunca notifica al autor del evento (p_autor).
-- ---------------------------------------------------------------------
create function app.notificar(
  p_usuario uuid, p_tipo text, p_titulo text, p_cuerpo text default '',
  p_datos jsonb default '{}'::jsonb, p_autor uuid default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_app boolean := true;
  v_email boolean := true;
begin
  if p_usuario is null or p_usuario is not distinct from p_autor then return; end if;
  select pr.app, pr.email into v_app, v_email
    from public.notificacion_preferencia pr
    where pr.usuario_id = p_usuario and pr.tipo = p_tipo;
  v_app := coalesce(v_app, true);
  v_email := coalesce(v_email, true);
  if not v_app and not v_email then return; end if;
  insert into public.notificacion (usuario_id, tipo, titulo, cuerpo, datos, email_estado, leida_at)
  values (p_usuario, p_tipo, p_titulo, coalesce(p_cuerpo, ''), coalesce(p_datos, '{}'::jsonb),
          case when v_email then 'pendiente' else 'omitido' end,
          case when v_app then null else now() end);
end;
$$;
revoke execute on function app.notificar(uuid, text, text, text, jsonb, uuid) from public, anon, authenticated;

-- Cuentas ligadas a un equipo: jugadores con cuenta, tutores y entrenadores.
create function app.destinatarios_equipo(p_equipo uuid) returns setof uuid
language sql stable security definer set search_path = '' as $$
  select j.usuario_id from public.equipo_miembro m
    join public.jugador j on j.id = m.jugador_id
    where m.equipo_id = p_equipo and j.usuario_id is not null
  union
  select t.tutor_usuario_id from public.equipo_miembro m
    join public.tutor_jugador t on t.jugador_id = m.jugador_id
    where m.equipo_id = p_equipo
  union
  select e.usuario_id from public.entrenador_equipo e where e.equipo_id = p_equipo
$$;
revoke execute on function app.destinatarios_equipo(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Eventos
-- ---------------------------------------------------------------------

-- Resultado registrado: avisa a los dos equipos del encuentro.
create function public.notif_encuentro_resultado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  v_local uuid; v_visit uuid; v_nom_l text; v_nom_v text; u uuid;
  v_titulo text;
begin
  if new.estado in ('FINALIZADO', 'NO_PRESENTADO')
     and (old.estado is distinct from new.estado
          or old.puntos_local is distinct from new.puntos_local
          or old.puntos_visitante is distinct from new.puntos_visitante) then
    select i.equipo_id, q.nombre into v_local, v_nom_l
      from public.inscripcion i join public.equipo q on q.id = i.equipo_id
      where i.id = new.local_inscripcion_id;
    select i.equipo_id, q.nombre into v_visit, v_nom_v
      from public.inscripcion i join public.equipo q on q.id = i.equipo_id
      where i.id = new.visitante_inscripcion_id;
    v_titulo := case when new.estado = 'NO_PRESENTADO' then 'Encuentro: no presentado'
                     else 'Resultado registrado' end;
    for u in
      select distinct d from (
        select app.destinatarios_equipo(v_local) as d
        union all select app.destinatarios_equipo(v_visit)) x
    loop
      perform app.notificar(u, 'resultado_registrado', v_titulo,
        format('%s %s - %s %s', v_nom_l, new.puntos_local, new.puntos_visitante, v_nom_v),
        jsonb_build_object('ruta', 'encuentro', 'encuentro_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_encuentro_resultado after update on public.encuentro
  for each row execute function public.notif_encuentro_resultado();

-- Calendario generado: la competición pasa a EN_CURSO y se avisa a los equipos inscritos.
create function public.notif_competicion_en_curso() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  u uuid;
begin
  if new.estado = 'EN_CURSO' and old.estado is distinct from 'EN_CURSO' then
    for u in
      select distinct app.destinatarios_equipo(i.equipo_id)
      from public.categoria ca
      join public.inscripcion i on i.categoria_id = ca.id and i.estado = 'ACEPTADA'
      where ca.competicion_id = new.id
    loop
      perform app.notificar(u, 'competicion_en_curso', 'Calendario disponible',
        format('La competición «%s» ya está en marcha. Consulta tus encuentros.', new.nombre),
        jsonb_build_object('ruta', 'competicion', 'competicion_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_competicion_en_curso after update of estado on public.competicion
  for each row execute function public.notif_competicion_en_curso();

-- Inscripción aceptada o rechazada: avisa al equipo.
create function public.notif_inscripcion_estado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  u uuid;
  v_comp text;
begin
  if new.estado in ('ACEPTADA', 'RECHAZADA') and old.estado is distinct from new.estado then
    select c.nombre into v_comp
      from public.categoria ca join public.competicion c on c.id = ca.competicion_id
      where ca.id = new.categoria_id;
    for u in select app.destinatarios_equipo(new.equipo_id) loop
      perform app.notificar(u, 'inscripcion_estado',
        case when new.estado = 'ACEPTADA' then 'Inscripción aceptada' else 'Inscripción rechazada' end,
        format('Tu inscripción en «%s» ha sido %s.', v_comp,
               case when new.estado = 'ACEPTADA' then 'aceptada' else 'rechazada' end),
        jsonb_build_object('ruta', 'inscripcion', 'inscripcion_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_inscripcion_estado after update of estado on public.inscripcion
  for each row execute function public.notif_inscripcion_estado();

revoke execute on function public.notif_encuentro_resultado(), public.notif_competicion_en_curso(),
  public.notif_inscripcion_estado() from public, anon, authenticated;

-- Tiempo real: la app recibe los INSERT de sus propias notificaciones (filtrado por RLS).
-- (Se omite si la base no tiene publicación Realtime, p. ej. en los tests con PGlite.)
alter table public.notificacion replica identity full;
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.notificacion;
  end if;
end $$;


-- ============================================
-- migrations/0004_aprobar_inscripciones.sql
-- ============================================
-- =====================================================================
-- Aprobación de inscripciones
-- Una escuela que inscribe un equipo en una liga que organiza otra organización queda
-- PENDIENTE hasta que el organizador la acepta o la rechaza. Si inscribe quien organiza la
-- liga (o su propia escuela en una liga interna) la inscripción se acepta directamente.
-- =====================================================================

-- Devuelve el estado resultante ('aceptada' | 'pendiente') en vez de void.
drop function public.inscribir_equipo(uuid, uuid);
create function public.inscribir_equipo(p_competicion uuid, p_equipo uuid)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; cat uuid; v_estado inscripcion_estado;
begin
  select * into c from competicion where id = p_competicion;
  select * into e from equipo where id = p_equipo;
  if c.id is null or e.id is null then raise exception 'competición o equipo no encontrado'; end if;
  if not (app.admin_org(e.organizacion_id) or app.gestiona_comp(c.id)) then
    raise exception 'sin permiso para inscribir este equipo' using errcode = '42501';
  end if;
  if c.estado <> 'INSCRIPCION_ABIERTA' then
    raise exception 'la competición no está abierta a inscripción' using errcode = '23514';
  end if;
  if not (c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') or e.organizacion_id = c.organizacion_id) then
    raise exception 'la competición es privada de su organización' using errcode = '42501';
  end if;
  v_estado := case when app.gestiona_comp(c.id) or e.organizacion_id = c.organizacion_id
                   then 'ACEPTADA' else 'PENDIENTE' end;
  select id into cat from categoria where competicion_id = c.id order by nombre limit 1;
  insert into inscripcion (categoria_id, equipo_id, estado) values (cat, e.id, v_estado);
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (c.id, e.organizacion_id, (case when v_estado = 'ACEPTADA' then 'ACEPTADA' else 'PENDIENTE' end)::invitacion_estado)
    on conflict (competicion_id, organizacion_id) do nothing;
  return lower(v_estado::text);
end $$;

-- El organizador acepta o rechaza una inscripción pendiente.
create function public.resolver_inscripcion(p_inscripcion uuid, p_aceptar boolean)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare i inscripcion; comp uuid; org uuid;
begin
  select * into i from inscripcion where id = p_inscripcion;
  if i.id is null then raise exception 'inscripción no encontrada'; end if;
  comp := app.comp_de_categoria(i.categoria_id);
  if not app.gestiona_comp(comp) then
    raise exception 'sin permiso para resolver esta inscripción' using errcode = '42501';
  end if;
  if i.estado <> 'PENDIENTE' then
    raise exception 'la inscripción ya está resuelta' using errcode = '23514';
  end if;
  if p_aceptar and exists (select 1 from jornada where categoria_id = i.categoria_id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  update inscripcion set estado = (case when p_aceptar then 'ACEPTADA' else 'RECHAZADA' end)::inscripcion_estado
    where id = i.id;
  if p_aceptar then
    select organizacion_id into org from equipo where id = i.equipo_id;
    insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
      values (comp, org, 'ACEPTADA')
      on conflict (competicion_id, organizacion_id) do update set estado_invitacion = 'ACEPTADA';
  end if;
end $$;

-- Inscripciones de una liga: las ve quien la organiza y la escuela dueña del equipo.
create view public.v_inscripciones_competicion as
  select i.id as inscripcion_id, ca.competicion_id, i.equipo_id, e.nombre as equipo,
         e.organizacion_id, o.nombre as escuela, lower(i.estado::text) as estado, i.fecha
  from inscripcion i
  join categoria ca on ca.id = i.categoria_id
  join equipo e on e.id = i.equipo_id
  join organizacion o on o.id = e.organizacion_id
  where app.gestiona_comp(ca.competicion_id) or app.admin_org(e.organizacion_id);

revoke execute on function public.inscribir_equipo(uuid, uuid) from public;
revoke execute on function public.resolver_inscripcion(uuid, boolean) from public;
grant execute on function public.inscribir_equipo(uuid, uuid) to authenticated;
grant execute on function public.resolver_inscripcion(uuid, boolean) to authenticated;
grant select on public.v_inscripciones_competicion to authenticated;


-- ============================================
-- migrations/0005_visibilidad_invitaciones.sql
-- ============================================
-- =====================================================================
-- Ligas públicas o privadas e invitación de escuelas
-- · competicion.visibilidad: PUBLICA (cualquier escuela la ve en «ligas abiertas» y solicita
--   inscribir, con aprobación del organizador) o PRIVADA (solo escuelas invitadas que aceptan).
-- · competicion_org.invitada: distingue una invitación del organizador de la fila PENDIENTE
--   que crea una solicitud de inscripción.
-- · RPC para invitar, responder y retirar invitaciones, y vistas para ambas partes.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden. Esta redefine inscribir_equipo (0004).
do $$ begin
  if to_regprocedure('public.resolver_inscripcion(uuid, boolean)') is null then
    raise exception 'Falta la migración 0004 (aprobar inscripciones). Aplica las migraciones en orden: 0001, 0002, 0003, 0004, 0005, 0006, 0007.';
  end if;
end $$;

create type competicion_visibilidad as enum ('PUBLICA', 'PRIVADA');

alter table public.competicion
  add column visibilidad competicion_visibilidad not null default 'PUBLICA';

alter table public.competicion_org
  add column invitada boolean not null default false;

-- ¿Tiene alguna organización que administro una invitación aceptada a esta competición?
create function app.invitada_a(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from competicion_org co
                 where co.competicion_id = comp and co.invitada and co.estado_invitacion = 'ACEPTADA'
                   and app.admin_org(co.organizacion_id))
$$;

-- ───────── crear_competicion con visibilidad ─────────
drop function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date);
create function public.crear_competicion(
  p_organizacion uuid, p_nombre text, p_deporte deporte_tipo, p_tipo competicion_tipo,
  p_fecha_inicio date default null, p_fecha_fin date default null,
  p_visibilidad competicion_visibilidad default 'PUBLICA')
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare cid uuid;
begin
  if not app.gestiona(p_organizacion) then
    raise exception 'sin permiso para crear competiciones en esta organización' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la competición'; end if;
  insert into competicion (organizacion_id, organizador_id, nombre, tipo, deporte, fecha_inicio, fecha_fin, visibilidad)
    values (p_organizacion, auth.uid(), btrim(p_nombre), p_tipo, p_deporte, p_fecha_inicio, p_fecha_fin, p_visibilidad)
    returning id into cid;
  insert into categoria (competicion_id, nombre) values (cid, 'General');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (cid, p_organizacion, 'ACEPTADA');
  return cid;
end $$;

-- ───────── inscribir_equipo: respeta la visibilidad ─────────
-- Liga privada (visibilidad) solo admite escuelas con invitación aceptada, cuya inscripción
-- se acepta directamente porque el organizador ya las eligió.
create or replace function public.inscribir_equipo(p_competicion uuid, p_equipo uuid)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; cat uuid; v_estado inscripcion_estado; v_invitada boolean;
begin
  select * into c from competicion where id = p_competicion;
  select * into e from equipo where id = p_equipo;
  if c.id is null or e.id is null then raise exception 'competición o equipo no encontrado'; end if;
  if not (app.admin_org(e.organizacion_id) or app.gestiona_comp(c.id)) then
    raise exception 'sin permiso para inscribir este equipo' using errcode = '42501';
  end if;
  if c.estado <> 'INSCRIPCION_ABIERTA' then
    raise exception 'la competición no está abierta a inscripción' using errcode = '23514';
  end if;
  select exists (select 1 from competicion_org co
                 where co.competicion_id = c.id and co.organizacion_id = e.organizacion_id
                   and co.invitada and co.estado_invitacion = 'ACEPTADA') into v_invitada;
  if not (e.organizacion_id = c.organizacion_id
          or (c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') and (c.visibilidad = 'PUBLICA' or v_invitada))) then
    raise exception 'la competición es privada: solo participan las escuelas invitadas' using errcode = '42501';
  end if;
  v_estado := case when app.gestiona_comp(c.id) or e.organizacion_id = c.organizacion_id or v_invitada
                   then 'ACEPTADA' else 'PENDIENTE' end;
  select id into cat from categoria where competicion_id = c.id order by nombre limit 1;
  insert into inscripcion (categoria_id, equipo_id, estado) values (cat, e.id, v_estado);
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (c.id, e.organizacion_id, (case when v_estado = 'ACEPTADA' then 'ACEPTADA' else 'PENDIENTE' end)::invitacion_estado)
    on conflict (competicion_id, organizacion_id) do nothing;
  return lower(v_estado::text);
end $$;

-- ───────── Invitaciones ─────────
create function public.invitar_org_a_competicion(p_competicion uuid, p_organizacion uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; o organizacion; prev competicion_org;
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para invitar a esta competición' using errcode = '42501';
  end if;
  if c.tipo not in ('MUNICIPAL', 'ENTRE_ESCUELAS') then
    raise exception 'esta competición no admite escuelas de fuera' using errcode = '23514';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite invitaciones' using errcode = '23514';
  end if;
  select * into o from organizacion where id = p_organizacion;
  if o.id is null or o.tipo <> 'ESCUELA' or not o.activa then
    raise exception 'solo se puede invitar a escuelas activas' using errcode = '23514';
  end if;
  select * into prev from competicion_org where competicion_id = c.id and organizacion_id = o.id;
  if prev.competicion_id is not null then
    if prev.invitada and prev.estado_invitacion = 'RECHAZADA' then
      update competicion_org set estado_invitacion = 'PENDIENTE'
        where competicion_id = c.id and organizacion_id = o.id;
      return;
    end if;
    raise exception 'la escuela ya participa, está invitada o tiene una solicitud' using errcode = '23505';
  end if;
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion, invitada)
    values (c.id, o.id, 'PENDIENTE', true);
end $$;

-- La escuela invitada acepta o rechaza (solo su administrador).
create function public.responder_invitacion_org(p_competicion uuid, p_organizacion uuid, p_aceptar boolean)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare prev competicion_org;
begin
  if not app.admin_org(p_organizacion) then
    raise exception 'sin permiso para responder en nombre de esta escuela' using errcode = '42501';
  end if;
  select * into prev from competicion_org where competicion_id = p_competicion and organizacion_id = p_organizacion;
  if prev.competicion_id is null or not prev.invitada then
    raise exception 'invitación no encontrada' using errcode = '23514';
  end if;
  if prev.estado_invitacion <> 'PENDIENTE' then
    raise exception 'la invitación ya está resuelta' using errcode = '23514';
  end if;
  update competicion_org
     set estado_invitacion = (case when p_aceptar then 'ACEPTADA' else 'RECHAZADA' end)::invitacion_estado
   where competicion_id = p_competicion and organizacion_id = p_organizacion;
end $$;

-- El organizador retira una invitación mientras la escuela no tenga equipos inscritos.
create function public.retirar_invitacion_org(p_competicion uuid, p_organizacion uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare prev competicion_org;
begin
  if not app.gestiona_comp(p_competicion) then
    raise exception 'sin permiso para retirar esta invitación' using errcode = '42501';
  end if;
  select * into prev from competicion_org where competicion_id = p_competicion and organizacion_id = p_organizacion;
  if prev.competicion_id is null or not prev.invitada then
    raise exception 'invitación no encontrada' using errcode = '23514';
  end if;
  if exists (select 1 from inscripcion i
             join categoria ca on ca.id = i.categoria_id
             join equipo e on e.id = i.equipo_id
             where ca.competicion_id = p_competicion and e.organizacion_id = p_organizacion) then
    raise exception 'la escuela ya tiene equipos inscritos' using errcode = '23514';
  end if;
  delete from competicion_org where competicion_id = p_competicion and organizacion_id = p_organizacion;
end $$;

-- ───────── Vistas ─────────
-- v_ligas expone la visibilidad (columna nueva al final, el resto igual que en 0002).
create or replace view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at,
         c.visibilidad::text as visibilidad
  from competicion c
  where app.ve_competicion(c.id);

-- Ligas abiertas: las públicas, y las privadas a las que mi escuela fue invitada y aceptó.
create or replace view public.v_ligas_abiertas as
  select c.id as competicion_id, c.nombre, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         o.nombre as organizadora,
         c.visibilidad::text as visibilidad
  from competicion c
  join organizacion o on o.id = c.organizacion_id
  where c.estado = 'INSCRIPCION_ABIERTA'
    and ((c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') and (c.visibilidad = 'PUBLICA' or app.invitada_a(c.id)))
         or app.es_miembro(c.organizacion_id) or app.es_admin())
    and (app.es_admin() or exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                                   where ar.usuario_id = auth.uid() and r.codigo = 'ADMIN_ESCUELAS'));

-- Para el organizador: escuelas invitadas a su liga y su estado.
create view public.v_invitaciones_liga as
  select co.competicion_id, co.organizacion_id, o.nombre as escuela, o.ciudad,
         lower(co.estado_invitacion::text) as estado
  from competicion_org co
  join organizacion o on o.id = co.organizacion_id
  where co.invitada and app.gestiona_comp(co.competicion_id);

-- Para la escuela: invitaciones pendientes de responder.
create view public.v_mis_invitaciones as
  select co.competicion_id, co.organizacion_id, o.nombre as escuela,
         c.nombre, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         org.nombre as organizadora
  from competicion_org co
  join competicion c on c.id = co.competicion_id
  join organizacion o on o.id = co.organizacion_id
  join organizacion org on org.id = c.organizacion_id
  where co.invitada and co.estado_invitacion = 'PENDIENTE' and app.admin_org(co.organizacion_id)
    and c.estado not in ('FINALIZADA', 'CANCELADA');

-- Escuelas a las que se puede invitar (solo nombre y ciudad, para quien organiza ligas).
create view public.v_escuelas_invitables as
  select o.id as organizacion_id, o.nombre, o.ciudad
  from organizacion o
  where o.tipo = 'ESCUELA' and o.activa
    and (app.es_admin() or exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                                   where ar.usuario_id = auth.uid()
                                     and r.codigo in ('ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS')));

-- ───────── Permisos ─────────
revoke execute on function app.invitada_a(uuid) from public;
grant execute on function app.invitada_a(uuid) to authenticated;

revoke execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad) from public;
revoke execute on function public.invitar_org_a_competicion(uuid, uuid) from public;
revoke execute on function public.responder_invitacion_org(uuid, uuid, boolean) from public;
revoke execute on function public.retirar_invitacion_org(uuid, uuid) from public;
grant execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad) to authenticated;
grant execute on function public.invitar_org_a_competicion(uuid, uuid) to authenticated;
grant execute on function public.responder_invitacion_org(uuid, uuid, boolean) to authenticated;
grant execute on function public.retirar_invitacion_org(uuid, uuid) to authenticated;
grant select on public.v_invitaciones_liga, public.v_mis_invitaciones, public.v_escuelas_invitables to authenticated;


-- ============================================
-- migrations/0006_gobierno_liga.sql
-- ============================================
-- =====================================================================
-- Gobierno de la liga
-- · Puntuación configurable por liga (victoria / empate / derrota).
-- · Varias categorías por liga: alta y baja con RPC, elección de categoría al inscribir.
-- · Co-organizadores a nivel de liga (asignacion_rol con competicion_id, sin organización).
-- =====================================================================

-- Requisito: las migraciones se aplican en orden (esta usa competicion.visibilidad de la 0005).
do $$ begin
  if to_regtype('competicion_visibilidad') is null then
    raise exception 'Falta la migración 0005 (visibilidad e invitaciones). Aplica las migraciones en orden: 0001 … 0007.';
  end if;
end $$;

-- ───────── Puntuación configurable ─────────
alter table public.competicion
  add column puntos_victoria smallint not null default 3,
  add column puntos_empate   smallint not null default 1,
  add column puntos_derrota  smallint not null default 0,
  add constraint competicion_puntuacion_valida
    check (puntos_derrota >= 0 and puntos_empate >= puntos_derrota and puntos_victoria >= puntos_empate
           and puntos_victoria <= 20);

-- La clasificación lee la puntuación de la liga (columnas y tipos iguales que en 0002).
create or replace view public.clasificacion
with (security_invoker = true)
as
with resultados as (
  select e.id as encuentro_id, e.local_inscripcion_id as inscripcion_id,
         e.puntos_local as pf, e.puntos_visitante as pc
  from public.encuentro e
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO')
  union all
  select e.id, e.visitante_inscripcion_id, e.puntos_visitante, e.puntos_local
  from public.encuentro e
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO')
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
       count(*) filter (where r.pf > r.pc) * co.puntos_victoria
         + count(*) filter (where r.pf = r.pc) * co.puntos_empate
         + count(*) filter (where r.pf < r.pc) * co.puntos_derrota as puntos
from public.inscripcion i
join public.categoria ca on ca.id = i.categoria_id
join public.competicion co on co.id = ca.competicion_id
left join resultados r on r.inscripcion_id = i.id
where i.estado = 'ACEPTADA'
group by i.categoria_id, i.id, i.equipo_id, co.puntos_victoria, co.puntos_empate, co.puntos_derrota;

-- ───────── Visibilidad de la liga para quien la co-organiza ─────────
create or replace function app.ve_competicion(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      c.organizador_id = auth.uid()
      or app.es_miembro(c.organizacion_id)
      or exists (select 1 from asignacion_rol ar join rol r on r.id = ar.rol_id
                 where ar.usuario_id = auth.uid() and ar.competicion_id = c.id and r.codigo = 'ORGANIZADOR_LIGAS')
      or exists (select 1 from competicion_org co
                 where co.competicion_id = c.id and co.estado_invitacion = 'ACEPTADA' and app.es_miembro(co.organizacion_id))
      or exists (select 1 from categoria ca
                 join inscripcion i on i.categoria_id = ca.id
                 join equipo e on e.id = i.equipo_id
                 where ca.competicion_id = c.id and app.es_miembro(e.organizacion_id))))
$$;

-- ───────── Vistas con los datos nuevos (columnas añadidas siempre al final) ─────────
create or replace view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at,
         c.visibilidad::text as visibilidad,
         c.puntos_victoria::int as puntos_victoria, c.puntos_empate::int as puntos_empate,
         c.puntos_derrota::int as puntos_derrota
  from competicion c
  where app.ve_competicion(c.id);

create or replace view public.v_encuentros_competicion as
  select en.id as encuentro_id, ca.competicion_id, ca.id as categoria_id,
         j.numero::int as jornada, j.fecha as jornada_fecha, en.fecha_hora as fecha,
         lower(en.estado::text) as estado,
         el.id as local_equipo_id, el.nombre as local,
         ev.id as visitante_equipo_id, ev.nombre as visitante,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_local::int end as partidos_local,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_visitante::int end as partidos_visitante,
         case when en.estado = 'NO_PRESENTADO'
              then case when en.puntos_local < en.puntos_visitante then 'local' else 'visitante' end end as incomparecencia,
         ca.nombre as categoria
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

create or replace view public.v_clasificacion_competicion as
  with lados as (
    select e.local_inscripcion_id as inscripcion_id, s.juegos_local as jf, s.juegos_visitante as jc
    from encuentro e
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
    union all
    select e.visitante_inscripcion_id, s.juegos_visitante, s.juegos_local
    from encuentro e
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
  ), sets as (
    select inscripcion_id,
           count(*) filter (where jf > jc) as sf, count(*) filter (where jf < jc) as sc,
           sum(jf) as jf, sum(jc) as jc
    from lados group by inscripcion_id
  )
  select ca.competicion_id, c.categoria_id,
         (row_number() over (
            partition by c.categoria_id
            order by c.puntos desc, (c.favor - c.contra) desc,
                     coalesce(s.sf, 0) - coalesce(s.sc, 0) desc, coalesce(s.jf, 0) - coalesce(s.jc, 0) desc, eq.nombre))::int as posicion,
         c.equipo_id, eq.nombre as equipo, o.nombre as escuela,
         c.pj::int as pj, c.pg::int as pg, c.pe::int as pe, c.pp::int as pp, c.puntos::int as puntos,
         c.favor::int as partidos_f, c.contra::int as partidos_c,
         coalesce(s.sf, 0)::int as sets_f, coalesce(s.sc, 0)::int as sets_c,
         coalesce(s.jf, 0)::int as juegos_f, coalesce(s.jc, 0)::int as juegos_c,
         ca.nombre as categoria
  from public.clasificacion c
  join categoria ca on ca.id = c.categoria_id
  join equipo eq on eq.id = c.equipo_id
  join organizacion o on o.id = eq.organizacion_id
  left join sets s on s.inscripcion_id = c.inscripcion_id
  where app.ve_competicion(ca.competicion_id);

create or replace view public.v_inscripciones_competicion as
  select i.id as inscripcion_id, ca.competicion_id, i.equipo_id, e.nombre as equipo,
         e.organizacion_id, o.nombre as escuela, lower(i.estado::text) as estado, i.fecha,
         ca.id as categoria_id, ca.nombre as categoria
  from inscripcion i
  join categoria ca on ca.id = i.categoria_id
  join equipo e on e.id = i.equipo_id
  join organizacion o on o.id = e.organizacion_id
  where app.gestiona_comp(ca.competicion_id) or app.admin_org(e.organizacion_id);

-- ───────── crear_competicion con puntuación ─────────
drop function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad);
create function public.crear_competicion(
  p_organizacion uuid, p_nombre text, p_deporte deporte_tipo, p_tipo competicion_tipo,
  p_fecha_inicio date default null, p_fecha_fin date default null,
  p_visibilidad competicion_visibilidad default 'PUBLICA',
  p_puntos_victoria smallint default 3, p_puntos_empate smallint default 1, p_puntos_derrota smallint default 0)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare cid uuid;
begin
  if not app.gestiona(p_organizacion) then
    raise exception 'sin permiso para crear competiciones en esta organización' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la competición'; end if;
  insert into competicion (organizacion_id, organizador_id, nombre, tipo, deporte, fecha_inicio, fecha_fin, visibilidad,
                           puntos_victoria, puntos_empate, puntos_derrota)
    values (p_organizacion, auth.uid(), btrim(p_nombre), p_tipo, p_deporte, p_fecha_inicio, p_fecha_fin, p_visibilidad,
            p_puntos_victoria, p_puntos_empate, p_puntos_derrota)
    returning id into cid;
  insert into categoria (competicion_id, nombre) values (cid, 'General');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (cid, p_organizacion, 'ACEPTADA');
  return cid;
end $$;

-- ───────── Categorías ─────────
create function public.crear_categoria(
  p_competicion uuid, p_nombre text, p_genero genero_tipo default null,
  p_edad_min smallint default null, p_edad_max smallint default null, p_nivel text default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; cid uuid;
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para gestionar las categorías' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la categoría'; end if;
  insert into categoria (competicion_id, nombre, genero, edad_min, edad_max, nivel)
    values (c.id, btrim(p_nombre), p_genero, p_edad_min, p_edad_max, nullif(btrim(coalesce(p_nivel, '')), ''))
    returning id into cid;
  return cid;
end $$;

-- Solo se elimina una categoría vacía y nunca la última de la liga.
create function public.eliminar_categoria(p_categoria uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare ca categoria;
begin
  select * into ca from categoria where id = p_categoria;
  if ca.id is null then raise exception 'categoría no encontrada'; end if;
  if not app.gestiona_comp(ca.competicion_id) then
    raise exception 'sin permiso para gestionar las categorías' using errcode = '42501';
  end if;
  if exists (select 1 from inscripcion where categoria_id = ca.id) then
    raise exception 'la categoría tiene equipos inscritos' using errcode = '23514';
  end if;
  if (select count(*) from categoria where competicion_id = ca.competicion_id) <= 1 then
    raise exception 'la liga necesita al menos una categoría' using errcode = '23514';
  end if;
  delete from categoria where id = ca.id;
end $$;

-- Categorías de una liga: las de mis ligas y las de las ligas abiertas a mi escuela (para elegir al inscribir).
create view public.v_categorias_competicion as
  select ca.competicion_id, ca.id as categoria_id, ca.nombre, ca.genero::text as genero,
         ca.edad_min::int as edad_min, ca.edad_max::int as edad_max, ca.nivel
  from categoria ca
  where app.ve_competicion(ca.competicion_id)
     or exists (select 1 from v_ligas_abiertas la where la.competicion_id = ca.competicion_id);

-- ───────── inscribir_equipo con categoría ─────────
drop function public.inscribir_equipo(uuid, uuid);
create function public.inscribir_equipo(p_competicion uuid, p_equipo uuid, p_categoria uuid default null)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; cat uuid; v_estado inscripcion_estado; v_invitada boolean; ncat int;
begin
  select * into c from competicion where id = p_competicion;
  select * into e from equipo where id = p_equipo;
  if c.id is null or e.id is null then raise exception 'competición o equipo no encontrado'; end if;
  if not (app.admin_org(e.organizacion_id) or app.gestiona_comp(c.id)) then
    raise exception 'sin permiso para inscribir este equipo' using errcode = '42501';
  end if;
  if c.estado <> 'INSCRIPCION_ABIERTA' then
    raise exception 'la competición no está abierta a inscripción' using errcode = '23514';
  end if;
  select exists (select 1 from competicion_org co
                 where co.competicion_id = c.id and co.organizacion_id = e.organizacion_id
                   and co.invitada and co.estado_invitacion = 'ACEPTADA') into v_invitada;
  if not (e.organizacion_id = c.organizacion_id
          or (c.tipo in ('MUNICIPAL', 'ENTRE_ESCUELAS') and (c.visibilidad = 'PUBLICA' or v_invitada))) then
    raise exception 'la competición es privada: solo participan las escuelas invitadas' using errcode = '42501';
  end if;
  v_estado := case when app.gestiona_comp(c.id) or e.organizacion_id = c.organizacion_id or v_invitada
                   then 'ACEPTADA' else 'PENDIENTE' end;

  if p_categoria is not null then
    select id into cat from categoria where id = p_categoria and competicion_id = c.id;
    if cat is null then raise exception 'la categoría no pertenece a la competición' using errcode = '23514'; end if;
  else
    select count(*) into ncat from categoria where competicion_id = c.id;
    if ncat > 1 then raise exception 'elige una categoría' using errcode = '23514'; end if;
    select id into cat from categoria where competicion_id = c.id;
  end if;

  insert into inscripcion (categoria_id, equipo_id, estado) values (cat, e.id, v_estado);
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (c.id, e.organizacion_id, (case when v_estado = 'ACEPTADA' then 'ACEPTADA' else 'PENDIENTE' end)::invitacion_estado)
    on conflict (competicion_id, organizacion_id) do nothing;
  return lower(v_estado::text);
end $$;

-- ───────── Co-organizadores ─────────
-- Solo quien gestiona la organización de la liga (o el administrador) añade o quita co-organizadores.
-- Un co-organizador gestiona esa liga (calendario, resultados, solicitudes, invitaciones…) sin tener
-- ningún rol en la organización: su asignación lleva competicion_id y no organizacion_id.
create function public.asignar_organizador_liga(p_competicion uuid, p_email text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; uid uuid; rid smallint; mail text := lower(btrim(p_email));
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para asignar organizadores' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  select id into uid from usuario where lower(email) = mail;
  if uid is null then
    raise exception 'usuario no encontrado: debe tener cuenta en Ligaria' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'ORGANIZADOR_LIGAS';
  if exists (select 1 from asignacion_rol ar
             where ar.usuario_id = uid and ar.organizacion_id = c.organizacion_id
               and ar.rol_id in (select id from rol where codigo in ('ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS'))) then
    raise exception 'ya organiza las ligas de esta organización' using errcode = '23505';
  end if;
  if exists (select 1 from asignacion_rol where usuario_id = uid and rol_id = rid and competicion_id = c.id) then
    raise exception 'ya es organizador de esta liga' using errcode = '23505';
  end if;
  insert into asignacion_rol (usuario_id, rol_id, competicion_id) values (uid, rid, c.id);
end $$;

create function public.quitar_organizador_liga(p_competicion uuid, p_usuario uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; n int;
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para quitar organizadores' using errcode = '42501';
  end if;
  delete from asignacion_rol
   where usuario_id = p_usuario and competicion_id = c.id and organizacion_id is null
     and rol_id = (select id from rol where codigo = 'ORGANIZADOR_LIGAS');
  get diagnostics n = row_count;
  if n = 0 then raise exception 'organizador no encontrado' using errcode = '23514'; end if;
end $$;

-- Co-organizadores de una liga (los ven quienes la gestionan).
create view public.v_organizadores_liga as
  select ar.competicion_id, u.id as usuario_id, u.email,
         trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join usuario u on u.id = ar.usuario_id
  where ar.competicion_id is not null and ar.organizacion_id is null
    and app.gestiona_comp(ar.competicion_id);

-- Organizaciones cuyas ligas co-organizo sin pertenecer a su equipo de gestión.
create view public.v_mis_coorganizaciones as
  select distinct o.id as organizacion_id, o.nombre as organizacion, o.tipo::text as org_tipo
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join competicion c on c.id = ar.competicion_id
  join organizacion o on o.id = c.organizacion_id
  where ar.usuario_id = auth.uid() and ar.organizacion_id is null and not app.gestiona(c.organizacion_id);

-- ───────── Permisos ─────────
revoke execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint) from public;
revoke execute on function public.crear_categoria(uuid, text, genero_tipo, smallint, smallint, text) from public;
revoke execute on function public.eliminar_categoria(uuid) from public;
revoke execute on function public.inscribir_equipo(uuid, uuid, uuid) from public;
revoke execute on function public.asignar_organizador_liga(uuid, text) from public;
revoke execute on function public.quitar_organizador_liga(uuid, uuid) from public;
grant execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint) to authenticated;
grant execute on function public.crear_categoria(uuid, text, genero_tipo, smallint, smallint, text) to authenticated;
grant execute on function public.eliminar_categoria(uuid) to authenticated;
grant execute on function public.inscribir_equipo(uuid, uuid, uuid) to authenticated;
grant execute on function public.asignar_organizador_liga(uuid, text) to authenticated;
grant execute on function public.quitar_organizador_liga(uuid, uuid) to authenticated;
grant select on public.v_categorias_competicion, public.v_organizadores_liga, public.v_mis_coorganizaciones to authenticated;


-- ============================================
-- migrations/0007_eliminatoria_grupos.sql
-- ============================================
-- =====================================================================
-- Formatos de competición: eliminatoria y grupos + playoff
-- · ELIMINATORIA: cuadro con byes (pase directo) si el nº de equipos no es potencia de 2.
--   Se genera la 1ª ronda; al terminar una ronda se crea la siguiente automáticamente.
-- · MIXTO: fase de grupos (liga dentro de cada grupo) y, después, un playoff con los N primeros
--   de cada grupo (mismo cuadro que la eliminatoria).
-- Un bye es un encuentro ya finalizado sin visitante (el equipo pasa a la siguiente ronda); las
-- vistas de calendario lo ocultan y v_byes_competicion lo lista.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden (esta usa la puntuación de competicion de la 0006).
do $$ begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'competicion' and column_name = 'puntos_victoria') then
    raise exception 'Falta la migración 0006 (gobierno de la liga). Aplica las migraciones en orden: 0001 … 0007.';
  end if;
end $$;

create type jornada_fase as enum ('LIGA', 'ELIMINATORIA');

alter table public.jornada
  add column fase   jornada_fase not null default 'LIGA',
  add column grupo  smallint,                -- grupo de la fase de liga (MIXTO); null si no hay grupos
  add column llaves smallint;                -- eliminatoria: emparejamientos de la ronda (incluye byes)
alter table public.jornada drop constraint jornada_categoria_id_numero_key;
create unique index uq_jornada on public.jornada (categoria_id, fase, coalesce(grupo, 0::smallint), numero);

alter table public.inscripcion add column grupo smallint;

alter table public.encuentro
  alter column visitante_inscripcion_id drop not null,
  add column llave smallint,                 -- eliminatoria: posición del emparejamiento en el cuadro
  add constraint encuentro_bye_finalizado check (visitante_inscripcion_id is not null or estado = 'FINALIZADO');

-- ───────── Clasificación: solo la fase de liga, por grupo ─────────
create or replace view public.clasificacion
with (security_invoker = true)
as
with resultados as (
  select e.id as encuentro_id, e.local_inscripcion_id as inscripcion_id,
         e.puntos_local as pf, e.puntos_visitante as pc
  from public.encuentro e
  join public.jornada j on j.id = e.jornada_id
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and j.fase = 'LIGA'
  union all
  select e.id, e.visitante_inscripcion_id, e.puntos_visitante, e.puntos_local
  from public.encuentro e
  join public.jornada j on j.id = e.jornada_id
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and j.fase = 'LIGA'
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
       count(*) filter (where r.pf > r.pc) * co.puntos_victoria
         + count(*) filter (where r.pf = r.pc) * co.puntos_empate
         + count(*) filter (where r.pf < r.pc) * co.puntos_derrota as puntos,
       i.grupo
from public.inscripcion i
join public.categoria ca on ca.id = i.categoria_id
join public.competicion co on co.id = ca.competicion_id
left join resultados r on r.inscripcion_id = i.id
where i.estado = 'ACEPTADA'
group by i.categoria_id, i.id, i.equipo_id, co.puntos_victoria, co.puntos_empate, co.puntos_derrota, i.grupo;

create or replace view public.v_clasificacion_competicion as
  with lados as (
    select e.local_inscripcion_id as inscripcion_id, s.juegos_local as jf, s.juegos_visitante as jc
    from encuentro e
    join jornada jo on jo.id = e.jornada_id and jo.fase = 'LIGA'
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
    union all
    select e.visitante_inscripcion_id, s.juegos_visitante, s.juegos_local
    from encuentro e
    join jornada jo on jo.id = e.jornada_id and jo.fase = 'LIGA'
    join partido p on p.encuentro_id = e.id
    join set_partido s on s.partido_id = p.id
    where e.estado = 'FINALIZADO'
  ), sets as (
    select inscripcion_id,
           count(*) filter (where jf > jc) as sf, count(*) filter (where jf < jc) as sc,
           sum(jf) as jf, sum(jc) as jc
    from lados group by inscripcion_id
  )
  select ca.competicion_id, c.categoria_id,
         (row_number() over (
            partition by c.categoria_id, c.grupo
            order by c.puntos desc, (c.favor - c.contra) desc,
                     coalesce(s.sf, 0) - coalesce(s.sc, 0) desc, coalesce(s.jf, 0) - coalesce(s.jc, 0) desc, eq.nombre))::int as posicion,
         c.equipo_id, eq.nombre as equipo, o.nombre as escuela,
         c.pj::int as pj, c.pg::int as pg, c.pe::int as pe, c.pp::int as pp, c.puntos::int as puntos,
         c.favor::int as partidos_f, c.contra::int as partidos_c,
         coalesce(s.sf, 0)::int as sets_f, coalesce(s.sc, 0)::int as sets_c,
         coalesce(s.jf, 0)::int as juegos_f, coalesce(s.jc, 0)::int as juegos_c,
         ca.nombre as categoria,
         c.grupo::int as grupo,
         c.inscripcion_id
  from public.clasificacion c
  join categoria ca on ca.id = c.categoria_id
  join equipo eq on eq.id = c.equipo_id
  join organizacion o on o.id = eq.organizacion_id
  left join sets s on s.inscripcion_id = c.inscripcion_id
  where app.ve_competicion(ca.competicion_id);

-- ───────── Calendario: fase, grupo y ronda; los byes no aparecen (visitante nulo) ─────────
create or replace view public.v_encuentros_competicion as
  select en.id as encuentro_id, ca.competicion_id, ca.id as categoria_id,
         j.numero::int as jornada, j.fecha as jornada_fecha, en.fecha_hora as fecha,
         lower(en.estado::text) as estado,
         el.id as local_equipo_id, el.nombre as local,
         ev.id as visitante_equipo_id, ev.nombre as visitante,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_local::int end as partidos_local,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_visitante::int end as partidos_visitante,
         case when en.estado = 'NO_PRESENTADO'
              then case when en.puntos_local < en.puntos_visitante then 'local' else 'visitante' end end as incomparecencia,
         ca.nombre as categoria,
         lower(j.fase::text) as fase,
         j.grupo::int as grupo,
         j.llaves::int as llaves
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

-- Descansos de la fase de liga (por grupo): solo equipos del mismo grupo que la jornada.
create or replace view public.v_descansos_competicion as
  select ca.competicion_id, j.numero::int as jornada, e.id as equipo_id, e.nombre as equipo
  from jornada j
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.categoria_id = ca.id and i.estado = 'ACEPTADA'
                    and i.grupo is not distinct from j.grupo
  join equipo e on e.id = i.equipo_id
  where j.fase = 'LIGA'
    and app.ve_competicion(ca.competicion_id)
    and not exists (select 1 from encuentro en
                    where en.jornada_id = j.id and i.id in (en.local_inscripcion_id, en.visitante_inscripcion_id));

-- Equipos que pasan directamente de ronda en una eliminatoria (byes).
create view public.v_byes_competicion as
  select ca.competicion_id, ca.id as categoria_id, ca.nombre as categoria, j.numero::int as jornada,
         eq.id as equipo_id, eq.nombre as equipo
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.id = en.local_inscripcion_id
  join equipo eq on eq.id = i.equipo_id
  where en.visitante_inscripcion_id is null and app.ve_competicion(ca.competicion_id);

create or replace view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at,
         c.visibilidad::text as visibilidad,
         c.puntos_victoria::int as puntos_victoria, c.puntos_empate::int as puntos_empate,
         c.puntos_derrota::int as puntos_derrota,
         c.formato::text as formato
  from competicion c
  where app.ve_competicion(c.id);

-- ───────── crear_competicion con formato ─────────
drop function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint);
create function public.crear_competicion(
  p_organizacion uuid, p_nombre text, p_deporte deporte_tipo, p_tipo competicion_tipo,
  p_fecha_inicio date default null, p_fecha_fin date default null,
  p_visibilidad competicion_visibilidad default 'PUBLICA',
  p_puntos_victoria smallint default 3, p_puntos_empate smallint default 1, p_puntos_derrota smallint default 0,
  p_formato competicion_formato default 'LIGA')
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare cid uuid;
begin
  if not app.gestiona(p_organizacion) then
    raise exception 'sin permiso para crear competiciones en esta organización' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la competición'; end if;
  insert into competicion (organizacion_id, organizador_id, nombre, tipo, deporte, fecha_inicio, fecha_fin, visibilidad,
                           puntos_victoria, puntos_empate, puntos_derrota, formato)
    values (p_organizacion, auth.uid(), btrim(p_nombre), p_tipo, p_deporte, p_fecha_inicio, p_fecha_fin, p_visibilidad,
            p_puntos_victoria, p_puntos_empate, p_puntos_derrota, p_formato)
    returning id into cid;
  insert into categoria (competicion_id, nombre) values (cid, 'General');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (cid, p_organizacion, 'ACEPTADA');
  return cid;
end $$;

-- ───────── Helpers de calendario ─────────
-- Orden estándar de un cuadro de p plazas (potencia de 2): los emparejamientos son pares consecutivos
-- (1-p, 2-(p-1)…) y los cabezas de serie solo se cruzan al final.
create function app.semillas_llave(p int) returns int[]
language plpgsql immutable as $$
declare arr int[] := array[1]; tam int := 1; nuevo int[]; s int;
begin
  while tam < p loop
    nuevo := array[]::int[];
    foreach s in array arr loop
      nuevo := nuevo || s || (2 * tam + 1 - s);
    end loop;
    arr := nuevo; tam := tam * 2;
  end loop;
  return arr;
end $$;

-- Crea una ronda de eliminatoria con las plazas en pares consecutivos. Si una plaza del par es nula,
-- el otro equipo pasa directo (bye: encuentro finalizado sin visitante). Devuelve los encuentros reales.
create function app.crear_ronda_eliminatoria(
  p_cat uuid, p_numero int, p_plazas uuid[], p_fecha date, p_individuales int, p_dobles int)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare jid uuid; eid uuid; k int; i int; orden int; a uuid; b uuid; npares int; creados int := 0;
begin
  npares := array_length(p_plazas, 1) / 2;
  insert into jornada (categoria_id, numero, fecha, fase, llaves)
    values (p_cat, p_numero, p_fecha, 'ELIMINATORIA', npares) returning id into jid;
  for k in 1..npares loop
    a := p_plazas[2 * k - 1]; b := p_plazas[2 * k];
    if a is null and b is null then raise exception 'cuadro no válido'; end if;
    if a is null or b is null then
      insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id, estado,
                             puntos_local, puntos_visitante, llave)
        values (jid, coalesce(a, b), null, 'FINALIZADO', 1, 0, k);
    else
      insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id, llave)
        values (jid, a, b, k) returning id into eid;
      creados := creados + 1;
      orden := 0;
      for i in 1..p_individuales loop
        orden := orden + 1;
        insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'INDIVIDUAL');
      end loop;
      for i in 1..p_dobles loop
        orden := orden + 1;
        insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'DOBLES');
      end loop;
    end if;
  end loop;
  return creados;
end $$;

-- Cuando todos los encuentros de la última ronda están jugados, crea la siguiente con los ganadores
-- (en orden de cuadro). Si solo queda un ganador, la eliminatoria ha terminado.
create function app.avanzar_ronda(p_cat uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare j jornada; ganadores uuid[]; ind int; dob int; ref uuid;
begin
  select * into j from jornada where categoria_id = p_cat and fase = 'ELIMINATORIA' order by numero desc limit 1;
  if j.id is null then return; end if;
  if exists (select 1 from encuentro where jornada_id = j.id and estado not in ('FINALIZADO', 'NO_PRESENTADO')) then
    return;
  end if;
  select array_agg(case when puntos_local > puntos_visitante then local_inscripcion_id else visitante_inscripcion_id end
                   order by llave)
    into ganadores from encuentro where jornada_id = j.id;
  if coalesce(array_length(ganadores, 1), 0) <= 1 then return; end if;
  select e.id into ref from encuentro e join jornada jj on jj.id = e.jornada_id
   where jj.categoria_id = p_cat and jj.fase = 'ELIMINATORIA' and e.visitante_inscripcion_id is not null limit 1;
  select count(*) filter (where tipo = 'INDIVIDUAL'), count(*) filter (where tipo = 'DOBLES')
    into ind, dob from partido where encuentro_id = ref;
  perform app.crear_ronda_eliminatoria(p_cat, j.numero + 1, ganadores,
    case when j.fecha is null then null else j.fecha + 7 end, coalesce(ind, 2), coalesce(dob, 1));
end $$;

-- Liga todos contra todos de un grupo (método del círculo; con número impar, descansa uno cada jornada).
-- Es el bucle de generar_calendario (0002) extraído para poder repetirlo por grupo.
create function app.generar_liga_grupo(
  p_cat uuid, p_grupo smallint, p_equipos uuid[], p_fecha_inicio date, p_dias int, p_vueltas int,
  p_individuales int, p_dobles int)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  t uuid[]; m int; n int; r int; i int; k int; v int;
  pos uuid[]; a uuid; b uuid; tmp uuid; bal jsonb := '{}'::jsonb; orient jsonb := '{}'::jsonb;
  clave text; ba int; bb int; jid uuid; eid uuid; num int := 0; creados int := 0; orden int;
begin
  n := coalesce(array_length(p_equipos, 1), 0);
  if n < 2 then return 0; end if;
  t := p_equipos;
  if n % 2 = 1 then t := t || array[null::uuid]; end if;
  m := array_length(t, 1);

  for v in 1..p_vueltas loop
    for r in 0..m - 2 loop
      num := num + 1;
      insert into jornada (categoria_id, numero, fecha, grupo)
        values (p_cat, num, case when p_fecha_inicio is null then null
                                 else p_fecha_inicio + (num - 1) * p_dias end, p_grupo)
        returning id into jid;

      pos := array[t[1]];
      for k in 2..m loop
        pos := pos || t[2 + ((k - 2 - r) % (m - 1) + (m - 1)) % (m - 1)];
      end loop;

      for i in 1..m / 2 loop
        a := pos[i]; b := pos[m + 1 - i];
        if a is null or b is null then continue; end if;   -- descanso: no hay encuentro
        -- Localía: 1ª vuelta equilibrada de forma voraz; 2ª vuelta invierte la 1ª.
        clave := least(a::text, b::text) || '|' || greatest(a::text, b::text);
        if v = 1 then
          ba := coalesce((bal ->> a::text)::int, 0);
          bb := coalesce((bal ->> b::text)::int, 0);
          if ba > bb or (ba = bb and (r + i) % 2 = 1) then tmp := a; a := b; b := tmp; end if;
          bal := bal || jsonb_build_object(a::text, coalesce((bal ->> a::text)::int, 0) + 1,
                                           b::text, coalesce((bal ->> b::text)::int, 0) - 1);
          orient := orient || jsonb_build_object(clave, a::text);
        else
          if (orient ->> clave)::uuid = a then tmp := a; a := b; b := tmp; end if;
        end if;

        insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id)
          values (jid, a, b) returning id into eid;
        creados := creados + 1;

        orden := 0;
        for k in 1..p_individuales loop
          orden := orden + 1;
          insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'INDIVIDUAL');
        end loop;
        for k in 1..p_dobles loop
          orden := orden + 1;
          insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'DOBLES');
        end loop;
      end loop;
    end loop;
  end loop;
  return creados;
end $$;

-- ───────── generar_calendario: grupos en formato MIXTO ─────────
drop function public.generar_calendario(uuid, date, int, int, int, int);
create function public.generar_calendario(
  p_competicion uuid, p_fecha_inicio date default null, p_dias_entre_jornadas int default 7,
  p_vueltas int default 1, p_individuales int default 2, p_dobles int default 1, p_grupos int default 2)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; g int; i int; creados int := 0; alguna boolean := false;
  ronda int; posg int; grupo_i int; del_grupo uuid[];
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el calendario' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato = 'ELIMINATORIA' then
    raise exception 'la competición es de eliminatoria: genera el cuadro' using errcode = '23514';
  end if;
  if p_vueltas not in (1, 2) then raise exception 'vueltas debe ser 1 o 2'; end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if p_grupos < 2 or p_grupos > 8 then raise exception 'el número de grupos debe estar entre 2 y 8'; end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and e.estado <> 'PROGRAMADO' and e.visitante_inscripcion_id is not null) then
    raise exception 'ya hay resultados registrados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    select array_agg(id order by fecha, id) into equipos
      from inscripcion where categoria_id = cat.id and estado = 'ACEPTADA';
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id;   -- cascada: encuentros y partidos
    if c.formato = 'MIXTO' then
      -- Reparto «serpiente» por orden de inscripción; cada grupo con al menos 2 equipos.
      g := greatest(least(p_grupos, n / 2), 1);
      for i in 0..n - 1 loop
        ronda := i / g; posg := i % g;
        grupo_i := case when ronda % 2 = 0 then posg + 1 else g - posg end;
        update inscripcion set grupo = grupo_i where id = equipos[i + 1];
      end loop;
      for grupo_i in 1..g loop
        creados := creados + app.generar_liga_grupo(
          cat.id, grupo_i::smallint,
          (select array_agg(id order by fecha, id) from inscripcion
            where categoria_id = cat.id and estado = 'ACEPTADA' and grupo = grupo_i),
          p_fecha_inicio, p_dias_entre_jornadas, p_vueltas, p_individuales, p_dobles);
      end loop;
    else
      update inscripcion set grupo = null where categoria_id = cat.id;
      creados := creados + app.generar_liga_grupo(
        cat.id, null, equipos, p_fecha_inicio, p_dias_entre_jornadas, p_vueltas, p_individuales, p_dobles);
    end if;
  end loop;

  if not alguna then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;
  update competicion set estado = 'EN_CURSO' where id = c.id and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  return creados;
end $$;

-- ───────── Eliminatoria ─────────
create function public.generar_eliminatoria(
  p_competicion uuid, p_fecha_inicio date default null, p_individuales int default 2, p_dobles int default 1)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; p int; orden int[]; plazas uuid[]; i int;
  creados int := 0; alguna boolean := false;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el cuadro' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato <> 'ELIMINATORIA' then
    raise exception 'la competición no es de eliminatoria' using errcode = '23514';
  end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and e.estado <> 'PROGRAMADO' and e.visitante_inscripcion_id is not null) then
    raise exception 'ya hay resultados registrados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    -- cabezas de serie por orden de inscripción
    select array_agg(id order by fecha, id) into equipos
      from inscripcion where categoria_id = cat.id and estado = 'ACEPTADA';
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id;
    update inscripcion set grupo = null where categoria_id = cat.id;
    p := 1;
    while p < n loop p := p * 2; end loop;
    orden := app.semillas_llave(p);
    plazas := array[]::uuid[];
    for i in 1..p loop
      plazas := plazas || (case when orden[i] <= n then equipos[orden[i]] end);
    end loop;
    creados := creados + app.crear_ronda_eliminatoria(cat.id, 1, plazas, p_fecha_inicio, p_individuales, p_dobles);
  end loop;

  if not alguna then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;
  update competicion set estado = 'EN_CURSO' where id = c.id and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  return creados;
end $$;

-- ───────── Playoff de un formato MIXTO ─────────
-- Con la fase de grupos terminada, los p_clasifican primeros de cada grupo juegan un cuadro.
-- Los cabezas de serie se ordenan por posición en su grupo y, dentro de la misma posición, por grupo:
-- así el 1º del grupo A cae contra el 2º del B (con un número par de grupos no se repite cruce de grupo
-- en la primera ronda; con un número impar puede darse algún cruce entre equipos del mismo grupo).
create function public.generar_playoff(
  p_competicion uuid, p_clasifican int default 2, p_fecha_inicio date default null,
  p_individuales int default 2, p_dobles int default 1)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; p int; orden int[]; plazas uuid[]; i int;
  creados int := 0; alguna boolean := false;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el playoff' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato <> 'MIXTO' then
    raise exception 'la competición no tiene fase de grupos' using errcode = '23514';
  end if;
  if p_clasifican < 1 or p_clasifican > 8 then raise exception 'clasifican entre 1 y 8 equipos por grupo'; end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if not exists (select 1 from encuentro e
                 join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
                 where ca.competicion_id = c.id and j.fase = 'LIGA') then
    raise exception 'primero hay que generar el calendario de la fase de grupos' using errcode = '23514';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and j.fase = 'LIGA' and e.estado not in ('FINALIZADO', 'NO_PRESENTADO')) then
    raise exception 'la fase de grupos no ha terminado' using errcode = '23514';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and j.fase = 'ELIMINATORIA'
               and e.visitante_inscripcion_id is not null and e.estado <> 'PROGRAMADO') then
    raise exception 'el playoff ya tiene resultados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    select array_agg(x.insc order by x.posicion, x.grupo, x.equipo) into equipos from (
      select cl.inscripcion_id as insc, cl.posicion, cl.grupo, cl.equipo
        from v_clasificacion_competicion cl
       where cl.categoria_id = cat.id and cl.posicion <= p_clasifican) x;
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id and fase = 'ELIMINATORIA';
    p := 1;
    while p < n loop p := p * 2; end loop;
    orden := app.semillas_llave(p);
    plazas := array[]::uuid[];
    for i in 1..p loop
      plazas := plazas || (case when orden[i] <= n then equipos[orden[i]] end);
    end loop;
    creados := creados + app.crear_ronda_eliminatoria(cat.id, 1, plazas, p_fecha_inicio, p_individuales, p_dobles);
  end loop;

  if not alguna then raise exception 'no hay equipos suficientes para el playoff'; end if;
  return creados;
end $$;

-- ───────── registrar_resultado: eliminatoria (sin empates, avance de ronda) ─────────
create or replace function public.registrar_resultado(p_encuentro uuid, p_resultado jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  e encuentro; e2 encuentro; j jornada; comp uuid; eq_l uuid; eq_v uuid; est competicion_estado;
  fmt competicion_formato; previo uuid; nuevo uuid;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if e.visitante_inscripcion_id is null then
    raise exception 'el encuentro es un pase directo del cuadro: no tiene resultado' using errcode = '23514';
  end if;
  comp := app.comp_de_encuentro(e.id);
  select equipo_id into eq_l from inscripcion where id = e.local_inscripcion_id;
  select equipo_id into eq_v from inscripcion where id = e.visitante_inscripcion_id;
  if not (app.gestiona_comp(comp) or app.entrena_equipo(eq_l) or app.entrena_equipo(eq_v)) then
    raise exception 'sin permiso para registrar el resultado' using errcode = '42501';
  end if;
  select estado, formato into est, fmt from competicion where id = comp;
  if est = 'CANCELADA' then raise exception 'la competición está cancelada' using errcode = '23514'; end if;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') and not app.gestiona_comp(comp) then
    raise exception 'el resultado ya está registrado; solicita una corrección a la organización' using errcode = '23514';
  end if;
  select * into j from jornada where id = e.jornada_id;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') then
    previo := case when e.puntos_local > e.puntos_visitante then e.local_inscripcion_id else e.visitante_inscripcion_id end;
  end if;

  perform app.escribir_resultado(p_encuentro, p_resultado);

  if j.fase = 'ELIMINATORIA' then
    select * into e2 from encuentro where id = e.id;
    if e2.puntos_local = e2.puntos_visitante then
      raise exception 'en eliminatoria no puede haber empate: se necesita un ganador' using errcode = '23514';
    end if;
    nuevo := case when e2.puntos_local > e2.puntos_visitante then e2.local_inscripcion_id else e2.visitante_inscripcion_id end;
    if previo is not null and previo <> nuevo and exists (
         select 1 from jornada jn where jn.categoria_id = j.categoria_id and jn.fase = 'ELIMINATORIA' and jn.numero > j.numero) then
      raise exception 'la siguiente ronda ya está generada: no se puede cambiar el ganador' using errcode = '23514';
    end if;
    perform app.avanzar_ronda(j.categoria_id);
  end if;

  update competicion set estado = 'EN_CURSO' where id = comp and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  -- cierre automático: todo jugado y, en un MIXTO, con el playoff ya generado
  if not exists (select 1 from encuentro x
                 join jornada jo on jo.id = x.jornada_id join categoria ca on ca.id = jo.categoria_id
                 where ca.competicion_id = comp and x.estado not in ('FINALIZADO', 'NO_PRESENTADO'))
     and (fmt <> 'MIXTO' or exists (select 1 from jornada jp join categoria cp on cp.id = jp.categoria_id
                                    where cp.competicion_id = comp and jp.fase = 'ELIMINATORIA')) then
    update competicion set estado = 'FINALIZADA' where id = comp and estado = 'EN_CURSO';
  end if;
end $$;

-- ───────── Permisos ─────────
revoke execute on function app.semillas_llave(int) from public;
revoke execute on function app.crear_ronda_eliminatoria(uuid, int, uuid[], date, int, int) from public;
revoke execute on function app.avanzar_ronda(uuid) from public;
revoke execute on function app.generar_liga_grupo(uuid, smallint, uuid[], date, int, int, int, int) from public;
revoke execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint, competicion_formato) from public;
revoke execute on function public.generar_calendario(uuid, date, int, int, int, int, int) from public;
revoke execute on function public.generar_eliminatoria(uuid, date, int, int) from public;
revoke execute on function public.generar_playoff(uuid, int, date, int, int) from public;
grant execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint, competicion_formato) to authenticated;
grant execute on function public.generar_calendario(uuid, date, int, int, int, int, int) to authenticated;
grant execute on function public.generar_eliminatoria(uuid, date, int, int) to authenticated;
grant execute on function public.generar_playoff(uuid, int, date, int, int) to authenticated;
grant select on public.v_byes_competicion to authenticated;


-- ============================================
-- migrations/0008_organizadores_invitan.sql
-- ============================================
-- =====================================================================
-- Un organizador de ligas puede invitar a su equipo
-- Hasta ahora solo invitaba el administrador de la organización (ADMIN_ESCUELAS o superadmin), así que
-- un ayuntamiento, cuyo responsable es ORGANIZADOR_LIGAS, no podía añadir a nadie de su equipo.
-- Ahora quien gestiona la organización (ORGANIZADOR_LIGAS) puede invitar a otros ORGANIZADOR_LIGAS de
-- esa misma organización. No puede dar ningún otro rol (administrador, entrenador, tutor, jugador): no
-- gana más poder del que ya tiene. Un co-organizador de una sola liga no puede invitar.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden.
do $$ begin
  if to_regtype('jornada_fase') is null then
    raise exception 'Falta la migración 0007 (eliminatoria y grupos). Aplica las migraciones en orden: 0001 … 0008.';
  end if;
end $$;

create or replace function public.invitar_usuario(
  p_organizacion uuid, p_email text, p_rol text, p_jugador uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(btrim(p_email)); rid smallint;
begin
  if not (app.admin_org(p_organizacion)
          or (p_rol = 'ORGANIZADOR_LIGAS' and app.gestiona(p_organizacion))) then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if p_rol = 'ADMINISTRADOR' then raise exception 'rol no invitable'; end if;
  select id into rid from rol where codigo = p_rol;
  if rid is null then raise exception 'rol desconocido'; end if;
  if p_jugador is not null and app.org_de_jugador(p_jugador) is distinct from p_organizacion then
    raise exception 'el jugador no pertenece a la organización';
  end if;
  insert into invitacion (organizacion_id, email, rol_id, jugador_id)
    values (p_organizacion, mail, rid, p_jugador) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;

-- Organizadores de ligas de una organización (los ve quien la gestiona).
create view public.v_organizadores_org as
  select ar.organizacion_id, u.id as usuario_id, u.email,
         trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join usuario u on u.id = ar.usuario_id
  where ar.organizacion_id is not null and app.gestiona(ar.organizacion_id);

grant select on public.v_organizadores_org to authenticated;


-- ============================================
-- migrations/0009_coorganizador_invitado.sql
-- ============================================
-- =====================================================================
-- Co-organizadores que aún no tienen cuenta
-- Hasta ahora asignar_organizador_liga exigía que el correo ya estuviera registrado. Ahora, si no lo
-- está, se guarda una invitación (tabla invitacion, con competicion_id) que se aplica sola cuando la
-- persona se registra con ese correo: queda como co-organizador de esa liga, sin rol en la organización.
-- Esa invitación también permite el registro por correo (REGISTRO_SOLO_INVITACION).
-- =====================================================================

-- Requisito: las migraciones se aplican en orden.
do $$ begin
  if to_regclass('public.v_organizadores_org') is null then
    raise exception 'Falta la migración 0008 (organizadores invitan). Aplica las migraciones en orden: 0001 … 0009.';
  end if;
end $$;

alter table public.invitacion
  add column competicion_id uuid references public.competicion (id) on delete cascade;
create unique index uq_invitacion_coorganizador
  on public.invitacion (competicion_id, lower(email))
  where competicion_id is not null and aplicada_en is null;

-- Al aplicar una invitación de liga se crea la asignación de co-organizador (competicion_id, sin organización).
create or replace function app.aplicar_invitacion(i invitacion, uid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare cod text;
begin
  select codigo into cod from rol where id = i.rol_id;
  if i.competicion_id is not null then
    if not exists (select 1 from asignacion_rol
                   where usuario_id = uid and rol_id = i.rol_id and competicion_id = i.competicion_id) then
      insert into asignacion_rol (usuario_id, rol_id, competicion_id) values (uid, i.rol_id, i.competicion_id);
    end if;
  else
    insert into asignacion_rol (usuario_id, rol_id, organizacion_id) values (uid, i.rol_id, i.organizacion_id)
      on conflict do nothing;
    if i.jugador_id is not null then
      if cod = 'TUTOR' then
        insert into tutor_jugador (tutor_usuario_id, jugador_id) values (uid, i.jugador_id) on conflict do nothing;
      elsif cod = 'JUGADOR' then
        update jugador set usuario_id = uid where id = i.jugador_id and usuario_id is null;
      end if;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Devuelve 'asignado' (la persona ya tenía cuenta) o 'invitado' (se activará al registrarse).
drop function public.asignar_organizador_liga(uuid, text);
create function public.asignar_organizador_liga(p_competicion uuid, p_email text)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; uid uuid; rid smallint; mail text := lower(btrim(p_email));
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para asignar organizadores' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if mail !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'correo no válido' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'ORGANIZADOR_LIGAS';
  select id into uid from usuario where lower(email) = mail;

  if uid is null then
    -- aún no tiene cuenta: invitación pendiente que se aplica al registrarse
    if exists (select 1 from invitacion
               where competicion_id = c.id and lower(email) = mail and aplicada_en is null) then
      raise exception 'ya está invitado como organizador de esta liga' using errcode = '23505';
    end if;
    insert into invitacion (organizacion_id, email, rol_id, competicion_id)
      values (c.organizacion_id, mail, rid, c.id);
    return 'invitado';
  end if;

  if exists (select 1 from asignacion_rol ar
             where ar.usuario_id = uid and ar.organizacion_id = c.organizacion_id
               and ar.rol_id in (select id from rol where codigo in ('ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS'))) then
    raise exception 'ya organiza las ligas de esta organización' using errcode = '23505';
  end if;
  if exists (select 1 from asignacion_rol where usuario_id = uid and rol_id = rid and competicion_id = c.id) then
    raise exception 'ya es organizador de esta liga' using errcode = '23505';
  end if;
  insert into asignacion_rol (usuario_id, rol_id, competicion_id) values (uid, rid, c.id);
  return 'asignado';
end $$;

-- Retira una invitación de co-organizador que aún no se ha aplicado.
create function public.retirar_invitacion_organizador(p_competicion uuid, p_email text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; n int;
begin
  select * into c from competicion where id = p_competicion;
  if c.id is null then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organizacion_id) then
    raise exception 'sin permiso para quitar organizadores' using errcode = '42501';
  end if;
  delete from invitacion
   where competicion_id = c.id and lower(email) = lower(btrim(p_email)) and aplicada_en is null;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'invitación no encontrada' using errcode = '23514'; end if;
end $$;

-- Co-organizadores de una liga: los que ya tienen cuenta y las invitaciones pendientes (usuario_id nulo).
create or replace view public.v_organizadores_liga as
  select ar.competicion_id, u.id as usuario_id, u.email,
         trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre,
         false as pendiente
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join usuario u on u.id = ar.usuario_id
  where ar.competicion_id is not null and ar.organizacion_id is null
    and app.gestiona_comp(ar.competicion_id)
  union all
  select i.competicion_id, null::uuid, i.email, null::text, true
  from invitacion i
  where i.competicion_id is not null and i.aplicada_en is null and app.gestiona_comp(i.competicion_id);

revoke execute on function public.asignar_organizador_liga(uuid, text) from public;
revoke execute on function public.retirar_invitacion_organizador(uuid, text) from public;
grant execute on function public.asignar_organizador_liga(uuid, text) to authenticated;
grant execute on function public.retirar_invitacion_organizador(uuid, text) to authenticated;


-- ============================================
-- migrations/0010_cuadro_llaves.sql
-- ============================================
-- =====================================================================
-- Posición en el cuadro (llave) para dibujar la eliminatoria
-- encuentro.llave es la posición del emparejamiento dentro de su ronda (1…n). Para dibujar el cuadro hay
-- que saberla en los encuentros y en los pases directos (byes): el ganador de las llaves 2k-1 y 2k de una
-- ronda juega la llave k de la siguiente. Solo se añade una columna al final de cada vista.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden.
do $$ begin
  if to_regclass('public.v_byes_competicion') is null then
    raise exception 'Falta la migración 0007 (eliminatoria y grupos). Aplica las migraciones en orden: 0001 … 0010.';
  end if;
end $$;

create or replace view public.v_encuentros_competicion as
  select en.id as encuentro_id, ca.competicion_id, ca.id as categoria_id,
         j.numero::int as jornada, j.fecha as jornada_fecha, en.fecha_hora as fecha,
         lower(en.estado::text) as estado,
         el.id as local_equipo_id, el.nombre as local,
         ev.id as visitante_equipo_id, ev.nombre as visitante,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_local::int end as partidos_local,
         case when en.estado in ('FINALIZADO', 'NO_PRESENTADO') then en.puntos_visitante::int end as partidos_visitante,
         case when en.estado = 'NO_PRESENTADO'
              then case when en.puntos_local < en.puntos_visitante then 'local' else 'visitante' end end as incomparecencia,
         ca.nombre as categoria,
         lower(j.fase::text) as fase,
         j.grupo::int as grupo,
         j.llaves::int as llaves,
         en.llave::int as llave
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

create or replace view public.v_byes_competicion as
  select ca.competicion_id, ca.id as categoria_id, ca.nombre as categoria, j.numero::int as jornada,
         eq.id as equipo_id, eq.nombre as equipo,
         en.llave::int as llave
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.id = en.local_inscripcion_id
  join equipo eq on eq.id = i.equipo_id
  where en.visitante_inscripcion_id is null and app.ve_competicion(ca.competicion_id);


