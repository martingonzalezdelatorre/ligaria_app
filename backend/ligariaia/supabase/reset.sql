-- ⚠️  DESTRUCTIVO E IRREVERSIBLE  ⚠️
-- Borra TODAS las tablas, vistas, funciones y datos de Ligaria (esquemas `public` y `app`)
-- y el historial de migraciones de la CLI. NO toca los usuarios de autenticación (`auth.users`)
-- ni el almacenamiento (`storage`), ni los esquemas internos de Supabase.
--
-- Úsalo solo en el proyecto de pruebas. Haz una copia antes si hay algo que quieras conservar
-- (Database → Backups). Ejecútalo en el SQL Editor de Supabase.

drop schema if exists app cascade;
drop schema if exists public cascade;

create schema public;
grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres, service_role;
alter default privileges in schema public grant all on tables    to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;

-- Olvida las migraciones aplicadas: así `supabase db push` volverá a aplicarlas desde la 0001.
delete from supabase_migrations.schema_migrations;

-- Opcional: borra también los usuarios de prueba (descomenta si quieres empezar sin ninguno).
-- delete from auth.users;

notify pgrst, 'reload schema';
