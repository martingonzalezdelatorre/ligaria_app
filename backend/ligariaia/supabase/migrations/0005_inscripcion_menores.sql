-- Ligaria · 0005 · Inscripción de menores en la escuela (RGPD / LOPDGDD)
--
-- Decisiones de diseño (ver README, sección «Inscripción de menores»):
--   · `jugador` NO se amplía: la política jugador_sel deja leer la fila entera al entrenador (entrena_a),
--     así que los datos personales nuevos van a `alumno_ficha`, que el entrenador no puede leer.
--   · `tutor_jugador` (cuentas con acceso) se mantiene. Se añade `tutor_legal` (persona, con o sin cuenta)
--     y `tutor_legal_jugador` (N:M, reutilizable entre hermanos).
--   · Datos de salud, IBAN y borradores: cifrados en la aplicación (Edge Function, AES-256-GCM, clave en
--     secretos). Aquí solo se guarda `bytea` + versión de clave. Esas tablas NO son accesibles para los roles
--     `authenticated`/`anon` (sin políticas ni grants): solo la Edge Function con service_role.
--   · La categoría no se guarda: se deriva con app.categoria_alumno() (único sitio, configurable).
--   · El entrenador no tiene acceso a ninguna tabla nueva; recibirá sus 4 campos por RPC (paso de roles).
--   · No se guardan IP ni user-agent.

-- ───────── Tipos ─────────
create type documento_tipo        as enum ('DNI', 'NIE', 'PASAPORTE');
create type nivel_tipo            as enum ('INICIACION', 'INTERMEDIO', 'AVANZADO', 'COMPETICION');
create type objetivo_tipo         as enum ('OCIO', 'MEJORA', 'COMPETICION');
create type modalidad_tipo        as enum ('COLECTIVA', 'INDIVIDUAL', 'MINITENIS', 'OTRA');
create type tramo_tipo            as enum ('MANANA', 'MEDIODIA', 'TARDE');
create type relacion_tutor_tipo   as enum ('PADRE', 'MADRE', 'TUTOR');
create type periodicidad_tipo     as enum ('MENSUAL', 'TRIMESTRAL', 'ANUAL');
create type forma_pago_tipo       as enum ('DOMICILIACION', 'TARJETA', 'TRANSFERENCIA', 'EFECTIVO');
create type descuento_tipo        as enum ('HERMANOS', 'FAMILIA_NUMEROSA', 'SOCIO');
create type seguro_tipo           as enum ('INCLUIDO_POR_ESCUELA', 'PROPIO');
create type inscripcion_escuela_estado as enum ('PENDIENTE', 'ACTIVA', 'BAJA');
create type consentimiento_tipo   as enum (
  'TRATAMIENTO_DATOS', 'DATOS_SALUD', 'REGLAMENTO_CONDICIONES',
  'IMAGEN_WEB', 'IMAGEN_REDES', 'IMAGEN_CARTELERIA',
  'ATENCION_MEDICA_URGENCIA', 'SALIDA_RECOGIDA', 'COMUNICACIONES_COMERCIALES', 'EXENCION_RESPONSABILIDAD');

-- ───────── Configuración de la escuela ─────────
-- categorias: [{"nombre": "...", "edad_min": n, "edad_max": n}]. Vacío hasta que la escuela las defina.
create table public.config_escuela (
  organizacion_id    uuid primary key references public.organizacion (id) on delete cascade,
  corte_mes          smallint not null default 1  check (corte_mes between 1 and 12),
  corte_dia          smallint not null default 1  check (corte_dia between 1 and 31),
  categorias         jsonb    not null default '[]'::jsonb check (jsonb_typeof(categorias) = 'array'),
  exencion_activa    boolean  not null default false,
  borrador_dias      smallint not null default 30 check (borrador_dias between 1 and 365),
  updated_at         timestamptz not null default now()
);
create trigger trg_config_escuela_updated_at before update on public.config_escuela
  for each row execute function public.set_updated_at();

