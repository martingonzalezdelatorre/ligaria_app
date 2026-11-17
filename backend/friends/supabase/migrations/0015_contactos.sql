-- =====================================================================
-- Contactos: quien invita a un amigo a un grupo lo conserva como contacto.
-- Así puede seguir viéndolo, añadirlo a otros grupos y crear amistosos con él,
-- aunque ya no compartan grupo. La relación es de quien invita hacia el invitado.
-- =====================================================================

create table public.contacto (
  usuario_id   uuid not null references public.perfil (id) on delete cascade,  -- quien invitó
  contacto_id  uuid not null references public.perfil (id) on delete cascade,  -- el amigo invitado
  created_at   timestamptz not null default now(),
  primary key (usuario_id, contacto_id),
  check (usuario_id <> contacto_id)
);
create index idx_contacto_contacto on public.contacto (contacto_id);

alter table public.contacto enable row level security;
create policy contacto_sel on public.contacto for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy contacto_del on public.contacto for delete to authenticated
  using (usuario_id = (select auth.uid()));
grant select, delete on public.contacto to authenticated;

create function app.es_contacto(u uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.contacto c
                 where c.usuario_id = (select auth.uid()) and c.contacto_id = u)
$$;
grant execute on function app.es_contacto(uuid) to authenticated;

-- El perfil de un contacto es visible aunque ya no se comparta grupo.
drop policy perfil_sel on public.perfil;
create policy perfil_sel on public.perfil for select to authenticated
  using (id = (select auth.uid()) or app.comparte_grupo(id) or app.es_contacto(id));

-- Unirse con código; p_invitador (opcional) es quien compartió el enlace.
-- Sin invitador conocido (código escrito a mano) se toma a quien creó el grupo.
drop function public.unirse_a_grupo(text);
create function public.unirse_a_grupo(p_codigo text, p_invitador uuid default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare uid uuid := (select auth.uid()); gid uuid; inv uuid; nuevo boolean;
begin
  if uid is null then raise exception 'Debes iniciar sesión.' using errcode = '28000'; end if;
  select id, creado_por into gid, inv from public.grupo where codigo_invitacion = upper(btrim(p_codigo));
  if gid is null then raise exception 'Código de invitación no válido.' using errcode = 'P0002'; end if;
  with ins as (
    insert into public.grupo_miembro (grupo_id, usuario_id) values (gid, uid)
    on conflict do nothing returning 1)
  select exists (select 1 from ins) into nuevo;
  -- Solo vale como invitador un miembro del grupo.
  if p_invitador is not null and exists (
       select 1 from public.grupo_miembro m where m.grupo_id = gid and m.usuario_id = p_invitador) then
    inv := p_invitador;
  end if;
  if nuevo and inv is not null and inv <> uid then
    insert into public.contacto (usuario_id, contacto_id) values (inv, uid) on conflict do nothing;
  end if;
  return gid;
end;
$$;
revoke execute on function public.unirse_a_grupo(text, uuid) from public, anon;
grant execute on function public.unirse_a_grupo(text, uuid) to authenticated;

-- Añade a un contacto a otro grupo (solo administradores del grupo).
create function public.anadir_contacto_a_grupo(p_grupo uuid, p_usuario uuid)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not app.es_admin_grupo(p_grupo) then
    raise exception 'Solo un administrador puede añadir amigos al grupo.' using errcode = '42501';
  end if;
  if not app.es_contacto(p_usuario) then
    raise exception 'Esa persona no está entre tus amigos.' using errcode = '42501';
  end if;
  insert into public.grupo_miembro (grupo_id, usuario_id) values (p_grupo, p_usuario)
  on conflict do nothing;
end;
$$;
revoke execute on function public.anadir_contacto_a_grupo(uuid, uuid) from public, anon;
grant execute on function public.anadir_contacto_a_grupo(uuid, uuid) to authenticated;

create view public.v_mis_contactos with (security_invoker = true) as
select c.contacto_id as id,
       coalesce(p.apodo, p.nombre, 'Jugador') as nombre
from public.contacto c
join public.perfil p on p.id = c.contacto_id
where c.usuario_id = (select auth.uid());
grant select on public.v_mis_contactos to authenticated;
