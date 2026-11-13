-- Ligaria · 0015 · Control de acceso basado en roles y permisos (RBAC) en tablas
--   rol          catálogo de roles (antes un enum fijo `rol_t`)
--   permiso      catálogo de permisos
--   rol_permiso  qué permisos concede cada rol
-- pertenencia.rol e invitacion.rol pasan a ser FK a rol(codigo). Las políticas RLS y las RPC
-- consultan permisos (app.tiene_permiso) en lugar de comparar nombres de rol.

-- ───────── Catálogos ─────────
create table rol (
  codigo text primary key check (codigo ~ '^[a-z][a-z0-9_]*$'),
  nombre text not null,
  descripcion text,
  ambito text not null check (ambito in ('plataforma', 'escuela', 'ayuntamiento')),
  invitable boolean not null default false,   -- se puede asignar invitando a un usuario a una escuela
  sistema boolean not null default true       -- rol base: no se puede borrar
);
create table permiso (
  codigo text primary key check (codigo ~ '^[a-z][a-z0-9_.]*$'),
  descripcion text not null
);
create table rol_permiso (
  rol text not null references rol(codigo) on update cascade on delete cascade,
  permiso text not null references permiso(codigo) on update cascade on delete cascade,
  primary key (rol, permiso)
);

insert into rol (codigo, nombre, descripcion, ambito, invitable) values
  ('superadmin',       'Superadministrador',        'Gestiona toda la plataforma',                        'plataforma',   false),
  ('admin_escuela',    'Administrador de escuela',  'Gestiona usuarios, jugadores, equipos y ligas de su escuela', 'escuela', true),
  ('organizador_liga', 'Organizador de liga',       'Crea ligas, genera calendarios y valida resultados', 'escuela',      true),
  ('entrenador',       'Entrenador',                'Dirige equipos y propone resultados',                'escuela',      true),
  ('alumno',           'Alumno',                    'Jugador con cuenta propia',                          'escuela',      true),
  ('tutor',            'Tutor',                     'Responsable legal de uno o más menores',             'escuela',      true),
  ('ayuntamiento',     'Ayuntamiento',              'Gestiona las escuelas y ligas de su municipio',      'ayuntamiento', false);

insert into permiso (codigo, descripcion) values
  ('plataforma.administrar', 'Administrar la plataforma (escuelas, ayuntamientos, temporadas, registro)'),
  ('escuela.administrar',    'Administrar la escuela: usuarios, jugadores, tutores, equipos e inscripciones'),
  ('liga.gestionar',         'Crear y gestionar ligas, generar calendarios y confirmar o corregir resultados'),
  ('resultado.proponer',     'Proponer el resultado de los encuentros de sus equipos'),
  ('ficha.propia',           'Ver y gestionar su propia ficha'),
  ('ficha.menores',          'Ver y gestionar las fichas de los menores a su cargo'),
  ('ayuntamiento.administrar', 'Administrar las escuelas y ligas del municipio');

insert into rol_permiso (rol, permiso) values
  ('superadmin',       'plataforma.administrar'),
  ('admin_escuela',    'escuela.administrar'),
  ('admin_escuela',    'liga.gestionar'),
  ('organizador_liga', 'liga.gestionar'),
  ('entrenador',       'resultado.proponer'),
  ('alumno',           'ficha.propia'),
  ('tutor',            'ficha.menores'),
  ('ayuntamiento',     'ayuntamiento.administrar');

alter table rol enable row level security;
alter table permiso enable row level security;
alter table rol_permiso enable row level security;
create policy rol_sel on rol for select using (auth.uid() is not null);
create policy permiso_sel on permiso for select using (auth.uid() is not null);
create policy rolperm_sel on rol_permiso for select using (auth.uid() is not null);
-- El catálogo solo lo modifica quien tiene el permiso de plataforma (se define abajo la función).
grant select on rol, permiso, rol_permiso to authenticated;

-- ───────── pertenencia / invitacion: de enum a FK ─────────
create or replace function app.tiene_rol(org uuid, r rol_t) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia
                 where usuario_id = auth.uid() and escuela_id = org and rol::text = r::text)
