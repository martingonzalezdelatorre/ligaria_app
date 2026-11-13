-- Ligaria · 0014 · Días de juego y nº de jornadas configurables en el calendario
-- competicion.reglas admite:
--   dias_juego: 'finde' | 'semana' | 'ambos'  → las fechas de las jornadas caen en esos días
--   jornadas:   nº de jornadas a jugar (por defecto todas las del todos contra todos)
-- Sin dias_juego se mantiene el comportamiento anterior (fecha de inicio + días entre jornadas).

create or replace function public.generar_calendario(
  p_competicion uuid, p_fecha_inicio date default null, p_dias_entre_jornadas int default 7)
returns int language plpgsql set search_path = public, pg_temp as $$
declare
  c competicion;
  equipos uuid[];
  t uuid[];                 -- equipos (+ null si impar)
  m int; n int;
  vueltas int; ind int; dob int;
  r int; i int; k int; v int;
  pos uuid[];
  a uuid; b uuid; tmp uuid;
  bal jsonb := '{}'::jsonb; orient jsonb := '{}'::jsonb;
  clave text; ba int; bb int;
  jid uuid; eid uuid; pid uuid;
  num int := 0; creados int := 0; orden int;
  modo text; limite int; maximo int; inicio date; d date; base int; dow int;
  fechas date[] := '{}';
  idx int;
