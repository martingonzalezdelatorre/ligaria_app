
-- ============================================
-- migrations/0001_schema.sql
-- ============================================
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


-- ============================================
-- migrations/0002_helpers_rls.sql
-- ============================================
-- Ligaria · 0002 · Funciones auxiliares, auditoría, RLS y RPC de privacidad
-- Requiere auth.uid() (Supabase Auth).

-- ───────── Helpers (security definer: evitan recursión de RLS) ─────────
create function app.es_superadmin() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia where usuario_id = auth.uid() and rol = 'superadmin')
$$;

create function app.es_miembro(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia where usuario_id = auth.uid() and escuela_id = org)
$$;

create function app.tiene_rol(org uuid, r rol_t) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia
                 where usuario_id = auth.uid() and escuela_id = org and rol = r)
$$;

-- Gestiona la liga/escuela: admin de escuela u organizador de liga de esa escuela, o superadmin
create function app.gestiona(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from pertenencia where usuario_id = auth.uid() and escuela_id = org
      and rol in ('admin_escuela','organizador_liga'))
$$;

create function app.es_yo(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from persona where id = p and usuario_id = auth.uid())
$$;

create function app.es_tutor_de(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from tutoria where persona_id = p and tutor_usuario_id = auth.uid())
$$;

create function app.entrena_equipo(eq uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from equipo_entrenador where equipo_id = eq and usuario_id = auth.uid())
$$;

create function app.entrena_a(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from equipo_miembro em
    join equipo_entrenador ee on ee.equipo_id = em.equipo_id
    where em.persona_id = p and ee.usuario_id = auth.uid())
$$;

-- ¿Puede el usuario ver la competición? organizadora, inscrita o superadmin
create function app.ve_competicion(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      app.es_miembro(c.organization_id)
      or exists (select 1 from inscripcion_equipo i
                 where i.competicion_id = c.id and app.es_miembro(i.escuela_id))))
$$;

create function app.edad(nac date) returns int
language sql immutable as $$ select extract(year from age(current_date, nac))::int $$;

create function app.consentimiento_vigente(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select c.otorgado from consentimiento c
                   where c.persona_id = p and c.tipo = 'tratamiento_datos'
                   order by c.fecha desc limit 1), false)
$$;

-- ───────── Auditoría genérica ─────────
create function app.auditar() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare n jsonb; o jsonb; esc uuid;
begin
  n := case when tg_op <> 'DELETE' then to_jsonb(new) end;
  o := case when tg_op <> 'INSERT' then to_jsonb(old) end;
  esc := coalesce((coalesce(n, o)->>'organization_id'), (coalesce(n, o)->>'escuela_id'))::uuid;
  insert into registro_cambios (escuela_id, usuario_id, tabla, registro_id, accion, antes, despues)
  values (esc, auth.uid(), tg_table_name, coalesce(n, o)->>'id', tg_op, o, n);
  return coalesce(new, old);
end $$;

create trigger aud_competicion after insert or update or delete on competicion
  for each row execute function app.auditar();
create trigger aud_encuentro after insert or update or delete on encuentro
  for each row execute function app.auditar();
create trigger aud_persona after insert or update or delete on persona
  for each row execute function app.auditar();
create trigger aud_pertenencia after insert or update or delete on pertenencia
  for each row execute function app.auditar();
-- partido/resultado_set no tienen columna id: auditan con PK compuesta
create function app.auditar_resultado() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare n jsonb; o jsonb;
begin
  n := case when tg_op <> 'DELETE' then to_jsonb(new) end;
  o := case when tg_op <> 'INSERT' then to_jsonb(old) end;
  insert into registro_cambios (escuela_id, usuario_id, tabla, registro_id, accion, antes, despues)
  values ((coalesce(n, o)->>'organization_id')::uuid, auth.uid(), tg_table_name,
          (coalesce(n, o)->>'partido_id'), tg_op, o, n);
  return coalesce(new, old);
end $$;
create trigger aud_resultado_set after insert or update or delete on resultado_set
  for each row execute function app.auditar_resultado();

-- ───────── RLS ─────────
alter table escuela enable row level security;
alter table escuela_modulo enable row level security;
alter table usuario enable row level security;
alter table pertenencia enable row level security;
alter table persona enable row level security;
alter table tutoria enable row level security;
alter table consentimiento enable row level security;
alter table deporte enable row level security;
alter table categoria enable row level security;
alter table temporada enable row level security;
alter table competicion enable row level security;
alter table equipo enable row level security;
alter table equipo_miembro enable row level security;
alter table equipo_entrenador enable row level security;
alter table inscripcion_equipo enable row level security;
alter table jornada enable row level security;
alter table encuentro enable row level security;
alter table partido enable row level security;
alter table partido_participante enable row level security;
alter table resultado_set enable row level security;
alter table notificacion enable row level security;
alter table registro_cambios enable row level security;
alter table registro_acceso_menores enable row level security;

-- escuela
create policy escuela_sel on escuela for select
  using (app.es_superadmin() or app.es_miembro(id));
create policy escuela_mod on escuela for all
  using (app.es_superadmin()) with check (app.es_superadmin());
create policy modulo_sel on escuela_modulo for select
  using (app.es_superadmin() or app.es_miembro(escuela_id));
create policy modulo_mod on escuela_modulo for all
  using (app.es_superadmin()) with check (app.es_superadmin());

