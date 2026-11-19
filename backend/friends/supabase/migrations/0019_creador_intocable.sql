-- =====================================================================
-- El creador del grupo es intocable: nadie puede quitarle el rol de administrador
-- ni expulsarlo. Solo él puede salir del grupo por su cuenta. Se permite el borrado
-- en cascada (grupo o cuenta eliminados), donde no hay usuario autenticado actuando.
-- =====================================================================
create or replace function public.grupo_miembro_creador_intocable()
returns trigger
language plpgsql
set search_path = ''
as $$
declare creador uuid;
begin
  select g.creado_por into creador from public.grupo g where g.id = old.grupo_id;
  if creador is null or old.usuario_id <> creador then
    return case when tg_op = 'DELETE' then old else new end;
  end if;
  if tg_op = 'DELETE' then
    -- Puede salir él mismo; el resto de borrados (expulsión) se bloquean.
    if (select auth.uid()) is not null and (select auth.uid()) <> creador then
      raise exception 'El creador del grupo no puede ser expulsado.' using errcode = 'P0001';
    end if;
  elsif new.rol <> 'ADMIN' or new.grupo_id <> old.grupo_id then
    raise exception 'El creador del grupo siempre es administrador.' using errcode = 'P0001';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_grupo_miembro_creador_intocable
  before update or delete on public.grupo_miembro
  for each row execute function public.grupo_miembro_creador_intocable();
