-- Ligaria · 0013 · La liga tiene fechas de inicio/fin y un máximo de equipos
-- (ida y vuelta ya vive en reglas.vueltas; las jornadas se calculan a partir de los equipos).

alter table competicion
  add column fecha_inicio date,
  add column fecha_fin date,
  add column max_equipos int;

alter table competicion add constraint competicion_fechas_validas
  check (fecha_inicio is null or fecha_fin is null or fecha_fin >= fecha_inicio);
alter table competicion add constraint competicion_max_equipos_valido
  check (max_equipos is null or max_equipos >= 2);

-- La inscripción respeta el máximo de equipos.
create or replace function app.validar_inscripcion() returns trigger
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
  if c.max_equipos is not null
     and (select count(*) from inscripcion_equipo where competicion_id = c.id) >= c.max_equipos then
    raise exception 'la liga ya tiene el máximo de equipos (%)', c.max_equipos using errcode = '23514';
  end if;
  return new;
end $$;
