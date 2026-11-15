-- =====================================================================
-- Ligaria Friends - Confirmación de resultados.
-- Al registrarse un resultado queda «Sin confirmar» hasta que lo confirman todos los jugadores
-- del partido (2 en individual, 4 en dobles). Quien registra el resultado y juega el partido
-- cuenta como confirmado. Si el resultado cambia, las confirmaciones se reinician.
-- Se escribe solo por trigger / RPC confirmar_resultado.
-- =====================================================================

create table public.resultado_confirmacion (
  id           uuid primary key default gen_random_uuid(),
  amistoso_id  uuid references public.amistoso (id) on delete cascade,
  partido_id   uuid references public.partido (id) on delete cascade,
  usuario_id   uuid not null references public.perfil (id) on delete cascade,
  created_at   timestamptz not null default now(),
  check ((amistoso_id is null) <> (partido_id is null)),
  unique (amistoso_id, usuario_id),
  unique (partido_id, usuario_id)
);
create index idx_res_conf_usuario on public.resultado_confirmacion (usuario_id);

alter table public.resultado_confirmacion enable row level security;
create policy res_conf_sel on public.resultado_confirmacion for select to authenticated
  using (app.es_miembro(coalesce(app.grupo_de_amistoso(amistoso_id), app.grupo_de_partido(partido_id))));
grant select on public.resultado_confirmacion to authenticated;

-- ¿Es el usuario jugador de ese partido? (se comprueba por id, no solo por auth.uid())
create function app.es_jugador_de_amistoso(a uuid, u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.amistoso_jugador j where j.amistoso_id = a and j.usuario_id = u)
$$;
create function app.es_jugador_de_partido(p uuid, u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.partido pa
    join public.participante_jugador pj on pj.participante_id in (pa.local_id, pa.visitante_id)
    where pa.id = p and pj.usuario_id = u)
$$;
revoke execute on function app.es_jugador_de_amistoso(uuid, uuid), app.es_jugador_de_partido(uuid, uuid) from public, anon;
grant execute on function app.es_jugador_de_amistoso(uuid, uuid), app.es_jugador_de_partido(uuid, uuid) to authenticated;

-- Al registrar (o cambiar) un resultado: reinicia confirmaciones y cuenta la de quien lo registra.
create function public.amistoso_resultado_registrado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid());
begin
  if new.estado = 'JUGADO'
     and (old.estado is distinct from 'JUGADO' or new.ganador is distinct from old.ganador
          or new.sets is distinct from old.sets) then
    delete from public.resultado_confirmacion where amistoso_id = new.id;
    if uid is not null and app.es_jugador_de_amistoso(new.id, uid) then
      insert into public.resultado_confirmacion (amistoso_id, usuario_id) values (new.id, uid);
    end if;
  end if;
  return null;
end;
$$;
create trigger trg_amistoso_resultado after update on public.amistoso
  for each row execute function public.amistoso_resultado_registrado();

create function public.partido_resultado_registrado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid());
begin
  if new.estado = 'JUGADO'
     and (old.estado is distinct from 'JUGADO' or new.ganador is distinct from old.ganador) then
    delete from public.resultado_confirmacion where partido_id = new.id;
    if uid is not null and app.es_jugador_de_partido(new.id, uid) then
      insert into public.resultado_confirmacion (partido_id, usuario_id) values (new.id, uid);
    end if;
  end if;
  return null;
end;
$$;
create trigger trg_partido_resultado after update on public.partido
  for each row execute function public.partido_resultado_registrado();

-- Confirma el resultado el jugador del partido.
create function public.confirmar_resultado(p_amistoso uuid, p_partido uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid());
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  if (p_amistoso is null) = (p_partido is null) then
    raise exception 'Indica un partido.' using errcode = '22023';
  end if;
  if p_amistoso is not null then
    if not exists (select 1 from public.amistoso where id = p_amistoso and estado = 'JUGADO') then
      raise exception 'El partido aún no tiene resultado.' using errcode = 'P0001';
    end if;
    if not app.es_jugador_de_amistoso(p_amistoso, uid) then
      raise exception 'Solo los jugadores del partido pueden confirmar el resultado.' using errcode = '42501';
    end if;
    insert into public.resultado_confirmacion (amistoso_id, usuario_id) values (p_amistoso, uid)
      on conflict (amistoso_id, usuario_id) do nothing;
  else
    if not exists (select 1 from public.partido where id = p_partido and estado = 'JUGADO') then
      raise exception 'El partido aún no tiene resultado.' using errcode = 'P0001';
    end if;
    if not app.es_jugador_de_partido(p_partido, uid) then
      raise exception 'Solo los jugadores del partido pueden confirmar el resultado.' using errcode = '42501';
    end if;
    insert into public.resultado_confirmacion (partido_id, usuario_id) values (p_partido, uid)
      on conflict (partido_id, usuario_id) do nothing;
  end if;
end;
$$;
revoke execute on function public.confirmar_resultado(uuid, uuid) from public, anon;
grant execute on function public.confirmar_resultado(uuid, uuid) to authenticated;

-- Estado de confirmación de cada partido con resultado (hereda la RLS del usuario).
create view public.v_confirmaciones with (security_invoker = true) as
select a.id as ref_id, a.grupo_id,
       (select count(*) from public.amistoso_jugador j where j.amistoso_id = a.id) as total,
       (select count(*) from public.resultado_confirmacion c where c.amistoso_id = a.id) as confirmados,
       exists (select 1 from public.amistoso_jugador j
               where j.amistoso_id = a.id and j.usuario_id = (select auth.uid())) as yo_juego,
       exists (select 1 from public.resultado_confirmacion c
               where c.amistoso_id = a.id and c.usuario_id = (select auth.uid())) as yo_confirmado
from public.amistoso a where a.estado = 'JUGADO'
union all
select p.id, l.grupo_id,
       (select count(*) from public.participante_jugador pj
         where pj.participante_id in (p.local_id, p.visitante_id)) as total,
       (select count(*) from public.resultado_confirmacion c where c.partido_id = p.id) as confirmados,
       exists (select 1 from public.participante_jugador pj
               where pj.participante_id in (p.local_id, p.visitante_id)
                 and pj.usuario_id = (select auth.uid())) as yo_juego,
       exists (select 1 from public.resultado_confirmacion c
               where c.partido_id = p.id and c.usuario_id = (select auth.uid())) as yo_confirmado
from public.partido p join public.liga l on l.id = p.liga_id
where p.estado = 'JUGADO';
grant select on public.v_confirmaciones to authenticated;