$$;
drop view if exists v_mis_pertenencias;
drop policy pert_mod on pertenencia;          -- usa la columna rol; se recrea más abajo
-- Las CHECK que comparan con el literal del enum se descartan y se recrean con texto.
do $c$
declare r record;
begin
  for r in select conrelid::regclass as t, conname from pg_constraint
           where contype = 'c' and conrelid in ('pertenencia'::regclass, 'invitacion'::regclass)
             and pg_get_constraintdef(oid) like '%rol_t%' loop
    execute format('alter table %s drop constraint %I', r.t, r.conname);
  end loop;
end $c$;
alter table pertenencia alter column rol type text using rol::text;
alter table invitacion  alter column rol type text using rol::text;
alter table pertenencia add constraint pertenencia_global_chk check ((rol = 'superadmin') = (escuela_id is null));
alter table invitacion  add constraint invitacion_no_superadmin_chk check (rol <> 'superadmin');
alter table pertenencia add constraint pertenencia_rol_fk foreign key (rol) references rol(codigo) on update cascade;
alter table invitacion  add constraint invitacion_rol_fk  foreign key (rol) references rol(codigo) on update cascade;

-- ───────── Funciones de permiso ─────────
-- Permiso global (sin escuela): p. ej. superadmin → plataforma.administrar
create or replace function app.tiene_permiso_global(perm text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia p join rol_permiso rp on rp.rol = p.rol
                 where p.usuario_id = auth.uid() and p.escuela_id is null and rp.permiso = perm)
$$;

create or replace function app.es_superadmin() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.tiene_permiso_global('plataforma.administrar')
$$;

-- Permiso dentro de una escuela (el superadmin lo tiene siempre)
create function app.tiene_permiso(org uuid, perm text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from pertenencia p join rol_permiso rp on rp.rol = p.rol
    where p.usuario_id = auth.uid() and p.escuela_id = org and rp.permiso = perm)
$$;
grant execute on function app.tiene_permiso(uuid, text), app.tiene_permiso_global(text) to authenticated;

