# Fundación existente de Ando-UI (`app_auronix`)

Este documento es la Tarea 0 del plan de Ando-UI: un inventario verificado de lo que **ya existe y
funciona** en este repositorio, para que ninguna tarea posterior recree algo que ya está construido.

**Regla para toda tarea futura:** antes de crear un átomo, molécula, organismo, servicio, interceptor
o mecanismo de almacenamiento/navegación nuevo en `lib/app/` o `lib/shared/`, revisar este documento.
Si ya existe un equivalente, se adapta o se extiende — nunca se duplica. Si de verdad falta algo, se
crea en el lugar correcto según la convención ya establecida (ver abajo) y se agrega a este documento.

## Arquitectura ya adoptada

Feature-First + Clean Architecture por feature + Atomic Design en la capa de presentación:

```
lib/
  app/            # cross-cutting: config, DI, router, theme, network, blocs base, permisos
  features/       # auth, home, trips, client, messages, admin, onBoarding
    <feature>/
      data/       # datasources, repositories, models
      domain/     # models, repositories (interfaces), usecases
      presentation/
        atoms/ molecules/ organisms/ pages/ templates/ bloc/
  shared/         # atoms/molecules/organisms/templates reusados entre features
```

## Diseño: tema y tokens (YA EXISTE, no recrear)

- `lib/app/design/theme/app_theme.dart`, `app_colors.dart`, `theme_extensions.dart` — tema y paleta
  corporativa completos (claro/oscuro vía `context.isDark`/`context.isLight`/`context.appColors`).
- `lib/app/design/tokens/{shadows,radius,spacing,typography,animations}.dart` — tokens visuales.

## Átomos (YA EXISTEN, no recrear)

- `shared/atoms/buttons/`: `app_button.dart`, `app_icon_button.dart`, `app_notification_button.dart`,
  `app_theme_toogle.dart`.
- `shared/atoms/inputs/`: `app_radio.dart`, `app_checkbox.dart`,
  `inputs/input_default/app_text_field.dart` (con `validation_rule.dart`, indicador de fuerza de
  contraseña, botón mostrar/ocultar password, formatters).
- `shared/atoms/images/`: `app_image_asset.dart`, `app_svg_image_asset.dart`, `app_avatar.dart`.
- `shared/atoms/{icons,text,spacing,radius,skeleton}/`: iconografía, `app_text.dart` (tipografía),
  espaciado, radios, skeleton boxes.

## Moléculas y organismos (YA EXISTEN, no recrear)

- `shared/molecules/`: `app_snackbar.dart`, `app_skeleton_list_tile.dart`, `app_appbar.dart`,
  `app_bottom_nav.dart`, `app_horizontal_logo.dart`, `app_avatar_button.dart`,
  `app_editable_avatar.dart`, `app_input_select.dart`.
- `shared/organisms/dialogs/`: `custom_dialog.dart` con animaciones (Rive + nativas),
  `header_dialog.dart`, `animated_button.dart`.
- `shared/templates/`: `status_form.dart`, `allow_permits_screen.dart`, `profile_drawer.dart`,
  `version_screen.dart`, `session_screen.dart`, cubit de bottom nav.

## Infraestructura de app (YA EXISTE, no recrear)

- **DI:** `lib/app/di/dependency_injection.dart` usa **get_it** (`^8.2.0`, ya en `pubspec.yaml`).
  No introducir otro framework de DI; registrar servicios nuevos aquí.
- **Router:** `lib/app/router/{app_router,app_routes,router}.dart` usa **go_router** (`^16.2.4`, ya
  en `pubspec.yaml`), con `client_routes`/`conductor_routes` separadas por rol, ya conectado en
  `main.dart`. No crear un router paralelo.
- **Red:** `lib/app/core/network/dio_client.dart` ya tiene `AuthInterceptor`,
  `CacheControlInterceptor` y `RetryControlInterceptor` registrados e inyectados vía DI.
