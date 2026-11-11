-- Ligaria · 0001 · Esquema base (multi-tenant)
-- Todo dato privado cuelga de una escuela (escuela_id / organization_id).
-- Las claves foráneas compuestas garantizan que hijos y padres comparten escuela.

create schema if not exists app;

create type rol_t as enum
  ('superadmin','organizador_liga','admin_escuela','entrenador','alumno','tutor');
create type competicion_tipo_t as enum ('liga','torneo','ranking','escalera');
create type competicion_estado_t as enum ('borrador','publicada','en_curso','finalizada');
create type visibilidad_ficha_t as enum ('nombre_completo','iniciales','solo_escuela');
create type encuentro_estado_t as enum ('programado','propuesto','confirmado');
create type lado_t as enum ('local','visitante');
create type partido_tipo_t as enum ('individual','dobles');

-- ───────── Núcleo ─────────
create table escuela (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  slug text not null unique,
  activa boolean not null default true,
  created_at timestamptz not null default now()
);

-- Módulos activables por escuela (feature flags). Ahora solo 'competiciones'.
create table escuela_modulo (
  escuela_id uuid not null references escuela(id) on delete cascade,
  modulo text not null,
  activo boolean not null default true,
  primary key (escuela_id, modulo)
);

create table usuario (
  id uuid primary key,              -- = auth.users.id en Supabase
  email text,
  nombre text,
  created_at timestamptz not null default now()
);

-- Pertenencia (usuario, escuela, rol). superadmin => escuela_id nulo.
create table pertenencia (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuario(id) on delete cascade,
  escuela_id uuid references escuela(id) on delete cascade,
  rol rol_t not null,
  created_at timestamptz not null default now(),
  check ((rol = 'superadmin') = (escuela_id is null))
);
create unique index pertenencia_uq
  on pertenencia (usuario_id, coalesce(escuela_id, '00000000-0000-0000-0000-000000000000'::uuid), rol);
create index pertenencia_escuela_idx on pertenencia (escuela_id);

-- Persona: separada de Usuario (un menor puede no tener login).
create table persona (
  id uuid primary key default gen_random_uuid(),
  escuela_id uuid not null references escuela(id) on delete cascade,
  usuario_id uuid references usuario(id) on delete set null,
  nombre text not null,
  apellidos text not null default '',
  fecha_nacimiento date not null,
  visibilidad_ficha visibilidad_ficha_t not null default 'solo_escuela',
  foto_url text,                    -- sin fotos por defecto
  mostrar_foto boolean not null default false,
  created_at timestamptz not null default now(),
  unique (id, escuela_id)
);
create index persona_escuela_idx on persona (escuela_id);

-- Tutoría: menor (persona) ↔ tutor (usuario con login)
create table tutoria (
  persona_id uuid not null references persona(id) on delete cascade,
  tutor_usuario_id uuid not null references usuario(id) on delete cascade,
  parentesco text,
  primary key (persona_id, tutor_usuario_id)
);

create table consentimiento (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  tutor_usuario_id uuid references usuario(id),
  tipo text not null default 'tratamiento_datos',
  otorgado boolean not null,
  fecha timestamptz not null default now()
);
create index consentimiento_persona_idx on consentimiento (persona_id, tipo, fecha desc);

-- ───────── Catálogos globales ─────────
create table deporte (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique
);
create table categoria (
  id uuid primary key default gen_random_uuid(),
  deporte_id uuid not null references deporte(id),
  nombre text not null,
  edad_min int,
  edad_max int,
  unique (deporte_id, nombre)
);
create table temporada (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  inicio date not null,
  fin date not null,
  check (fin >= inicio)
);

-- ───────── Competiciones ─────────
-- organization_id = escuela organizadora. Otras escuelas participan por inscripción.
create table competicion (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references escuela(id),
  temporada_id uuid not null references temporada(id),
  deporte_id uuid not null references deporte(id),
  categoria_id uuid references categoria(id),
  nombre text not null,
  tipo competicion_tipo_t not null default 'liga',
  estado competicion_estado_t not null default 'borrador',
  reglas jsonb not null default '{
    "vueltas": 1,
    "partidos_por_encuentro": {"individuales": 2, "dobles": 1},
    "puntos": {"victoria": 3, "empate": 1, "derrota": 0},
    "desempates": ["enfrentamiento_directo","diferencia_partidos","diferencia_sets","diferencia_juegos"],
    "incomparecencia": {"partidos_local": 0, "partidos_visitante": 3}
  }'::jsonb,
  created_at timestamptz not null default now(),
  unique (id, organization_id)
);

