-- =====================================================================
-- Ligaria Friends - Perfil Tienda.
-- perfil.tipo_cuenta distingue JUGADOR (por defecto) de TIENDA. Una cuenta TIENDA se crea
-- al registrarse con raw_user_meta_data { tipo_cuenta: 'TIENDA', nombre_tienda: '...' }:
-- el trigger crea su comercio (owner_id = la cuenta). La tienda gestiona sus productos
-- y los datos de su comercio; los pedidos ya se leen/gestionan por RPC (0011).
-- tipo_cuenta no es editable por el usuario (no está en el grant de update de perfil).
-- =====================================================================

create type cuenta_tipo as enum ('JUGADOR', 'TIENDA');

alter table public.perfil add column tipo_cuenta cuenta_tipo not null default 'JUGADOR';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_nombre  text := nullif(btrim(new.raw_user_meta_data ->> 'nombre'), '');
  v_tienda  text := nullif(btrim(new.raw_user_meta_data ->> 'nombre_tienda'), '');
  v_es_tienda boolean := (new.raw_user_meta_data ->> 'tipo_cuenta') = 'TIENDA';
begin
  insert into public.perfil (id, email, nombre, tipo_cuenta)
  values (new.id, new.email, coalesce(v_nombre, case when v_es_tienda then v_tienda end),
          case when v_es_tienda then 'TIENDA'::public.cuenta_tipo else 'JUGADOR'::public.cuenta_tipo end);

  if v_es_tienda then
    insert into public.comercio (nombre, tipo, owner_id)
    values (coalesce(v_tienda, v_nombre, 'Mi tienda'), 'TIENDA', new.id);
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- La tienda gestiona su catálogo y los datos de su comercio.
-- ---------------------------------------------------------------------
create policy producto_ins on public.producto for insert to authenticated
  with check (app.es_dueno_comercio(comercio_id));
create policy producto_upd on public.producto for update to authenticated
  using (app.es_dueno_comercio(comercio_id))
  with check (app.es_dueno_comercio(comercio_id));
create policy producto_del on public.producto for delete to authenticated
  using (app.es_dueno_comercio(comercio_id));

grant insert, update, delete on public.producto to authenticated;

create policy comercio_upd on public.comercio for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

grant update (nombre, descripcion, ciudad) on public.comercio to authenticated;
