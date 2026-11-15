-- =====================================================================
-- Ligaria Friends - Marcador en directo.
-- Quien puntúa un partido (jugadores del partido y quien gestiona la liga / admins en amistosos)
-- publica el estado del tanteador; los miembros del grupo lo ven en tiempo real (Realtime).
-- La fila se borra al terminar o cancelar. Se escribe solo por RPC.
-- =====================================================================

create table public.marcador_vivo (
  id               uuid primary key default gen_random_uuid(),
  grupo_id         uuid not null references public.grupo (id) on delete cascade,
  amistoso_id      uuid unique references public.amistoso (id) on delete cascade,
  partido_id       uuid unique references public.partido (id) on delete cascade,
  estado           jsonb not null,
  actualizado_por  uuid default auth.uid() references public.perfil (id) on delete set null,
  updated_at       timestamptz not null default now(),
  check ((amistoso_id is null) <> (partido_id is null))
);
create index idx_marcador_vivo_grupo on public.marcador_vivo (grupo_id);
create index idx_marcador_vivo_actualizado_por on public.marcador_vivo (actualizado_por);

alter table public.marcador_vivo enable row level security;
create policy marcador_sel on public.marcador_vivo for select to authenticated
  using (app.es_miembro(grupo_id));
grant select on public.marcador_vivo to authenticated;

-- p_estado = null borra el marcador (partido terminado o cancelado).
create function public.publicar_marcador(p_amistoso uuid, p_partido uuid, p_estado jsonb)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := (select auth.uid());
  g uuid;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  if (p_amistoso is null) = (p_partido is null) then
    raise exception 'Indica un partido.' using errcode = '22023';
  end if;
  if p_estado is not null and jsonb_typeof(p_estado) <> 'object' then
    raise exception 'Marcador no válido.' using errcode = '22023';
  end if;

  if p_amistoso is not null then
    g := app.grupo_de_amistoso(p_amistoso);
    if g is null or not (app.es_admin_grupo(g) or exists (
         select 1 from public.amistoso_jugador j
         where j.amistoso_id = p_amistoso and j.usuario_id = uid)) then
      raise exception 'No puedes puntuar este partido.' using errcode = '42501';
    end if;
    if p_estado is null then
      delete from public.marcador_vivo where amistoso_id = p_amistoso;
    else
      insert into public.marcador_vivo (grupo_id, amistoso_id, estado)
      values (g, p_amistoso, p_estado)
      on conflict (amistoso_id) do update
        set estado = excluded.estado, updated_at = now(), actualizado_por = uid;
    end if;
  else
    g := app.grupo_de_partido(p_partido);
    if g is null or not (
         app.puede_gestionar_liga((select liga_id from public.partido where id = p_partido))
         or app.juega_en_partido(p_partido)) then
      raise exception 'No puedes puntuar este partido.' using errcode = '42501';
    end if;
    if p_estado is null then
      delete from public.marcador_vivo where partido_id = p_partido;
    else
      insert into public.marcador_vivo (grupo_id, partido_id, estado)
      values (g, p_partido, p_estado)
      on conflict (partido_id) do update
        set estado = excluded.estado, updated_at = now(), actualizado_por = uid;
    end if;
  end if;
end;
$$;
revoke execute on function public.publicar_marcador(uuid, uuid, jsonb) from public, anon;
grant execute on function public.publicar_marcador(uuid, uuid, jsonb) to authenticated;

-- Tiempo real: los cambios (y borrados) llegan a quien pasa la RLS de arriba.
alter table public.marcador_vivo replica identity full;
alter publication supabase_realtime add table public.marcador_vivo;
