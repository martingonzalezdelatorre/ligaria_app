-- =====================================================================
-- Amistosos sin grupo: un amistoso ya no tiene por qué pertenecer a un grupo.
-- Jugadores permitidos: quien lo crea, sus contactos (0015) y quienes comparten
-- algún grupo con él. Lo ven el creador, los jugadores y, si lo tiene, el grupo.
-- =====================================================================

alter table public.amistoso alter column grupo_id drop not null;
alter table public.marcador_vivo alter column grupo_id drop not null;

-- ¿Puede el usuario actual ver este amistoso? (creador, jugador o miembro del grupo)
create function app.ve_amistoso(a uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.amistoso x
    where x.id = a
      and (x.creado_por = (select auth.uid())
           or (x.grupo_id is not null and app.es_miembro(x.grupo_id))
           or exists (select 1 from public.amistoso_jugador j
                      where j.amistoso_id = x.id and j.usuario_id = (select auth.uid()))))
$$;

-- ¿Comparte el usuario actual algún amistoso con u? (para ver su perfil)
create function app.comparte_amistoso(u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.amistoso_jugador a
    join public.amistoso_jugador b on b.amistoso_id = a.amistoso_id
    where a.usuario_id = (select auth.uid()) and b.usuario_id = u)
$$;

-- ¿Puede el usuario actual jugar con u? (él mismo, contacto o compañero de grupo)
create function app.puede_jugar_con(u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select u = (select auth.uid()) or app.es_contacto(u) or app.comparte_grupo(u)
$$;
grant execute on function app.ve_amistoso(uuid), app.comparte_amistoso(uuid), app.puede_jugar_con(uuid)
  to authenticated;

drop policy perfil_sel on public.perfil;
create policy perfil_sel on public.perfil for select to authenticated
  using (id = (select auth.uid()) or app.comparte_grupo(id) or app.es_contacto(id)
         or app.comparte_amistoso(id));

drop policy amistoso_sel on public.amistoso;
create policy amistoso_sel on public.amistoso for select to authenticated
  using (app.ve_amistoso(id));
drop policy amistoso_jug_sel on public.amistoso_jugador;
create policy amistoso_jug_sel on public.amistoso_jugador for select to authenticated
  using (app.ve_amistoso(amistoso_id));

drop policy marcador_sel on public.marcador_vivo;
create policy marcador_sel on public.marcador_vivo for select to authenticated
  using ((grupo_id is not null and app.es_miembro(grupo_id))
         or (amistoso_id is not null and app.ve_amistoso(amistoso_id)));

drop policy res_conf_sel on public.resultado_confirmacion;
create policy res_conf_sel on public.resultado_confirmacion for select to authenticated
  using ((amistoso_id is not null and app.ve_amistoso(amistoso_id))
         or (partido_id is not null and app.es_miembro(app.grupo_de_partido(partido_id))));

-- ---------------------------------------------------------------------
-- crear_amistoso: p_grupo opcional
-- ---------------------------------------------------------------------
drop function public.crear_amistoso(uuid, deporte_tipo, uuid[], uuid[], timestamptz, text, int);
create function public.crear_amistoso(
  p_deporte deporte_tipo,
  p_local uuid[],
  p_visitante uuid[],
  p_grupo uuid default null,
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
  if p_grupo is not null and not app.es_miembro(p_grupo) then
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
    if not (app.puede_jugar_con(u)
            or (p_grupo is not null and exists (
                  select 1 from public.grupo_miembro m where m.grupo_id = p_grupo and m.usuario_id = u))) then
      raise exception 'Solo puedes jugar con tus amigos o con miembros de tus grupos.' using errcode = 'P0001';
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
revoke execute on function public.crear_amistoso(deporte_tipo, uuid[], uuid[], uuid, timestamptz, text, int) from public, anon;
grant execute on function public.crear_amistoso(deporte_tipo, uuid[], uuid[], uuid, timestamptz, text, int) to authenticated;

-- ---------------------------------------------------------------------
-- registrar_resultado_amistoso: con grupo nulo es_admin_grupo devuelve NULL; se trata como falso.
-- ---------------------------------------------------------------------
create or replace function public.registrar_resultado_amistoso(p_amistoso uuid, p_sets jsonb)
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
  if not (coalesce(app.es_admin_grupo(a.grupo_id), false)
          or a.creado_por = (select auth.uid())
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

-- ---------------------------------------------------------------------
-- publicar_marcador: amistoso sin grupo permitido (juega o lo creó)
-- ---------------------------------------------------------------------
create or replace function public.publicar_marcador(p_amistoso uuid, p_partido uuid, p_estado jsonb)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  g uuid;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  if (p_amistoso is null) = (p_partido is null) then
    raise exception 'Indica un partido.' using errcode = '22023';
  end if;
  if p_estado is not null and jsonb_typeof(p_estado) <> 'object' then
    raise exception 'Marcador no válido.' using errcode = '22023';
  end if;

  if p_amistoso is not null then
    select grupo_id into g from public.amistoso where id = p_amistoso;
    if not found or not (
         coalesce(app.es_admin_grupo(g), false)
         or exists (select 1 from public.amistoso a where a.id = p_amistoso and a.creado_por = uid)
         or exists (select 1 from public.amistoso_jugador j
                    where j.amistoso_id = p_amistoso and j.usuario_id = uid)) then
      raise exception 'No puedes puntuar este partido.' using errcode = '42501';
    end if;
    if p_estado is null then
      delete from public.marcador_vivo where amistoso_id = p_amistoso;
    else
      insert into public.marcador_vivo (grupo_id, amistoso_id, estado)
      values (g, p_amistoso, p_estado)
      on conflict (amistoso_id) do update
        set estado = excluded.estado, updated_at = now(), actualizado_por = uid;
    end if;
  else
    g := app.grupo_de_partido(p_partido);
    if g is null or not (
         app.puede_gestionar_liga((select liga_id from public.partido where id = p_partido))
         or app.juega_en_partido(p_partido)) then
      raise exception 'No puedes puntuar este partido.' using errcode = '42501';
    end if;
    if p_estado is null then
      delete from public.marcador_vivo where partido_id = p_partido;
    else
      insert into public.marcador_vivo (grupo_id, partido_id, estado)
      values (g, p_partido, p_estado)
      on conflict (partido_id) do update
        set estado = excluded.estado, updated_at = now(), actualizado_por = uid;
    end if;
  end if;
end;
$$;
