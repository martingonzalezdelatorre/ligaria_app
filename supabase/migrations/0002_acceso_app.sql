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
