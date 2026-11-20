-- =====================================================================
-- Formatos de competición: eliminatoria y grupos + playoff
-- · ELIMINATORIA: cuadro con byes (pase directo) si el nº de equipos no es potencia de 2.
--   Se genera la 1ª ronda; al terminar una ronda se crea la siguiente automáticamente.
-- · MIXTO: fase de grupos (liga dentro de cada grupo) y, después, un playoff con los N primeros
--   de cada grupo (mismo cuadro que la eliminatoria).
-- Un bye es un encuentro ya finalizado sin visitante (el equipo pasa a la siguiente ronda); las
-- vistas de calendario lo ocultan y v_byes_competicion lo lista.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden (esta usa la puntuación de competicion de la 0006).
do $$ begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'competicion' and column_name = 'puntos_victoria') then
    raise exception 'Falta la migración 0006 (gobierno de la liga). Aplica las migraciones en orden: 0001 … 0007.';
  end if;
end $$;

create type jornada_fase as enum ('LIGA', 'ELIMINATORIA');

alter table public.jornada
  add column fase   jornada_fase not null default 'LIGA',
  add column grupo  smallint,                -- grupo de la fase de liga (MIXTO); null si no hay grupos
  add column llaves smallint;                -- eliminatoria: emparejamientos de la ronda (incluye byes)
alter table public.jornada drop constraint jornada_categoria_id_numero_key;
create unique index uq_jornada on public.jornada (categoria_id, fase, coalesce(grupo, 0::smallint), numero);

alter table public.inscripcion add column grupo smallint;

alter table public.encuentro
  alter column visitante_inscripcion_id drop not null,
  add column llave smallint,                 -- eliminatoria: posición del emparejamiento en el cuadro
  add constraint encuentro_bye_finalizado check (visitante_inscripcion_id is not null or estado = 'FINALIZADO');

-- ───────── Clasificación: solo la fase de liga, por grupo ─────────
create or replace view public.clasificacion
with (security_invoker = true)
as
with resultados as (
  select e.id as encuentro_id, e.local_inscripcion_id as inscripcion_id,
         e.puntos_local as pf, e.puntos_visitante as pc
  from public.encuentro e
  join public.jornada j on j.id = e.jornada_id
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and j.fase = 'LIGA'
  union all
  select e.id, e.visitante_inscripcion_id, e.puntos_visitante, e.puntos_local
  from public.encuentro e
  join public.jornada j on j.id = e.jornada_id
  where e.estado in ('FINALIZADO', 'NO_PRESENTADO') and j.fase = 'LIGA'
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
         + count(*) filter (where r.pf < r.pc) * co.puntos_derrota as puntos,
       i.grupo
from public.inscripcion i
join public.categoria ca on ca.id = i.categoria_id
join public.competicion co on co.id = ca.competicion_id
left join resultados r on r.inscripcion_id = i.id
where i.estado = 'ACEPTADA'
group by i.categoria_id, i.id, i.equipo_id, co.puntos_victoria, co.puntos_empate, co.puntos_derrota, i.grupo;

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
  )
  select ca.competicion_id, c.categoria_id,
         (row_number() over (
            partition by c.categoria_id, c.grupo
            order by c.puntos desc, (c.favor - c.contra) desc,
                     coalesce(s.sf, 0) - coalesce(s.sc, 0) desc, coalesce(s.jf, 0) - coalesce(s.jc, 0) desc, eq.nombre))::int as posicion,
         c.equipo_id, eq.nombre as equipo, o.nombre as escuela,
         c.pj::int as pj, c.pg::int as pg, c.pe::int as pe, c.pp::int as pp, c.puntos::int as puntos,
         c.favor::int as partidos_f, c.contra::int as partidos_c,
         coalesce(s.sf, 0)::int as sets_f, coalesce(s.sc, 0)::int as sets_c,
         coalesce(s.jf, 0)::int as juegos_f, coalesce(s.jc, 0)::int as juegos_c,
         ca.nombre as categoria,
         c.grupo::int as grupo,
         c.inscripcion_id
  from public.clasificacion c
  join categoria ca on ca.id = c.categoria_id
  join equipo eq on eq.id = c.equipo_id
  join organizacion o on o.id = eq.organizacion_id
  left join sets s on s.inscripcion_id = c.inscripcion_id
  where app.ve_competicion(ca.competicion_id);

