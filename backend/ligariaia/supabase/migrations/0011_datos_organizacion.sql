-- =====================================================================
-- Datos de contacto de la organización (escuela, ayuntamiento u organizador) y edición por su administrador.
-- Hasta ahora una organización solo tenía nombre y ciudad.
-- =====================================================================
alter table public.organizacion
  add column cif             text,
  add column direccion       text,
  add column codigo_postal   text,
  add column provincia       text,
  add column telefono        text,
  add column email_contacto  text,
  add column web             text;

-- Edita los datos de SU organización: el administrador de la escuela o el organizador de ligas
-- (ayuntamientos y organizadores independientes). No sirve a co-organizadores de una liga suelta.
-- security definer porque org_mod solo deja escribir en `organizacion` al superadministrador.
create or replace function public.actualizar_organizacion(
  p_org uuid, p_nombre text, p_cif text, p_ciudad text, p_direccion text,
  p_codigo_postal text, p_provincia text, p_telefono text, p_email_contacto text, p_web text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare nom text := nullif(btrim(p_nombre), ''); tipo_org organizacion_tipo;
begin
  if not (app.es_admin() or app.tiene_rol(p_org, array['ADMIN_ESCUELAS', 'ORGANIZADOR_LIGAS'])) then
    raise exception 'sin permiso para editar esta organización' using errcode = '42501';
  end if;
  if nom is null then raise exception 'el nombre es obligatorio' using errcode = '23514'; end if;
  select tipo into tipo_org from organizacion where id = p_org;
  if tipo_org is null then raise exception 'organización no encontrada' using errcode = 'P0002'; end if;
  if exists (select 1 from organizacion where tipo = tipo_org and id <> p_org and lower(btrim(nombre)) = lower(nom)) then
    raise exception 'ya existe otra entidad con ese nombre' using errcode = '23505';
  end if;
  update organizacion set
    nombre = left(nom, 160),
    cif = left(nullif(btrim(p_cif), ''), 30),
    ciudad = left(nullif(btrim(p_ciudad), ''), 120),
    direccion = left(nullif(btrim(p_direccion), ''), 200),
    codigo_postal = left(nullif(btrim(p_codigo_postal), ''), 12),
    provincia = left(nullif(btrim(p_provincia), ''), 120),
    telefono = left(nullif(btrim(p_telefono), ''), 40),
    email_contacto = left(nullif(btrim(p_email_contacto), ''), 254),
    web = left(nullif(btrim(p_web), ''), 200)
  where id = p_org;
end $$;

revoke execute on function public.actualizar_organizacion(uuid, text, text, text, text, text, text, text, text, text) from public, anon;
grant execute on function public.actualizar_organizacion(uuid, text, text, text, text, text, text, text, text, text) to authenticated;
