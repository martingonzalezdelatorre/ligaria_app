-- =====================================================================
-- Ligaria Friends - Reservas de pistas de clubs (franjas de 1 hora en punto).
-- Se reserva solo por RPC; cada usuario ve únicamente sus reservas. La
-- disponibilidad se consulta con pistas_ocupadas(), que no expone quién reservó.
-- =====================================================================

create table public.reserva (
  id          uuid primary key default gen_random_uuid(),
  pista_id    uuid not null references public.pista (id) on delete cascade,
  usuario_id  uuid not null default auth.uid() references public.perfil (id) on delete cascade,
  inicio      timestamptz not null,
  created_at  timestamptz not null default now(),
  unique (pista_id, inicio),
  check (inicio = date_trunc('hour', inicio))
);
create index idx_reserva_usuario on public.reserva (usuario_id, inicio);

alter table public.reserva enable row level security;

create policy reserva_sel on public.reserva for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy reserva_del on public.reserva for delete to authenticated
  using (usuario_id = (select auth.uid()) and inicio > now());

grant select, delete on public.reserva to authenticated;

create function public.reservar_pista(p_pista uuid, p_inicio timestamptz)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Inicia sesión para reservar.';
  end if;
  if p_inicio <> date_trunc('hour', p_inicio) then
    raise exception 'Las reservas son por horas en punto.';
  end if;
  if p_inicio <= now() then
    raise exception 'No puedes reservar una hora que ya ha pasado.';
  end if;
  if not exists (select 1 from public.pista where id = p_pista) then
    raise exception 'La pista no existe.';
  end if;
  begin
    insert into public.reserva (pista_id, usuario_id, inicio)
    values (p_pista, auth.uid(), p_inicio)
    returning id into v_id;
  exception when unique_violation then
    raise exception 'Esa hora ya está reservada.';
  end;
  return v_id;
end $$;
revoke execute on function public.reservar_pista(uuid, timestamptz) from public, anon;
grant execute on function public.reservar_pista(uuid, timestamptz) to authenticated;

-- Horas ocupadas de una pista entre dos instantes (sin datos de quién reservó).
create function public.pistas_ocupadas(p_pista uuid, p_desde timestamptz, p_hasta timestamptz)
returns setof timestamptz
language sql stable security definer set search_path = '' as $$
  select inicio from public.reserva
  where pista_id = p_pista and inicio >= p_desde and inicio < p_hasta
$$;
revoke execute on function public.pistas_ocupadas(uuid, timestamptz, timestamptz) from public, anon;
grant execute on function public.pistas_ocupadas(uuid, timestamptz, timestamptz) to authenticated;