-- ───────── Calendario: fase, grupo y ronda; los byes no aparecen (visitante nulo) ─────────
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
         j.llaves::int as llaves
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion il on il.id = en.local_inscripcion_id
  join equipo el on el.id = il.equipo_id
  join inscripcion iv on iv.id = en.visitante_inscripcion_id
  join equipo ev on ev.id = iv.equipo_id
  where app.ve_competicion(ca.competicion_id);

-- Descansos de la fase de liga (por grupo): solo equipos del mismo grupo que la jornada.
create or replace view public.v_descansos_competicion as
  select ca.competicion_id, j.numero::int as jornada, e.id as equipo_id, e.nombre as equipo
  from jornada j
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.categoria_id = ca.id and i.estado = 'ACEPTADA'
                    and i.grupo is not distinct from j.grupo
  join equipo e on e.id = i.equipo_id
  where j.fase = 'LIGA'
    and app.ve_competicion(ca.competicion_id)
    and not exists (select 1 from encuentro en
                    where en.jornada_id = j.id and i.id in (en.local_inscripcion_id, en.visitante_inscripcion_id));

-- Equipos que pasan directamente de ronda en una eliminatoria (byes).
create view public.v_byes_competicion as
  select ca.competicion_id, ca.id as categoria_id, ca.nombre as categoria, j.numero::int as jornada,
         eq.id as equipo_id, eq.nombre as equipo
  from encuentro en
  join jornada j on j.id = en.jornada_id
  join categoria ca on ca.id = j.categoria_id
  join inscripcion i on i.id = en.local_inscripcion_id
  join equipo eq on eq.id = i.equipo_id
  where en.visitante_inscripcion_id is null and app.ve_competicion(ca.competicion_id);

create or replace view public.v_ligas as
  select c.id, c.nombre,
         case c.estado when 'INSCRIPCION_ABIERTA' then 'publicada' else lower(c.estado::text) end as estado,
         c.organizacion_id, c.deporte::text as deporte_id,
         case c.deporte when 'TENIS' then 'Tenis' else 'Pádel' end as deporte,
         c.tipo::text as tipo, c.fecha_inicio, c.fecha_fin, c.created_at,
         c.visibilidad::text as visibilidad,
         c.puntos_victoria::int as puntos_victoria, c.puntos_empate::int as puntos_empate,
         c.puntos_derrota::int as puntos_derrota,
         c.formato::text as formato
  from competicion c
  where app.ve_competicion(c.id);

-- ───────── crear_competicion con formato ─────────
drop function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint);
create function public.crear_competicion(
  p_organizacion uuid, p_nombre text, p_deporte deporte_tipo, p_tipo competicion_tipo,
  p_fecha_inicio date default null, p_fecha_fin date default null,
  p_visibilidad competicion_visibilidad default 'PUBLICA',
  p_puntos_victoria smallint default 3, p_puntos_empate smallint default 1, p_puntos_derrota smallint default 0,
  p_formato competicion_formato default 'LIGA')
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare cid uuid;
begin
  if not app.gestiona(p_organizacion) then
    raise exception 'sin permiso para crear competiciones en esta organización' using errcode = '42501';
  end if;
  if nullif(btrim(p_nombre), '') is null then raise exception 'falta el nombre de la competición'; end if;
  insert into competicion (organizacion_id, organizador_id, nombre, tipo, deporte, fecha_inicio, fecha_fin, visibilidad,
                           puntos_victoria, puntos_empate, puntos_derrota, formato)
    values (p_organizacion, auth.uid(), btrim(p_nombre), p_tipo, p_deporte, p_fecha_inicio, p_fecha_fin, p_visibilidad,
            p_puntos_victoria, p_puntos_empate, p_puntos_derrota, p_formato)
    returning id into cid;
  insert into categoria (competicion_id, nombre) values (cid, 'General');
  insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
    values (cid, p_organizacion, 'ACEPTADA');
  return cid;
end $$;

