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
