# Auronix

App móvil Flutter de ride-hailing (tipo Uber/Cabify) con dos roles de usuario: **cliente** (solicita viajes) y **conductor** (los atiende). Nombre de paquete Dart `auronix_app`, `applicationId` Android `com.auronix.ando.app2026`.

> **Agentes de IA**: empieza por [`AGENT.md`](AGENT.md), no leas este archivo como punto de entrada directo a explorar código.

## Stack

- Flutter, Dart SDK `^3.9.0`.
- Estado: `flutter_bloc` (Bloc + Cubit).
- Navegación: `go_router`, con shells separados por rol (`/client/...`, `/driver/...`).
- Inyección de dependencias: `get_it` (service locator), en `lib/app/di/dependency_injection.dart`.
- Red: `dio` + interceptores propios (auth/refresh, cache, retry, logging).
- Persistencia local: `sqflite` (tabla `user` con tokens/credenciales por rol).
- Backend: API REST externa (fuera de este repo), URL base por entorno.
- Firebase: solo `firebase_core` inicializado (sin Auth/Firestore/Messaging todavía).
- Mapas: **`flutter_map`** (OpenStreetMap) es la única librería de mapas realmente usada en código. `mapbox_maps_flutter`, `google_maps_flutter`, `geolocator`, `geocoding` y `flutter_polyline_points` están en `pubspec.yaml` sin ninguna referencia en `lib/` — ver [`docs/questions.md`](docs/questions.md).
- Gráficos: `fl_chart` (panel de ganancias del conductor).

## Arquitectura (resumen)

Clean Architecture por feature (`data/domain/presentation`) + Atomic Design en la capa de UI (`atoms/molecules/organisms/templates/pages`). Detalle completo en [`docs/architecture.md`](docs/architecture.md), [`docs/design_patterns.md`](docs/design_patterns.md) y [`docs/hierarchy.md`](docs/hierarchy.md).

## Estructura de alto nivel

- `lib/app/` — app shell: DI, router, red, blocs globales (sesión, tema, permisos, diálogos), base de datos local, tema/design tokens, flavors (dev/prod).
- `lib/core/` — modelos/enums transversales, manejo de errores (`Failure` + `dartz.Either`), helpers, config Firebase por entorno.
- `lib/features/` — `auth`, `home`, `trips`, `messages`, `admin`, `onBoarding`. Varias están mockeadas o vacías — ver [`docs/functionality.md`](docs/functionality.md) antes de asumir que algo funciona.
- `lib/shared/` — UI kit reutilizable entre features (Atomic Design).
- `lib/l10n/` — i18n scaffolded (en/es) pero no usado realmente; la UI real tiene strings hardcodeadas en español.

## Entornos / flavors

- Entry points reales: `lib/main_dev.dart` y `lib/main_prod.dart` (`lib/main.dart` es boilerplate sin usar).
- Config por entorno: `lib/app/environments/flavors/`.
- Flavors Android (`dev`/`prod`): `android/app/build.gradle.kts`. **Firma de release no configurada** (usa el keystore de debug) — ver [`docs/security.md`](docs/security.md).
- Proyectos Firebase separados (`auronix-ando-dev` / `auronix-ando-prod`).

## Estado del proyecto

El producto se redefinió como una app de **taxis seguros** tipo inDrive con cooperativas verificadas (ver [`docs/context.md`](docs/context.md) para la visión completa). El backend (Spring Boot) se está construyendo en paralelo contra el contrato de [`docs/requerimientos_backend.md`](docs/requerimientos_backend.md). El código actual del repo sigue en el estado descrito arriba (auth de cliente real, resto mockeado/vacío) hasta que se ejecute el backlog de [`docs/task.md`](docs/task.md) fase por fase.

## Documentación completa

Todo el detalle técnico vive en `docs/`. Índice completo y orden de lectura recomendado en [`AGENT.md`](AGENT.md).