-- usuario: uno mismo, superadmin o admin de una escuela donde pertenece
create policy usuario_sel on usuario for select using (
  id = auth.uid() or app.es_superadmin() or exists (
    select 1 from pertenencia p where p.usuario_id = usuario.id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy usuario_upd on usuario for update
  using (id = auth.uid()) with check (id = auth.uid());

-- pertenencia
create policy pert_sel on pertenencia for select using (
  usuario_id = auth.uid() or app.es_superadmin()
  or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')));
create policy pert_mod on pertenencia for all
  using (app.es_superadmin() or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')))
  with check (app.es_superadmin() or (escuela_id is not null and rol <> 'superadmin'
              and app.tiene_rol(escuela_id, 'admin_escuela')));

-- persona: fichas privadas solo para admin de su escuela, su entrenador, ella misma o su tutor
create policy persona_sel on persona for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
  or app.es_yo(id) or app.es_tutor_de(id) or app.entrena_a(id));
create policy persona_mod on persona for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));

create policy tutoria_sel on tutoria for select using (
  tutor_usuario_id = auth.uid() or app.es_superadmin()
  or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy tutoria_mod on tutoria for all
  using (app.es_superadmin()
         or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')))
  with check (app.es_superadmin()
         or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));

-- consentimiento: lo ve y lo otorga el tutor (o la propia persona si es mayor de 14)
create policy consent_sel on consentimiento for select using (
  app.es_superadmin() or app.es_tutor_de(persona_id) or app.es_yo(persona_id)
  or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy consent_ins on consentimiento for insert with check (
  (app.es_tutor_de(persona_id) and tutor_usuario_id = auth.uid())
  or (app.es_yo(persona_id) and exists (select 1 from persona p where p.id = persona_id and app.edad(p.fecha_nacimiento) >= 14)));

-- catálogos globales
create policy deporte_sel on deporte for select using (auth.uid() is not null);
create policy deporte_mod on deporte for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy categoria_sel on categoria for select using (auth.uid() is not null);
create policy categoria_mod on categoria for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy temporada_sel on temporada for select using (auth.uid() is not null);
create policy temporada_mod on temporada for all using (app.es_superadmin()) with check (app.es_superadmin());

-- competiciones
create policy comp_sel on competicion for select using (app.ve_competicion(id));
create policy comp_mod on competicion for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));

-- equipos (datos internos de la escuela; otras escuelas usan las vistas públicas)
create policy equipo_sel on equipo for select using (app.es_superadmin() or app.es_miembro(escuela_id));
create policy equipo_mod on equipo for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy eqm_sel on equipo_miembro for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela') or app.entrena_equipo(equipo_id)
  or app.es_yo(persona_id) or app.es_tutor_de(persona_id));
create policy eqm_mod on equipo_miembro for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy eqe_sel on equipo_entrenador for select using (
  app.es_superadmin() or app.es_miembro(escuela_id));
create policy eqe_mod on equipo_entrenador for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));

create policy insc_sel on inscripcion_equipo for select using (app.ve_competicion(competicion_id));
create policy insc_mod on inscripcion_equipo for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
         or exists (select 1 from competicion c where c.id = competicion_id and app.gestiona(c.organization_id)))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
         or exists (select 1 from competicion c where c.id = competicion_id and app.gestiona(c.organization_id)));

-- calendario y resultados: visibles a participantes; editables solo por la organizadora
create policy jornada_sel on jornada for select using (app.ve_competicion(competicion_id));
create policy jornada_mod on jornada for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy enc_sel on encuentro for select using (app.ve_competicion(competicion_id));
create policy enc_mod on encuentro for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy partido_sel on partido for select using (app.ve_competicion(competicion_id));
create policy partido_mod on partido for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy ppart_sel on partido_participante for select using (app.ve_competicion(competicion_id));
create policy ppart_mod on partido_participante for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy rset_sel on resultado_set for select using (app.ve_competicion(competicion_id));
create policy rset_mod on resultado_set for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));

