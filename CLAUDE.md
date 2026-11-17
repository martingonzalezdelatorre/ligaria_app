# Reglas permanentes del proyecto (inscripción de menores, escuela de tenis, España)

Aplican RGPD y LOPDGDD. Estas reglas no cambian entre tareas.

## Protección de datos
- Minimización: no añadir campos de datos personales sin aprobación explícita.
- Datos de salud e IBAN: cifrados en reposo, acceso por rol y registro de accesos (sin guardar contenido).
- No escribir datos personales ni de salud en logs, mensajes de error, tests con datos reales ni commits. Usar datos ficticios en tests y seeds.
- Nunca guardar datos personales en `localStorage`/`sessionStorage`.
- No guardar datos de tarjeta de pago.
- Las casillas de consentimiento nunca vienen premarcadas; cada consentimiento guarda usuario, fecha y hora, y versión del texto.
- No inventes textos legales: usa placeholders versionados para revisión por un DPO o abogado.
- Secretos y claves de cifrado solo por variables de entorno o gestor de secretos; nunca en el repositorio.

## Forma de trabajar
- Primero diseño y confirmación; después implementación por pasos.
- Commits pequeños y atómicos, en una rama propia. Sin push.
- Antes de dar un paso por terminado: tests y linter en verde, sin warnings nuevos.
- Si algo es ambiguo, pregunta en lugar de suponer, agrupando las dudas en un solo bloque.
- No instalar dependencias nuevas sin avisar.
- Respetar las convenciones del repositorio (estructura, estilo, nombres) si ya existen.

## Convenciones
- Interfaz en español; commits en español.
- Validación con esquema tipado compartido entre cliente y servidor.
- El filtrado por rol se hace en el servidor, no solo en la interfaz.
