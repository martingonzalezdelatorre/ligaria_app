-- =====================================================================
-- Dos rankings:
--  * Global de la app: solo entran los jugadores que se unen (perfil.ranking_global).
--  * De grupo: todos los miembros del grupo, visible solo para sus miembros.
-- Puntos = 10 por partido ganado; porcentaje = ganados / jugados.
-- =====================================================================

-- Ajuste de cuenta: «Unirme al ranking global». Por defecto NO (opt-in).
alter table public.perfil add column if not exists ranking_global boolean not null default false;
grant update (ranking_global) on public.perfil to authenticated;

-- Global: solo perfiles que se han unido.
-- Se borra antes porque create or replace no permite cambiar las columnas de salida
-- si la función existente las tenía distintas.
drop function if exists public.ranking_global(int);
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
           count(*)                     as jugados,
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
  where (select auth.uid()) is not null and pf.ranking_global
  order by puntos desc, puntaje desc, t.jugados desc, nombre
  limit greatest(coalesce(p_limite, 100), 1)
$$;

revoke execute on function public.ranking_global(int) from public, anon;
grant execute on function public.ranking_global(int) to authenticated;

-- De grupo: amistosos y partidos de liga de ese grupo; aparecen todos los miembros.
create function public.ranking_grupo(p_grupo uuid)
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
    union all
    select pj.usuario_id,
           ((p.ganador = 'LOCAL' and pj.participante_id = p.local_id)
            or (p.ganador = 'VISITANTE' and pj.participante_id = p.visitante_id))
    from public.partido p
    join public.liga l on l.id = p.liga_id and l.grupo_id = p_grupo
    join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
    where p.estado = 'JUGADO' and p.ganador is not null
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
revoke execute on function public.ranking_grupo(uuid) from public, anon;
grant execute on function public.ranking_grupo(uuid) to authenticated;