-- notificaciones propias
create policy notif_sel on notificacion for select using (usuario_id = auth.uid());
create policy notif_upd on notificacion for update
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- registros: solo lectura para quien corresponde
create policy regcamb_sel on registro_cambios for select using (
  app.es_superadmin() or (escuela_id is not null and app.tiene_rol(escuela_id, 'organizador_liga')
                          ) or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')));
create policy regacc_sel on registro_acceso_menores for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela') or app.es_tutor_de(persona_id));

-- ───────── Vistas públicas para ligas compartidas ─────────
-- Solo nombre y resultados. Corren con permisos del propietario y filtran por ve_competicion.
create view v_equipos_competicion as
  select i.competicion_id, e.id as equipo_id, e.nombre as equipo, s.id as escuela_id, s.nombre as escuela
  from inscripcion_equipo i
  join equipo e on e.id = i.equipo_id
  join escuela s on s.id = e.escuela_id
  where app.ve_competicion(i.competicion_id);

-- Nombre mostrado según visibilidad de la ficha y consentimiento (menores de 14)
create view v_jugadores_competicion as
  select pp.partido_id, pp.competicion_id, pp.lado, p.id as persona_id,
    case
      when app.es_superadmin() or app.es_miembro(p.escuela_id) then trim(p.nombre || ' ' || p.apellidos)
      when app.edad(p.fecha_nacimiento) < 14 and not app.consentimiento_vigente(p.id) then 'Jugador/a'
      when p.visibilidad_ficha = 'nombre_completo' then trim(p.nombre || ' ' || p.apellidos)
      when p.visibilidad_ficha = 'iniciales'
        then upper(left(p.nombre,1)) || '.' || coalesce(upper(left(nullif(p.apellidos,''),1)) || '.', '')
      else 'Jugador/a'
    end as nombre_mostrado
  from partido_participante pp
  join persona p on p.id = pp.persona_id
  where app.ve_competicion(pp.competicion_id);

-- ───────── RPC de privacidad y acceso a fichas ─────────
-- El tutor (o la propia persona mayor de 14) gestiona la visibilidad de la ficha.
create function public.actualizar_privacidad(
  p_persona uuid, p_visibilidad visibilidad_ficha_t, p_mostrar_foto boolean default false)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then raise exception 'persona no encontrada'; end if;
  if not (app.es_tutor_de(p_persona)
          or (app.es_yo(p_persona) and app.edad(p.fecha_nacimiento) >= 14)
          or app.tiene_rol(p.escuela_id, 'admin_escuela') or app.es_superadmin()) then
    raise exception 'sin permiso para gestionar la privacidad' using errcode = '42501';
  end if;
  update persona set visibilidad_ficha = p_visibilidad,
         mostrar_foto = p_mostrar_foto where id = p_persona;
end $$;

-- Lectura de ficha con registro de acceso si es menor de edad (< 18).
create function public.leer_ficha(p_persona uuid, p_contexto text default null)
returns setof persona language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then return; end if;
  if not (app.es_superadmin() or app.tiene_rol(p.escuela_id, 'admin_escuela')
          or app.es_yo(p_persona) or app.es_tutor_de(p_persona) or app.entrena_a(p_persona)) then
    raise exception 'sin acceso a la ficha' using errcode = '42501';
  end if;
  if app.edad(p.fecha_nacimiento) < 18 then
    insert into registro_acceso_menores (persona_id, escuela_id, usuario_id, contexto)
    values (p.id, p.escuela_id, auth.uid(), p_contexto);
  end if;
  return next p;
end $$;

-- ───────── Permisos ─────────
grant usage on schema public, app to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
grant execute on all functions in schema app to authenticated;
revoke execute on function public.actualizar_privacidad(uuid, visibilidad_ficha_t, boolean) from public;
revoke execute on function public.leer_ficha(uuid, text) from public;
grant execute on function public.actualizar_privacidad(uuid, visibilidad_ficha_t, boolean) to authenticated;
grant execute on function public.leer_ficha(uuid, text) to authenticated;
-- registros: nadie escribe directamente
revoke insert, update, delete on registro_cambios, registro_acceso_menores from authenticated;


-- ============================================
-- migrations/0003_auth_personas.sql
-- ============================================
-- Ligaria · 0003 · Alta de usuarios, invitaciones, consentimiento de menores y módulos

-- ───────── Invitaciones ─────────
-- El admin de escuela invita por email con un rol; se aplica al registrarse (o ya, si el usuario existe).
create table invitacion (
  id uuid primary key default gen_random_uuid(),
  escuela_id uuid not null references escuela(id) on delete cascade,
  email text not null,
  rol rol_t not null check (rol <> 'superadmin'),
  persona_id uuid references persona(id) on delete cascade,  -- tutor→menor, alumno→su ficha
  created_at timestamptz not null default now(),
  aplicada_en timestamptz
);
create index invitacion_email_idx on invitacion (lower(email)) where aplicada_en is null;
alter table invitacion enable row level security;
create policy inv_sel on invitacion for select
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy inv_del on invitacion for delete
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
grant select, delete on invitacion to authenticated;

create function app.aplicar_invitacion(i invitacion, uid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  insert into pertenencia (usuario_id, escuela_id, rol) values (uid, i.escuela_id, i.rol)
    on conflict do nothing;
  if i.persona_id is not null then
    if i.rol = 'tutor' then
      insert into tutoria (persona_id, tutor_usuario_id) values (i.persona_id, uid) on conflict do nothing;
    elsif i.rol = 'alumno' then
      update persona set usuario_id = uid where id = i.persona_id and usuario_id is null;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Alta en auth.users → fila en usuario + invitaciones pendientes por email
create function app.alta_usuario() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare i invitacion; mail text;
begin
  mail := lower(coalesce(to_jsonb(new)->>'email', ''));
  insert into usuario (id, email, nombre)
    values (new.id, mail, coalesce(to_jsonb(new)->'raw_user_meta_data'->>'nombre', split_part(mail, '@', 1)))
    on conflict (id) do nothing;
  for i in select * from invitacion where lower(email) = mail and aplicada_en is null loop
    perform app.aplicar_invitacion(i, new.id);
  end loop;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function app.alta_usuario();

-- RPC: invitar (o asignar directamente si ya existe el usuario)
create function public.invitar_usuario(
  p_escuela uuid, p_email text, p_rol rol_t, p_persona uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(trim(p_email));
begin
  if not (app.es_superadmin() or app.tiene_rol(p_escuela, 'admin_escuela')) then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if p_rol = 'superadmin' then raise exception 'rol no invitable'; end if;
  if p_persona is not null and not exists (select 1 from persona where id = p_persona and escuela_id = p_escuela) then
    raise exception 'la persona no pertenece a la escuela';
  end if;
  insert into invitacion (escuela_id, email, rol, persona_id)
    values (p_escuela, mail, p_rol, p_persona) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;
revoke execute on function public.invitar_usuario(uuid, text, rol_t, uuid) from public;
grant execute on function public.invitar_usuario(uuid, text, rol_t, uuid) to authenticated;

-- ───────── Menores de 14: no entran en equipos sin consentimiento del tutor ─────────
create function app.exigir_consentimiento() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare nac date;
begin
  select fecha_nacimiento into nac from persona where id = new.persona_id;
  if app.edad(nac) < 14 and not app.consentimiento_vigente(new.persona_id) then
    raise exception 'menor de 14 años sin consentimiento del tutor' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger eqm_consentimiento before insert on equipo_miembro
  for each row execute function app.exigir_consentimiento();

-- ───────── Módulos activables ─────────
create function app.modulo_activo(org uuid, m text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select activo from escuela_modulo where escuela_id = org and modulo = m), false)
$$;
grant execute on function app.modulo_activo(uuid, text) to authenticated;

-- Crear/gestionar competiciones exige el módulo 'competiciones' en la escuela organizadora
drop policy comp_mod on competicion;
create policy comp_mod on competicion for all
  using (app.gestiona(organization_id))
  with check (app.gestiona(organization_id) and app.modulo_activo(organization_id, 'competiciones'));

-- ───────── Mis pertenencias (para el cliente) ─────────
create view v_mis_pertenencias as
  select p.id, p.escuela_id, s.nombre as escuela, p.rol
  from pertenencia p left join escuela s on s.id = p.escuela_id
  where p.usuario_id = auth.uid();
grant select on v_mis_pertenencias to authenticated;


-- ============================================
-- migrations/0004_calendario.sql
-- ============================================
-- Ligaria · 0004 · Inscripción validada, descansos y generador de calendario (algoritmo del círculo)

-- ───────── Descansos (jornada con número impar de equipos) ─────────
create table descanso (
  jornada_id uuid not null,
  competicion_id uuid not null,
  organization_id uuid not null,
  equipo_id uuid not null references equipo(id),
  primary key (jornada_id, equipo_id),
  foreign key (jornada_id, competicion_id, organization_id)
    references jornada(id, competicion_id, organization_id) on delete cascade
);
alter table descanso enable row level security;
create policy descanso_sel on descanso for select using (app.ve_competicion(competicion_id));
create policy descanso_mod on descanso for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
grant select, insert, update, delete on descanso to authenticated;

-- ───────── Inscripción: mismo deporte/categoría y solo antes de generar el calendario ─────────
create function app.validar_inscripcion() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo;
begin
  select * into c from competicion where id = new.competicion_id;
  select * into e from equipo where id = new.equipo_id;
  if c.tipo <> 'liga' then raise exception 'solo se implementan ligas'; end if;
  if c.deporte_id <> e.deporte_id then
    raise exception 'el deporte del equipo no coincide con la competición' using errcode = '23514';
  end if;
  if c.categoria_id is not null and e.categoria_id is distinct from c.categoria_id then
    raise exception 'la categoría del equipo no coincide con la competición' using errcode = '23514';
  end if;
  if exists (select 1 from jornada where competicion_id = c.id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger insc_validar before insert on inscripcion_equipo
  for each row execute function app.validar_inscripcion();

-- ───────── Generador de calendario todos contra todos ─────────
-- Método del círculo: un equipo fijo y los demás rotan. Con número impar se añade un
-- "descanso" (bye) y el equipo emparejado con él descansa esa jornada.
-- Reglas leídas de competicion.reglas: vueltas (1|2) y partidos_por_encuentro.
-- Devuelve el número de encuentros creados. Se puede regenerar mientras no haya resultados.
create function public.generar_calendario(
  p_competicion uuid, p_fecha_inicio date default null, p_dias_entre_jornadas int default 7)
returns int language plpgsql set search_path = public, pg_temp as $$
declare
  c competicion;
  equipos uuid[];
  t uuid[];                 -- equipos (+ null si impar)
  m int; n int;
  vueltas int; ind int; dob int;
  r int; i int; k int; v int;
  pos uuid[];
  a uuid; b uuid; tmp uuid;
  bal jsonb := '{}'::jsonb; orient jsonb := '{}'::jsonb;
  clave text; ba int; bb int;
  jid uuid; eid uuid; pid uuid;
  num int := 0; creados int := 0; orden int;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organization_id) then
    raise exception 'sin permiso para generar el calendario' using errcode = '42501';
  end if;
  if c.tipo <> 'liga' then raise exception 'solo se implementan ligas'; end if;
  if exists (select 1 from encuentro where competicion_id = c.id and estado <> 'programado') then
    raise exception 'ya hay resultados propuestos o confirmados; no se puede regenerar' using errcode = '23514';
  end if;

  vueltas := coalesce((c.reglas->>'vueltas')::int, 1);
  if vueltas not in (1, 2) then raise exception 'vueltas debe ser 1 o 2'; end if;
  ind := coalesce((c.reglas#>>'{partidos_por_encuentro,individuales}')::int, 2);
  dob := coalesce((c.reglas#>>'{partidos_por_encuentro,dobles}')::int, 1);

  select array_agg(equipo_id order by created_at, equipo_id) into equipos
    from inscripcion_equipo where competicion_id = c.id;
  n := coalesce(array_length(equipos, 1), 0);
  if n < 2 then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;

  delete from jornada where competicion_id = c.id;   -- cascada: encuentros, partidos, descansos

  t := equipos;
  if n % 2 = 1 then t := t || array[null::uuid]; end if;
  m := array_length(t, 1);

  for v in 1..vueltas loop
    for r in 0..m - 2 loop
      num := num + 1;
      insert into jornada (competicion_id, organization_id, numero, fecha)
        values (c.id, c.organization_id, num,
                case when p_fecha_inicio is null then null
                     else p_fecha_inicio + (num - 1) * p_dias_entre_jornadas end)
        returning id into jid;

      -- posiciones tras r rotaciones (t[1] fijo)
      pos := array[t[1]];
      for k in 2..m loop
        pos := pos || t[2 + ((k - 2 - r) % (m - 1) + (m - 1)) % (m - 1)];
      end loop;

      for i in 1..m / 2 loop
        a := pos[i]; b := pos[m + 1 - i];
        if a is null or b is null then
          insert into descanso (jornada_id, competicion_id, organization_id, equipo_id)
            values (jid, c.id, c.organization_id, coalesce(a, b));
          continue;
        end if;
        -- Localía: 1ª vuelta equilibrada de forma voraz (el equipo con más partidos de local
        -- pasa a visitante; en empate se alterna por jornada). 2ª vuelta: invierte la 1ª.
        clave := least(a::text, b::text) || '|' || greatest(a::text, b::text);
        if v = 1 then
          ba := coalesce((bal->>a::text)::int, 0);
          bb := coalesce((bal->>b::text)::int, 0);
          if ba > bb or (ba = bb and (r + i) % 2 = 1) then tmp := a; a := b; b := tmp; end if;
          bal := bal || jsonb_build_object(a::text, coalesce((bal->>a::text)::int, 0) + 1,
                                           b::text, coalesce((bal->>b::text)::int, 0) - 1);
          orient := orient || jsonb_build_object(clave, a::text);
        else
          if (orient->>clave)::uuid = a then tmp := a; a := b; b := tmp; end if;
        end if;

        insert into encuentro (competicion_id, organization_id, jornada_id, local_equipo_id, visitante_equipo_id)
          values (c.id, c.organization_id, jid, a, b) returning id into eid;
        creados := creados + 1;

        orden := 0;
        for k in 1..ind loop
          orden := orden + 1;
          insert into partido (encuentro_id, competicion_id, organization_id, orden, tipo)
            values (eid, c.id, c.organization_id, orden, 'individual');
        end loop;
        for k in 1..dob loop
          orden := orden + 1;
          insert into partido (encuentro_id, competicion_id, organization_id, orden, tipo)
            values (eid, c.id, c.organization_id, orden, 'dobles');
        end loop;
      end loop;
    end loop;
  end loop;
  return creados;
end $$;
revoke execute on function public.generar_calendario(uuid, date, int) from public;
grant execute on function public.generar_calendario(uuid, date, int) to authenticated;


-- ============================================
-- migrations/0005_resultados_clasificacion.sql
-- ============================================
-- Ligaria · 0005 · Resultados (propuesto → confirmado, correcciones con historial) y clasificación
-- La clasificación NUNCA se almacena ni se edita: se calcula de los encuentros confirmados.

-- ───────── Historial de correcciones ─────────
create table correccion_resultado (
  id uuid primary key default gen_random_uuid(),
  encuentro_id uuid not null references encuentro(id) on delete cascade,
  competicion_id uuid not null,
  organization_id uuid not null,
  usuario_id uuid references usuario(id),
  motivo text not null,
  antes jsonb not null,
  despues jsonb not null,
  created_at timestamptz not null default now()
);
alter table correccion_resultado enable row level security;
create policy corr_sel on correccion_resultado for select using (app.gestiona(organization_id));
grant select on correccion_resultado to authenticated;

-- ───────── Utilidades ─────────
create function app.snapshot_resultado(p_enc uuid) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'estado', e.estado,
    'incomparecencia', e.incomparecencia,
    'partidos', coalesce((
      select jsonb_agg(jsonb_build_object(
        'orden', p.orden, 'tipo', p.tipo,
        'local', coalesce((select jsonb_agg(pp.persona_id order by pp.persona_id) from partido_participante pp
                           where pp.partido_id = p.id and pp.lado = 'local'), '[]'),
        'visitante', coalesce((select jsonb_agg(pp.persona_id order by pp.persona_id) from partido_participante pp
                           where pp.partido_id = p.id and pp.lado = 'visitante'), '[]'),
        'sets', coalesce((select jsonb_agg(jsonb_build_array(rs.juegos_local, rs.juegos_visitante) order by rs.numero)
                          from resultado_set rs where rs.partido_id = p.id), '[]')
      ) order by p.orden) from partido p where p.encuentro_id = e.id), '[]'))
  from encuentro e where e.id = p_enc
$$;

-- Escribe el resultado de un encuentro (reemplaza lo anterior). Formato:
-- {"incomparecencia": null|"local"|"visitante",
--  "partidos":[{"orden":1,"local":[uuid],"visitante":[uuid],"sets":[[6,4],[3,6],[10,8]]}]}
create function app.escribir_resultado(p_enc uuid, p_res jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  e encuentro; part jsonb; pa partido; lado lado_t; pid text; st record;
  esperados int; total_sets int := 0; inc lado_t; jl int; jv int; eq uuid; nj int;
begin
  select * into e from encuentro where id = p_enc for update;
  inc := nullif(p_res->>'incomparecencia', '')::lado_t;

  delete from resultado_set where partido_id in (select id from partido where encuentro_id = p_enc);
  delete from partido_participante where partido_id in (select id from partido where encuentro_id = p_enc);
  update encuentro set incomparecencia = inc where id = p_enc;
  if inc is not null then return; end if;

  for part in select value from jsonb_array_elements(coalesce(p_res->'partidos', '[]'::jsonb)) loop
    select * into pa from partido where encuentro_id = p_enc and orden = (part->>'orden')::int;
    if not found then raise exception 'el partido % no existe en el encuentro', part->>'orden'; end if;
    esperados := case pa.tipo when 'dobles' then 2 else 1 end;

    foreach lado in array array['local', 'visitante']::lado_t[] loop
      eq := case lado when 'local' then e.local_equipo_id else e.visitante_equipo_id end;
      nj := 0;
      for pid in select value from jsonb_array_elements_text(coalesce(part->(lado::text), '[]'::jsonb)) loop
        nj := nj + 1;
        if not exists (select 1 from equipo_miembro where equipo_id = eq and persona_id = pid::uuid) then
          raise exception 'el jugador % no pertenece al equipo %', pid, lado;
        end if;
        insert into partido_participante (partido_id, competicion_id, organization_id, lado, persona_id)
          values (pa.id, e.competicion_id, e.organization_id, lado, pid::uuid);
      end loop;
      if nj > esperados then raise exception 'demasiados jugadores en el partido %', pa.orden; end if;
    end loop;

    for st in select value, ordinality as n from jsonb_array_elements(coalesce(part->'sets', '[]'::jsonb)) with ordinality loop
      if jsonb_typeof(st.value) <> 'array' or jsonb_array_length(st.value) <> 2 then
        raise exception 'set con formato incorrecto';
      end if;
      jl := (st.value->>0)::int; jv := (st.value->>1)::int;
      if jl < 0 or jv < 0 or jl = jv then raise exception 'marcador de set no válido: %-%', jl, jv; end if;
      insert into resultado_set (partido_id, competicion_id, organization_id, numero, juegos_local, juegos_visitante)
        values (pa.id, e.competicion_id, e.organization_id, st.n, jl, jv);
      total_sets := total_sets + 1;
    end loop;
  end loop;

  if total_sets = 0 then raise exception 'el resultado no contiene ningún set'; end if;
end $$;

create function app.notificar_organizacion(p_org uuid, p_titulo text, p_cuerpo text) returns void
language sql security definer set search_path = public, pg_temp as $$
  insert into notificacion (usuario_id, escuela_id, titulo, cuerpo)
  select distinct usuario_id, p_org, p_titulo, p_cuerpo from pertenencia
  where escuela_id = p_org and rol in ('organizador_liga', 'admin_escuela')
$$;

create function app.notificar_entrenadores(p_enc uuid, p_titulo text, p_cuerpo text) returns void
language sql security definer set search_path = public, pg_temp as $$
  insert into notificacion (usuario_id, escuela_id, titulo, cuerpo)
  select distinct ee.usuario_id, ee.escuela_id, p_titulo, p_cuerpo
  from encuentro e join equipo_entrenador ee on ee.equipo_id in (e.local_equipo_id, e.visitante_equipo_id)
  where e.id = p_enc
$$;

-- ───────── RPC ─────────
-- Entrenador de uno de los dos equipos (o la organización) propone el resultado.
create function public.proponer_resultado(p_encuentro uuid, p_resultado jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if not (app.entrena_equipo(e.local_equipo_id) or app.entrena_equipo(e.visitante_equipo_id)
          or app.gestiona(e.organization_id)) then
    raise exception 'sin permiso para proponer el resultado' using errcode = '42501';
  end if;
  if e.estado = 'confirmado' then
    raise exception 'el resultado ya está confirmado; solicita una corrección' using errcode = '23514';
  end if;
  perform app.escribir_resultado(p_encuentro, p_resultado);
  update encuentro set estado = 'propuesto', propuesto_por = auth.uid(), propuesto_en = now(),
         confirmado_por = null, confirmado_en = null where id = p_encuentro;
  perform app.notificar_organizacion(e.organization_id, 'Resultado pendiente de confirmar',
                                     'Hay un resultado propuesto en tu liga.');
end $$;

create function public.confirmar_resultado(p_encuentro uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if not app.gestiona(e.organization_id) then
    raise exception 'solo la organización puede confirmar resultados' using errcode = '42501';
  end if;
  if e.estado <> 'propuesto' then raise exception 'no hay un resultado propuesto que confirmar' using errcode = '23514'; end if;
  update encuentro set estado = 'confirmado', confirmado_por = auth.uid(), confirmado_en = now()
    where id = p_encuentro;
  update competicion set estado = 'en_curso'
    where id = e.competicion_id and estado in ('borrador', 'publicada');
  perform app.notificar_entrenadores(p_encuentro, 'Resultado confirmado', 'La organización ha confirmado un resultado.');
end $$;

-- La organización devuelve una propuesta al entrenador (vuelve a «programado»).
create function public.rechazar_resultado(p_encuentro uuid, p_motivo text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if not app.gestiona(e.organization_id) then
    raise exception 'solo la organización puede rechazar resultados' using errcode = '42501';
  end if;
  if e.estado <> 'propuesto' then raise exception 'no hay un resultado propuesto' using errcode = '23514'; end if;
  delete from resultado_set where partido_id in (select id from partido where encuentro_id = p_encuentro);
  delete from partido_participante where partido_id in (select id from partido where encuentro_id = p_encuentro);
  update encuentro set estado = 'programado', incomparecencia = null, propuesto_por = null, propuesto_en = null
    where id = p_encuentro;
  perform app.notificar_entrenadores(p_encuentro, 'Resultado rechazado', coalesce(p_motivo, 'Revisa el resultado y vuelve a proponerlo.'));
end $$;

-- Corrección por la organización (también sobre resultados confirmados). Guarda historial.
create function public.corregir_resultado(p_encuentro uuid, p_resultado jsonb, p_motivo text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro; antes jsonb;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if not app.gestiona(e.organization_id) then
    raise exception 'solo la organización puede corregir resultados' using errcode = '42501';
  end if;
  if coalesce(trim(p_motivo), '') = '' then raise exception 'indica el motivo de la corrección'; end if;
  if e.estado = 'programado' then raise exception 'el encuentro no tiene resultado que corregir' using errcode = '23514'; end if;
  antes := app.snapshot_resultado(p_encuentro);
  perform app.escribir_resultado(p_encuentro, p_resultado);
  update encuentro set estado = 'confirmado', confirmado_por = auth.uid(), confirmado_en = now()
    where id = p_encuentro;
  insert into correccion_resultado (encuentro_id, competicion_id, organization_id, usuario_id, motivo, antes, despues)
    values (p_encuentro, e.competicion_id, e.organization_id, auth.uid(), p_motivo, antes, app.snapshot_resultado(p_encuentro));
  perform app.notificar_entrenadores(p_encuentro, 'Resultado corregido', p_motivo);
end $$;

revoke execute on function public.proponer_resultado(uuid, jsonb) from public;
revoke execute on function public.confirmar_resultado(uuid) from public;
revoke execute on function public.rechazar_resultado(uuid, text) from public;
revoke execute on function public.corregir_resultado(uuid, jsonb, text) from public;
grant execute on function public.proponer_resultado(uuid, jsonb) to authenticated;
grant execute on function public.confirmar_resultado(uuid) to authenticated;
grant execute on function public.rechazar_resultado(uuid, text) to authenticated;
grant execute on function public.corregir_resultado(uuid, jsonb, text) to authenticated;

-- ───────── Clasificación (calculada) ─────────
create function app.metrica(crit text, h2h int, dp int, ds int, dj int) returns int
language sql immutable as $$
  select case crit
    when 'enfrentamiento_directo' then h2h
    when 'diferencia_partidos' then dp
    when 'diferencia_sets' then ds
    when 'diferencia_juegos' then dj
    else 0 end
$$;

-- Solo encuentros confirmados. Puntos y orden de desempates salen de competicion.reglas.
-- Incomparecencia: el equipo que comparece gana todos los partidos del encuentro (p. ej. 3-0);
-- sets y juegos no puntúan.
-- Enfrentamiento directo: puntos obtenidos entre los equipos empatados a puntos.
create function public.clasificacion(p_competicion uuid)
returns table (posicion int, equipo_id uuid, equipo text, escuela text,
               pj int, pg int, pe int, pp int, puntos int,
               partidos_f int, partidos_c int, sets_f int, sets_c int, juegos_f int, juegos_c int)
language plpgsql stable security definer set search_path = public, pg_temp as $$
#variable_conflict use_column
declare c competicion; v_gana int; v_empata int; v_pierde int; d1 text; d2 text; d3 text; d4 text;
begin
  if not app.ve_competicion(p_competicion) then
    raise exception 'sin acceso a la competición' using errcode = '42501';
  end if;
  select * into c from competicion where id = p_competicion;
  v_gana := coalesce((c.reglas#>>'{puntos,victoria}')::int, 3);
  v_empata := coalesce((c.reglas#>>'{puntos,empate}')::int, 1);
  v_pierde := coalesce((c.reglas#>>'{puntos,derrota}')::int, 0);
  d1 := c.reglas#>>'{desempates,0}'; d2 := c.reglas#>>'{desempates,1}';
  d3 := c.reglas#>>'{desempates,2}'; d4 := c.reglas#>>'{desempates,3}';

  return query
  with pst as (
    select p.encuentro_id, p.id as partido_id,
           count(*) filter (where rs.juegos_local > rs.juegos_visitante) as sl,
           count(*) filter (where rs.juegos_local < rs.juegos_visitante) as sv,
           coalesce(sum(rs.juegos_local), 0) as jl, coalesce(sum(rs.juegos_visitante), 0) as jv
    from partido p
    join encuentro e on e.id = p.encuentro_id and e.competicion_id = p_competicion and e.estado = 'confirmado'
    left join resultado_set rs on rs.partido_id = p.id
    group by p.encuentro_id, p.id
  ),
  enc0 as (
    select e.id, e.local_equipo_id as l, e.visitante_equipo_id as v, e.incomparecencia as inc,
           (select count(*) from partido where encuentro_id = e.id)::int as np,
           (count(*) filter (where ps.sl > ps.sv))::int as pl, (count(*) filter (where ps.sv > ps.sl))::int as pv,
           coalesce(sum(ps.sl), 0)::int as sl, coalesce(sum(ps.sv), 0)::int as sv,
           coalesce(sum(ps.jl), 0)::int as jl, coalesce(sum(ps.jv), 0)::int as jv
    from encuentro e left join pst ps on ps.encuentro_id = e.id
    where e.competicion_id = p_competicion and e.estado = 'confirmado'
    group by e.id
  ),
  enc as (
    select id, l, v,
      case inc when 'local' then 0 when 'visitante' then np else pl end as pl,
      case inc when 'visitante' then 0 when 'local' then np else pv end as pv,
      case when inc is null then sl else 0 end as sl, case when inc is null then sv else 0 end as sv,
      case when inc is null then jl else 0 end as jl, case when inc is null then jv else 0 end as jv
    from enc0
  ),
  filas as (
    select l as eq, v as rival, pl as pf, pv as pc, sl as sf, sv as sc, jl as jf, jv as jc,
           case when pl > pv then v_gana when pl = pv then v_empata else v_pierde end as pts
      from enc
    union all
    select v, l, pv, pl, sv, sl, jv, jl,
           case when pv > pl then v_gana when pv = pl then v_empata else v_pierde end
      from enc
  ),
  tot as (
    select i.equipo_id as eq,
           count(f.eq)::int as pj,
           (count(*) filter (where f.pf > f.pc))::int as pg,
           (count(*) filter (where f.eq is not null and f.pf = f.pc))::int as pe,
           (count(*) filter (where f.pf < f.pc))::int as pp,
           coalesce(sum(f.pts), 0)::int as puntos,
           coalesce(sum(f.pf), 0)::int as pf, coalesce(sum(f.pc), 0)::int as pc,
           coalesce(sum(f.sf), 0)::int as sf, coalesce(sum(f.sc), 0)::int as sc,
           coalesce(sum(f.jf), 0)::int as jf, coalesce(sum(f.jc), 0)::int as jc
    from inscripcion_equipo i left join filas f on f.eq = i.equipo_id
    where i.competicion_id = p_competicion
    group by i.equipo_id
  ),
  h2h as (
    select f.eq, sum(f.pts)::int as h
    from filas f join tot a on a.eq = f.eq join tot b on b.eq = f.rival
    where a.puntos = b.puntos group by f.eq
  )
  select (row_number() over (
            order by t.puntos desc,
                     app.metrica(d1, coalesce(h.h, 0), t.pf - t.pc, t.sf - t.sc, t.jf - t.jc) desc,
                     app.metrica(d2, coalesce(h.h, 0), t.pf - t.pc, t.sf - t.sc, t.jf - t.jc) desc,
                     app.metrica(d3, coalesce(h.h, 0), t.pf - t.pc, t.sf - t.sc, t.jf - t.jc) desc,
                     app.metrica(d4, coalesce(h.h, 0), t.pf - t.pc, t.sf - t.sc, t.jf - t.jc) desc,
                     q.nombre, t.eq))::int,
         t.eq, q.nombre, s.nombre,
         t.pj, t.pg, t.pe, t.pp, t.puntos, t.pf, t.pc, t.sf, t.sc, t.jf, t.jc
  from tot t
  left join h2h h on h.eq = t.eq
  join equipo q on q.id = t.eq
  join escuela s on s.id = q.escuela_id
  order by 1;
end $$;
revoke execute on function public.clasificacion(uuid) from public;
grant execute on function public.clasificacion(uuid) to authenticated;


-- ============================================
-- migrations/0006_vistas_app.sql
-- ============================================
-- Ligaria · 0006 · Vistas de lectura para la app y preferencias de notificación

alter table usuario add column notif_prefs jsonb not null default '{"resultados": true, "calendario": true}'::jsonb;

-- Encuentros con nombres de equipo y marcador (en partidos). El marcador de un resultado solo
-- «propuesto» lo ven la organización y los entrenadores implicados.
create view v_encuentros_competicion as
select e.id as encuentro_id, e.competicion_id, j.numero as jornada, j.fecha as jornada_fecha, e.fecha,
       e.estado, e.incomparecencia,
       e.local_equipo_id, ql.nombre as local, sl.nombre as escuela_local,
       e.visitante_equipo_id, qv.nombre as visitante, sv.nombre as escuela_visitante,
       case when e.estado = 'confirmado'
              or (e.estado = 'propuesto' and (app.gestiona(e.organization_id)
                   or app.entrena_equipo(e.local_equipo_id) or app.entrena_equipo(e.visitante_equipo_id)))
            then case e.incomparecencia when 'local' then 0 when 'visitante' then r.np else r.pl end end as partidos_local,
       case when e.estado = 'confirmado'
              or (e.estado = 'propuesto' and (app.gestiona(e.organization_id)
                   or app.entrena_equipo(e.local_equipo_id) or app.entrena_equipo(e.visitante_equipo_id)))
            then case e.incomparecencia when 'visitante' then 0 when 'local' then r.np else r.pv end end as partidos_visitante
from encuentro e
join jornada j on j.id = e.jornada_id
join equipo ql on ql.id = e.local_equipo_id join escuela sl on sl.id = ql.escuela_id
join equipo qv on qv.id = e.visitante_equipo_id join escuela sv on sv.id = qv.escuela_id
left join lateral (
  select count(*) filter (where s.sl > s.sv)::int as pl, count(*) filter (where s.sv > s.sl)::int as pv, count(*)::int as np
  from (select p.id,
               count(*) filter (where rs.juegos_local > rs.juegos_visitante) as sl,
               count(*) filter (where rs.juegos_local < rs.juegos_visitante) as sv
        from partido p left join resultado_set rs on rs.partido_id = p.id
        where p.encuentro_id = e.id group by p.id) s) r on true
where app.ve_competicion(e.competicion_id);

create view v_descansos_competicion as
select d.competicion_id, j.numero as jornada, d.equipo_id, q.nombre as equipo
from descanso d join jornada j on j.id = d.jornada_id join equipo q on q.id = d.equipo_id
where app.ve_competicion(d.competicion_id);

-- Mis equipos (entrenador, jugador o tutor de un jugador) y las ligas en que participan
create view v_mis_equipos as
select x.equipo_id, q.nombre as equipo, q.escuela_id, s.nombre as escuela, x.rol,
       i.competicion_id, c.nombre as competicion
from (
  select equipo_id, 'entrenador'::text as rol from equipo_entrenador where usuario_id = auth.uid()
  union
  select em.equipo_id, 'alumno' from equipo_miembro em join persona p on p.id = em.persona_id where p.usuario_id = auth.uid()
  union
  select em.equipo_id, 'tutor' from equipo_miembro em join tutoria t on t.persona_id = em.persona_id where t.tutor_usuario_id = auth.uid()
) x
join equipo q on q.id = x.equipo_id join escuela s on s.id = q.escuela_id
left join inscripcion_equipo i on i.equipo_id = x.equipo_id
left join competicion c on c.id = i.competicion_id;

-- Mis fichas: la mía y las de mis tutelados
create view v_mis_fichas as
select p.id as persona_id, p.escuela_id, s.nombre as escuela, p.nombre, p.apellidos, p.fecha_nacimiento,
       p.visibilidad_ficha, p.mostrar_foto,
       app.edad(p.fecha_nacimiento) < 14 as menor_14,
       app.consentimiento_vigente(p.id) as consentimiento,
       case when p.usuario_id = auth.uid() then 'propia' else 'tutor' end as relacion
from persona p join escuela s on s.id = p.escuela_id
where p.usuario_id = auth.uid()
   or exists (select 1 from tutoria t where t.persona_id = p.id and t.tutor_usuario_id = auth.uid());

-- Jugadores de un equipo (respeta RLS: solo los ve quien puede ver esas fichas)
create view v_jugadores_equipo with (security_invoker = true) as
select em.equipo_id, p.id as persona_id, p.nombre, p.apellidos
from equipo_miembro em join persona p on p.id = em.persona_id;

-- Ligas publicadas a las que otras escuelas pueden inscribir equipos (solo datos públicos)
create view v_ligas_abiertas as
select c.id as competicion_id, c.nombre, c.deporte_id, d.nombre as deporte, c.categoria_id,
       c.organization_id, s.nombre as organizadora
from competicion c join deporte d on d.id = c.deporte_id join escuela s on s.id = c.organization_id
where auth.uid() is not null and c.tipo = 'liga' and c.estado = 'publicada'
  and not exists (select 1 from jornada j where j.competicion_id = c.id);

grant select on v_encuentros_competicion, v_descansos_competicion, v_mis_equipos, v_mis_fichas,
                v_jugadores_equipo, v_ligas_abiertas to authenticated;