-- ───────── Helpers de calendario ─────────
-- Orden estándar de un cuadro de p plazas (potencia de 2): los emparejamientos son pares consecutivos
-- (1-p, 2-(p-1)…) y los cabezas de serie solo se cruzan al final.
create function app.semillas_llave(p int) returns int[]
language plpgsql immutable as $$
declare arr int[] := array[1]; tam int := 1; nuevo int[]; s int;
begin
  while tam < p loop
    nuevo := array[]::int[];
    foreach s in array arr loop
      nuevo := nuevo || s || (2 * tam + 1 - s);
    end loop;
    arr := nuevo; tam := tam * 2;
  end loop;
  return arr;
end $$;

-- Crea una ronda de eliminatoria con las plazas en pares consecutivos. Si una plaza del par es nula,
-- el otro equipo pasa directo (bye: encuentro finalizado sin visitante). Devuelve los encuentros reales.
create function app.crear_ronda_eliminatoria(
  p_cat uuid, p_numero int, p_plazas uuid[], p_fecha date, p_individuales int, p_dobles int)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare jid uuid; eid uuid; k int; i int; orden int; a uuid; b uuid; npares int; creados int := 0;
begin
  npares := array_length(p_plazas, 1) / 2;
  insert into jornada (categoria_id, numero, fecha, fase, llaves)
    values (p_cat, p_numero, p_fecha, 'ELIMINATORIA', npares) returning id into jid;
  for k in 1..npares loop
    a := p_plazas[2 * k - 1]; b := p_plazas[2 * k];
    if a is null and b is null then raise exception 'cuadro no válido'; end if;
    if a is null or b is null then
      insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id, estado,
                             puntos_local, puntos_visitante, llave)
        values (jid, coalesce(a, b), null, 'FINALIZADO', 1, 0, k);
    else
      insert into encuentro (jornada_id, local_inscripcion_id, visitante_inscripcion_id, llave)
        values (jid, a, b, k) returning id into eid;
      creados := creados + 1;
      orden := 0;
      for i in 1..p_individuales loop
        orden := orden + 1;
        insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'INDIVIDUAL');
      end loop;
      for i in 1..p_dobles loop
        orden := orden + 1;
        insert into partido (encuentro_id, orden, tipo) values (eid, orden, 'DOBLES');
      end loop;
    end if;
  end loop;
  return creados;
end $$;

