-- =====================================================================
-- Ligaria Friends - Amistosos: partidos de un grupo que no pertenecen a ninguna liga.
-- Se crean y puntúan solo por RPC (crear_amistoso / registrar_resultado_amistoso);
-- cualquier miembro del grupo los ve. No afectan a clasificaciones de ligas.
-- =====================================================================

create table public.amistoso (
  id               uuid primary key default gen_random_uuid(),
  grupo_id         uuid not null references public.grupo (id) on delete cascade,
  deporte          deporte_tipo not null default 'PADEL',
  sets_para_ganar  smallint not null default 2 check (sets_para_ganar between 1 and 3),
  fecha_hora       timestamptz,
  lugar            text,
  estado           partido_estado not null default 'PROGRAMADO',
  ganador          lado_tipo,
  sets             jsonb,
  creado_por       uuid not null default auth.uid() references public.perfil (id) on delete restrict,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  check (ganador is null or estado = 'JUGADO')
);
create index idx_amistoso_grupo on public.amistoso (grupo_id);
create index idx_amistoso_creado_por on public.amistoso (creado_por);

create trigger trg_amistoso_updated_at
  before update on public.amistoso
  for each row execute function public.set_updated_at();

-- Jugadores de cada lado: 1 (individual) o 2 (parejas).
create table public.amistoso_jugador (
  amistoso_id  uuid not null references public.amistoso (id) on delete cascade,
  usuario_id   uuid not null references public.perfil (id) on delete cascade,
  lado         lado_tipo not null,
  primary key (amistoso_id, usuario_id)
);
create index idx_amistoso_jugador_usuario on public.amistoso_jugador (usuario_id);

alter table public.amistoso         enable row level security;
alter table public.amistoso_jugador enable row level security;