-- Textos legales y avisos: PLACEHOLDERS versionados que revisará un DPO/abogado. Nunca texto definitivo.
-- tipo: un consentimiento, 'INFO_PRIMERA_CAPA' o 'AVISO_14_MAS'.
create table public.texto_legal_version (
  id               uuid primary key default gen_random_uuid(),
  organizacion_id  uuid not null references public.organizacion (id) on delete cascade,
  tipo             text not null check (tipo in (
                     'TRATAMIENTO_DATOS','DATOS_SALUD','REGLAMENTO_CONDICIONES','IMAGEN_WEB','IMAGEN_REDES',
                     'IMAGEN_CARTELERIA','ATENCION_MEDICA_URGENCIA','SALIDA_RECOGIDA','COMUNICACIONES_COMERCIALES',
                     'EXENCION_RESPONSABILIDAD','INFO_PRIMERA_CAPA','AVISO_14_MAS')),
  version          int  not null check (version > 0),
  contenido        text not null,
  vigente_desde    timestamptz not null default now(),
  unique (organizacion_id, tipo, version)
);

-- ───────── Alumno: datos personales (aparte de `jugador`) ─────────
create table public.alumno_ficha (
  jugador_id          uuid primary key references public.jugador (id) on delete cascade,
  sexo                text check (sexo in ('M', 'F', 'X')),
  documento_tipo      documento_tipo,
  documento_numero    text,
  nacionalidad        text,
  foto_path           text,
  direccion           text,
  codigo_postal       text check (codigo_postal ~ '^[0-9]{5}$'),
  localidad           text,
  custodia_compartida boolean not null default false,
  puede_irse_solo     boolean not null default false,
  updated_at          timestamptz not null default now(),
  check ((documento_tipo is null) = (documento_numero is null))
);
create trigger trg_alumno_ficha_updated_at before update on public.alumno_ficha
  for each row execute function public.set_updated_at();

