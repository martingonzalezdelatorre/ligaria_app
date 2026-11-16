-- =====================================================================
-- Ligaria Friends - Ranking global.
-- Puntos = 10 por partido ganado. Porcentaje (puntaje) = ganados / jugados (0..1).
-- Se calcula sobre todos los partidos con resultado (JUGADO) de cada jugador:
-- amistosos y partidos de liga. Orden: puntos, porcentaje y partidos jugados.
-- Se expone por RPC security definer porque la RLS solo deja ver partidos del propio grupo;
-- solo devuelve nombre público y totales, nunca emails ni partidos concretos.
-- =====================================================================

create function public.ranking_global(p_limite int default 100)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language sql stable security definer set search_path = '' as $$
  with resultados as (
    select aj.usuario_id, (aj.lado = a.ganador) as gano
    from public.amistoso a
    join public.amistoso_jugador aj on aj.amistoso_id = a.id
    where a.estado = 'JUGADO' and a.ganador is not null
    union all
    select pj.usuario_id,
           ((p.ganador = 'LOCAL' and pj.participante_id = p.local_id)
            or (p.ganador = 'VISITANTE' and pj.participante_id = p.visitante_id))
    from public.partido p
    join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
    where p.estado = 'JUGADO' and p.ganador is not null
  ),
  totales as (
    select r.usuario_id,
           count(*)                    as jugados,
           count(*) filter (where gano) as ganados
    from resultados r
    group by r.usuario_id
  )
  select t.usuario_id,
         coalesce(nullif(btrim(pf.apodo), ''), nullif(btrim(pf.nombre), ''), 'Jugador') as nombre,
         t.jugados,
         t.ganados,
         t.ganados * 10 as puntos,
         round(t.ganados::numeric / t.jugados, 4) as puntaje
  from totales t
  join public.perfil pf on pf.id = t.usuario_id
  where (select auth.uid()) is not null
  order by puntos desc, puntaje desc, t.jugados desc, nombre
  limit greatest(coalesce(p_limite, 100), 1)
$$;
revoke execute on function public.ranking_global(int) from public, anon;
grant execute on function public.ranking_global(int) to authenticated;
