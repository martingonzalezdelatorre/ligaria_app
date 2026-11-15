-- =====================================================================
-- Ligaria Friends - Store: tiendas de material y clubs con pistas de alquiler.
-- Catálogo de solo lectura para usuarios autenticados. Las empresas se dan de alta
-- desde el panel de administración (service_role); la gestión propia (owner_id)
-- y las reservas de pistas quedan para una iteración posterior.
-- =====================================================================

create type comercio_tipo as enum ('TIENDA', 'CLUB');

create table public.comercio (
  id           uuid primary key default gen_random_uuid(),
  nombre       text not null check (length(trim(nombre)) > 0),
  tipo         comercio_tipo not null,
  descripcion  text,
  ciudad       text,
  owner_id     uuid references public.perfil (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index idx_comercio_tipo on public.comercio (tipo);
create index idx_comercio_owner on public.comercio (owner_id);

create trigger trg_comercio_updated_at
  before update on public.comercio
  for each row execute function public.set_updated_at();

create table public.producto (
  id           uuid primary key default gen_random_uuid(),
  comercio_id  uuid not null references public.comercio (id) on delete cascade,
  nombre       text not null check (length(trim(nombre)) > 0),
  categoria    text,
  descripcion  text,
  precio       numeric(10, 2) not null check (precio >= 0),
  created_at   timestamptz not null default now()
);
create index idx_producto_comercio on public.producto (comercio_id);

create table public.pista (
  id           uuid primary key default gen_random_uuid(),
  comercio_id  uuid not null references public.comercio (id) on delete cascade,
  nombre       text not null check (length(trim(nombre)) > 0),
  deporte      text not null default 'Pádel',
  cubierta     boolean not null default false,
  precio_hora  numeric(10, 2) not null check (precio_hora >= 0),
  created_at   timestamptz not null default now()
);
create index idx_pista_comercio on public.pista (comercio_id);

alter table public.comercio enable row level security;
alter table public.producto enable row level security;
alter table public.pista    enable row level security;

create policy comercio_sel on public.comercio for select to authenticated using (true);
create policy producto_sel on public.producto for select to authenticated using (true);
create policy pista_sel    on public.pista    for select to authenticated using (true);

grant select on public.comercio, public.producto, public.pista to authenticated;
