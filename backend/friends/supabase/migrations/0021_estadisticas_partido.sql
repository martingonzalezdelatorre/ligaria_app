-- =====================================================================
-- Ligaria Friends - Puntos de cada partido y estadísticas por jugador.
-- Los sets ya se guardan (amistoso.sets y set_partido). Aquí se guarda la secuencia punto a punto
-- que lleva el tanteador: una cadena de «L» / «V» (quién ganó cada punto, en orden).
-- En dobles el punto se atribuye al lado (pareja), no al jugador concreto.
-- Se escribe solo por la RPC guardar_puntos. Si el resultado del partido cambia, los puntos se borran.
-- Las estadísticas solo cuentan partidos con resultado confirmado (como el ranking).
-- Requiere 0020 (app.amistoso_confirmado / app.partido_confirmado).
-- =====================================================================

create table public.resultado_puntos (
  id                 uuid primary key default gen_random_uuid(),
  amistoso_id        uuid references public.amistoso (id) on delete cascade,
  partido_id         uuid references public.partido (id) on delete cascade,
  puntos             text not null check (puntos ~ '^[LV]{4,800}$'),
  puntos_local       int  not null check (puntos_local >= 0),
  puntos_visitante   int  not null check (puntos_visitante >= 0),
  registrado_por     uuid not null references public.perfil (id) on delete cascade,
  created_at         timestamptz not null default now(),
  check ((amistoso_id is null) <> (partido_id is null)),
  unique (amistoso_id),
  unique (partido_id)
);

alter table public.resultado_puntos enable row level security;
create policy res_puntos_sel on public.resultado_puntos for select to authenticated
  using ((amistoso_id is not null and app.ve_amistoso(amistoso_id))
         or (partido_id is not null and app.es_miembro(app.grupo_de_partido(partido_id))));
grant select on public.resultado_puntos to authenticated;

-- ---------------------------------------------------------------------
-- Guardar los puntos de un partido ya jugado. Mismos permisos que registrar el resultado.
-- ---------------------------------------------------------------------
create function public.guardar_puntos(p_amistoso uuid, p_partido uuid, p_puntos text)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  pl int; pv int;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  if (p_amistoso is null) = (p_partido is null) then
    raise exception 'Indica un partido.' using errcode = '22023';
  end if;
  if p_puntos is null or p_puntos !~ '^[LV]{4,800}$' then
    raise exception 'Formato de puntos no válido.' using errcode = '22023';
  end if;
  pv := length(p_puntos) - length(replace(p_puntos, 'V', ''));
  pl := length(p_puntos) - pv;

  if p_amistoso is not null then
    if not exists (select 1 from public.amistoso where id = p_amistoso and estado = 'JUGADO') then
      raise exception 'El partido aún no tiene resultado.' using errcode = 'P0001';
    end if;
    if not (exists (select 1 from public.amistoso a
                    where a.id = p_amistoso
                      and (coalesce(app.es_admin_grupo(a.grupo_id), false) or a.creado_por = uid))
            or app.es_jugador_de_amistoso(p_amistoso, uid)) then
      raise exception 'No puedes guardar los puntos de este partido.' using errcode = '42501';
    end if;
    insert into public.resultado_puntos (amistoso_id, puntos, puntos_local, puntos_visitante, registrado_por)
    values (p_amistoso, p_puntos, pl, pv, uid)
    on conflict (amistoso_id) do update
      set puntos = excluded.puntos, puntos_local = excluded.puntos_local,
          puntos_visitante = excluded.puntos_visitante, registrado_por = excluded.registrado_por,
          created_at = now();
  else
    if not exists (select 1 from public.partido where id = p_partido and estado = 'JUGADO') then
      raise exception 'El partido aún no tiene resultado.' using errcode = 'P0001';
    end if;
    if not (app.es_jugador_de_partido(p_partido, uid)
            or exists (select 1 from public.partido pa where pa.id = p_partido
                       and app.puede_gestionar_liga(pa.liga_id))) then
      raise exception 'No puedes guardar los puntos de este partido.' using errcode = '42501';
    end if;
    insert into public.resultado_puntos (partido_id, puntos, puntos_local, puntos_visitante, registrado_por)
    values (p_partido, p_puntos, pl, pv, uid)
    on conflict (partido_id) do update
      set puntos = excluded.puntos, puntos_local = excluded.puntos_local,
          puntos_visitante = excluded.puntos_visitante, registrado_por = excluded.registrado_por,
          created_at = now();
  end if;
end;
$$;
revoke execute on function public.guardar_puntos(uuid, uuid, text) from public, anon;
grant execute on function public.guardar_puntos(uuid, uuid, text) to authenticated;

-- Si el resultado cambia, los puntos guardados dejan de corresponder: se borran.
create function public.amistoso_puntos_obsoletos() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.sets is distinct from old.sets or new.ganador is distinct from old.ganador then
    delete from public.resultado_puntos where amistoso_id = new.id;
  end if;
  return null;
end;
$$;
create trigger trg_amistoso_puntos after update on public.amistoso
  for each row execute function public.amistoso_puntos_obsoletos();

create function public.partido_puntos_obsoletos() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.estado is distinct from old.estado or new.ganador is distinct from old.ganador then
    delete from public.resultado_puntos where partido_id = new.id;
  end if;
  return null;
end;
$$;
create trigger trg_partido_puntos after update on public.partido
  for each row execute function public.partido_puntos_obsoletos();

