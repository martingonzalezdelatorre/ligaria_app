-- =====================================================================
-- Ligaria IA - Notificaciones (bandeja en la app + cola de email).
-- `notificacion` es la fuente de verdad: la app la recibe por Realtime y la muestra como
-- notificación local; la Edge Function `enviar-notificaciones` envía por SMTP las filas con
-- email_estado = 'pendiente'. Se escribe solo desde triggers / app.notificar().
-- =====================================================================

create table public.notificacion (
  id                uuid primary key default gen_random_uuid(),
  usuario_id        uuid not null references public.usuario (id) on delete cascade,
  tipo              text not null,
  titulo            text not null,
  cuerpo            text not null default '',
  datos             jsonb not null default '{}'::jsonb,
  leida_at          timestamptz,
  email_estado      text not null default 'pendiente'
                    check (email_estado in ('pendiente', 'enviado', 'error', 'omitido')),
  email_intentos    smallint not null default 0,
  email_enviado_at  timestamptz,
  created_at        timestamptz not null default now()
);
create index idx_notificacion_usuario on public.notificacion (usuario_id, created_at desc);
create index idx_notificacion_email_pendiente on public.notificacion (created_at)
  where email_estado in ('pendiente', 'error');

create table public.notificacion_preferencia (
  usuario_id  uuid not null references public.usuario (id) on delete cascade,
  tipo        text not null,
  app         boolean not null default true,
  email       boolean not null default true,
  primary key (usuario_id, tipo)
);

alter table public.notificacion enable row level security;
alter table public.notificacion_preferencia enable row level security;

create policy notificacion_sel on public.notificacion for select to authenticated
  using (usuario_id = (select auth.uid()));
-- Solo se puede marcar como leída (columna leida_at) una notificación propia.
create policy notificacion_upd on public.notificacion for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));

create policy notif_pref_sel on public.notificacion_preferencia for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy notif_pref_ins on public.notificacion_preferencia for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy notif_pref_upd on public.notificacion_preferencia for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));

-- 0002 concede permisos amplios sobre todas las tablas: aquí se acota a lo necesario.
revoke all on public.notificacion, public.notificacion_preferencia from authenticated;
grant select on public.notificacion to authenticated;
grant update (leida_at) on public.notificacion to authenticated;
grant select, insert, update on public.notificacion_preferencia to authenticated;

