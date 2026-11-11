-- Ligaria · 0002 · Funciones auxiliares, auditoría, RLS y RPC de privacidad
-- Requiere auth.uid() (Supabase Auth).

-- ───────── Helpers (security definer: evitan recursión de RLS) ─────────
create function app.es_superadmin() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia where usuario_id = auth.uid() and rol = 'superadmin')
$$;

create function app.es_miembro(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia where usuario_id = auth.uid() and escuela_id = org)
$$;

create function app.tiene_rol(org uuid, r rol_t) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from pertenencia
                 where usuario_id = auth.uid() and escuela_id = org and rol = r)
$$;

-- Gestiona la liga/escuela: admin de escuela u organizador de liga de esa escuela, o superadmin
create function app.gestiona(org uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from pertenencia where usuario_id = auth.uid() and escuela_id = org
      and rol in ('admin_escuela','organizador_liga'))
$$;

create function app.es_yo(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from persona where id = p and usuario_id = auth.uid())
$$;

create function app.es_tutor_de(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from tutoria where persona_id = p and tutor_usuario_id = auth.uid())
$$;

create function app.entrena_equipo(eq uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from equipo_entrenador where equipo_id = eq and usuario_id = auth.uid())
$$;

create function app.entrena_a(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from equipo_miembro em
    join equipo_entrenador ee on ee.equipo_id = em.equipo_id
    where em.persona_id = p and ee.usuario_id = auth.uid())
$$;

-- ¿Puede el usuario ver la competición? organizadora, inscrita o superadmin
create function app.ve_competicion(comp uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.es_superadmin() or exists (
    select 1 from competicion c
    where c.id = comp and (
      app.es_miembro(c.organization_id)
      or exists (select 1 from inscripcion_equipo i
                 where i.competicion_id = c.id and app.es_miembro(i.escuela_id))))
$$;

create function app.edad(nac date) returns int
language sql immutable as $$ select extract(year from age(current_date, nac))::int $$;

create function app.consentimiento_vigente(p uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select c.otorgado from consentimiento c
                   where c.persona_id = p and c.tipo = 'tratamiento_datos'
                   order by c.fecha desc limit 1), false)
$$;

-- ───────── Auditoría genérica ─────────
create function app.auditar() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare n jsonb; o jsonb; esc uuid;
begin
  n := case when tg_op <> 'DELETE' then to_jsonb(new) end;
  o := case when tg_op <> 'INSERT' then to_jsonb(old) end;
  esc := coalesce((coalesce(n, o)->>'organization_id'), (coalesce(n, o)->>'escuela_id'))::uuid;
  insert into registro_cambios (escuela_id, usuario_id, tabla, registro_id, accion, antes, despues)
  values (esc, auth.uid(), tg_table_name, coalesce(n, o)->>'id', tg_op, o, n);
  return coalesce(new, old);
end $$;

create trigger aud_competicion after insert or update or delete on competicion
  for each row execute function app.auditar();
create trigger aud_encuentro after insert or update or delete on encuentro
  for each row execute function app.auditar();
create trigger aud_persona after insert or update or delete on persona
  for each row execute function app.auditar();
create trigger aud_pertenencia after insert or update or delete on pertenencia
  for each row execute function app.auditar();
-- partido/resultado_set no tienen columna id: auditan con PK compuesta
create function app.auditar_resultado() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare n jsonb; o jsonb;
begin
  n := case when tg_op <> 'DELETE' then to_jsonb(new) end;
  o := case when tg_op <> 'INSERT' then to_jsonb(old) end;
  insert into registro_cambios (escuela_id, usuario_id, tabla, registro_id, accion, antes, despues)
  values ((coalesce(n, o)->>'organization_id')::uuid, auth.uid(), tg_table_name,
          (coalesce(n, o)->>'partido_id'), tg_op, o, n);
  return coalesce(new, old);
end $$;
create trigger aud_resultado_set after insert or update or delete on resultado_set
  for each row execute function app.auditar_resultado();

-- ───────── RLS ─────────
alter table escuela enable row level security;
alter table escuela_modulo enable row level security;
alter table usuario enable row level security;
alter table pertenencia enable row level security;
alter table persona enable row level security;
alter table tutoria enable row level security;
alter table consentimiento enable row level security;
alter table deporte enable row level security;
alter table categoria enable row level security;
alter table temporada enable row level security;
alter table competicion enable row level security;
alter table equipo enable row level security;
alter table equipo_miembro enable row level security;
alter table equipo_entrenador enable row level security;
alter table inscripcion_equipo enable row level security;
alter table jornada enable row level security;
alter table encuentro enable row level security;
alter table partido enable row level security;
alter table partido_participante enable row level security;
alter table resultado_set enable row level security;
alter table notificacion enable row level security;
alter table registro_cambios enable row level security;
alter table registro_acceso_menores enable row level security;

