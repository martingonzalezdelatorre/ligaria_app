-- =====================================================================
-- Un jugador mayor de edad (18 años cumplidos) no necesita la cuenta de un adulto:
-- no se le pueden asociar padres, madres ni tutores. Aplica a anadir_tutor y a
-- crear_jugador_con_tutores (ambas pasan por app.anadir_tutor_int).
-- =====================================================================
create or replace function app.anadir_tutor_int(
  p_jugador uuid, p_nombre text, p_parentesco text, p_email text, p_telefono text)
returns text language plpgsql security definer set search_path = public, pg_temp as $$
declare
  org uuid := app.org_de_jugador(p_jugador);
  mail text := lower(btrim(coalesce(p_email, '')));
  par text := nullif(btrim(coalesce(p_parentesco, '')), '');
  nac date;
  inv invitacion; uid uuid; rid smallint;
begin
  if org is null then raise exception 'el jugador no pertenece a ninguna organización' using errcode = '23514'; end if;
  select fecha_nacimiento into nac from jugador where id = p_jugador;
  if nac is not null and age(current_date, nac) >= interval '18 years' then
    raise exception 'el jugador es mayor de edad y no necesita tutor' using errcode = '23514';
  end if;
  if mail !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'el email del tutor no es válido' using errcode = '23514';
  end if;
  select id into rid from rol where codigo = 'TUTOR';
  -- Una misma persona no se asocia dos veces al mismo jugador.
  if exists (select 1 from invitacion where jugador_id = p_jugador and lower(email) = mail
             and rol_id = rid and aplicada_en is null)
     or exists (select 1 from tutor_jugador tj join usuario u on u.id = tj.tutor_usuario_id
                where tj.jugador_id = p_jugador and lower(u.email) = mail) then
    raise exception 'ese tutor ya está asociado al jugador' using errcode = '23505';
  end if;
  insert into invitacion (organizacion_id, email, rol_id, jugador_id, parentesco, nombre_contacto, telefono_contacto)
    values (org, mail, rid, p_jugador, par, left(nullif(btrim(coalesce(p_nombre, '')), ''), 160),
            left(nullif(btrim(coalesce(p_telefono, '')), ''), 40))
    returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); return 'vinculado'; end if;
  return 'pendiente';
end $$;
revoke execute on function app.anadir_tutor_int(uuid, text, text, text, text) from public, anon, authenticated;