-- ---------------------------------------------------------------------
-- Estadísticas. Núcleo común: una fila por usuario (aparecen aunque no tengan partidos).
-- Solo partidos JUGADO y confirmados. Los puntos solo cuentan en partidos con tanteo guardado
-- (partidos_con_puntos); un resultado introducido a mano no tiene puntos.
-- ---------------------------------------------------------------------
create function app.estadisticas_de(p_usuarios uuid[])
returns table (
  usuario_id uuid, nombre text,
  partidos bigint, ganados bigint,
  sets_ganados bigint, sets_perdidos bigint,
  juegos_ganados bigint, juegos_perdidos bigint,
  partidos_con_puntos bigint, puntos_ganados bigint, puntos_perdidos bigint
)
language sql stable security definer set search_path = '' as $$
  with filas as (
    select aj.usuario_id, aj.lado, a.ganador,
           (select count(*) filter (where (e ->> 'local')::int > (e ->> 'visitante')::int)
              from jsonb_array_elements(a.sets) e) as sl,
           (select count(*) filter (where (e ->> 'local')::int < (e ->> 'visitante')::int)
              from jsonb_array_elements(a.sets) e) as sv,
           (select coalesce(sum((e ->> 'local')::int), 0) from jsonb_array_elements(a.sets) e) as jl,
           (select coalesce(sum((e ->> 'visitante')::int), 0) from jsonb_array_elements(a.sets) e) as jv,
           rp.puntos_local as pl, rp.puntos_visitante as pv
    from public.amistoso a
    join public.amistoso_jugador aj on aj.amistoso_id = a.id
    left join public.resultado_puntos rp on rp.amistoso_id = a.id
    where a.estado = 'JUGADO' and a.ganador is not null
      and aj.usuario_id = any (p_usuarios) and app.amistoso_confirmado(a.id)
    union all
    select pj.usuario_id,
           case when pj.participante_id = p.local_id then 'LOCAL'::public.lado_tipo
                else 'VISITANTE'::public.lado_tipo end,
           p.ganador,
           (select count(*) from public.set_partido s
             where s.partido_id = p.id and s.juegos_local > s.juegos_visitante),
           (select count(*) from public.set_partido s
             where s.partido_id = p.id and s.juegos_local < s.juegos_visitante),
           (select coalesce(sum(s.juegos_local), 0) from public.set_partido s where s.partido_id = p.id),
           (select coalesce(sum(s.juegos_visitante), 0) from public.set_partido s where s.partido_id = p.id),
           rp.puntos_local, rp.puntos_visitante
    from public.partido p
    join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
    left join public.resultado_puntos rp on rp.partido_id = p.id
    where p.estado = 'JUGADO' and p.ganador is not null
      and pj.usuario_id = any (p_usuarios) and app.partido_confirmado(p.id)
  ),
  tot as (
    select f.usuario_id,
           count(*)                                                       as partidos,
           count(*) filter (where f.lado = f.ganador)                     as ganados,
           coalesce(sum(case f.lado when 'LOCAL' then f.sl else f.sv end), 0) as sg,
           coalesce(sum(case f.lado when 'LOCAL' then f.sv else f.sl end), 0) as sp,
           coalesce(sum(case f.lado when 'LOCAL' then f.jl else f.jv end), 0) as jg,
           coalesce(sum(case f.lado when 'LOCAL' then f.jv else f.jl end), 0) as jp,
           count(f.pl)                                                    as con_puntos,
           coalesce(sum(case f.lado when 'LOCAL' then f.pl else f.pv end), 0) as pg,
           coalesce(sum(case f.lado when 'LOCAL' then f.pv else f.pl end), 0) as pp
    from filas f
    group by f.usuario_id
  )
  select pf.id,
         coalesce(nullif(btrim(pf.apodo), ''),
                  nullif(btrim(coalesce(pf.nombre, '') || ' ' || coalesce(pf.apellidos, '')), ''),
                  'Jugador'),
         coalesce(t.partidos, 0)::bigint, coalesce(t.ganados, 0)::bigint,
         coalesce(t.sg, 0)::bigint, coalesce(t.sp, 0)::bigint,
         coalesce(t.jg, 0)::bigint, coalesce(t.jp, 0)::bigint,
         coalesce(t.con_puntos, 0)::bigint, coalesce(t.pg, 0)::bigint, coalesce(t.pp, 0)::bigint
  from public.perfil pf
  left join tot t on t.usuario_id = pf.id
  where pf.id = any (p_usuarios)
$$;
revoke execute on function app.estadisticas_de(uuid[]) from public, anon, authenticated;

-- Las del propio usuario.
create function public.estadisticas_mias()
returns table (
  usuario_id uuid, nombre text,
  partidos bigint, ganados bigint,
  sets_ganados bigint, sets_perdidos bigint,
  juegos_ganados bigint, juegos_perdidos bigint,
  partidos_con_puntos bigint, puntos_ganados bigint, puntos_perdidos bigint
)
language sql stable security definer set search_path = '' as $$
  select * from app.estadisticas_de(array[(select auth.uid())])
$$;
revoke execute on function public.estadisticas_mias() from public, anon;
grant execute on function public.estadisticas_mias() to authenticated;

-- Las de todos los miembros de un grupo.
create function public.estadisticas_grupo(p_grupo uuid)
returns table (
  usuario_id uuid, nombre text,
  partidos bigint, ganados bigint,
  sets_ganados bigint, sets_perdidos bigint,
  juegos_ganados bigint, juegos_perdidos bigint,
  partidos_con_puntos bigint, puntos_ganados bigint, puntos_perdidos bigint
)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not app.es_miembro(p_grupo) then
    raise exception 'No perteneces a este grupo.' using errcode = '42501';
  end if;
  return query
  select * from app.estadisticas_de(
    array(select m.usuario_id from public.grupo_miembro m where m.grupo_id = p_grupo));
end;
$$;
revoke execute on function public.estadisticas_grupo(uuid) from public, anon;
grant execute on function public.estadisticas_grupo(uuid) to authenticated;