-- Cuando todos los encuentros de la última ronda están jugados, crea la siguiente con los ganadores
-- (en orden de cuadro). Si solo queda un ganador, la eliminatoria ha terminado.
create function app.avanzar_ronda(p_cat uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare j jornada; ganadores uuid[]; ind int; dob int; ref uuid;
begin
  select * into j from jornada where categoria_id = p_cat and fase = 'ELIMINATORIA' order by numero desc limit 1;
  if j.id is null then return; end if;
  if exists (select 1 from encuentro where jornada_id = j.id and estado not in ('FINALIZADO', 'NO_PRESENTADO')) then
    return;
  end if;
  select array_agg(case when puntos_local > puntos_visitante then local_inscripcion_id else visitante_inscripcion_id end
                   order by llave)
    into ganadores from encuentro where jornada_id = j.id;
  if coalesce(array_length(ganadores, 1), 0) <= 1 then return; end if;
  select e.id into ref from encuentro e join jornada jj on jj.id = e.jornada_id
   where jj.categoria_id = p_cat and jj.fase = 'ELIMINATORIA' and e.visitante_inscripcion_id is not null limit 1;
  select count(*) filter (where tipo = 'INDIVIDUAL'), count(*) filter (where tipo = 'DOBLES')
    into ind, dob from partido where encuentro_id = ref;
  perform app.crear_ronda_eliminatoria(p_cat, j.numero + 1, ganadores,
    case when j.fecha is null then null else j.fecha + 7 end, coalesce(ind, 2), coalesce(dob, 1));
end $$;

-- Liga todos contra todos de un grupo (método del círculo; con número impar, descansa uno cada jornada).
-- Es el bucle de generar_calendario (0002) extraído para poder repetirlo por grupo.
create function app.generar_liga_grupo(
  p_cat uuid, p_grupo smallint, p_equipos uuid[], p_fecha_inicio date, p_dias int, p_vueltas int,
  p_individuales int, p_dobles int)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  t uuid[]; m int; n int; r int; i int; k int; v int;
  pos uuid[]; a uuid; b uuid; tmp uuid; bal jsonb := '{}'::jsonb; orient jsonb := '{}'::jsonb;
  clave text; ba int; bb int; jid uuid; eid uuid; num int := 0; creados int := 0; orden int;
begin
  n := coalesce(array_length(p_equipos, 1), 0);
  if n < 2 then return 0; end if;
  t := p_equipos;
  if n % 2 = 1 then t := t || array[null::uuid]; end if;
  m := array_length(t, 1);

  for v in 1..p_vueltas loop
    for r in 0..m - 2 loop
      num := num + 1;
      insert into jornada (categoria_id, numero, fecha, grupo)
        values (p_cat, num, case when p_fecha_inicio is null then null
                                 else p_fecha_inicio + (num - 1) * p_dias end, p_grupo)
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
  return creados;
end $$;

-- ───────── generar_calendario: grupos en formato MIXTO ─────────
drop function public.generar_calendario(uuid, date, int, int, int, int);
create function public.generar_calendario(
  p_competicion uuid, p_fecha_inicio date default null, p_dias_entre_jornadas int default 7,
  p_vueltas int default 1, p_individuales int default 2, p_dobles int default 1, p_grupos int default 2)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; g int; i int; creados int := 0; alguna boolean := false;
  ronda int; posg int; grupo_i int; del_grupo uuid[];
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el calendario' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato = 'ELIMINATORIA' then
    raise exception 'la competición es de eliminatoria: genera el cuadro' using errcode = '23514';
  end if;
  if p_vueltas not in (1, 2) then raise exception 'vueltas debe ser 1 o 2'; end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if p_grupos < 2 or p_grupos > 8 then raise exception 'el número de grupos debe estar entre 2 y 8'; end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and e.estado <> 'PROGRAMADO' and e.visitante_inscripcion_id is not null) then
    raise exception 'ya hay resultados registrados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    select array_agg(id order by fecha, id) into equipos
      from inscripcion where categoria_id = cat.id and estado = 'ACEPTADA';
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id;   -- cascada: encuentros y partidos
    if c.formato = 'MIXTO' then
      -- Reparto «serpiente» por orden de inscripción; cada grupo con al menos 2 equipos.
      g := greatest(least(p_grupos, n / 2), 1);
      for i in 0..n - 1 loop
        ronda := i / g; posg := i % g;
        grupo_i := case when ronda % 2 = 0 then posg + 1 else g - posg end;
        update inscripcion set grupo = grupo_i where id = equipos[i + 1];
      end loop;
      for grupo_i in 1..g loop
        creados := creados + app.generar_liga_grupo(
          cat.id, grupo_i::smallint,
          (select array_agg(id order by fecha, id) from inscripcion
            where categoria_id = cat.id and estado = 'ACEPTADA' and grupo = grupo_i),
          p_fecha_inicio, p_dias_entre_jornadas, p_vueltas, p_individuales, p_dobles);
      end loop;
    else
      update inscripcion set grupo = null where categoria_id = cat.id;
      creados := creados + app.generar_liga_grupo(
        cat.id, null, equipos, p_fecha_inicio, p_dias_entre_jornadas, p_vueltas, p_individuales, p_dobles);
    end if;
  end loop;

  if not alguna then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;
  update competicion set estado = 'EN_CURSO' where id = c.id and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  return creados;
end $$;

-- ───────── Eliminatoria ─────────
create function public.generar_eliminatoria(
  p_competicion uuid, p_fecha_inicio date default null, p_individuales int default 2, p_dobles int default 1)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; p int; orden int[]; plazas uuid[]; i int;
  creados int := 0; alguna boolean := false;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el cuadro' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato <> 'ELIMINATORIA' then
    raise exception 'la competición no es de eliminatoria' using errcode = '23514';
  end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and e.estado <> 'PROGRAMADO' and e.visitante_inscripcion_id is not null) then
    raise exception 'ya hay resultados registrados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    -- cabezas de serie por orden de inscripción
    select array_agg(id order by fecha, id) into equipos
      from inscripcion where categoria_id = cat.id and estado = 'ACEPTADA';
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id;
    update inscripcion set grupo = null where categoria_id = cat.id;
    p := 1;
    while p < n loop p := p * 2; end loop;
    orden := app.semillas_llave(p);
    plazas := array[]::uuid[];
    for i in 1..p loop
      plazas := plazas || (case when orden[i] <= n then equipos[orden[i]] end);
    end loop;
    creados := creados + app.crear_ronda_eliminatoria(cat.id, 1, plazas, p_fecha_inicio, p_individuales, p_dobles);
  end loop;

  if not alguna then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;
  update competicion set estado = 'EN_CURSO' where id = c.id and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  return creados;