-- ---------------------------------------------------------------------
-- Acceso
-- ---------------------------------------------------------------------
create function app.grupo_de_amistoso(a uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select grupo_id from public.amistoso where id = a
$$;
revoke execute on function app.grupo_de_amistoso(uuid) from public, anon;
grant execute on function app.grupo_de_amistoso(uuid) to authenticated;

create policy amistoso_sel on public.amistoso for select to authenticated using (app.es_miembro(grupo_id));
create policy amistoso_del on public.amistoso for delete to authenticated
  using (app.es_admin_grupo(grupo_id) or creado_por = (select auth.uid()));

create policy amistoso_jug_sel on public.amistoso_jugador for select to authenticated
  using (app.es_miembro(app.grupo_de_amistoso(amistoso_id)));

grant select on public.amistoso, public.amistoso_jugador to authenticated;
grant delete on public.amistoso to authenticated;

-- ---------------------------------------------------------------------
-- RPC
-- ---------------------------------------------------------------------
create function public.crear_amistoso(
  p_grupo uuid,
  p_deporte deporte_tipo,
  p_local uuid[],
  p_visitante uuid[],
  p_fecha timestamptz default null,
  p_lugar text default null,
  p_sets_para_ganar int default 2
)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  aid uuid;
  u uuid;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  if not app.es_miembro(p_grupo) then
    raise exception 'No perteneces a este grupo.' using errcode = '42501';
  end if;
  if coalesce(array_length(p_local, 1), 0) not between 1 and 2
     or array_length(p_local, 1) is distinct from array_length(p_visitante, 1) then
    raise exception 'Cada lado necesita 1 jugador (individual) o 2 (pareja), y los dos el mismo número.'
      using errcode = '22023';
  end if;
  if p_local && p_visitante then
    raise exception 'Un jugador no puede estar en los dos lados.' using errcode = '22023';
  end if;
  if (select count(distinct x) from unnest(p_local) x) <> array_length(p_local, 1)
     or (select count(distinct x) from unnest(p_visitante) x) <> array_length(p_visitante, 1) then
    raise exception 'Hay un jugador repetido.' using errcode = '22023';
  end if;
  if p_sets_para_ganar not between 1 and 3 then
    raise exception 'Formato de sets no válido.' using errcode = '22023';
  end if;
  for u in select unnest(p_local || p_visitante) loop
    if not exists (select 1 from public.grupo_miembro m where m.grupo_id = p_grupo and m.usuario_id = u) then
      raise exception 'Todos los jugadores deben pertenecer al grupo.' using errcode = 'P0001';
    end if;
  end loop;

  insert into public.amistoso (grupo_id, deporte, sets_para_ganar, fecha_hora, lugar, estado, creado_por)
  values (
    p_grupo, p_deporte, p_sets_para_ganar, p_fecha, nullif(btrim(p_lugar), ''),
    case when p_fecha is null then 'PROPUESTO'::public.partido_estado else 'PROGRAMADO'::public.partido_estado end,
    uid)
  returning id into aid;

  insert into public.amistoso_jugador (amistoso_id, usuario_id, lado)
  select aid, x, 'LOCAL'::public.lado_tipo from unnest(p_local) x;
  insert into public.amistoso_jugador (amistoso_id, usuario_id, lado)
  select aid, x, 'VISITANTE'::public.lado_tipo from unnest(p_visitante) x;
  return aid;
end;
$$;

-- p_sets: [{"local":6,"visitante":4}, ...]. El partido termina exactamente cuando alguien llega a sets_para_ganar.
create function public.registrar_resultado_amistoso(p_amistoso uuid, p_sets jsonb)
returns lado_tipo
language plpgsql security definer set search_path = '' as $$
declare
  a public.amistoso%rowtype;
  rec record;
  sl int := 0; sv int := 0; total int;
  jl int; jv int; v_ganador public.lado_tipo;
begin
  select * into a from public.amistoso where id = p_amistoso for update;
  if not found then raise exception 'Partido no encontrado.' using errcode = 'P0002'; end if;
  if not (app.es_admin_grupo(a.grupo_id)
          or exists (select 1 from public.amistoso_jugador j
                     where j.amistoso_id = p_amistoso and j.usuario_id = (select auth.uid()))) then
    raise exception 'No puedes registrar el resultado de este partido.' using errcode = '42501';
  end if;
  if jsonb_typeof(p_sets) <> 'array' then raise exception 'Formato de sets no válido.' using errcode = '22023'; end if;

  total := jsonb_array_length(p_sets);
  if total < a.sets_para_ganar or total > 2 * a.sets_para_ganar - 1 then
    raise exception 'Nº de sets no válido (entre % y %).', a.sets_para_ganar, 2 * a.sets_para_ganar - 1
      using errcode = '22023';
  end if;

  for rec in select e.value as s, e.ordinality as n from jsonb_array_elements(p_sets) with ordinality as e loop
    jl := (rec.s ->> 'local')::int;
    jv := (rec.s ->> 'visitante')::int;
    if jl is null or jv is null or jl = jv or jl < 0 or jv < 0 or jl > 99 or jv > 99 then
      raise exception 'Set % no válido.', rec.n using errcode = '22023';
    end if;
    if sl = a.sets_para_ganar or sv = a.sets_para_ganar then
      raise exception 'El partido ya estaba decidido antes del set %.', rec.n using errcode = '22023';
    end if;
    if jl > jv then sl := sl + 1; else sv := sv + 1; end if;
  end loop;
  if sl <> a.sets_para_ganar and sv <> a.sets_para_ganar then
    raise exception 'Ningún lado llega a % sets ganados.', a.sets_para_ganar using errcode = '22023';
  end if;
  v_ganador := case when sl > sv then 'LOCAL'::public.lado_tipo else 'VISITANTE'::public.lado_tipo end;

  update public.amistoso
     set sets = p_sets, estado = 'JUGADO', ganador = v_ganador
   where id = p_amistoso;
  return v_ganador;
end;
$$;

revoke execute on function public.crear_amistoso(uuid, deporte_tipo, uuid[], uuid[], timestamptz, text, int) from public, anon;
revoke execute on function public.registrar_resultado_amistoso(uuid, jsonb) from public, anon;
grant execute on function public.crear_amistoso(uuid, deporte_tipo, uuid[], uuid[], timestamptz, text, int) to authenticated;
grant execute on function public.registrar_resultado_amistoso(uuid, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- Vista para la app (hereda la RLS del usuario)
-- ---------------------------------------------------------------------
create view public.v_amistosos with (security_invoker = true) as
select a.id, a.grupo_id, a.deporte, a.fecha_hora, a.lugar, a.estado, a.ganador, a.sets_para_ganar,
       a.creado_por, a.created_at,
       (select string_agg(coalesce(pf.apodo, pf.nombre, 'Jugador'), ' / ' order by coalesce(pf.apodo, pf.nombre))
          from public.amistoso_jugador j
          left join public.perfil pf on pf.id = j.usuario_id
         where j.amistoso_id = a.id and j.lado = 'LOCAL') as local_nombre,
       (select string_agg(coalesce(pf.apodo, pf.nombre, 'Jugador'), ' / ' order by coalesce(pf.apodo, pf.nombre))
          from public.amistoso_jugador j
          left join public.perfil pf on pf.id = j.usuario_id
         where j.amistoso_id = a.id and j.lado = 'VISITANTE') as visitante_nombre,
       (select string_agg((e.value ->> 'local') || '-' || (e.value ->> 'visitante'), ' ' order by e.ordinality)
          from jsonb_array_elements(a.sets) with ordinality as e) as resultado
from public.amistoso a;

grant select on public.v_amistosos to authenticated;
