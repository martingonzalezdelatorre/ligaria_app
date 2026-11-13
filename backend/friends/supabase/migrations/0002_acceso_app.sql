-- =====================================================================
-- Ligaria Friends - Acceso desde la app: helpers, RLS, RPC y vistas v_*
-- Regla general: solo los miembros de un grupo ven y tocan sus datos.
-- grupo / grupo_miembro NO tienen política de INSERT: se escriben solo por RPC.
-- =====================================================================

grant usage on schema app to authenticated;

-- ---------------------------------------------------------------------
-- 1. Helpers (security definer: leen tablas sin depender de las políticas)
-- ---------------------------------------------------------------------
create function app.es_miembro(g uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.grupo_miembro m
                 where m.grupo_id = g and m.usuario_id = (select auth.uid()))
$$;

create function app.es_admin_grupo(g uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.grupo_miembro m
                 where m.grupo_id = g and m.usuario_id = (select auth.uid()) and m.rol = 'ADMIN')
$$;

create function app.comparte_grupo(u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1
                 from public.grupo_miembro a
                 join public.grupo_miembro b on b.grupo_id = a.grupo_id
                 where a.usuario_id = (select auth.uid()) and b.usuario_id = u)
$$;

create function app.grupo_de_liga(l uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select grupo_id from public.liga where id = l
$$;

create function app.grupo_de_partido(p uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select l.grupo_id from public.partido pa join public.liga l on l.id = pa.liga_id where pa.id = p
$$;

create function app.juega_en_partido(p uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.partido pa
    join public.participante_jugador pj on pj.participante_id in (pa.local_id, pa.visitante_id)
    where pa.id = p and pj.usuario_id = (select auth.uid()))
$$;

grant execute on all functions in schema app to authenticated;

-- ---------------------------------------------------------------------
-- 2. Políticas RLS
-- ---------------------------------------------------------------------
-- perfil: el propio y los compañeros de grupo; solo se edita el propio.
create policy perfil_sel on public.perfil for select to authenticated
  using (id = (select auth.uid()) or app.comparte_grupo(id));
create policy perfil_upd on public.perfil for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- grupo
create policy grupo_sel on public.grupo for select to authenticated using (app.es_miembro(id));
create policy grupo_upd on public.grupo for update to authenticated
  using (app.es_admin_grupo(id)) with check (app.es_admin_grupo(id));
create policy grupo_del on public.grupo for delete to authenticated using (app.es_admin_grupo(id));

-- grupo_miembro: ve a sus compañeros; el admin cambia roles y expulsa; cada uno puede salir.
create policy gm_sel on public.grupo_miembro for select to authenticated using (app.es_miembro(grupo_id));
create policy gm_upd on public.grupo_miembro for update to authenticated
  using (app.es_admin_grupo(grupo_id)) with check (app.es_admin_grupo(grupo_id));
create policy gm_del on public.grupo_miembro for delete to authenticated
  using (app.es_admin_grupo(grupo_id) or usuario_id = (select auth.uid()));

-- liga
create policy liga_sel on public.liga for select to authenticated using (app.es_miembro(grupo_id));
create policy liga_ins on public.liga for insert to authenticated
  with check (app.es_admin_grupo(grupo_id) and creado_por = (select auth.uid()));
create policy liga_upd on public.liga for update to authenticated
  using (app.es_admin_grupo(grupo_id)) with check (app.es_admin_grupo(grupo_id));
create policy liga_del on public.liga for delete to authenticated using (app.es_admin_grupo(grupo_id));

-- participante / participante_jugador
create policy part_sel on public.participante for select to authenticated
  using (app.es_miembro(app.grupo_de_liga(liga_id)));
create policy part_mod on public.participante for all to authenticated
  using (app.es_admin_grupo(app.grupo_de_liga(liga_id)))
  with check (app.es_admin_grupo(app.grupo_de_liga(liga_id)));

create policy pj_sel on public.participante_jugador for select to authenticated
  using (app.es_miembro(app.grupo_de_liga(liga_id)));
create policy pj_mod on public.participante_jugador for all to authenticated
  using (app.es_admin_grupo(app.grupo_de_liga(liga_id)))
  with check (app.es_admin_grupo(app.grupo_de_liga(liga_id)));

-- partido: lo crea/borra el admin; admin o jugadores lo actualizan (fecha, lugar...).
create policy partido_sel on public.partido for select to authenticated
  using (app.es_miembro(app.grupo_de_liga(liga_id)));
create policy partido_ins on public.partido for insert to authenticated
  with check (app.es_admin_grupo(app.grupo_de_liga(liga_id)));
create policy partido_upd on public.partido for update to authenticated
  using (app.es_admin_grupo(app.grupo_de_liga(liga_id)) or app.juega_en_partido(id))
  with check (app.es_admin_grupo(app.grupo_de_liga(liga_id)) or app.juega_en_partido(id));
create policy partido_del on public.partido for delete to authenticated
  using (app.es_admin_grupo(app.grupo_de_liga(liga_id)));

-- set_partido: solo lectura directa; se escribe con registrar_resultado().
create policy set_sel on public.set_partido for select to authenticated
  using (app.es_miembro(app.grupo_de_partido(partido_id)));

-- Un jugador solo puede cambiar fecha, lugar y estado (propuesto/programado/cancelado);
-- ganador y resultado solo por registrar_resultado() (que activa app.resultado).
create function public.partido_validar_cambio() returns trigger
language plpgsql set search_path = '' as $$
begin
  if app.es_admin_grupo(app.grupo_de_liga(old.liga_id))
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

create trigger trg_partido_validar_cambio
  before update on public.partido
  for each row execute function public.partido_validar_cambio();

-- ---------------------------------------------------------------------
-- 3. RPC (expuestas por la API; solo usuarios autenticados)
-- ---------------------------------------------------------------------
create function public.crear_grupo(p_nombre text, p_descripcion text default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid()); gid uuid;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  insert into public.grupo (nombre, descripcion, creado_por)
  values (btrim(p_nombre), nullif(btrim(p_descripcion), ''), uid)
  returning id into gid;
  insert into public.grupo_miembro (grupo_id, usuario_id, rol) values (gid, uid, 'ADMIN');
  return gid;
end;
$$;

create function public.unirse_a_grupo(p_codigo text)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid()); gid uuid;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  select id into gid from public.grupo where codigo_invitacion = upper(btrim(p_codigo));
  if gid is null then raise exception 'Código de invitación no válido.' using errcode = 'P0002'; end if;
  insert into public.grupo_miembro (grupo_id, usuario_id) values (gid, uid)
  on conflict do nothing;
  return gid;
end;
$$;

create function public.regenerar_codigo(p_grupo uuid)
returns text
language plpgsql security definer set search_path = '' as $$
declare nuevo text;
begin
  if not app.es_admin_grupo(p_grupo) then
    raise exception 'Solo un administrador puede regenerar el código.' using errcode = '42501';
  end if;
  update public.grupo set codigo_invitacion = app.generar_codigo() where id = p_grupo
  returning codigo_invitacion into nuevo;
  return nuevo;
end;
$$;

create function public.salir_de_grupo(p_grupo uuid)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  -- Si es el último administrador, el trigger grupo_miembro_conservar_admin lo impide.
  delete from public.grupo_miembro where grupo_id = p_grupo and usuario_id = (select auth.uid());
end;
$$;

-- Liga todos contra todos (método del círculo; con nº impar, uno descansa cada ronda).
create function public.generar_calendario(p_liga uuid)
returns integer
language plpgsql security definer set search_path = '' as $$
declare
  l public.liga%rowtype;
  arr uuid[]; n int; r int; i int; a uuid; b uuid; cnt int := 0;
begin
  select * into l from public.liga where id = p_liga for update;
  if not found then raise exception 'Liga no encontrada.' using errcode = 'P0002'; end if;
  if not app.es_admin_grupo(l.grupo_id) then
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

-- p_sets: [{"local":6,"visitante":4}, {"local":7,"visitante":6,"tb_local":7,"tb_visitante":5}, ...]
-- Valida que el partido termina exactamente cuando alguien llega a sets_para_ganar.
create function public.registrar_resultado(p_partido uuid, p_sets jsonb)
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

  if not (app.es_admin_grupo(l.grupo_id)
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

-- Solo usuarios autenticados pueden llamar a las RPC.
revoke execute on function public.crear_grupo(text, text)       from public, anon;
revoke execute on function public.unirse_a_grupo(text)          from public, anon;
revoke execute on function public.regenerar_codigo(uuid)        from public, anon;
revoke execute on function public.salir_de_grupo(uuid)          from public, anon;
revoke execute on function public.generar_calendario(uuid)      from public, anon;
revoke execute on function public.registrar_resultado(uuid, jsonb) from public, anon;
grant execute on function public.crear_grupo(text, text)       to authenticated;
grant execute on function public.unirse_a_grupo(text)          to authenticated;
grant execute on function public.regenerar_codigo(uuid)        to authenticated;
grant execute on function public.salir_de_grupo(uuid)          to authenticated;
grant execute on function public.generar_calendario(uuid)      to authenticated;
grant execute on function public.registrar_resultado(uuid, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Vistas para la app (security_invoker: heredan la RLS del usuario)
-- ---------------------------------------------------------------------
create view public.v_mis_grupos with (security_invoker = true) as
select g.id, g.nombre, g.descripcion, g.codigo_invitacion, m.rol,
       (select count(*) from public.grupo_miembro x where x.grupo_id = g.id) as miembros
from public.grupo g
join public.grupo_miembro m on m.grupo_id = g.id and m.usuario_id = (select auth.uid());

create view public.v_ligas with (security_invoker = true) as
select l.*,
       (select count(*) from public.participante p where p.liga_id = l.id) as participantes,
       (select count(*) from public.partido p where p.liga_id = l.id) as partidos,
       (select count(*) from public.partido p where p.liga_id = l.id and p.estado = 'JUGADO') as partidos_jugados
from public.liga l;

create view public.v_partidos_liga with (security_invoker = true) as
select p.id, p.liga_id, p.ronda, p.fecha_hora, p.lugar, p.estado, p.ganador,
       p.local_id, pl.nombre as local_nombre,
       p.visitante_id, pv.nombre as visitante_nombre,
       (select string_agg(s.juegos_local || '-' || s.juegos_visitante
                          || coalesce(' (' || s.tiebreak_local || '-' || s.tiebreak_visitante || ')', ''),
                          ' ' order by s.numero)
        from public.set_partido s where s.partido_id = p.id) as resultado
from public.partido p
join public.participante pl on pl.id = p.local_id
join public.participante pv on pv.id = p.visitante_id;

-- Victorias por jugador en todas las ligas de cada grupo.
create view public.v_ranking_grupo with (security_invoker = true) as
select l.grupo_id, pj.usuario_id, pf.nombre,
       count(*) as partidos,
       count(*) filter (where (p.ganador = 'LOCAL' and p.local_id = pj.participante_id)
                           or (p.ganador = 'VISITANTE' and p.visitante_id = pj.participante_id)) as victorias
from public.partido p
join public.liga l on l.id = p.liga_id
join public.participante_jugador pj on pj.participante_id in (p.local_id, p.visitante_id)
left join public.perfil pf on pf.id = pj.usuario_id
where p.ganador is not null
group by l.grupo_id, pj.usuario_id, pf.nombre;

-- Permisos de tabla: la RLS decide qué filas; aquí solo se abre el acceso a authenticated.
grant select on public.perfil, public.grupo, public.grupo_miembro, public.liga, public.participante,
                public.participante_jugador, public.partido, public.set_partido, public.clasificacion,
                public.v_mis_grupos, public.v_ligas, public.v_partidos_liga, public.v_ranking_grupo
  to authenticated;
grant update (nombre, apodo, avatar_url, mano_dominante, nivel) on public.perfil to authenticated;
grant update (nombre, descripcion) on public.grupo to authenticated;
grant delete on public.grupo to authenticated;
grant update (rol, alias) on public.grupo_miembro to authenticated;
grant delete on public.grupo_miembro to authenticated;
grant insert, update, delete on public.liga, public.participante, public.participante_jugador, public.partido
  to authenticated;
