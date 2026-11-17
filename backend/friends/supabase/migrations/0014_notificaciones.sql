-- =====================================================================
-- Ligaria Friends - Notificaciones (bandeja en la app + cola de email).
-- `notificacion` es la fuente de verdad: la app la recibe por Realtime y la muestra como
-- notificación local; la Edge Function `enviar-notificaciones` envía por SMTP las filas con
-- email_estado = 'pendiente'. Se escribe solo desde triggers / app.notificar().
-- =====================================================================

create table public.notificacion (
  id                uuid primary key default gen_random_uuid(),
  usuario_id        uuid not null references public.perfil (id) on delete cascade,
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
  usuario_id  uuid not null references public.perfil (id) on delete cascade,
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
grant select on public.notificacion to authenticated;
grant update (leida_at) on public.notificacion to authenticated;

create policy notif_pref_sel on public.notificacion_preferencia for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy notif_pref_ins on public.notificacion_preferencia for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy notif_pref_upd on public.notificacion_preferencia for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));
grant select, insert, update on public.notificacion_preferencia to authenticated;

-- ---------------------------------------------------------------------
-- app.notificar: crea la notificación respetando las preferencias del destinatario.
-- App desactivada => no se crea fila (tampoco email). Email desactivado => 'omitido'.
-- Nunca notifica al propio autor del evento (p_autor).
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
  insert into public.notificacion (usuario_id, tipo, titulo, cuerpo, datos, email_estado,
                                   leida_at)
  values (p_usuario, p_tipo, p_titulo, coalesce(p_cuerpo, ''), coalesce(p_datos, '{}'::jsonb),
          case when v_email then 'pendiente' else 'omitido' end,
          -- Sin aviso en la app: queda ya leída para no aparecer en la bandeja.
          case when v_app then null else now() end);
end;
$$;
revoke execute on function app.notificar(uuid, text, text, text, jsonb, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Eventos
-- ---------------------------------------------------------------------

-- Resultado por confirmar: avisa a los demás jugadores del partido.
create function public.notif_amistoso_resultado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  j record;
begin
  if new.estado = 'JUGADO'
     and (old.estado is distinct from 'JUGADO' or new.ganador is distinct from old.ganador
          or new.sets is distinct from old.sets) then
    for j in select usuario_id from public.amistoso_jugador where amistoso_id = new.id loop
      perform app.notificar(j.usuario_id, 'resultado_por_confirmar',
        'Resultado por confirmar', 'Se ha registrado el resultado de un amistoso. Confírmalo.',
        jsonb_build_object('ruta', 'amistoso', 'amistoso_id', new.id, 'grupo_id', new.grupo_id),
        uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_amistoso_resultado after update on public.amistoso
  for each row execute function public.notif_amistoso_resultado();

create function public.notif_partido_resultado() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  j record;
begin
  if new.estado = 'JUGADO'
     and (old.estado is distinct from 'JUGADO' or new.ganador is distinct from old.ganador) then
    for j in
      select distinct pj.usuario_id
      from public.participante_jugador pj
      where pj.participante_id in (new.local_id, new.visitante_id)
    loop
      perform app.notificar(j.usuario_id, 'resultado_por_confirmar',
        'Resultado por confirmar', 'Se ha registrado el resultado de un partido de liga. Confírmalo.',
        jsonb_build_object('ruta', 'partido', 'partido_id', new.id, 'liga_id', new.liga_id), uid);
    end loop;
  end if;
  return null;
end;
$$;
create trigger trg_notif_partido_resultado after update on public.partido
  for each row execute function public.notif_partido_resultado();

-- Pedidos: nuevo pedido -> dueño del comercio; cambio de estado -> solicitante (o tienda si cancela).
create function public.notif_pedido() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  v_dueno uuid;
  v_comercio text;
begin
  select c.owner_id, c.nombre into v_dueno, v_comercio
    from public.comercio c where c.id = new.comercio_id;
  if tg_op = 'INSERT' then
    perform app.notificar(v_dueno, 'pedido_nuevo', 'Nuevo pedido',
      format('%s x%s en %s', new.producto_nombre, new.cantidad, v_comercio),
      jsonb_build_object('ruta', 'pedidos_recibidos', 'pedido_id', new.id), uid);
  elsif new.estado is distinct from old.estado then
    if new.estado = 'CANCELADO' then
      perform app.notificar(v_dueno, 'pedido_cancelado', 'Pedido cancelado',
        format('%s x%s en %s', new.producto_nombre, new.cantidad, v_comercio),
        jsonb_build_object('ruta', 'pedidos_recibidos', 'pedido_id', new.id), uid);
    else
      perform app.notificar(new.usuario_id, 'pedido_estado',
        'Tu pedido está ' || lower(new.estado::text),
        format('%s x%s en %s', new.producto_nombre, new.cantidad, v_comercio),
        jsonb_build_object('ruta', 'mis_pedidos', 'pedido_id', new.id), uid);
    end if;
  end if;
  return null;
end;
$$;
create trigger trg_notif_pedido after insert or update of estado on public.pedido
  for each row execute function public.notif_pedido();

-- Reserva de pista: avisa al dueño del club.
create function public.notif_reserva() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_dueno uuid;
  v_texto text;
begin
  select c.owner_id, format('%s - %s, %s', c.nombre, p.nombre,
           to_char(new.inicio at time zone 'Europe/Madrid', 'DD/MM HH24:MI'))
    into v_dueno, v_texto
    from public.pista p join public.comercio c on c.id = p.comercio_id
    where p.id = new.pista_id;
  perform app.notificar(v_dueno, 'reserva_nueva', 'Nueva reserva', v_texto,
    jsonb_build_object('ruta', 'reservas', 'reserva_id', new.id), (select auth.uid()));
  return null;
end;
$$;
create trigger trg_notif_reserva after insert on public.reserva
  for each row execute function public.notif_reserva();

-- Los triggers solo los dispara la base de datos.
revoke execute on function public.notif_amistoso_resultado(), public.notif_partido_resultado(),
  public.notif_pedido(), public.notif_reserva() from public, anon, authenticated;

-- Tiempo real: la app recibe los INSERT de sus propias notificaciones (filtrado por RLS).
alter table public.notificacion replica identity full;
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.notificacion;
  end if;
end $$;
