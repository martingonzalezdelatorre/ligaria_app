-- =====================================================================
-- Gestión de la liga: programación de partidos, desempates configurables y cierre
-- · encuentro.sede / encuentro.pista: texto libre (la organización escribe «Polideportivo Norte», «Pista 3»).
-- · programar_encuentro: fecha y hora, sede y pista. cambiar_estado_encuentro: aplazado / suspendido / programado.
--   (La incomparecencia sigue registrándose con registrar_resultado.)
-- · competicion.desempate: orden de los criterios de desempate cuando hay igualdad a puntos.
--   Criterios: ENFRENTAMIENTO (puntos en los partidos entre los empatados), DIF_PARTIDOS, DIF_SETS, DIF_JUEGOS.
-- · finalizar_competicion / reabrir_competicion: cierre manual de la liga.
-- Requisito: las migraciones se aplican en orden.
-- =====================================================================
alter table public.encuentro add column sede text, add column pista text;
alter table public.competicion add column desempate text not null default 'DIF_PARTIDOS,DIF_SETS,DIF_JUEGOS';

-- ───────── Vistas: sede/pista en el calendario y desempate en la liga ─────────
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
         en.llave::int as llave,
         en.sede, en.pista
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

create or replace view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at,
         c.visibilidad::text as visibilidad,
         c.puntos_victoria::int as puntos_victoria, c.puntos_empate::int as puntos_empate,
         c.puntos_derrota::int as puntos_derrota,
         c.formato::text as formato,
         c.desempate
  from competicion c
  where app.ve_competicion(c.id);

-- ───────── Clasificación con desempates configurables ─────────
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
  ), duelos as (   -- cada encuentro de liga jugado, visto desde cada lado, con sus puntos de clasificación
    select e.local_inscripcion_id as insc, e.visitante_inscripcion_id as rival,
           case when e.puntos_local > e.puntos_visitante then co.puntos_victoria
                when e.puntos_local = e.puntos_visitante then co.puntos_empate else co.puntos_derrota end as pts
    from encuentro e
    join jornada jo on jo.id = e.jornada_id and jo.fase = 'LIGA'
    join categoria ca on ca.id = jo.categoria_id
    join competicion co on co.id = ca.competicion_id
    where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and e.visitante_inscripcion_id is not null
    union all
    select e.visitante_inscripcion_id, e.local_inscripcion_id,
           case when e.puntos_visitante > e.puntos_local then co.puntos_victoria
                when e.puntos_visitante = e.puntos_local then co.puntos_empate else co.puntos_derrota end
    from encuentro e
    join jornada jo on jo.id = e.jornada_id and jo.fase = 'LIGA'
    join categoria ca on ca.id = jo.categoria_id
    join competicion co on co.id = ca.competicion_id
    where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and e.visitante_inscripcion_id is not null
  ), base as (
    select ca.competicion_id, c.categoria_id, c.equipo_id, eq.nombre as equipo, o.nombre as escuela,
           c.pj::int as pj, c.pg::int as pg, c.pe::int as pe, c.pp::int as pp, c.puntos::int as puntos,
           c.favor::int as partidos_f, c.contra::int as partidos_c,
           coalesce(s.sf, 0)::int as sets_f, coalesce(s.sc, 0)::int as sets_c,
           coalesce(s.jf, 0)::int as juegos_f, coalesce(s.jc, 0)::int as juegos_c,
           ca.nombre as categoria, c.grupo::int as grupo, c.inscripcion_id, co.desempate,
           -- puntos obtenidos contra los equipos que tienen los mismos puntos totales (mini-liga entre empatados)
           coalesce((select sum(d.pts) from duelos d
                     join public.clasificacion c2 on c2.inscripcion_id = d.rival and c2.puntos = c.puntos
                     where d.insc = c.inscripcion_id), 0)::int as enfrentamiento
    from public.clasificacion c
    join categoria ca on ca.id = c.categoria_id
    join competicion co on co.id = ca.competicion_id
    join equipo eq on eq.id = c.equipo_id
    join organizacion o on o.id = eq.organizacion_id
    left join sets s on s.inscripcion_id = c.inscripcion_id
    where app.ve_competicion(ca.competicion_id)
  ), claves as (
    select b.*, k.n, case split_part(b.desempate, ',', k.n)
                       when 'ENFRENTAMIENTO' then b.enfrentamiento
                       when 'DIF_PARTIDOS' then b.partidos_f - b.partidos_c
                       when 'DIF_SETS' then b.sets_f - b.sets_c
                       when 'DIF_JUEGOS' then b.juegos_f - b.juegos_c
                       else 0 end as clave
    from base b cross join generate_series(1, 4) as k(n)
  ), planas as (
    select competicion_id, categoria_id, equipo_id, equipo, escuela, pj, pg, pe, pp, puntos, partidos_f, partidos_c,
           sets_f, sets_c, juegos_f, juegos_c, categoria, grupo, inscripcion_id,
           max(clave) filter (where n = 1) as k1, max(clave) filter (where n = 2) as k2,
           max(clave) filter (where n = 3) as k3, max(clave) filter (where n = 4) as k4
    from claves
    group by competicion_id, categoria_id, equipo_id, equipo, escuela, pj, pg, pe, pp, puntos, partidos_f, partidos_c,
             sets_f, sets_c, juegos_f, juegos_c, categoria, grupo, inscripcion_id
  )
  select competicion_id, categoria_id,
         (row_number() over (partition by categoria_id, grupo
                             order by puntos desc, k1 desc, k2 desc, k3 desc, k4 desc, equipo))::int as posicion,
         equipo_id, equipo, escuela, pj, pg, pe, pp, puntos, partidos_f, partidos_c,
         sets_f, sets_c, juegos_f, juegos_c, categoria, grupo, inscripcion_id
  from planas;

