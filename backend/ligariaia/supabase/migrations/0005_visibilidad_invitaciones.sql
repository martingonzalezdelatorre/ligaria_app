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
