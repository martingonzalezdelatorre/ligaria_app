# Ligaria

Plataforma multi-escuela de competiciones deportivas (ligas interescuelas de tenis y pádel).
PWA en **Flutter Web** + **Supabase** (Postgres con RLS y Auth).

## Estructura

```
lib/                       App Flutter (core, data, features por rol)
supabase/migrations/       Esquema, RLS, RPC y vistas (0001 … 0006)
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

1. Crea el proyecto en Supabase y aplica las migraciones en orden (`supabase db push`, o pega cada
   `supabase/migrations/000X_*.sql` en el editor SQL).
2. Opcional, solo desarrollo: ejecuta `supabase/seed.sql` (3 escuelas, 1 liga infantil de tenis, 6 equipos).
   Con la CLI local, `supabase db reset` aplica migraciones y seed.
3. Arranca la app con las claves del proyecto (Settings → API):

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=<clave publicable>
```

Producción: `flutter build web --dart-define=...` y sirve `build/web`.

## Usuarios de prueba (seed)

Contraseña de todos: `Ligaria2026!` — **no cargar el seed en producción**.

| Usuario | Rol |
|---|---|
| superadmin@ligaria.test | Superadmin |
| organizador@ligaria.test | Organizador (Club de Tenis Norte, organiza la liga) |
| admin.norte / admin.sur / admin.este@ligaria.test | Admin de cada escuela |
| entrenador.norte / entrenador.sur / entrenador.este@ligaria.test | Entrenador de 2 equipos cada uno |
| tutor@ligaria.test | Tutor de 2 menores (uno con consentimiento pendiente) |
| alumno@ligaria.test | Alumna de 14 años con cuenta (Academia Sur) |

La liga tiene el calendario generado, 6 encuentros confirmados (jornadas 1-2) y 1 resultado propuesto
pendiente de confirmar (jornada 3).

## Decisiones clave

- **Multi-tenant con RLS**: todo cuelga de `escuela_id`/`organization_id`; otras escuelas solo ven
  nombres y resultados de ligas compartidas, mediante vistas.
- **Clasificación calculada**, nunca editada: `clasificacion(competicion)` usa solo encuentros confirmados.
- **Resultados**: propuesto por el entrenador → confirmado por la organización; las correcciones guardan
  historial (`correccion_resultado`) y se auditan en `registro_cambios`.
- **Menores**: consentimiento del tutor para menores de 14, visibilidad de ficha configurable,
  registro de accesos (`registro_acceso_menores`).
