-- ⚠️  DESTRUCTIVO E IRREVERSIBLE  ⚠️
-- Borra TODOS los datos de Ligaria IA (escuelas, organizaciones, equipos, jugadores, ligas, partidos,
-- invitaciones, notificaciones) y TODOS los usuarios de autenticación (auth.users).
-- CONSERVA el esquema, las funciones y el catálogo de roles/permisos (rol, permiso, rol_permiso),
-- así que no hace falta volver a aplicar migraciones.
-- Haz una copia antes si hay algo que quieras conservar (Database → Backups).
-- Ejecútalo en el SQL Editor del proyecto gftslrixaeggchimldmf.

begin;

truncate table
  public.notificacion_preferencia,
  public.notificacion,
  public.invitacion,
  public.set_partido,
  public.partido_jugador,
  public.partido,
  public.encuentro,
  public.jornada,
  public.inscripcion,
  public.categoria,
  public.competicion_org,
  public.competicion,
  public.entrenador_equipo,
  public.equipo_miembro,
  public.equipo,
  public.tutor_jugador,
  public.jugador,
  public.pista,
  public.sede,
  public.asignacion_rol,
  public.organizacion,
  public.usuario
restart identity cascade;

delete from auth.users;  -- identidades, sesiones y tokens caen en cascada

commit;