-- escuela
create policy escuela_sel on escuela for select
  using (app.es_superadmin() or app.es_miembro(id));
create policy escuela_mod on escuela for all
  using (app.es_superadmin()) with check (app.es_superadmin());
create policy modulo_sel on escuela_modulo for select
  using (app.es_superadmin() or app.es_miembro(escuela_id));
create policy modulo_mod on escuela_modulo for all
  using (app.es_superadmin()) with check (app.es_superadmin());

-- usuario: uno mismo, superadmin o admin de una escuela donde pertenece
create policy usuario_sel on usuario for select using (
  id = auth.uid() or app.es_superadmin() or exists (
    select 1 from pertenencia p where p.usuario_id = usuario.id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy usuario_upd on usuario for update
  using (id = auth.uid()) with check (id = auth.uid());

-- pertenencia
create policy pert_sel on pertenencia for select using (
  usuario_id = auth.uid() or app.es_superadmin()
  or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')));
create policy pert_mod on pertenencia for all
  using (app.es_superadmin() or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')))
  with check (app.es_superadmin() or (escuela_id is not null and rol <> 'superadmin'
              and app.tiene_rol(escuela_id, 'admin_escuela')));

-- persona: fichas privadas solo para admin de su escuela, su entrenador, ella misma o su tutor
create policy persona_sel on persona for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
  or app.es_yo(id) or app.es_tutor_de(id) or app.entrena_a(id));
create policy persona_mod on persona for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));

create policy tutoria_sel on tutoria for select using (
  tutor_usuario_id = auth.uid() or app.es_superadmin()
  or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy tutoria_mod on tutoria for all
  using (app.es_superadmin()
         or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')))
  with check (app.es_superadmin()
         or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));

-- consentimiento: lo ve y lo otorga el tutor (o la propia persona si es mayor de 14)
create policy consent_sel on consentimiento for select using (
  app.es_superadmin() or app.es_tutor_de(persona_id) or app.es_yo(persona_id)
  or exists (select 1 from persona p where p.id = persona_id and app.tiene_rol(p.escuela_id, 'admin_escuela')));
create policy consent_ins on consentimiento for insert with check (
  (app.es_tutor_de(persona_id) and tutor_usuario_id = auth.uid())
  or (app.es_yo(persona_id) and exists (select 1 from persona p where p.id = persona_id and app.edad(p.fecha_nacimiento) >= 14)));

-- catálogos globales
create policy deporte_sel on deporte for select using (auth.uid() is not null);
create policy deporte_mod on deporte for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy categoria_sel on categoria for select using (auth.uid() is not null);
create policy categoria_mod on categoria for all using (app.es_superadmin()) with check (app.es_superadmin());
create policy temporada_sel on temporada for select using (auth.uid() is not null);
create policy temporada_mod on temporada for all using (app.es_superadmin()) with check (app.es_superadmin());

-- competiciones
create policy comp_sel on competicion for select using (app.ve_competicion(id));
create policy comp_mod on competicion for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));

-- equipos (datos internos de la escuela; otras escuelas usan las vistas públicas)
create policy equipo_sel on equipo for select using (app.es_superadmin() or app.es_miembro(escuela_id));
create policy equipo_mod on equipo for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy eqm_sel on equipo_miembro for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela') or app.entrena_equipo(equipo_id)
  or app.es_yo(persona_id) or app.es_tutor_de(persona_id));
create policy eqm_mod on equipo_miembro for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));
create policy eqe_sel on equipo_entrenador for select using (
  app.es_superadmin() or app.es_miembro(escuela_id));
create policy eqe_mod on equipo_entrenador for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela'));

create policy insc_sel on inscripcion_equipo for select using (app.ve_competicion(competicion_id));
create policy insc_mod on inscripcion_equipo for all
  using (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
         or exists (select 1 from competicion c where c.id = competicion_id and app.gestiona(c.organization_id)))
  with check (app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela')
         or exists (select 1 from competicion c where c.id = competicion_id and app.gestiona(c.organization_id)));

-- calendario y resultados: visibles a participantes; editables solo por la organizadora
create policy jornada_sel on jornada for select using (app.ve_competicion(competicion_id));
create policy jornada_mod on jornada for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy enc_sel on encuentro for select using (app.ve_competicion(competicion_id));
create policy enc_mod on encuentro for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy partido_sel on partido for select using (app.ve_competicion(competicion_id));
create policy partido_mod on partido for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy ppart_sel on partido_participante for select using (app.ve_competicion(competicion_id));
create policy ppart_mod on partido_participante for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));
create policy rset_sel on resultado_set for select using (app.ve_competicion(competicion_id));
create policy rset_mod on resultado_set for all
  using (app.gestiona(organization_id)) with check (app.gestiona(organization_id));

