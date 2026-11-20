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
