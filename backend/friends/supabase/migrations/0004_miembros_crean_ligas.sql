-- =====================================================================
-- Ligaria Friends - Cualquier miembro puede crear ligas y partidos en su grupo.
-- Quien crea una liga la gestiona (participantes, calendario, partidos, resultados),
-- igual que los administradores del grupo. El resto de miembros solo la ven y
-- registran el resultado de sus propios partidos.
-- =====================================================================

-- Gestiona una liga quien es administrador de su grupo o quien la creó (y sigue en el grupo).
create function app.puede_gestionar_liga(l uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.liga x
    where x.id = l
      and app.es_miembro(x.grupo_id)
      and (app.es_admin_grupo(x.grupo_id) or x.creado_por = (select auth.uid())))
$$;
revoke execute on function app.puede_gestionar_liga(uuid) from public, anon;
grant execute on function app.puede_gestionar_liga(uuid) to authenticated;

-- liga
drop policy liga_ins on public.liga;
drop policy liga_upd on public.liga;
drop policy liga_del on public.liga;
create policy liga_ins on public.liga for insert to authenticated
  with check (app.es_miembro(grupo_id) and creado_por = (select auth.uid()));
create policy liga_upd on public.liga for update to authenticated
  using (app.puede_gestionar_liga(id)) with check (app.puede_gestionar_liga(id));
create policy liga_del on public.liga for delete to authenticated
  using (app.puede_gestionar_liga(id));

-- participante / participante_jugador
drop policy part_mod on public.participante;
create policy part_mod on public.participante for all to authenticated
  using (app.puede_gestionar_liga(liga_id)) with check (app.puede_gestionar_liga(liga_id));
drop policy pj_mod on public.participante_jugador;
create policy pj_mod on public.participante_jugador for all to authenticated
  using (app.puede_gestionar_liga(liga_id)) with check (app.puede_gestionar_liga(liga_id));

-- partido
drop policy partido_ins on public.partido;
drop policy partido_upd on public.partido;
drop policy partido_del on public.partido;
create policy partido_ins on public.partido for insert to authenticated
  with check (app.puede_gestionar_liga(liga_id));
create policy partido_upd on public.partido for update to authenticated
  using (app.puede_gestionar_liga(liga_id) or app.juega_en_partido(id))
  with check (app.puede_gestionar_liga(liga_id) or app.juega_en_partido(id));
create policy partido_del on public.partido for delete to authenticated
  using (app.puede_gestionar_liga(liga_id));

-- Triggers y RPC que comprobaban «es administrador del grupo»
create or replace function public.partido_validar_cambio() returns trigger
language plpgsql set search_path = '' as $$
begin
  if app.puede_gestionar_liga(old.liga_id)
     or coalesce(current_setting('app.resultado', true), '') = 'on' then
    return new;
  end if;
  if new.liga_id <> old.liga_id or new.local_id <> old.local_id or new.visitante_id <> old.visitante_id
     or new.ronda <> old.ronda or new.ganador is distinct from old.ganador then
    raise exception 'Solo un administrador puede cambiar los participantes o el ganador.' using errcode = 'P0001';
  end if;
  if new.estado not in ('PROPUESTO', 'PROGRAMADO', 'CANCELADO') and new.estado <> old.estado then
    raise exception 'El resultado se registra con registrar_resultado().' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create or replace function public.generar_calendario(p_liga uuid)
returns integer
language plpgsql security definer set search_path = '' as $$
declare
  l public.liga%rowtype;
  arr uuid[]; n int; r int; i int; a uuid; b uuid; cnt int := 0;