end $$;

-- ───────── Playoff de un formato MIXTO ─────────
-- Con la fase de grupos terminada, los p_clasifican primeros de cada grupo juegan un cuadro.
-- Los cabezas de serie se ordenan por posición en su grupo y, dentro de la misma posición, por grupo:
-- así el 1º del grupo A cae contra el 2º del B (con un número par de grupos no se repite cruce de grupo
-- en la primera ronda; con un número impar puede darse algún cruce entre equipos del mismo grupo).
create function public.generar_playoff(
  p_competicion uuid, p_clasifican int default 2, p_fecha_inicio date default null,
  p_individuales int default 2, p_dobles int default 1)
returns int language plpgsql security definer set search_path = public, pg_temp as $$
declare
  c competicion; cat categoria; equipos uuid[]; n int; p int; orden int[]; plazas uuid[]; i int;
  creados int := 0; alguna boolean := false;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona_comp(c.id) then
    raise exception 'sin permiso para generar el playoff' using errcode = '42501';
  end if;
  if c.estado in ('FINALIZADA', 'CANCELADA') then
    raise exception 'la competición ya no admite cambios' using errcode = '23514';
  end if;
  if c.formato <> 'MIXTO' then
    raise exception 'la competición no tiene fase de grupos' using errcode = '23514';
  end if;
  if p_clasifican < 1 or p_clasifican > 8 then raise exception 'clasifican entre 1 y 8 equipos por grupo'; end if;
  if p_individuales < 0 or p_dobles < 0 or p_individuales + p_dobles < 1 then
    raise exception 'el encuentro necesita al menos un partido';
  end if;
  if not exists (select 1 from encuentro e
                 join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
                 where ca.competicion_id = c.id and j.fase = 'LIGA') then
    raise exception 'primero hay que generar el calendario de la fase de grupos' using errcode = '23514';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and j.fase = 'LIGA' and e.estado not in ('FINALIZADO', 'NO_PRESENTADO')) then
    raise exception 'la fase de grupos no ha terminado' using errcode = '23514';
  end if;
  if exists (select 1 from encuentro e
             join jornada j on j.id = e.jornada_id join categoria ca on ca.id = j.categoria_id
             where ca.competicion_id = c.id and j.fase = 'ELIMINATORIA'
               and e.visitante_inscripcion_id is not null and e.estado <> 'PROGRAMADO') then
    raise exception 'el playoff ya tiene resultados; no se puede regenerar' using errcode = '23514';
  end if;

  for cat in select * from categoria where competicion_id = c.id order by nombre loop
    select array_agg(x.insc order by x.posicion, x.grupo, x.equipo) into equipos from (
      select cl.inscripcion_id as insc, cl.posicion, cl.grupo, cl.equipo
        from v_clasificacion_competicion cl
       where cl.categoria_id = cat.id and cl.posicion <= p_clasifican) x;
    n := coalesce(array_length(equipos, 1), 0);
    if n < 2 then continue; end if;
    alguna := true;

    delete from jornada where categoria_id = cat.id and fase = 'ELIMINATORIA';
    p := 1;
    while p < n loop p := p * 2; end loop;
    orden := app.semillas_llave(p);
    plazas := array[]::uuid[];
    for i in 1..p loop
      plazas := plazas || (case when orden[i] <= n then equipos[orden[i]] end);
    end loop;
    creados := creados + app.crear_ronda_eliminatoria(cat.id, 1, plazas, p_fecha_inicio, p_individuales, p_dobles);
  end loop;

  if not alguna then raise exception 'no hay equipos suficientes para el playoff'; end if;
  return creados;
end $$;

