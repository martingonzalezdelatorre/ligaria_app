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