-- ───────── Programación de partidos ─────────
create or replace function app.encuentro_editable(p_encuentro uuid) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare e encuentro; comp uuid; est competicion_estado;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado' using errcode = '23514'; end if;
  comp := app.comp_de_encuentro(e.id);
  if not app.gestiona_comp(comp) then
    raise exception 'sin permiso para programar los partidos de esta liga' using errcode = '42501';
  end if;
  if e.visitante_inscripcion_id is null then
    raise exception 'el pase directo del cuadro no se programa' using errcode = '23514';
  end if;
  select estado into est from competicion where id = comp;
  if est in ('CANCELADA', 'FINALIZADA') then
    raise exception 'la liga está cerrada: no se puede programar' using errcode = '23514';
  end if;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') then
    raise exception 'el partido ya se ha jugado' using errcode = '23514';
  end if;
  return comp;
end $$;
revoke execute on function app.encuentro_editable(uuid) from public, anon, authenticated;

-- Fecha y hora, sede y pista de un partido (todo opcional: null borra el dato).
create or replace function public.programar_encuentro(
  p_encuentro uuid, p_fecha_hora timestamptz, p_sede text default null, p_pista text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform app.encuentro_editable(p_encuentro);
  update encuentro set fecha_hora = p_fecha_hora,
         sede = left(nullif(btrim(coalesce(p_sede, '')), ''), 120),
         pista = left(nullif(btrim(coalesce(p_pista, '')), ''), 60)
   where id = p_encuentro;
end $$;

-- Marca un partido pendiente como PROGRAMADO, APLAZADO o SUSPENDIDO.
create or replace function public.cambiar_estado_encuentro(p_encuentro uuid, p_estado encuentro_estado)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if p_estado not in ('PROGRAMADO', 'APLAZADO', 'SUSPENDIDO') then
    raise exception 'estado no permitido: el resultado se registra con registrar_resultado' using errcode = '23514';
  end if;
  perform app.encuentro_editable(p_encuentro);
  update encuentro set estado = p_estado where id = p_encuentro;
end $$;

-- ───────── Desempates ─────────
-- p_orden: criterios separados por comas, p. ej. 'ENFRENTAMIENTO,DIF_SETS,DIF_JUEGOS' (sin repetir, máx. 4).
create or replace function public.fijar_desempate(p_competicion uuid, p_orden text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare partes text[]; x text;
begin
  if not app.gestiona_comp(p_competicion) then
    raise exception 'sin permiso para cambiar los desempates' using errcode = '42501';
  end if;
  partes := string_to_array(btrim(coalesce(p_orden, '')), ',');
  if array_length(partes, 1) is null or array_length(partes, 1) > 4 then
    raise exception 'indica entre 1 y 4 criterios de desempate' using errcode = '23514';
  end if;
  foreach x in array partes loop
    if x not in ('ENFRENTAMIENTO', 'DIF_PARTIDOS', 'DIF_SETS', 'DIF_JUEGOS') then
      raise exception 'criterio de desempate no válido: %', x using errcode = '23514';
    end if;
  end loop;
  if (select count(distinct v) from unnest(partes) v) <> array_length(partes, 1) then
    raise exception 'los criterios de desempate no pueden repetirse' using errcode = '23514';
  end if;
  update competicion set desempate = array_to_string(partes, ',') where id = p_competicion;
end $$;

-- ───────── Cierre de la liga ─────────
create or replace function public.finalizar_competicion(p_competicion uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare est competicion_estado;
begin
  if not app.gestiona_comp(p_competicion) then
    raise exception 'sin permiso para finalizar esta liga' using errcode = '42501';
  end if;
  select estado into est from competicion where id = p_competicion;
  if est <> 'EN_CURSO' then
    raise exception 'solo se puede finalizar una liga en curso' using errcode = '23514';
  end if;
  update competicion set estado = 'FINALIZADA' where id = p_competicion;
end $$;

create or replace function public.reabrir_competicion(p_competicion uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare est competicion_estado;
begin
  if not app.gestiona_comp(p_competicion) then
    raise exception 'sin permiso para reabrir esta liga' using errcode = '42501';
  end if;
  select estado into est from competicion where id = p_competicion;
  if est <> 'FINALIZADA' then
    raise exception 'solo se puede reabrir una liga finalizada' using errcode = '23514';
  end if;
  update competicion set estado = 'EN_CURSO' where id = p_competicion;
end $$;

revoke execute on function public.programar_encuentro(uuid, timestamptz, text, text) from public, anon;
revoke execute on function public.cambiar_estado_encuentro(uuid, encuentro_estado) from public, anon;
revoke execute on function public.fijar_desempate(uuid, text) from public, anon;
revoke execute on function public.finalizar_competicion(uuid) from public, anon;
revoke execute on function public.reabrir_competicion(uuid) from public, anon;
grant execute on function public.programar_encuentro(uuid, timestamptz, text, text) to authenticated;
grant execute on function public.cambiar_estado_encuentro(uuid, encuentro_estado) to authenticated;
grant execute on function public.fijar_desempate(uuid, text) to authenticated;
grant execute on function public.finalizar_competicion(uuid) to authenticated;
grant execute on function public.reabrir_competicion(uuid) to authenticated;
