# Ligaria

Plataforma de competiciones deportivas para escuelas, ayuntamientos y grupos de amigos (ligas de tenis y pádel).
PWA en **Flutter Web** + **Supabase** (Postgres con RLS y Auth).

## Estructura

```
lib/                       App Flutter (core, data, features por rol)
supabase/migrations/       0001 esquema base · 0002 acceso de la app (RLS, vistas v_*, RPC, invitaciones)
supabase/legacy/           Esquema anterior y copias (.bak) de lo retirado; solo referencia
supabase/seed.sql          Datos de ejemplo de DESARROLLO
supabase/tests/            Tests SQL con PGlite (Postgres en WASM, sin Docker)
test/                      Tests de widgets (mocktail)
```

## Tests

```bash
cd supabase/tests && npm install && npm test   # RLS, calendario, clasificación, seed
```

```bash
flutter analyze && flutter test
```

## Puesta en marcha con Supabase

**Una sola vez**

1. `cp env.example.json env.json` y pega en `env.json` la clave publicable (Supabase → Settings → API).
   `env.json` no se sube a git.
2. `scripts/supabase.sh enlazar` (pide la contraseña de la base de datos; vincula la carpeta con el proyecto).
3. Si ya ejecutaste migraciones a mano en el SQL Editor, márcalas como aplicadas para que no se repitan
   (comprueba antes con `scripts/supabase.sh estado`):
   `scripts/supabase.sh marcar 0001 0002`
   ⚠️ La base remota existente tiene el esquema ANTERIOR: el nuevo esquema (0001) no es compatible. Aplícalo en un
   proyecto nuevo o resetea antes (`supabase/reset.sql`); `subir` sobre producción NO migra datos.

**Cada vez que haya una migración nueva**

```bash
scripts/supabase.sh simular   # ver qué se aplicaría
scripts/supabase.sh subir     # aplicar (pide confirmar)
```

**Arrancar y publicar la app**

```bash
flutter run -d chrome --dart-define-from-file=env.json
flutter build web --dart-define-from-file=env.json     # sirve build/web en tu hosting
```

El seed (`supabase/seed.sql`) es solo para desarrollo: no lo cargues en producción.

## Registro de usuarios (contrato para la web)

El alta es un `signUp` de Supabase Auth (`POST /auth/v1/signup`) con `data` (= `raw_user_meta_data`).
El trigger `handle_new_user` (0002) hace el resto.

**1. Autoservicio en la web** — solo estos tres perfiles; crea la organización y te hace su responsable:

| `data.perfil` | Crea organización | Rol |
|---|---|---|
| `escuela` | ESCUELA | ADMIN_ESCUELAS |
| `ayuntamiento` | AYUNTAMIENTO | ORGANIZADOR_LIGAS |
| `organizador` | GRUPO_AMIGOS (organizador independiente) | ORGANIZADOR_LIGAS |

Metadatos: `nombre`, `apellidos` (opc.), `perfil`, `entidad` (nombre de la escuela/ayuntamiento/liga; obligatorio en
escuela y ayuntamiento, opcional en organizador → «Ligas de <nombre>»).
Errores (mensaje de Postgres): `ESCUELA_EXISTE`, `ESCUELA_REQUERIDA`, `PERFIL_INVALIDO`.

**2. Por invitación** — entrenador, jugador, tutor (y más administradores/organizadores de una organización):
un administrador/organizador llama a `invitar_usuario(org, email, rol, jugador?)` desde la app. La persona se registra
en la web **sin `perfil`**, con el mismo correo; al crearse la cuenta recibe el rol invitado (si ya tenía cuenta, se asigna
al instante). Sin invitación pendiente el alta se rechaza con `REGISTRO_SOLO_INVITACION`. Si pasan `perfil` =
`entrenador`/`familia`/`jugador` → `PERFIL_INVALIDO`.

Seed/tests/soporte pueden crear usuarios sueltos con `set app.alta_libre = 'on'`.

## Usuarios de prueba (seed)

Contraseña de todos: `Ligaria2026!` — **no cargar el seed en producción**.

| Usuario | Rol |
|---|---|
| superadmin@ligaria.test | ADMINISTRADOR (superadmin) |
| organizador@ligaria.test | ORGANIZADOR_LIGAS (organiza la liga) |
| ayuntamiento@ligaria.test | ORGANIZADOR_LIGAS en un ayuntamiento |
| admin.norte / admin.sur / admin.este@ligaria.test | ADMIN_ESCUELAS de cada escuela |
| entrenador.norte / entrenador.sur / entrenador.este@ligaria.test | ENTRENADOR |
| tutor@ligaria.test | TUTOR |
| alumno@ligaria.test | JUGADOR con cuenta |

## Decisiones clave

- **Roles**: ADMINISTRADOR = superadmin de la plataforma; ADMIN_ESCUELAS administra su organización;
  ORGANIZADOR_LIGAS organiza ligas (escuela o ayuntamiento); ENTRENADOR, TUTOR y JUGADOR como en el esquema.
- **Acceso con RLS**: la app lee vistas `v_*` y llama RPC (`crear_competicion`, `inscribir_equipo`,
  `invitar_usuario`, `generar_calendario`, `registrar_resultado`); funciones auxiliares en el esquema `app`.
- **Extensiones sobre el esquema base** (0002): `jugador.organizacion_id`, tabla `invitacion`, y la vista
  `clasificacion` cuenta también los `NO_PRESENTADO`.
- **Una categoría «General»** por competición; las inscripciones se aceptan automáticamente.
- **Resultados**: el entrenador de uno de los equipos los registra una vez; la organización puede corregirlos.
  Incomparecencia = `NO_PRESENTADO` con victoria para el otro equipo.
- **Privacidad**: de otras organizaciones solo se muestra «Nombre I.» de los jugadores.
- **Retirado** (sin tablas equivalentes): temporadas, consentimiento/visibilidad de menores, notificaciones,
  registro de cambios, correcciones con historial.
