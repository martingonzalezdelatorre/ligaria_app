-- =====================================================================
-- Categoría de edad de los equipos de una escuela.
-- · equipo.categoria: BENJAMIN | ALEVIN | INFANTIL | CADETE | JUNIOR | ABSOLUTO | VETERANOS.
--   Null en los equipos ya existentes (sin categoría: se puede añadir a cualquier jugador).
-- · La app filtra los jugadores que se pueden añadir según su año de nacimiento
--   (edad deportiva = año actual − año de nacimiento), ver apps/ligariaia/lib/data/categoria_edad.dart.
-- Requisito: las migraciones se aplican en orden.
-- =====================================================================
alter table public.equipo
  add column categoria text
  check (categoria is null or categoria in
    ('BENJAMIN', 'ALEVIN', 'INFANTIL', 'CADETE', 'JUNIOR', 'ABSOLUTO', 'VETERANOS'));
