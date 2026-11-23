-- =====================================================================
-- Todos los jugadores aparecen en la búsqueda de jugadores por defecto.
-- Cada persona puede desactivarlo en Ajustes («Aparecer en la búsqueda de jugadores»).
-- =====================================================================

alter table public.perfil alter column buscable set default true;
update public.perfil set buscable = true where not buscable;