begin
  select * into l from public.liga where id = p_liga for update;
  if not found then raise exception 'Liga no encontrada.' using errcode = 'P0002'; end if;
  if not app.puede_gestionar_liga(l.id) then
    raise exception 'Solo un administrador puede generar el calendario.' using errcode = '42501';
  end if;
  if l.estado <> 'BORRADOR' then raise exception 'La liga ya está en marcha.' using errcode = 'P0001'; end if;
  if l.formato <> 'LIGA' then
    raise exception 'El calendario automático solo existe para el formato LIGA.' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from public.participante pa
    where pa.liga_id = p_liga
      and (select count(*) from public.participante_jugador pj where pj.participante_id = pa.id)
          <> case l.modalidad when 'INDIVIDUAL' then 1 else 2 end
  ) then
    raise exception 'Todos los participantes deben tener sus jugadores completos.' using errcode = 'P0001';
  end if;

  select array_agg(id order by created_at, id) into arr from public.participante where liga_id = p_liga;
  n := coalesce(array_length(arr, 1), 0);
  if n < 2 then raise exception 'Hacen falta al menos 2 participantes.' using errcode = 'P0001'; end if;
  if n % 2 = 1 then arr := array_append(arr, null::uuid); n := n + 1; end if;

  for r in 1 .. n - 1 loop
    for i in 1 .. n / 2 loop
      a := arr[i]; b := arr[n + 1 - i];
      if a is not null and b is not null then
        if i = 1 and r % 2 = 0 then  -- alterna local/visitante del participante fijo
          insert into public.partido (liga_id, ronda, local_id, visitante_id) values (p_liga, r, b, a);
        else
          insert into public.partido (liga_id, ronda, local_id, visitante_id) values (p_liga, r, a, b);
        end if;
        cnt := cnt + 1;
      end if;
    end loop;
    arr := arr[1:1] || arr[n:n] || arr[2:n - 1];  -- el primero fijo, el resto rota
  end loop;

  update public.liga set estado = 'EN_CURSO' where id = p_liga;
  return cnt;
end;
$$;

create or replace function public.registrar_resultado(p_partido uuid, p_sets jsonb)
returns lado_tipo
language plpgsql security definer set search_path = '' as $$
declare
  pa public.partido%rowtype;
  l public.liga%rowtype;
  rec record;
  sl int := 0; sv int := 0; total int;
  jl int; jv int; ganador public.lado_tipo;
begin
  select * into pa from public.partido where id = p_partido for update;
  if not found then raise exception 'Partido no encontrado.' using errcode = 'P0002'; end if;
  select * into l from public.liga where id = pa.liga_id;

  if not (app.puede_gestionar_liga(l.id)
          or (app.juega_en_partido(p_partido) and pa.estado in ('PROPUESTO', 'PROGRAMADO'))) then
    raise exception 'No puedes registrar el resultado de este partido.' using errcode = '42501';
  end if;
  if l.estado <> 'EN_CURSO' then raise exception 'La liga no está en curso.' using errcode = 'P0001'; end if;
  if jsonb_typeof(p_sets) <> 'array' then raise exception 'Formato de sets no válido.' using errcode = '22023'; end if;

  total := jsonb_array_length(p_sets);
  if total < l.sets_para_ganar or total > 2 * l.sets_para_ganar - 1 then
    raise exception 'Nº de sets no válido (entre % y %).', l.sets_para_ganar, 2 * l.sets_para_ganar - 1
      using errcode = '22023';
  end if;

  for rec in select e.value as s, e.ordinality as n from jsonb_array_elements(p_sets) with ordinality as e loop
    jl := (rec.s ->> 'local')::int;
    jv := (rec.s ->> 'visitante')::int;
    if jl is null or jv is null or jl = jv or jl < 0 or jv < 0 or jl > 99 or jv > 99 then
      raise exception 'Set % no válido.', rec.n using errcode = '22023';
    end if;
    if sl = l.sets_para_ganar or sv = l.sets_para_ganar then
      raise exception 'El partido ya estaba decidido antes del set %.', rec.n using errcode = '22023';
    end if;
    if jl > jv then sl := sl + 1; else sv := sv + 1; end if;
  end loop;
  if sl <> l.sets_para_ganar and sv <> l.sets_para_ganar then
    raise exception 'Ningún lado llega a % sets ganados.', l.sets_para_ganar using errcode = '22023';
  end if;
  ganador := case when sl > sv then 'LOCAL' else 'VISITANTE' end;

  delete from public.set_partido where partido_id = p_partido;
  insert into public.set_partido (partido_id, numero, juegos_local, juegos_visitante, tiebreak_local, tiebreak_visitante)
  select p_partido, e.ordinality, (e.value ->> 'local')::int, (e.value ->> 'visitante')::int,
         (e.value ->> 'tb_local')::int, (e.value ->> 'tb_visitante')::int
  from jsonb_array_elements(p_sets) with ordinality as e;

  perform set_config('app.resultado', 'on', true);  -- solo durante esta transacción
  update public.partido set estado = 'JUGADO', ganador = ganador_calc.g
  from (select ganador as g) as ganador_calc
  where id = p_partido;
  perform set_config('app.resultado', 'off', true);
  return ganador;
end;
$$;