-- ---------------------------------------------------------------------
-- app.notificar: crea la notificación respetando las preferencias del destinatario.
-- App desactivada => queda ya leída (no aparece en la bandeja). Email desactivado => 'omitido'.
-- Ambos desactivados => no se crea fila. Nunca notifica al autor del evento (p_autor).
-- ---------------------------------------------------------------------
create function app.notificar(
  p_usuario uuid, p_tipo text, p_titulo text, p_cuerpo text default '',
  p_datos jsonb default '{}'::jsonb, p_autor uuid default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_app boolean := true;
  v_email boolean := true;
begin
  if p_usuario is null or p_usuario is not distinct from p_autor then return; end if;
  select pr.app, pr.email into v_app, v_email
    from public.notificacion_preferencia pr
    where pr.usuario_id = p_usuario and pr.tipo = p_tipo;
  v_app := coalesce(v_app, true);
  v_email := coalesce(v_email, true);
  if not v_app and not v_email then return; end if;
  insert into public.notificacion (usuario_id, tipo, titulo, cuerpo, datos, email_estado, leida_at)
  values (p_usuario, p_tipo, p_titulo, coalesce(p_cuerpo, ''), coalesce(p_datos, '{}'::jsonb),
          case when v_email then 'pendiente' else 'omitido' end,
          case when v_app then null else now() end);
end;
$$;
revoke execute on function app.notificar(uuid, text, text, text, jsonb, uuid) from public, anon, authenticated;

-- Cuentas ligadas a un equipo: jugadores con cuenta, tutores y entrenadores.
create function app.destinatarios_equipo(p_equipo uuid) returns setof uuid
language sql stable security definer set search_path = '' as $$
  select j.usuario_id from public.equipo_miembro m
    join public.jugador j on j.id = m.jugador_id
    where m.equipo_id = p_equipo and j.usuario_id is not null
  union
  select t.tutor_usuario_id from public.equipo_miembro m
    join public.tutor_jugador t on t.jugador_id = m.jugador_id
    where m.equipo_id = p_equipo
  union
  select e.usuario_id from public.entrenador_equipo e where e.equipo_id = p_equipo
$$;
revoke execute on function app.destinatarios_equipo(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Eventos
-- ---------------------------------------------------------------------

-- Resultado registrado: avisa a los dos equipos del encuentro.
create function public.notif_encuentro_resultado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  v_local uuid; v_visit uuid; v_nom_l text; v_nom_v text; u uuid;
  v_titulo text;
begin
  if new.estado in ('FINALIZADO', 'NO_PRESENTADO')
     and (old.estado is distinct from new.estado
          or old.puntos_local is distinct from new.puntos_local
          or old.puntos_visitante is distinct from new.puntos_visitante) then
    select i.equipo_id, q.nombre into v_local, v_nom_l
      from public.inscripcion i join public.equipo q on q.id = i.equipo_id
      where i.id = new.local_inscripcion_id;
    select i.equipo_id, q.nombre into v_visit, v_nom_v
      from public.inscripcion i join public.equipo q on q.id = i.equipo_id
      where i.id = new.visitante_inscripcion_id;
    v_titulo := case when new.estado = 'NO_PRESENTADO' then 'Encuentro: no presentado'
                     else 'Resultado registrado' end;
    for u in
      select distinct d from (
        select app.destinatarios_equipo(v_local) as d
        union all select app.destinatarios_equipo(v_visit)) x
    loop
      perform app.notificar(u, 'resultado_registrado', v_titulo,
        format('%s %s - %s %s', v_nom_l, new.puntos_local, new.puntos_visitante, v_nom_v),
        jsonb_build_object('ruta', 'encuentro', 'encuentro_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_encuentro_resultado after update on public.encuentro
  for each row execute function public.notif_encuentro_resultado();

-- Calendario generado: la competición pasa a EN_CURSO y se avisa a los equipos inscritos.
create function public.notif_competicion_en_curso() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  u uuid;
begin
  if new.estado = 'EN_CURSO' and old.estado is distinct from 'EN_CURSO' then
    for u in
      select distinct app.destinatarios_equipo(i.equipo_id)
      from public.categoria ca
      join public.inscripcion i on i.categoria_id = ca.id and i.estado = 'ACEPTADA'
      where ca.competicion_id = new.id
    loop
      perform app.notificar(u, 'competicion_en_curso', 'Calendario disponible',
        format('La competición «%s» ya está en marcha. Consulta tus encuentros.', new.nombre),
        jsonb_build_object('ruta', 'competicion', 'competicion_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_competicion_en_curso after update of estado on public.competicion
  for each row execute function public.notif_competicion_en_curso();

-- Inscripción aceptada o rechazada: avisa al equipo.
create function public.notif_inscripcion_estado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  u uuid;
  v_comp text;
begin
  if new.estado in ('ACEPTADA', 'RECHAZADA') and old.estado is distinct from new.estado then
    select c.nombre into v_comp
      from public.categoria ca join public.competicion c on c.id = ca.competicion_id
      where ca.id = new.categoria_id;
    for u in select app.destinatarios_equipo(new.equipo_id) loop
      perform app.notificar(u, 'inscripcion_estado',
        case when new.estado = 'ACEPTADA' then 'Inscripción aceptada' else 'Inscripción rechazada' end,
        format('Tu inscripción en «%s» ha sido %s.', v_comp,
               case when new.estado = 'ACEPTADA' then 'aceptada' else 'rechazada' end),
        jsonb_build_object('ruta', 'inscripcion', 'inscripcion_id', new.id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_inscripcion_estado after update of estado on public.inscripcion
  for each row execute function public.notif_inscripcion_estado();

revoke execute on function public.notif_encuentro_resultado(), public.notif_competicion_en_curso(),
  public.notif_inscripcion_estado() from public, anon, authenticated;

-- Tiempo real: la app recibe los INSERT de sus propias notificaciones (filtrado por RLS).
-- (Se omite si la base no tiene publicación Realtime, p. ej. en los tests con PGlite.)
alter table public.notificacion replica identity full;
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.notificacion;
  end if;
end $$;
