-- =====================================================================
-- Ligaria Friends - Las ligas las crea y gestiona solo el administrador del grupo.
-- Revierte lo que abrió 0004: los miembros siguen pudiendo crear amistosos
-- (crear_amistoso) y sus propios grupos (donde son administradores).
-- Las políticas y RPC de 0004 llaman a app.puede_gestionar_liga, así que basta con redefinirla.
-- =====================================================================

create or replace function app.puede_gestionar_liga(l uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.liga x
    where x.id = l and app.es_admin_grupo(x.grupo_id))
$$;

drop policy liga_ins on public.liga;
create policy liga_ins on public.liga for insert to authenticated
  with check (app.es_admin_grupo(grupo_id) and creado_por = (select auth.uid()));
