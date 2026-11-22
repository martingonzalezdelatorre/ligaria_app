-- =====================================================================
-- Ligaria Friends - El ranking solo cuenta partidos con resultado CONFIRMADO.
-- Un resultado está confirmado cuando han confirmado todos sus jugadores
-- (misma regla que v_confirmaciones: confirmados >= total y total > 0).
-- Afecta a ranking_global, ranking_provincia, ranking_localidad (vía app.ranking_de)
-- y a ranking_grupo. Los partidos JUGADO sin confirmar dejan de puntuar hasta que se confirmen.
-- =====================================================================

create function app.amistoso_confirmado(p_amistoso uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((select count(*) from public.amistoso_jugador j where j.amistoso_id = p_amistoso), 0) > 0
     and (select count(*) from public.resultado_confirmacion c where c.amistoso_id = p_amistoso)
         >= (select count(*) from public.amistoso_jugador j where j.amistoso_id = p_amistoso)
$$;

create function app.partido_confirmado(p_partido uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select (select count(*) from public.participante_jugador pj
           join public.partido p on pj.participante_id in (p.local_id, p.visitante_id)
          where p.id = p_partido) > 0
     and (select count(*) from public.resultado_confirmacion c where c.partido_id = p_partido)
         >= (select count(*) from public.participante_jugador pj
              join public.partido p on pj.participante_id in (p.local_id, p.visitante_id)
             where p.id = p_partido)
$$;
revoke execute on function app.amistoso_confirmado(uuid), app.partido_confirmado(uuid)
  from public, anon, authenticated;

-- Núcleo común (global / provincia / localidad).
create or replace function app.ranking_de(p_usuarios uuid[], p_limite int default 100)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language sql stable security definer set search_path = '' as $$
  with resultados as (
    select aj.usuario_id, (aj.lado = a.ganador) as gano
    from public.amistoso a
    join public.amistoso_jugador aj on aj.amistoso_id = a.id
    where a.estado = 'JUGADO' and a.ganador is not null and app.amistoso_confirmado(a.id)
    union all
    select pj.usuario_id,
           ((p.ganador = 'LOCAL' and pj.participante_id = p.local_id)
            or (p.ganador = 'VISITANTE' and pj.participante_id = p.visitante_id))
    from public.partido p
    join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
    where p.estado = 'JUGADO' and p.ganador is not null and app.partido_confirmado(p.id)
  ),
  totales as (
    select r.usuario_id,
           count(*)                     as jugados,
           count(*) filter (where gano) as ganados
    from resultados r
    group by r.usuario_id
  )
  select pf.id,
         coalesce(nullif(btrim(pf.apodo), ''),
                  nullif(btrim(coalesce(pf.nombre, '') || ' ' || coalesce(pf.apellidos, '')), ''),
                  'Jugador') as nombre,
         coalesce(t.jugados, 0)::bigint,
         coalesce(t.ganados, 0)::bigint,
         coalesce(t.ganados, 0) * 10,
         case when coalesce(t.jugados, 0) = 0 then 0::numeric
              else round(t.ganados::numeric / t.jugados, 4) end
  from public.perfil pf
  left join totales t on t.usuario_id = pf.id
  where pf.id = any (p_usuarios)
  order by 5 desc, 6 desc, 3 desc, 2
  limit greatest(coalesce(p_limite, 100), 1)
$$;

-- De grupo.
create or replace function public.ranking_grupo(p_grupo uuid)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not app.es_miembro(p_grupo) then
    raise exception 'No perteneces a este grupo.' using errcode = '42501';
  end if;
  return query
  with resultados as (
    select aj.usuario_id, (aj.lado = a.ganador) as gano
    from public.amistoso a
    join public.amistoso_jugador aj on aj.amistoso_id = a.id
    where a.grupo_id = p_grupo and a.estado = 'JUGADO' and a.ganador is not null
      and app.amistoso_confirmado(a.id)
    union all
    select pj.usuario_id,
           ((p.ganador = 'LOCAL' and pj.participante_id = p.local_id)
            or (p.ganador = 'VISITANTE' and pj.participante_id = p.visitante_id))
    from public.partido p
    join public.liga l on l.id = p.liga_id and l.grupo_id = p_grupo
    join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
    where p.estado = 'JUGADO' and p.ganador is not null and app.partido_confirmado(p.id)
  ),
  totales as (
    select r.usuario_id,
           count(*)                     as jugados,
           count(*) filter (where gano) as ganados
    from resultados r
    group by r.usuario_id
  )
  select m.usuario_id,
         coalesce(nullif(btrim(pf.apodo), ''), nullif(btrim(pf.nombre), ''), 'Jugador'),
         coalesce(t.jugados, 0)::bigint,
         coalesce(t.ganados, 0)::bigint,
         coalesce(t.ganados, 0) * 10,
         case when coalesce(t.jugados, 0) = 0 then 0
              else round(t.ganados::numeric / t.jugados, 4) end
  from public.grupo_miembro m
  join public.perfil pf on pf.id = m.usuario_id
  left join totales t on t.usuario_id = m.usuario_id
  where m.grupo_id = p_grupo
  order by 5 desc, 6 desc, 3 desc, 2;
end;
$$;
