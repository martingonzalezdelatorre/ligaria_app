-- Ligaria · 0004 · Inscripción validada, descansos y generador de calendario (algoritmo del círculo)

-- ───────── Descansos (jornada con número impar de equipos) ─────────
create table descanso (
  jornada_id uuid not null,
  competicion_id uuid not null,
  organization_id uuid not null,
  equipo_id uuid not null references equipo(id),
  primary key (jornada_id, equipo_id),
  foreign key (jornada_id, competicion_id, organization_id)
    references jornada(id, competicion_id, organization_id) on delete cascade
);
alter table descanso enable row level security;
create policy descanso_sel on descanso for select using (app.ve_competicion(competicion_id));
create policy descanso_mod on descanso for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
grant select, insert, update, delete on descanso to authenticated;

-- ───────── Inscripción: mismo deporte/categoría y solo antes de generar el calendario ─────────
create function app.validar_inscripcion() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare c competicion; e equipo;
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
  if exists (select 1 from jornada where competicion_id = c.id) then
    raise exception 'el calendario ya está generado; no se admiten más inscripciones' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger insc_validar before insert on inscripcion_equipo
  for each row execute function app.validar_inscripcion();

-- ───────── Generador de calendario todos contra todos ─────────
-- Método del círculo: un equipo fijo y los demás rotan. Con número impar se añade un
-- "descanso" (bye) y el equipo emparejado con él descansa esa jornada.
-- Reglas leídas de competicion.reglas: vueltas (1|2) y partidos_por_encuentro.
-- Devuelve el número de encuentros creados. Se puede regenerar mientras no haya resultados.
create function public.generar_calendario(
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

  delete from jornada where competicion_id = c.id;   -- cascada: encuentros, partidos, descansos

  t := equipos;
  if n % 2 = 1 then t := t || array[null::uuid]; end if;
  m := array_length(t, 1);

  for v in 1..vueltas loop
    for r in 0..m - 2 loop
      num := num + 1;
      insert into jornada (competicion_id, organization_id, numero, fecha)
        values (c.id, c.organization_id, num,
                case when p_fecha_inicio is null then null
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
    end loop;
  end loop;
  return creados;
end $$;
revoke execute on function public.generar_calendario(uuid, date, int) from public;
grant execute on function public.generar_calendario(uuid, date, int) to authenticated;
