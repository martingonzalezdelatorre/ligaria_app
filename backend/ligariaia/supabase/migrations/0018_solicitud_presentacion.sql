-- =====================================================================
-- Solicitudes de presentación comercial (formulario de la web ligaria.app).
-- Las envía un visitante sin cuenta (rol anon) a través de la RPC
-- solicitar_presentacion; nadie la lee desde la API salvo el ADMINISTRADOR.
-- =====================================================================
create table public.solicitud_presentacion (
  id             uuid primary key default gen_random_uuid(),
  creado_en      timestamptz not null default now(),
  segmento       text not null check (segmento in ('PADEL', 'TENIS', 'CLUBES', 'ESCUELAS', 'AYUNTAMIENTOS')),
  nombre         text not null check (char_length(nombre) between 1 and 160),
  email          text not null check (char_length(email) <= 254 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  entidad        text check (char_length(entidad) <= 200),
  telefono       text check (char_length(telefono) <= 40),
  mensaje        text check (char_length(mensaje) <= 2000),
  consentimiento boolean not null check (consentimiento),
  origen         text check (char_length(origen) <= 200)
);
create index solicitud_presentacion_email_idx on public.solicitud_presentacion (lower(email), creado_en);

-- RLS sin políticas para anon/authenticated: no pueden leer ni escribir directamente.
alter table public.solicitud_presentacion enable row level security;
-- Supabase concede por defecto todos los privilegios a anon/authenticated: se retiran y solo se
-- permite leer a authenticated (la política limita la lectura al ADMINISTRADOR).
revoke all on public.solicitud_presentacion from anon, authenticated;
grant select on public.solicitud_presentacion to authenticated;
create policy solicitud_presentacion_admin on public.solicitud_presentacion for select to authenticated
  using (app.es_admin());

-- Alta desde la web. Valida, limita abusos y guarda la solicitud.
create or replace function public.solicitar_presentacion(
  p_segmento text, p_nombre text, p_email text, p_consentimiento boolean,
  p_entidad text default null, p_telefono text default null,
  p_mensaje text default null, p_origen text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare
  mail text := lower(btrim(coalesce(p_email, '')));
  nom  text := btrim(coalesce(p_nombre, ''));
begin
  if p_segmento is null or p_segmento not in ('PADEL', 'TENIS', 'CLUBES', 'ESCUELAS', 'AYUNTAMIENTOS') then
    raise exception 'segmento no válido' using errcode = '23514';
  end if;
  if nom = '' or char_length(nom) > 160 then raise exception 'el nombre es obligatorio' using errcode = '23514'; end if;
  if char_length(mail) > 254 or mail !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'el email no es válido' using errcode = '23514';
  end if;
  if p_consentimiento is distinct from true then
    raise exception 'hay que aceptar el tratamiento de datos' using errcode = '23514';
  end if;
  -- Límites básicos anti-abuso: por correo y global.
  if (select count(*) from solicitud_presentacion
      where lower(email) = mail and creado_en > now() - interval '1 day') >= 3
     or (select count(*) from solicitud_presentacion where creado_en > now() - interval '1 hour') >= 100 then
    raise exception 'demasiadas solicitudes, inténtalo más tarde' using errcode = '54000';
  end if;
  insert into solicitud_presentacion (segmento, nombre, email, entidad, telefono, mensaje, consentimiento, origen)
  values (p_segmento, nom, mail,
          left(nullif(btrim(coalesce(p_entidad, '')), ''), 200),
          left(nullif(btrim(coalesce(p_telefono, '')), ''), 40),
          left(nullif(btrim(coalesce(p_mensaje, '')), ''), 2000),
          true,
          left(nullif(btrim(coalesce(p_origen, '')), ''), 200));
end $$;

revoke execute on function public.solicitar_presentacion(text, text, text, boolean, text, text, text, text) from public;
grant execute on function public.solicitar_presentacion(text, text, text, boolean, text, text, text, text) to anon, authenticated;