-- notificaciones propias
create policy notif_sel on notificacion for select using (usuario_id = auth.uid());
create policy notif_upd on notificacion for update
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- registros: solo lectura para quien corresponde
create policy regcamb_sel on registro_cambios for select using (
  app.es_superadmin() or (escuela_id is not null and app.tiene_rol(escuela_id, 'organizador_liga')
                          ) or (escuela_id is not null and app.tiene_rol(escuela_id, 'admin_escuela')));
create policy regacc_sel on registro_acceso_menores for select using (
  app.es_superadmin() or app.tiene_rol(escuela_id, 'admin_escuela') or app.es_tutor_de(persona_id));

-- ───────── Vistas públicas para ligas compartidas ─────────
-- Solo nombre y resultados. Corren con permisos del propietario y filtran por ve_competicion.
create view v_equipos_competicion as
  select i.competicion_id, e.id as equipo_id, e.nombre as equipo, s.id as escuela_id, s.nombre as escuela
  from inscripcion_equipo i
  join equipo e on e.id = i.equipo_id
  join escuela s on s.id = e.escuela_id
  where app.ve_competicion(i.competicion_id);

-- Nombre mostrado según visibilidad de la ficha y consentimiento (menores de 14)
create view v_jugadores_competicion as
  select pp.partido_id, pp.competicion_id, pp.lado, p.id as persona_id,
    case
      when app.es_superadmin() or app.es_miembro(p.escuela_id) then trim(p.nombre || ' ' || p.apellidos)
      when app.edad(p.fecha_nacimiento) < 14 and not app.consentimiento_vigente(p.id) then 'Jugador/a'
      when p.visibilidad_ficha = 'nombre_completo' then trim(p.nombre || ' ' || p.apellidos)
      when p.visibilidad_ficha = 'iniciales'
        then upper(left(p.nombre,1)) || '.' || coalesce(upper(left(nullif(p.apellidos,''),1)) || '.', '')
      else 'Jugador/a'
    end as nombre_mostrado
  from partido_participante pp
  join persona p on p.id = pp.persona_id
  where app.ve_competicion(pp.competicion_id);

-- ───────── RPC de privacidad y acceso a fichas ─────────
-- El tutor (o la propia persona mayor de 14) gestiona la visibilidad de la ficha.
create function public.actualizar_privacidad(
  p_persona uuid, p_visibilidad visibilidad_ficha_t, p_mostrar_foto boolean default false)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then raise exception 'persona no encontrada'; end if;
  if not (app.es_tutor_de(p_persona)
          or (app.es_yo(p_persona) and app.edad(p.fecha_nacimiento) >= 14)
          or app.tiene_rol(p.escuela_id, 'admin_escuela') or app.es_superadmin()) then
    raise exception 'sin permiso para gestionar la privacidad' using errcode = '42501';
  end if;
  update persona set visibilidad_ficha = p_visibilidad,
         mostrar_foto = p_mostrar_foto where id = p_persona;
end $$;

-- Lectura de ficha con registro de acceso si es menor de edad (< 18).
create function public.leer_ficha(p_persona uuid, p_contexto text default null)
returns setof persona language plpgsql security definer set search_path = public, pg_temp as $$
declare p persona;
begin
  select * into p from persona where id = p_persona;
  if not found then return; end if;
  if not (app.es_superadmin() or app.tiene_rol(p.escuela_id, 'admin_escuela')
          or app.es_yo(p_persona) or app.es_tutor_de(p_persona) or app.entrena_a(p_persona)) then
    raise exception 'sin acceso a la ficha' using errcode = '42501';
  end if;
  if app.edad(p.fecha_nacimiento) < 18 then
    insert into registro_acceso_menores (persona_id, escuela_id, usuario_id, contexto)
    values (p.id, p.escuela_id, auth.uid(), p_contexto);
  end if;
  return next p;
end $$;

-- ───────── Permisos ─────────
grant usage on schema public, app to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
grant execute on all functions in schema app to authenticated;
revoke execute on function public.actualizar_privacidad(uuid, visibilidad_ficha_t, boolean) from public;
revoke execute on function public.leer_ficha(uuid, text) from public;
grant execute on function public.actualizar_privacidad(uuid, visibilidad_ficha_t, boolean) to authenticated;
grant execute on function public.leer_ficha(uuid, text) to authenticated;
-- registros: nadie escribe directamente
revoke insert, update, delete on registro_cambios, registro_acceso_menores from authenticated;