-- ───────── Tutores legales (personas) ─────────
create table public.tutor_legal (
  id                  uuid primary key default gen_random_uuid(),
  organizacion_id     uuid not null references public.organizacion (id) on delete cascade,
  usuario_id          uuid references public.usuario (id) on delete set null,
  nombre              text not null,
  apellidos           text not null,
  documento_numero    text not null,
  telefono_movil      text not null,
  telefono_alternativo text,
  email               text not null,
  direccion           text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create trigger trg_tutor_legal_updated_at before update on public.tutor_legal
  for each row execute function public.set_updated_at();
create index idx_tutor_legal_org     on public.tutor_legal (organizacion_id);
create index idx_tutor_legal_usuario on public.tutor_legal (usuario_id);
create unique index uq_tutor_legal_doc on public.tutor_legal (organizacion_id, upper(documento_numero));

create table public.tutor_legal_jugador (
  tutor_id               uuid not null references public.tutor_legal (id) on delete cascade,
  jugador_id             uuid not null references public.jugador (id) on delete cascade,
  relacion               relacion_tutor_tipo not null,
  restricciones_recogida text,
  primary key (tutor_id, jugador_id)
);
create index idx_tlj_jugador on public.tutor_legal_jugador (jugador_id);

-- Máximo 2 tutores por alumno.
create function app.max_dos_tutores() returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if (select count(*) from tutor_legal_jugador where jugador_id = new.jugador_id and tutor_id <> new.tutor_id) >= 2 then
    raise exception 'un alumno admite como máximo 2 tutores' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger trg_max_dos_tutores before insert on public.tutor_legal_jugador
  for each row execute function app.max_dos_tutores();

-- ───────── Personas autorizadas a recoger ─────────
create table public.persona_autorizada (
  id                uuid primary key default gen_random_uuid(),
  jugador_id        uuid not null references public.jugador (id) on delete cascade,
  nombre            text not null,
  apellidos         text not null,
  telefono          text not null,
  parentesco        text not null,
  documento_numero  text            -- opcional (dato de un tercero, minimización)
);
create index idx_persona_autorizada_jugador on public.persona_autorizada (jugador_id);

-- ───────── Inscripción en la escuela (por alumno y temporada) ─────────
create table public.inscripcion_escuela (
  id                    uuid primary key default gen_random_uuid(),
  organizacion_id       uuid not null references public.organizacion (id) on delete cascade,
  jugador_id            uuid not null references public.jugador (id) on delete cascade,
  temporada             text not null,                              -- p. ej. '2026-2027'
  numero_alumno         bigint generated by default as identity,
  fecha_inscripcion     date not null default current_date,
  estado                inscripcion_escuela_estado not null default 'PENDIENTE',
  -- datos deportivos
  nivel                 nivel_tipo not null,
  experiencia_anios     smallint check (experiencia_anios between 0 and 30),
  experiencia_club      text,
  objetivo              objetivo_tipo,
  modalidad             modalidad_tipo not null,
  modalidad_otra        text,
  preferencia_texto     text,
  -- licencia y seguro
  tramita_licencia      boolean not null default false,
  seguro_accidentes     seguro_tipo not null default 'INCLUIDO_POR_ESCUELA',
  seguro_aseguradora    text,
  seguro_poliza         text,
  -- administración (la rellena la escuela)
  grupo_equipo_id       uuid references public.equipo (id) on delete set null,
  pista_id              uuid references public.pista (id) on delete set null,
  entrenador_usuario_id uuid references public.usuario (id) on delete set null,
  fecha_inicio          date,
  fecha_baja            date,
  observaciones         text,
  -- firma (opción A: casilla de aceptación con registro)
  firmante_tutor_id     uuid not null references public.tutor_legal (id) on delete restrict,
  firmada_en            timestamptz not null default now(),
  firmada_por           uuid not null references public.usuario (id) on delete restrict,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (jugador_id, temporada),
  check (modalidad <> 'OTRA' or nullif(trim(modalidad_otra), '') is not null),
  check (seguro_accidentes <> 'PROPIO'
         or (nullif(trim(seguro_aseguradora), '') is not null and nullif(trim(seguro_poliza), '') is not null)),
  check (fecha_baja is null or fecha_inicio is null or fecha_baja >= fecha_inicio)
);
create trigger trg_inscripcion_escuela_updated_at before update on public.inscripcion_escuela
  for each row execute function public.set_updated_at();
create index idx_ie_org_temporada_estado on public.inscripcion_escuela (organizacion_id, temporada, estado);
create index idx_ie_grupo      on public.inscripcion_escuela (grupo_equipo_id);
create index idx_ie_entrenador on public.inscripcion_escuela (entrenador_usuario_id);
create index idx_ie_firmante   on public.inscripcion_escuela (firmante_tutor_id);

-- El firmante debe ser tutor del alumno.
create function app.firmante_es_tutor() returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if not exists (select 1 from tutor_legal_jugador where tutor_id = new.firmante_tutor_id and jugador_id = new.jugador_id) then
    raise exception 'el firmante principal debe ser tutor del alumno' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger trg_firmante_es_tutor before insert or update of firmante_tutor_id, jugador_id
  on public.inscripcion_escuela for each row execute function app.firmante_es_tutor();

create table public.inscripcion_franja (
  inscripcion_id  uuid not null references public.inscripcion_escuela (id) on delete cascade,
  dia             smallint not null check (dia between 1 and 7),
  tramo           tramo_tipo not null,
  primary key (inscripcion_id, dia, tramo)
);

-- ───────── Salud (cifrada en la aplicación) ─────────
-- datos_cifrados = AES-256-GCM(JSON: contacto_emergencia, alergias, enfermedades, medicacion, lesiones,
--                  grupo/seguro sanitario, fecha_certificado, declaracion_aptitud). No se puede buscar por ellos.
create table public.inscripcion_salud (
  inscripcion_id  uuid primary key references public.inscripcion_escuela (id) on delete cascade,
  datos_cifrados  bytea not null,
  key_version     smallint not null,
  certificado_path text,
  updated_at      timestamptz not null default now()
);

-- ───────── Pago ─────────
create table public.inscripcion_pago (
  inscripcion_id       uuid primary key references public.inscripcion_escuela (id) on delete cascade,
  periodicidad         periodicidad_tipo not null,
  forma_pago           forma_pago_tipo not null,
  titular_cuenta       text,
  iban_cifrado         bytea,                       -- AES-256-GCM
  key_version          smallint,
  mandato_referencia   text,
  mandato_fecha        date,
  mandato_aceptado     boolean not null default false,
  fact_razon_social    text,
  fact_nif             text,
  fact_direccion       text,
  descuentos           descuento_tipo[] not null default '{}',
  updated_at           timestamptz not null default now(),
  check (forma_pago <> 'DOMICILIACION' or (
           nullif(trim(titular_cuenta), '') is not null and iban_cifrado is not null and key_version is not null
           and mandato_aceptado and nullif(trim(mandato_referencia), '') is not null and mandato_fecha is not null)),
  check (forma_pago = 'DOMICILIACION' or iban_cifrado is null)
);

-- ───────── Consentimientos (registro de solo inserción) ─────────
create table public.consentimiento (
  id              uuid primary key default gen_random_uuid(),
  inscripcion_id  uuid not null references public.inscripcion_escuela (id) on delete cascade,
  tipo            consentimiento_tipo not null,
  aceptado        boolean not null,
  texto_version   int not null check (texto_version > 0),
  otorgado_en     timestamptz not null default now(),
  usuario_id      uuid not null references public.usuario (id) on delete restrict
);
create index idx_consentimiento_insc on public.consentimiento (inscripcion_id, tipo, otorgado_en desc);

create function app.consentimiento_inmutable() returns trigger language plpgsql as $$
begin
  raise exception 'el registro de consentimientos es de solo inserción (la revocación es una fila nueva)'
    using errcode = '23514';
end $$;
create trigger trg_consentimiento_inmutable before update on public.consentimiento
  for each row execute function app.consentimiento_inmutable();

-- ───────── Borradores (payload cifrado entero; caducan) ─────────
create table public.borrador_inscripcion (
  id               uuid primary key default gen_random_uuid(),
  usuario_id       uuid not null references public.usuario (id) on delete cascade,
  organizacion_id  uuid not null references public.organizacion (id) on delete cascade,
  jugador_id       uuid references public.jugador (id) on delete cascade,
  payload_cifrado  bytea not null,
  key_version      smallint not null,
  paso             smallint not null default 1 check (paso between 1 and 20),
  expira_en        timestamptz not null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create trigger trg_borrador_updated_at before update on public.borrador_inscripcion
  for each row execute function public.set_updated_at();
create index idx_borrador_usuario on public.borrador_inscripcion (usuario_id);
create index idx_borrador_expira  on public.borrador_inscripcion (expira_en);

-- Purga de borradores caducados (la programa pg_cron o la Edge Function de mantenimiento).
create function app.purgar_borradores() returns integer language plpgsql security definer
set search_path = public, pg_temp as $$
declare n integer;
begin
  delete from borrador_inscripcion where expira_en < now();
  get diagnostics n = row_count;
  return n;
end $$;
revoke execute on function app.purgar_borradores() from public, authenticated;

-- ───────── Registro de accesos (sin contenido) ─────────
create table public.registro_acceso (
  id           bigint generated always as identity primary key,
  usuario_id   uuid,                  -- opaco; sin FK para sobrevivir a la supresión de la cuenta
  recurso      text not null check (recurso in (
                 'alumno_ficha','tutor_legal','persona_autorizada','inscripcion_escuela',
                 'inscripcion_salud','inscripcion_pago','certificado','foto','exportacion','supresion')),
  recurso_id   uuid not null,
  accion       text not null check (accion in ('LEER', 'CREAR', 'EDITAR', 'EXPORTAR', 'SUPRIMIR', 'DESCARGAR')),
  ocurrido_en  timestamptz not null default now()
);
create index idx_registro_acceso_recurso on public.registro_acceso (recurso, recurso_id, ocurrido_en desc);
create index idx_registro_acceso_usuario on public.registro_acceso (usuario_id, ocurrido_en desc);

-- ───────── Funciones auxiliares ─────────
create function app.tutor_puede(j uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_tutor_de(j) or exists (
    select 1 from tutor_legal_jugador tj join tutor_legal t on t.id = tj.tutor_id
    where tj.jugador_id = j and t.usuario_id = auth.uid())
$$;

create function app.jugador_de_inscripcion(i uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select jugador_id from inscripcion_escuela where id = i
$$;

create function app.org_de_inscripcion(i uuid) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select organizacion_id from inscripcion_escuela where id = i
$$;

-- Administración de la escuela o tutor del alumno.
create function app.ve_inscripcion(i uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_admin()
      or app.admin_org(app.org_de_inscripcion(i))
      or app.tutor_puede(app.jugador_de_inscripcion(i))
$$;

-- Edad cumplida en una fecha.
create function app.edad_en(p_nacimiento date, p_fecha date) returns integer
language sql immutable as $$ select extract(year from age(p_fecha, p_nacimiento))::int $$;

-- Categoría del alumno: edad a la fecha de corte de la temporada (único sitio; configurable por escuela).
create function app.categoria_alumno(p_nacimiento date, p_org uuid, p_anio_temporada int)
returns text language plpgsql stable security definer set search_path = public, pg_temp as $$
declare c config_escuela; edad int; cat jsonb;
begin
  select * into c from config_escuela where organizacion_id = p_org;
  if c.organizacion_id is null then return null; end if;
  edad := app.edad_en(p_nacimiento, make_date(p_anio_temporada, c.corte_mes, c.corte_dia));
  select e into cat from jsonb_array_elements(c.categorias) e
   where edad between (e ->> 'edad_min')::int and (e ->> 'edad_max')::int
   order by (e ->> 'edad_min')::int limit 1;
  return cat ->> 'nombre';
end $$;
revoke execute on function app.categoria_alumno(date, uuid, int) from public;
grant execute on function app.categoria_alumno(date, uuid, int) to authenticated;

-- Alta/expiración de borradores: fecha según config de la escuela.
create function app.expira_borrador(p_org uuid) returns timestamptz
language sql stable security definer set search_path = public, pg_temp as $$
  select now() + make_interval(days => coalesce((select borrador_dias from config_escuela where organizacion_id = p_org), 30))
$$;

-- ───────── RLS ─────────
alter table public.config_escuela        enable row level security;
alter table public.texto_legal_version   enable row level security;
alter table public.alumno_ficha          enable row level security;
alter table public.tutor_legal           enable row level security;
alter table public.tutor_legal_jugador   enable row level security;
alter table public.persona_autorizada    enable row level security;
alter table public.inscripcion_escuela   enable row level security;
alter table public.inscripcion_franja    enable row level security;
alter table public.inscripcion_salud     enable row level security;
alter table public.inscripcion_pago      enable row level security;
alter table public.consentimiento        enable row level security;
alter table public.borrador_inscripcion  enable row level security;
alter table public.registro_acceso       enable row level security;

-- Sin grants por defecto: se concede solo lo necesario.
revoke all on public.config_escuela, public.texto_legal_version, public.alumno_ficha, public.tutor_legal,
  public.tutor_legal_jugador, public.persona_autorizada, public.inscripcion_escuela, public.inscripcion_franja,
  public.inscripcion_salud, public.inscripcion_pago, public.consentimiento, public.borrador_inscripcion,
  public.registro_acceso from anon, authenticated;

-- Configuración y textos: leen los miembros de la escuela; modifica su administración.
grant select, insert, update on public.config_escuela to authenticated;
create policy cfg_sel on public.config_escuela for select to authenticated
  using (app.es_admin() or app.es_miembro(organizacion_id));
create policy cfg_mod on public.config_escuela for all to authenticated
  using (app.admin_org(organizacion_id)) with check (app.admin_org(organizacion_id));

grant select, insert on public.texto_legal_version to authenticated;
create policy txt_sel on public.texto_legal_version for select to authenticated
  using (app.es_admin() or app.es_miembro(organizacion_id));
create policy txt_ins on public.texto_legal_version for insert to authenticated
  with check (app.admin_org(organizacion_id));

-- Alumno, tutores, autorizados, inscripción: administración (todo) y tutor del alumno (solo lectura;
-- las altas y ediciones del tutor pasan por la acción de guardado del paso 3). El entrenador no accede.
grant select, insert, update, delete on public.alumno_ficha to authenticated;
create policy ficha_sel on public.alumno_ficha for select to authenticated using (
  app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)) or app.tutor_puede(jugador_id));
create policy ficha_mod on public.alumno_ficha for all to authenticated
  using (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)))
  with check (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)));

