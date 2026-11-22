-- =====================================================================
-- Los padres, madres y tutores invitados por la escuela (rol TUTOR) dan de alta a sus propios hijos.
-- La escuela solo tiene que invitar al tutor por email (sin elegir alumno); al registrarse, él añade
-- a sus hijos con nombre, apellidos y fecha de nacimiento. La ficha queda en la organización de la
-- escuela (que la ve y la gestiona) y asociada al tutor.
-- =====================================================================
create or replace function public.anadir_hijo(
  p_org uuid, p_nombre text, p_apellidos text, p_fecha_nacimiento date, p_parentesco text default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare uid uuid := auth.uid(); jid uuid; nom text := nullif(btrim(p_nombre), '');
        ape text := nullif(btrim(coalesce(p_apellidos, '')), '');
begin
  if uid is null or not app.tiene_rol(p_org, array['TUTOR']) then
    raise exception 'sin permiso: solo los tutores de esta organización pueden añadir hijos' using errcode = '42501';
  end if;
  if nom is null then raise exception 'el nombre es obligatorio' using errcode = '23514'; end if;
  if p_fecha_nacimiento is null or p_fecha_nacimiento > current_date
     or p_fecha_nacimiento < current_date - interval '100 years' then
    raise exception 'fecha de nacimiento no válida' using errcode = '23514';
  end if;
  if (select count(*) from tutor_jugador tj join jugador j on j.id = tj.jugador_id
      where tj.tutor_usuario_id = uid and j.organizacion_id = p_org) >= 12 then
    raise exception 'has alcanzado el máximo de hijos que se pueden añadir' using errcode = '23514';
  end if;
  -- Si la escuela ya dio de alta a ese alumno, no se duplica ni se enlaza sin permiso: que lo asocie la escuela.
  if exists (select 1 from jugador where organizacion_id = p_org and lower(btrim(nombre)) = lower(nom)
             and lower(btrim(coalesce(apellidos, ''))) = lower(coalesce(ape, ''))
             and fecha_nacimiento = p_fecha_nacimiento) then
    raise exception 'ese alumno ya está dado de alta: pide a tu escuela que te asocie como tutor' using errcode = '23505';
  end if;
  insert into jugador (organizacion_id, nombre, apellidos, fecha_nacimiento)
    values (p_org, left(nom, 120), left(ape, 120), p_fecha_nacimiento) returning id into jid;
  insert into tutor_jugador (tutor_usuario_id, jugador_id, parentesco)
    values (uid, jid, left(nullif(btrim(coalesce(p_parentesco, '')), ''), 40));
  return jid;
end $$;

revoke execute on function public.anadir_hijo(uuid, text, text, date, text) from public, anon;
grant execute on function public.anadir_hijo(uuid, text, text, date, text) to authenticated;
