# ligaria_friends

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Modos de ejecución

| Modo | Comando | Qué hace |
|---|---|---|
| **Normal** | `flutter run` | Supabase real (config por defecto en `lib/core/config.dart`), sin datos de ejemplo. Es también lo que se compila para las tiendas. |
| **Demo** | `flutter run --dart-define=MODO=demo` | Todo en memoria con datos de ejemplo (`demo@ligaria.es` / `demo1234`). No toca Supabase. |

Para apuntar a otro proyecto Supabase (staging): `flutter run --dart-define-from-file=env.json`.
