-- =====================================================================
-- Ligaria Friends - Solicitudes de producto a una tienda.
-- El usuario solicita un producto (solicitar_pedido); la tienda (comercio.owner_id)
-- ve las solicitudes de su comercio (pedidos_recibidos) y las responde
-- (cambiar_estado_pedido). El usuario ve las suyas y puede cancelar las pendientes.
-- El precio se toma siempre del producto en servidor.
-- =====================================================================

create type pedido_estado as enum ('PENDIENTE', 'CONFIRMADO', 'RECHAZADO', 'ENTREGADO', 'CANCELADO');

create table public.pedido (
  id               uuid primary key default gen_random_uuid(),
  comercio_id      uuid not null references public.comercio (id) on delete cascade,
  producto_id      uuid references public.producto (id) on delete set null,
  usuario_id       uuid not null default auth.uid() references public.perfil (id) on delete cascade,
  producto_nombre  text not null,
  cantidad         smallint not null check (cantidad between 1 and 99),
  precio_unitario  numeric(10, 2) not null check (precio_unitario >= 0),
  nota             text,
  estado           pedido_estado not null default 'PENDIENTE',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index idx_pedido_comercio on public.pedido (comercio_id, created_at desc);
create index idx_pedido_usuario on public.pedido (usuario_id, created_at desc);
create index idx_pedido_producto on public.pedido (producto_id);

create trigger trg_pedido_updated_at
  before update on public.pedido
  for each row execute function public.set_updated_at();

alter table public.pedido enable row level security;

-- El usuario ve solo sus pedidos; la tienda los lee por pedidos_recibidos().
create policy pedido_sel on public.pedido for select to authenticated
  using (usuario_id = (select auth.uid()));
grant select on public.pedido to authenticated;

create function app.es_dueno_comercio(c uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.comercio where id = c and owner_id = (select auth.uid())
  )
$$;
revoke execute on function app.es_dueno_comercio(uuid) from public, anon;
grant execute on function app.es_dueno_comercio(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Solicitar un producto
-- ---------------------------------------------------------------------
create function public.solicitar_pedido(p_producto uuid, p_cantidad int, p_nota text default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_prod public.producto%rowtype;
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Inicia sesión para solicitar un producto.';
  end if;
  if p_cantidad is null or p_cantidad < 1 or p_cantidad > 99 then
    raise exception 'La cantidad debe estar entre 1 y 99.';
  end if;
  select * into v_prod from public.producto where id = p_producto;
  if not found then
    raise exception 'El producto no existe.';
  end if;
  insert into public.pedido (comercio_id, producto_id, usuario_id, producto_nombre,
                             cantidad, precio_unitario, nota)
  values (v_prod.comercio_id, v_prod.id, auth.uid(), v_prod.nombre,
          p_cantidad, v_prod.precio, nullif(trim(p_nota), ''))
  returning id into v_id;
  return v_id;
end $$;
revoke execute on function public.solicitar_pedido(uuid, int, text) from public, anon;
grant execute on function public.solicitar_pedido(uuid, int, text) to authenticated;

-- ---------------------------------------------------------------------
-- Bandeja de la tienda: pedidos de los comercios de los que soy dueño
-- ---------------------------------------------------------------------
create function public.pedidos_recibidos()
returns table (
  id uuid, comercio_id uuid, comercio_nombre text, producto_nombre text,
  cantidad smallint, precio_unitario numeric, nota text, estado pedido_estado,
  created_at timestamptz, solicitante_nombre text, solicitante_email text
)
language sql stable security definer set search_path = '' as $$
  select p.id, p.comercio_id, c.nombre, p.producto_nombre, p.cantidad,
         p.precio_unitario, p.nota, p.estado, p.created_at,
         coalesce(u.nombre, u.apodo, 'Jugador'), u.email
  from public.pedido p
  join public.comercio c on c.id = p.comercio_id
  join public.perfil u on u.id = p.usuario_id
  where c.owner_id = (select auth.uid())
  order by p.created_at desc
$$;
revoke execute on function public.pedidos_recibidos() from public, anon;
grant execute on function public.pedidos_recibidos() to authenticated;

-- ---------------------------------------------------------------------
-- Cambiar estado: la tienda confirma / rechaza / entrega; el usuario cancela pendientes
-- ---------------------------------------------------------------------
create function public.cambiar_estado_pedido(p_pedido uuid, p_estado pedido_estado)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  v public.pedido%rowtype;
begin
  select * into v from public.pedido where id = p_pedido;
  if not found then
    raise exception 'El pedido no existe.';
  end if;
  if app.es_dueno_comercio(v.comercio_id) then
    if p_estado not in ('CONFIRMADO', 'RECHAZADO', 'ENTREGADO') then
      raise exception 'Estado no válido para la tienda.';
    end if;
    if v.estado in ('CANCELADO', 'RECHAZADO', 'ENTREGADO') then
      raise exception 'El pedido ya está cerrado.';
    end if;
  elsif v.usuario_id = auth.uid() then
    if p_estado <> 'CANCELADO' or v.estado <> 'PENDIENTE' then
      raise exception 'Solo puedes cancelar pedidos pendientes.';
    end if;
  else
    raise exception 'No tienes acceso a este pedido.';
  end if;
  update public.pedido set estado = p_estado where id = p_pedido;
end $$;
revoke execute on function public.cambiar_estado_pedido(uuid, pedido_estado) from public, anon;
grant execute on function public.cambiar_estado_pedido(uuid, pedido_estado) to authenticated;
