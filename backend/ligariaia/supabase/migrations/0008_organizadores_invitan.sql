-- =====================================================================
-- Un organizador de ligas puede invitar a su equipo
-- Hasta ahora solo invitaba el administrador de la organización (ADMIN_ESCUELAS o superadmin), así que
-- un ayuntamiento, cuyo responsable es ORGANIZADOR_LIGAS, no podía añadir a nadie de su equipo.
-- Ahora quien gestiona la organización (ORGANIZADOR_LIGAS) puede invitar a otros ORGANIZADOR_LIGAS de
-- esa misma organización. No puede dar ningún otro rol (administrador, entrenador, tutor, jugador): no
-- gana más poder del que ya tiene. Un co-organizador de una sola liga no puede invitar.
-- =====================================================================

-- Requisito: las migraciones se aplican en orden.
do $$ begin
  if to_regtype('jornada_fase') is null then
    raise exception 'Falta la migración 0007 (eliminatoria y grupos). Aplica las migraciones en orden: 0001 … 0008.';
  end if;
end $$;

create or replace function public.invitar_usuario(
  p_organizacion uuid, p_email text, p_rol text, p_jugador uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(btrim(p_email)); rid smallint;
begin
  if not (app.admin_org(p_organizacion)
          or (p_rol = 'ORGANIZADOR_LIGAS' and app.gestiona(p_organizacion))) then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if p_rol = 'ADMINISTRADOR' then raise exception 'rol no invitable'; end if;
  select id into rid from rol where codigo = p_rol;
  if rid is null then raise exception 'rol desconocido'; end if;
  if p_jugador is not null and app.org_de_jugador(p_jugador) is distinct from p_organizacion then
    raise exception 'el jugador no pertenece a la organización';
  end if;
  insert into invitacion (organizacion_id, email, rol_id, jugador_id)
    values (p_organizacion, mail, rid, p_jugador) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;

-- Organizadores de ligas de una organización (los ve quien la gestiona).
create view public.v_organizadores_org as
  select ar.organizacion_id, u.id as usuario_id, u.email,
         trim(coalesce(u.nombre, '') || ' ' || coalesce(u.apellidos, '')) as nombre
  from asignacion_rol ar
  join rol r on r.id = ar.rol_id and r.codigo = 'ORGANIZADOR_LIGAS'
  join usuario u on u.id = ar.usuario_id
  where ar.organizacion_id is not null and app.gestiona(ar.organizacion_id);

grant select on public.v_organizadores_org to authenticated;
