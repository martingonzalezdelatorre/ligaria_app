-- =====================================================================
-- Corregir los datos de un padre, madre o tutor cuya invitación sigue pendiente
-- (nombre, parentesco, correo y teléfono). Solo el administrador de la organización del jugador.
-- Devuelve 'pendiente' o 'vinculado' (si el nuevo correo ya tenía cuenta, se vincula al momento).
-- =====================================================================
create or replace function public.editar_tutor_pendiente(
  p_jugador uuid, p_email_actual text, p_nombre text, p_parentesco text, p_email text, p_telefono text default null)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare
  org uuid := app.org_de_jugador(p_jugador);
  actual text := lower(btrim(coalesce(p_email_actual, '')));
  mail text := lower(btrim(coalesce(p_email, '')));
  rid smallint; inv invitacion; uid uuid;
begin
  if org is null or not app.admin_org(org) then
    raise exception 'sin permiso para editar tutores de este jugador' using errcode = '42501';
  end if;
  if mail !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'el email del tutor no es válido' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'TUTOR';
  select * into inv from invitacion
    where jugador_id = p_jugador and rol_id = rid and lower(email) = actual and aplicada_en is null;
  if inv.id is null then
    raise exception 'la invitación ya no está pendiente' using errcode = '23514';
  end if;
  if mail <> actual and (
       exists (select 1 from invitacion where jugador_id = p_jugador and rol_id = rid
               and lower(email) = mail and aplicada_en is null)
       or exists (select 1 from tutor_jugador tj join usuario u on u.id = tj.tutor_usuario_id
                  where tj.jugador_id = p_jugador and lower(u.email) = mail)) then
    raise exception 'ese tutor ya está asociado al jugador' using errcode = '23505';
  end if;
  update invitacion set
      email = mail,
      parentesco = nullif(btrim(coalesce(p_parentesco, '')), ''),
      nombre_contacto = left(nullif(btrim(coalesce(p_nombre, '')), ''), 160),
      telefono_contacto = left(nullif(btrim(coalesce(p_telefono, '')), ''), 40)
    where id = inv.id returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); return 'vinculado'; end if;
  return 'pendiente';
end $$;
revoke execute on function public.editar_tutor_pendiente(uuid, text, text, text, text, text) from public, anon;
grant execute on function public.editar_tutor_pendiente(uuid, text, text, text, text, text) to authenticated;