grant select, insert, update, delete on public.tutor_legal to authenticated;
create policy tl_sel on public.tutor_legal for select to authenticated using (
  app.es_admin() or app.admin_org(organizacion_id) or usuario_id = auth.uid()
  or exists (select 1 from tutor_legal_jugador tj where tj.tutor_id = id and app.tutor_puede(tj.jugador_id)));
create policy tl_mod on public.tutor_legal for all to authenticated
  using (app.es_admin() or app.admin_org(organizacion_id))
  with check (app.es_admin() or app.admin_org(organizacion_id));

grant select, insert, update, delete on public.tutor_legal_jugador to authenticated;
create policy tlj_sel on public.tutor_legal_jugador for select to authenticated using (
  app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)) or app.tutor_puede(jugador_id));
create policy tlj_mod on public.tutor_legal_jugador for all to authenticated
  using (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)))
  with check (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)));

grant select, insert, update, delete on public.persona_autorizada to authenticated;
create policy pa_sel on public.persona_autorizada for select to authenticated using (
  app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)) or app.tutor_puede(jugador_id));
create policy pa_mod on public.persona_autorizada for all to authenticated
  using (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)))
  with check (app.es_admin() or app.admin_org(app.org_de_jugador(jugador_id)));

grant select, insert, update, delete on public.inscripcion_escuela to authenticated;
create policy ie_sel on public.inscripcion_escuela for select to authenticated
  using (app.es_admin() or app.admin_org(organizacion_id) or app.tutor_puede(jugador_id));
