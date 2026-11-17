-- =====================================================================
-- Ajustes de cuenta: datos personales, ubicación, ranking por provincia / localidad
-- y un interruptor general de notificaciones.
-- El email no se toca: es el usuario registrado (auth.users) y no está en el GRANT de UPDATE.
-- =====================================================================

alter table public.perfil
  add column if not exists apellidos          text check (apellidos is null or char_length(apellidos) <= 80),
  add column if not exists localidad          text check (localidad is null or char_length(localidad) <= 80),
  add column if not exists provincia          text check (provincia is null or char_length(provincia) <= 80),
  add column if not exists ranking_provincia  boolean not null default false,
  add column if not exists ranking_localidad  boolean not null default false,
  add column if not exists notificaciones     boolean not null default true;

grant update (apellidos, localidad, provincia, ranking_provincia, ranking_localidad, notificaciones)
  on public.perfil to authenticated;

-- ---------------------------------------------------------------------
-- Notificaciones: si el usuario las ha desactivado no se crea nada (ni app ni email).
-- ---------------------------------------------------------------------
create or replace function app.notificar(
  p_usuario uuid, p_tipo text, p_titulo text, p_cuerpo text default '',
  p_datos jsonb default '{}'::jsonb, p_autor uuid default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_app boolean := true;
  v_email boolean := true;
begin
  if p_usuario is null or p_usuario is not distinct from p_autor then return; end if;
  if not coalesce((select pf.notificaciones from public.perfil pf where pf.id = p_usuario), true) then
    return;
  end if;
  select pr.app, pr.email into v_app, v_email
    from public.notificacion_preferencia pr
    where pr.usuario_id = p_usuario and pr.tipo = p_tipo;
  v_app := coalesce(v_app, true);
  v_email := coalesce(v_email, true);
  if not v_app and not v_email then return; end if;
  insert into public.notificacion (usuario_id, tipo, titulo, cuerpo, datos, email_estado,
                                   leida_at)
  values (p_usuario, p_tipo, p_titulo, coalesce(p_cuerpo, ''), coalesce(p_datos, '{}'::jsonb),
          case when v_email then 'pendiente' else 'omitido' end,
          case when v_app then null else now() end);
end;
$$;

-- ---------------------------------------------------------------------
-- Rankings. Núcleo común: clasifica a una lista de usuarios (aparecen aunque tengan 0 partidos).
-- Puntos = 10 por victoria; porcentaje = ganados / jugados.
-- ---------------------------------------------------------------------
create function app.ranking_de(p_usuarios uuid[], p_limite int default 100)
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
revoke execute on function app.ranking_de(uuid[], int) from public, anon, authenticated;

drop function if exists public.ranking_global(int);
create function public.ranking_global(p_limite int default 100)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language sql stable security definer set search_path = '' as $$
  select * from app.ranking_de(
    array(select pf.id from public.perfil pf where pf.ranking_global),
    p_limite)
  where (select auth.uid()) is not null
$$;

-- Provincia / localidad: la del propio usuario; entran los que se han unido a ese ranking.
create function public.ranking_provincia(p_limite int default 100)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language sql stable security definer set search_path = '' as $$
  with yo as (
    select lower(btrim(provincia)) as provincia from public.perfil
    where id = (select auth.uid()) and nullif(btrim(provincia), '') is not null)
  select * from app.ranking_de(
    array(select pf.id from public.perfil pf, yo
          where pf.ranking_provincia and lower(btrim(pf.provincia)) = yo.provincia),
    p_limite)
$$;

create function public.ranking_localidad(p_limite int default 100)
returns table (usuario_id uuid, nombre text, jugados bigint, ganados bigint, puntos bigint, puntaje numeric)
language sql stable security definer set search_path = '' as $$
  with yo as (
    select lower(btrim(localidad)) as localidad, lower(btrim(coalesce(provincia, ''))) as provincia
    from public.perfil
    where id = (select auth.uid()) and nullif(btrim(localidad), '') is not null)
  select * from app.ranking_de(
    array(select pf.id from public.perfil pf, yo
          where pf.ranking_localidad
            and lower(btrim(pf.localidad)) = yo.localidad
            and lower(btrim(coalesce(pf.provincia, ''))) = yo.provincia),
    p_limite)
$$;

revoke execute on function public.ranking_global(int), public.ranking_provincia(int),
  public.ranking_localidad(int) from public, anon;
grant execute on function public.ranking_global(int), public.ranking_provincia(int),
  public.ranking_localidad(int) to authenticated;