- **Ambientes:** `lib/app/environments/environment.dart` +
  `environments/flavors/{env_base_config,env_dev_config,env_prod_config}.dart`.
- **Blocs base:** `lib/app/core/bloc/` — `session_bloc`, `global_cubit`, `theme_cubit`,
  `dialog_cubit`, `app_life_cycle_cubit`, `forms_states`.
- **Permisos:** `lib/app/core/permission/` — `permission_cubit` + `permission_handler.dart`.
- **Errores:** `lib/core/errors/{failure,service_exceptions,prefs_exceptions,errors}.dart` — jerarquía
  de excepciones ya definida. Cualquier excepción de red/dominio nueva debe encajar aquí.
- **Sockets de viaje:** `lib/features/trips/data/datasources/socket/{driver_trip_socket,
  trip_status_socket}.dart` + `trip_socket_events.dart` — tracking de viaje por WebSocket ya
  implementado. `driver_position_sender.dart` envía la posición del conductor cada 5s.
- **Mapa:** `google_maps_flutter` (`^2.14.2`) + `geolocator` (`^14.0.2`) +
  `flutter_polyline_points` (`^3.1.0`), ya integrados en `driver_nearby_map.dart` y
  `client_trip_in_progress_template.dart`. **Decisión de stack confirmada (investigación de mercado
  2026): quedarse en Google Maps, no migrar a Mapbox/OpenStreetMap** — ver detalle de costos en las
  tareas T27/T32 de Mnemosine.

## Inconsistencias/huecos reales encontrados (para que el dueño del proyecto decida)

1. **Almacenamiento de tokens inseguro:** `lib/app/database/auth_local_db_datasource.dart` guarda el
   JWT access/refresh token en SQLite plano (`AppDatabase.upsertUserMap`), sin cifrar. No hay
   `flutter_secure_storage` en `pubspec.yaml`. Es un hueco de seguridad real — migrar los tokens a
   almacenamiento seguro es una mejora legítima, no una duplicación (tarea T5 del plan).
2. **Marker de conductor sin rumbo ni animación:** `client_trip_in_progress_template.dart` dibuja al
   conductor con un pin de color plano, sin `rotation` ni interpolación suave entre actualizaciones de
   posición — no se ve "manejando" como se pidió (efecto estilo Waze). El campo `heading` de
   `Geolocator.Position` se captura pero nunca se envía por el socket. Ver tareas T27/T32.
3. **Icono de carro inconsistente:** `driver_nearby_map.dart` sí usa un icono de carro
   (`assets/images/png/car_marker.png`), pero `client_trip_in_progress_template.dart` no — debería
   usarse el mismo asset en ambos para consistencia visual.

## Verificación de línea base

`flutter analyze` y `flutter test` se corrieron sobre el código ya existente antes de tocar nada:

- **`flutter analyze`**: 4 advertencias preexistentes (ninguna introducida por esta tarea) — un
  include faltante en `analysis_options.yaml` (`flutter_lints/flutter.yaml`, probablemente por
  versión de dependencias desactualizada), un `_NotificationBadge` sin usar, y dos overrides de
  `Bloc` sin llamar a `super` (`must_call_super`). No bloquean la compilación.
- **`flutter test`**: el repo tiene **un solo archivo de test en todo el proyecto**,
  `test/widget_test.dart` — es el "Counter increments smoke test" que deja `flutter create` por
  defecto, nunca actualizado ni borrado. Falla porque busca un contador ("0" en pantalla) que ya no
  existe en la app real. **Hoy no hay cobertura de tests real en el repo.** No se corrige en esta
  tarea (decidir qué debería probar ese smoke test, o si se reemplaza por uno real de arranque de la
  app, es una decisión de alcance para el dueño del proyecto, no de auditoría) — queda señalado aquí
  para que se priorice pronto.

Si algo fallaba antes de esta tarea, no es responsabilidad de esta tarea arreglarlo — solo
documentarlo, como se hizo arriba.