create or replace function app.gestiona(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.tiene_permiso(org, 'liga.gestionar')
$$;

-- Solo quien administra la plataforma edita el catálogo
create policy rol_mod on rol for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy permiso_mod on permiso for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy rolperm_mod on rol_permiso for all using (app.es_superadmin()) with check (app.es_superadmin());
grant insert, update, delete on rol, permiso, rol_permiso to authenticated;

-- ───────── Políticas y funciones: 'admin_escuela' → permiso escuela.administrar ─────────
-- Reescribe toda política que llame a app.tiene_rol(x, 'admin_escuela' | 'organizador_liga') para usar
-- app.tiene_permiso(x, 'escuela.administrar' | 'liga.gestionar').
do $mig$
declare r record; q text; w text; ddl text;
  re1 constant text := $re$app\.tiene_rol\(([^,()]+), 'admin_escuela'::rol_t\)$re$;
  rep1 constant text := $rep$app.tiene_permiso(\1, 'escuela.administrar')$rep$;
  re2 constant text := $re$app\.tiene_rol\(([^,()]+), 'organizador_liga'::rol_t\)$re$;
  rep2 constant text := $rep$app.tiene_permiso(\1, 'liga.gestionar')$rep$;
begin
  for r in select * from pg_policies where schemaname = 'public'
           and (qual like '%tiene_rol%' or with_check like '%tiene_rol%') loop
    q := regexp_replace(regexp_replace(r.qual, re1, rep1, 'g'), re2, rep2, 'g');
    w := regexp_replace(regexp_replace(r.with_check, re1, rep1, 'g'), re2, rep2, 'g');
    if q like '%tiene_rol%' or w like '%tiene_rol%' then
      raise exception 'política % de % no migrada: %', r.policyname, r.tablename, coalesce(q, w);
    end if;
    execute format('drop policy %I on %I.%I', r.policyname, r.schemaname, r.tablename);
    ddl := format('create policy %I on %I.%I as %s for %s to %s', r.policyname, r.schemaname, r.tablename,
                  r.permissive, r.cmd, array_to_string(r.roles, ', '));
    if q is not null then ddl := ddl || format(' using (%s)', q); end if;
    if w is not null then ddl := ddl || format(' with check (%s)', w); end if;
    execute ddl;
  end loop;
end $mig$;

-- pert_mod (se eliminó arriba): el rol asignable lo marca el catálogo, no un nombre fijo
create policy pert_mod on pertenencia for all
  using (app.es_superadmin() or (escuela_id is not null and app.tiene_permiso(escuela_id, 'escuela.administrar')))
  with check (app.es_superadmin() or (escuela_id is not null
              and app.tiene_permiso(escuela_id, 'escuela.administrar')
              and exists (select 1 from rol where codigo = rol and invitable)));

create or replace function public.actualizar_privacidad(
  p_persona uuid, p_visibilidad visibilidad_ficha_t, p_mostrar_foto boolean default false)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then raise exception 'persona no encontrada'; end if;
  if not (app.es_tutor_de(p_persona)
          or (app.es_yo(p_persona) and app.edad(p.fecha_nacimiento) >= 14)
          or app.tiene_permiso(p.escuela_id, 'escuela.administrar')) then
    raise exception 'sin permiso para gestionar la privacidad' using errcode = '42501';
  end if;
  update persona set visibilidad_ficha = p_visibilidad,
         mostrar_foto = p_mostrar_foto where id = p_persona;
end $$;

create or replace function public.leer_ficha(p_persona uuid, p_contexto text default null)
returns setof persona language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then return; end if;
  if not (app.tiene_permiso(p.escuela_id, 'escuela.administrar')
          or app.es_yo(p_persona) or app.es_tutor_de(p_persona) or app.entrena_a(p_persona)) then
    raise exception 'sin acceso a la ficha' using errcode = '42501';
  end if;
  if app.edad(p.fecha_nacimiento) < 18 then
    insert into registro_acceso_menores (persona_id, escuela_id, usuario_id, contexto)
    values (p.id, p.escuela_id, auth.uid(), p_contexto);
  end if;
  return next p;
end $$;

create or replace function app.notificar_organizacion(p_org uuid, p_titulo text, p_cuerpo text) returns void
language sql security definer set search_path = public, pg_temp as $$
  insert into notificacion (usuario_id, escuela_id, titulo, cuerpo)
  select distinct p.usuario_id, p_org, p_titulo, p_cuerpo
  from pertenencia p join rol_permiso rp on rp.rol = p.rol
  where p.escuela_id = p_org and rp.permiso = 'liga.gestionar'
$$;

-- Invitar: el rol viene del catálogo (text en vez de enum) y debe ser invitable
drop function public.invitar_usuario(uuid, text, rol_t, uuid);
create function public.invitar_usuario(
  p_escuela uuid, p_email text, p_rol text, p_persona uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(trim(p_email));
begin
  if not app.tiene_permiso(p_escuela, 'escuela.administrar') then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if not exists (select 1 from rol where codigo = p_rol and invitable) then
    raise exception 'rol no invitable';
  end if;
  if p_persona is not null and not exists (select 1 from persona where id = p_persona and escuela_id = p_escuela) then
    raise exception 'la persona no pertenece a la escuela';
  end if;
  insert into invitacion (escuela_id, email, rol, persona_id)
    values (p_escuela, mail, p_rol, p_persona) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;
revoke execute on function public.invitar_usuario(uuid, text, text, uuid) from public;
grant execute on function public.invitar_usuario(uuid, text, text, uuid) to authenticated;

-- ───────── Vistas para el cliente ─────────
create view v_mis_pertenencias as
  select p.id, p.escuela_id, s.nombre as escuela, p.rol
  from pertenencia p left join escuela s on s.id = p.escuela_id
  where p.usuario_id = auth.uid() and coalesce(s.es_ayuntamiento, false) = false;
grant select on v_mis_pertenencias to authenticated;

-- Permisos efectivos del usuario por escuela (escuela_id null = globales)
create view v_mis_permisos as
  select p.escuela_id, rp.permiso
  from pertenencia p join rol_permiso rp on rp.rol = p.rol
  where p.usuario_id = auth.uid();
grant select on v_mis_permisos to authenticated;

-- El enum antiguo ya no se usa
drop function app.tiene_rol(uuid, rol_t);
drop type rol_t;