create table equipo (
  id uuid primary key default gen_random_uuid(),
  escuela_id uuid not null references escuela(id) on delete cascade,
  deporte_id uuid not null references deporte(id),
  categoria_id uuid references categoria(id),
  nombre text not null,
  created_at timestamptz not null default now(),
  unique (id, escuela_id)
);
create table equipo_miembro (
  equipo_id uuid not null,
  escuela_id uuid not null,
  persona_id uuid not null,
  primary key (equipo_id, persona_id),
  foreign key (equipo_id, escuela_id) references equipo(id, escuela_id) on delete cascade,
  foreign key (persona_id, escuela_id) references persona(id, escuela_id) on delete cascade
);
create table equipo_entrenador (
  equipo_id uuid not null,
  escuela_id uuid not null,
  usuario_id uuid not null references usuario(id) on delete cascade,
  primary key (equipo_id, usuario_id),
  foreign key (equipo_id, escuela_id) references equipo(id, escuela_id) on delete cascade
);

create table inscripcion_equipo (
  competicion_id uuid not null references competicion(id) on delete cascade,
  equipo_id uuid not null,
  escuela_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (competicion_id, equipo_id),
  foreign key (equipo_id, escuela_id) references equipo(id, escuela_id) on delete cascade
);

create table jornada (
  id uuid primary key default gen_random_uuid(),
  competicion_id uuid not null,
  organization_id uuid not null,
  numero int not null,
  fecha date,
  unique (competicion_id, numero),
  unique (id, competicion_id, organization_id),
  foreign key (competicion_id, organization_id) references competicion(id, organization_id) on delete cascade
);

create table encuentro (
  id uuid primary key default gen_random_uuid(),
  competicion_id uuid not null,
  organization_id uuid not null,
  jornada_id uuid not null,
  local_equipo_id uuid not null references equipo(id),
  visitante_equipo_id uuid not null references equipo(id),
  fecha timestamptz,
  estado encuentro_estado_t not null default 'programado',
  incomparecencia lado_t,             -- lado que NO se presentó
  propuesto_por uuid references usuario(id),
  propuesto_en timestamptz,
  confirmado_por uuid references usuario(id),
  confirmado_en timestamptz,
  check (local_equipo_id <> visitante_equipo_id),
  unique (id, competicion_id, organization_id),
  foreign key (jornada_id, competicion_id, organization_id)
    references jornada(id, competicion_id, organization_id) on delete cascade
);
create index encuentro_comp_idx on encuentro (competicion_id, estado);

create table partido (
  id uuid primary key default gen_random_uuid(),
  encuentro_id uuid not null,
  competicion_id uuid not null,
  organization_id uuid not null,
  orden int not null,
  tipo partido_tipo_t not null,
  unique (encuentro_id, orden),
  unique (id, competicion_id, organization_id),
  foreign key (encuentro_id, competicion_id, organization_id)
    references encuentro(id, competicion_id, organization_id) on delete cascade
);
create table partido_participante (
  partido_id uuid not null,
  competicion_id uuid not null,
  organization_id uuid not null,
  lado lado_t not null,
  persona_id uuid not null references persona(id),
  primary key (partido_id, lado, persona_id),
  foreign key (partido_id, competicion_id, organization_id)
    references partido(id, competicion_id, organization_id) on delete cascade
);
create table resultado_set (
  partido_id uuid not null,
  competicion_id uuid not null,
  organization_id uuid not null,
  numero int not null,
  juegos_local int not null check (juegos_local >= 0),
  juegos_visitante int not null check (juegos_visitante >= 0),
  primary key (partido_id, numero),
  foreign key (partido_id, competicion_id, organization_id)
    references partido(id, competicion_id, organization_id) on delete cascade
);

-- ───────── Transversales ─────────
create table notificacion (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuario(id) on delete cascade,
  escuela_id uuid references escuela(id) on delete cascade,
  titulo text not null,
  cuerpo text,
  leida boolean not null default false,
  created_at timestamptz not null default now()
);
create index notificacion_usuario_idx on notificacion (usuario_id, leida);

create table registro_cambios (
  id bigint generated always as identity primary key,
  escuela_id uuid,
  usuario_id uuid,
  tabla text not null,
  registro_id text,
  accion text not null,
  antes jsonb,
  despues jsonb,
  created_at timestamptz not null default now()
);
create index registro_cambios_escuela_idx on registro_cambios (escuela_id, created_at desc);

-- Registro de accesos a datos de menores
create table registro_acceso_menores (
  id bigint generated always as identity primary key,
  persona_id uuid not null,
  escuela_id uuid not null,
  usuario_id uuid,
  contexto text,
  created_at timestamptz not null default now()
);
create index registro_acceso_persona_idx on registro_acceso_menores (persona_id, created_at desc);