-- ───────── registrar_resultado: eliminatoria (sin empates, avance de ronda) ─────────
create or replace function public.registrar_resultado(p_encuentro uuid, p_resultado jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  e encuentro; e2 encuentro; j jornada; comp uuid; eq_l uuid; eq_v uuid; est competicion_estado;
  fmt competicion_formato; previo uuid; nuevo uuid;
begin
  select * into e from encuentro where id = p_encuentro for update;
  if not found then raise exception 'encuentro no encontrado'; end if;
  if e.visitante_inscripcion_id is null then
    raise exception 'el encuentro es un pase directo del cuadro: no tiene resultado' using errcode = '23514';
  end if;
  comp := app.comp_de_encuentro(e.id);
  select equipo_id into eq_l from inscripcion where id = e.local_inscripcion_id;
  select equipo_id into eq_v from inscripcion where id = e.visitante_inscripcion_id;
  if not (app.gestiona_comp(comp) or app.entrena_equipo(eq_l) or app.entrena_equipo(eq_v)) then
    raise exception 'sin permiso para registrar el resultado' using errcode = '42501';
  end if;
  select estado, formato into est, fmt from competicion where id = comp;
  if est = 'CANCELADA' then raise exception 'la competición está cancelada' using errcode = '23514'; end if;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') and not app.gestiona_comp(comp) then
    raise exception 'el resultado ya está registrado; solicita una corrección a la organización' using errcode = '23514';
  end if;
  select * into j from jornada where id = e.jornada_id;
  if e.estado in ('FINALIZADO', 'NO_PRESENTADO') then
    previo := case when e.puntos_local > e.puntos_visitante then e.local_inscripcion_id else e.visitante_inscripcion_id end;
  end if;

  perform app.escribir_resultado(p_encuentro, p_resultado);

  if j.fase = 'ELIMINATORIA' then
    select * into e2 from encuentro where id = e.id;
    if e2.puntos_local = e2.puntos_visitante then
      raise exception 'en eliminatoria no puede haber empate: se necesita un ganador' using errcode = '23514';
    end if;
    nuevo := case when e2.puntos_local > e2.puntos_visitante then e2.local_inscripcion_id else e2.visitante_inscripcion_id end;
    if previo is not null and previo <> nuevo and exists (
         select 1 from jornada jn where jn.categoria_id = j.categoria_id and jn.fase = 'ELIMINATORIA' and jn.numero > j.numero) then
      raise exception 'la siguiente ronda ya está generada: no se puede cambiar el ganador' using errcode = '23514';
    end if;
    perform app.avanzar_ronda(j.categoria_id);
  end if;

  update competicion set estado = 'EN_CURSO' where id = comp and estado in ('BORRADOR', 'INSCRIPCION_ABIERTA');
  -- cierre automático: todo jugado y, en un MIXTO, con el playoff ya generado
  if not exists (select 1 from encuentro x
                 join jornada jo on jo.id = x.jornada_id join categoria ca on ca.id = jo.categoria_id
                 where ca.competicion_id = comp and x.estado not in ('FINALIZADO', 'NO_PRESENTADO'))
     and (fmt <> 'MIXTO' or exists (select 1 from jornada jp join categoria cp on cp.id = jp.categoria_id
                                    where cp.competicion_id = comp and jp.fase = 'ELIMINATORIA')) then
    update competicion set estado = 'FINALIZADA' where id = comp and estado = 'EN_CURSO';
  end if;
end $$;

-- ───────── Permisos ─────────
revoke execute on function app.semillas_llave(int) from public;
revoke execute on function app.crear_ronda_eliminatoria(uuid, int, uuid[], date, int, int) from public;
revoke execute on function app.avanzar_ronda(uuid) from public;
revoke execute on function app.generar_liga_grupo(uuid, smallint, uuid[], date, int, int, int, int) from public;
revoke execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint, competicion_formato) from public;
revoke execute on function public.generar_calendario(uuid, date, int, int, int, int, int) from public;
revoke execute on function public.generar_eliminatoria(uuid, date, int, int) from public;
revoke execute on function public.generar_playoff(uuid, int, date, int, int) from public;
grant execute on function public.crear_competicion(uuid, text, deporte_tipo, competicion_tipo, date, date, competicion_visibilidad, smallint, smallint, smallint, competicion_formato) to authenticated;
grant execute on function public.generar_calendario(uuid, date, int, int, int, int, int) to authenticated;
grant execute on function public.generar_eliminatoria(uuid, date, int, int) to authenticated;
grant execute on function public.generar_playoff(uuid, int, date, int, int) to authenticated;
grant select on public.v_byes_competicion to authenticated;
