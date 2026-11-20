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