create policy ie_mod on public.inscripcion_escuela for all to authenticated
  using (app.es_admin() or app.admin_org(organizacion_id))
  with check (app.es_admin() or app.admin_org(organizacion_id));

grant select, insert, update, delete on public.inscripcion_franja to authenticated;
create policy if_sel on public.inscripcion_franja for select to authenticated using (app.ve_inscripcion(inscripcion_id));
create policy if_mod on public.inscripcion_franja for all to authenticated
  using (app.es_admin() or app.admin_org(app.org_de_inscripcion(inscripcion_id)))
  with check (app.es_admin() or app.admin_org(app.org_de_inscripcion(inscripcion_id)));

-- Consentimientos: lectura por quien ve la inscripción; inserción por tutor/administración
-- con usuario = quien la otorga. Sin update ni delete.
grant select, insert on public.consentimiento to authenticated;
create policy cons_sel on public.consentimiento for select to authenticated using (app.ve_inscripcion(inscripcion_id));
create policy cons_ins on public.consentimiento for insert to authenticated
  with check (usuario_id = auth.uid() and app.ve_inscripcion(inscripcion_id));

-- Registro de accesos: solo lo lee la administración; lo escribe el servidor (service_role).
grant select on public.registro_acceso to authenticated;
create policy ra_sel on public.registro_acceso for select to authenticated using (app.es_admin());

-- inscripcion_salud, inscripcion_pago y borrador_inscripcion: sin grants ni políticas para
-- authenticated/anon. Solo la Edge Function (service_role) lee y escribe, tras comprobar rol y registrar acceso.
