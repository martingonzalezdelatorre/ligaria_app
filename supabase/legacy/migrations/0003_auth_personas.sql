-- Ligaria · 0003 · Alta de usuarios, invitaciones, consentimiento de menores y módulos

-- ───────── Invitaciones ─────────
-- El admin de escuela invita por email con un rol; se aplica al registrarse (o ya, si el usuario existe).
create table invitacion (
  id uuid primary key default gen_random_uuid(),
  escuela_id uuid not null references escuela(id) on delete cascade,
  email text not null,
  rol rol_t not null check (rol <> 'superadmin'),
  persona_id uuid references persona(id) on delete cascade,  -- tutor→menor, alumno→su ficha
  created_at timestamptz not null default now(),
  aplicada_en timestamptz
);
create index invitacion_email_idx on invitacion (lower(email)) where aplicada_en is null;
alter table invitacion enable row level security;
create policy inv_sel on invitacion for select
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy inv_del on invitacion for delete
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
grant select, delete on invitacion to authenticated;

create function app.aplicar_invitacion(i invitacion, uid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  insert into pertenencia (usuario_id, escuela_id, rol) values (uid, i.escuela_id, i.rol)
    on conflict do nothing;
  if i.persona_id is not null then
    if i.rol = 'tutor' then
      insert into tutoria (persona_id, tutor_usuario_id) values (i.persona_id, uid) on conflict do nothing;
    elsif i.rol = 'alumno' then
      update persona set usuario_id = uid where id = i.persona_id and usuario_id is null;
    end if;
  end if;
  update invitacion set aplicada_en = now() where id = i.id;
end $$;

-- Alta en auth.users → fila en usuario + invitaciones pendientes por email
create function app.alta_usuario() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare i invitacion; mail text;
begin
  mail := lower(coalesce(to_jsonb(new)->>'email', ''));
  insert into usuario (id, email, nombre)
    values (new.id, mail, coalesce(to_jsonb(new)->'raw_user_meta_data'->>'nombre', split_part(mail, '@', 1)))
    on conflict (id) do nothing;
  for i in select * from invitacion where lower(email) = mail and aplicada_en is null loop
    perform app.aplicar_invitacion(i, new.id);
  end loop;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function app.alta_usuario();

-- RPC: invitar (o asignar directamente si ya existe el usuario)
create function public.invitar_usuario(
  p_escuela uuid, p_email text, p_rol rol_t, p_persona uuid default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare inv invitacion; uid uuid; mail text := lower(trim(p_email));
begin
  if not (app.es_superadmin() or app.tiene_rol(p_escuela, 'admin_escuela')) then
    raise exception 'sin permiso para invitar' using errcode = '42501';
  end if;
  if p_rol = 'superadmin' then raise exception 'rol no invitable'; end if;
  if p_persona is not null and not exists (select 1 from persona where id = p_persona and escuela_id = p_escuela) then
    raise exception 'la persona no pertenece a la escuela';
  end if;
  insert into invitacion (escuela_id, email, rol, persona_id)
    values (p_escuela, mail, p_rol, p_persona) returning * into inv;
  select id into uid from usuario where lower(email) = mail;
  if uid is not null then perform app.aplicar_invitacion(inv, uid); end if;
  return inv.id;
end $$;
revoke execute on function public.invitar_usuario(uuid, text, rol_t, uuid) from public;
grant execute on function public.invitar_usuario(uuid, text, rol_t, uuid) to authenticated;

-- ───────── Menores de 14: no entran en equipos sin consentimiento del tutor ─────────
create function app.exigir_consentimiento() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare nac date;
begin
  select fecha_nacimiento into nac from persona where id = new.persona_id;
  if app.edad(nac) < 14 and not app.consentimiento_vigente(new.persona_id) then
    raise exception 'menor de 14 años sin consentimiento del tutor' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger eqm_consentimiento before insert on equipo_miembro
  for each row execute function app.exigir_consentimiento();

-- ───────── Módulos activables ─────────
create function app.modulo_activo(org uuid, m text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select activo from escuela_modulo where escuela_id = org and modulo = m), false)
$$;
grant execute on function app.modulo_activo(uuid, text) to authenticated;

-- Crear/gestionar competiciones exige el módulo 'competiciones' en la escuela organizadora
drop policy comp_mod on competicion;
create policy comp_mod on competicion for all
  using (app.gestiona(organization_id))
  with check (app.gestiona(organization_id) and app.modulo_activo(organization_id, 'competiciones'));

-- ───────── Mis pertenencias (para el cliente) ─────────
create view v_mis_pertenencias as
  select p.id, p.escuela_id, s.nombre as escuela, p.rol
  from pertenencia p left join escuela s on s.id = p.escuela_id
  where p.usuario_id = auth.uid();
grant select on v_mis_pertenencias to authenticated;