begin
  select * into c from competicion where id = p_competicion;
  if not found then raise exception 'competición no encontrada'; end if;
  if not app.gestiona(c.organization_id) then
    raise exception 'sin permiso para generar el calendario' using errcode = '42501';
  end if;
  if c.tipo <> 'liga' then raise exception 'solo se implementan ligas'; end if;
  if exists (select 1 from encuentro where competicion_id = c.id and estado <> 'programado') then
    raise exception 'ya hay resultados propuestos o confirmados; no se puede regenerar' using errcode = '23514';
  end if;

  vueltas := coalesce((c.reglas->>'vueltas')::int, 1);
  if vueltas not in (1, 2) then raise exception 'vueltas debe ser 1 o 2'; end if;
  ind := coalesce((c.reglas#>>'{partidos_por_encuentro,individuales}')::int, 2);
  dob := coalesce((c.reglas#>>'{partidos_por_encuentro,dobles}')::int, 1);

  select array_agg(equipo_id order by created_at, equipo_id) into equipos
    from inscripcion_equipo where competicion_id = c.id;
  n := coalesce(array_length(equipos, 1), 0);
  if n < 2 then raise exception 'se necesitan al menos 2 equipos inscritos'; end if;

  t := equipos;
  if n % 2 = 1 then t := t || array[null::uuid]; end if;
  m := array_length(t, 1);

  -- Nº de jornadas: por defecto todas (todos contra todos); la liga puede fijar un número menor.
  maximo := (m - 1) * vueltas;
  limite := least(greatest(coalesce((c.reglas->>'jornadas')::int, maximo), 1), maximo);

  -- Días de juego: 'finde' (sábados), 'semana' (un día laborable fijo) o 'ambos' (ambos a la vez).
  modo := c.reglas->>'dias_juego';
  if modo is not null then
    if modo not in ('finde', 'semana', 'ambos') then raise exception 'dias_juego no válido'; end if;
    inicio := coalesce(p_fecha_inicio, c.fecha_inicio);
    if inicio is null then raise exception 'indica la fecha de inicio de la liga' using errcode = '23514'; end if;
    d := inicio;
    while extract(isodow from d) > 5 loop d := d + 1; end loop;
    base := extract(isodow from d)::int;   -- día laborable de referencia (el de la fecha de inicio)
    d := inicio;
    while coalesce(array_length(fechas, 1), 0) < limite loop
      dow := extract(isodow from d)::int;
      if (modo = 'finde' and dow = 6) or (modo = 'semana' and dow = base)
         or (modo = 'ambos' and (dow = 6 or dow = base)) then
        fechas := fechas || d;
      end if;
      d := d + 1;
    end loop;
    if c.fecha_fin is not null and fechas[limite] > c.fecha_fin then
      raise exception 'no caben % jornadas entre las fechas de la liga con esos días de juego', limite using errcode = '23514';
    end if;
  end if;

  delete from jornada where competicion_id = c.id;   -- cascada: encuentros, partidos, descansos

  for idx in 1..limite loop
    v := (idx - 1) / (m - 1) + 1;
    r := (idx - 1) % (m - 1);
    begin
      num := num + 1;
      insert into jornada (competicion_id, organization_id, numero, fecha)
        values (c.id, c.organization_id, num,
                case when modo is not null then fechas[num]
                     when p_fecha_inicio is null then null
                     else p_fecha_inicio + (num - 1) * p_dias_entre_jornadas end)
        returning id into jid;

      -- posiciones tras r rotaciones (t[1] fijo)
      pos := array[t[1]];
      for k in 2..m loop
        pos := pos || t[2 + ((k - 2 - r) % (m - 1) + (m - 1)) % (m - 1)];
      end loop;

      for i in 1..m / 2 loop
        a := pos[i]; b := pos[m + 1 - i];
        if a is null or b is null then
          insert into descanso (jornada_id, competicion_id, organization_id, equipo_id)
            values (jid, c.id, c.organization_id, coalesce(a, b));
          continue;
        end if;
        -- Localía: 1ª vuelta equilibrada de forma voraz (el equipo con más partidos de local
        -- pasa a visitante; en empate se alterna por jornada). 2ª vuelta: invierte la 1ª.
        clave := least(a::text, b::text) || '|' || greatest(a::text, b::text);
        if v = 1 then
          ba := coalesce((bal->>a::text)::int, 0);
          bb := coalesce((bal->>b::text)::int, 0);
          if ba > bb or (ba = bb and (r + i) % 2 = 1) then tmp := a; a := b; b := tmp; end if;
          bal := bal || jsonb_build_object(a::text, coalesce((bal->>a::text)::int, 0) + 1,
                                           b::text, coalesce((bal->>b::text)::int, 0) - 1);
          orient := orient || jsonb_build_object(clave, a::text);
        else
          if (orient->>clave)::uuid = a then tmp := a; a := b; b := tmp; end if;
        end if;

        insert into encuentro (competicion_id, organization_id, jornada_id, local_equipo_id, visitante_equipo_id)
          values (c.id, c.organization_id, jid, a, b) returning id into eid;
        creados := creados + 1;

        orden := 0;
        for k in 1..ind loop
          orden := orden + 1;
          insert into partido (encuentro_id, competicion_id, organization_id, orden, tipo)
            values (eid, c.id, c.organization_id, orden, 'individual');
        end loop;
        for k in 1..dob loop
          orden := orden + 1;
          insert into partido (encuentro_id, competicion_id, organization_id, orden, tipo)
            values (eid, c.id, c.organization_id, orden, 'dobles');
        end loop;
      end loop;
    end;
  end loop;
  return creados;
end $$;
revoke execute on function public.generar_calendario(uuid, date, int) from public;
grant execute on function public.generar_calendario(uuid, date, int) to authenticated;

-- Corrección: la 0013 redefinió la validación de inscripción sin la restricción municipal de la 0010.
-- Se unifican aquí: mismo deporte/categoría, solo escuelas del municipio, calendario sin generar y máximo de equipos.
create or replace function app.validar_inscripcion() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo; ayto uuid;
begin
  select * into c from competicion where id = new.competicion_id;
  select * into e from equipo where id = new.equipo_id;
  if c.tipo <> 'liga' then raise exception 'solo se implementan ligas'; end if;
  if c.deporte_id <> e.deporte_id then
    raise exception 'el deporte del equipo no coincide con la competición' using errcode = '23514';
  end if;
  if c.categoria_id is not null and e.categoria_id is distinct from c.categoria_id then
    raise exception 'la categoría del equipo no coincide con la competición' using errcode = '23514';
  end if;
  select a.id into ayto from ayuntamiento a where a.escuela_id = c.organization_id;
  if ayto is not null and not exists (
       select 1 from escuela s where s.id = e.escuela_id and s.ayuntamiento_id = ayto) then
    raise exception 'esta liga es solo para escuelas del municipio' using errcode = '23514';
  end if;
  if exists (select 1 from jornada where competicion_id = c.id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  if c.max_equipos is not null
     and (select count(*) from inscripcion_equipo where competicion_id = c.id) >= c.max_equipos then
    raise exception 'la liga ya tiene el máximo de equipos (%)', c.max_equipos using errcode = '23514';
  end if;
  return new;
end $$;
