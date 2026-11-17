# Arquitectura

Arquitectura objetivo para Auronix con alcance ya acotado: **sin panel admin ni carga de documentos en esta app** (ambos fuera de este repositorio). Se conserva toda la base actual (Clean Architecture + Atomic Design + BLoC + get_it + go_router + Dio + sqflite) — no se reescribe desde cero.

## 1. Capas por feature (se mantiene)
Igual que antes: `data → domain → presentation`, Atomic Design en `presentation/`. Ver [`hierarchy.md`](hierarchy.md).

Features nuevas/ampliadas:
- `lib/features/trips/negotiation/` — submódulo de `trips/` para publicar solicitud y negociar ofertas (no una feature nueva independiente, porque comparte el dominio "viaje").
- `lib/features/trips/chat/` — submódulo de `trips/` para el chat en vivo asociado a un viaje.
- `lib/features/trips/ratings/` — submódulo de `trips/` para calificación post-viaje.
- `lib/features/trips/safety/` — submódulo de `trips/` para SOS y contacto de emergencia.
- `lib/features/verification/` — se reduce a **solo mostrar estado** (`PENDIENTE`/`APROBADO`/`RECHAZADO`) del conductor; no incluye subida de documentos.
- `lib/features/admin/` — **se elimina** el stub existente (ver tarea de limpieza en [`task.md`](task.md)); el panel admin no vive en este repo.
- `lib/features/messages/` — deja de estar vacía: pasa a ser el chat de viaje (podría fusionarse con `trips/chat/`, decisión de implementación libre siempre que no quede duplicada).

## 2. App shell (`lib/app/`) — se mantiene, con extensiones
- **DI**: se añade, en este orden tras lo ya existente: `SecureStorageService` → `RealtimeClient` (STOMP) → `LocationService` (geolocator) → `PushNotificationService` (FCM, solo consumo — el backend ya tiene la integración, se **audita**, no se implementa desde cero) → blocs nuevos (`NegotiationBloc` o ampliación de `DriverTripBloc`/`ClientTripBloc`, `ChatBloc`, `RatingBloc`, `SosBloc`), todos `factory` salvo el bloc de viaje activo, que debe sobrevivir a la navegación mientras el viaje esté en curso.
- **Router**: rutas nuevas: `/driver/verification-pending`, `/client/trip/negotiating`, `/client/trip/active`, `/driver/trip/active`, `/trip/{id}/chat`. **Se elimina** cualquier ruta `/admin/**` planificada en la versión anterior de este documento. El guard de redirect se extiende: conductor con `estado_verificacion != APROBADO` → `/driver/verification-pending`, sin acceso a home ni a solicitudes.
- **Roles en el router**: `rolAdmin`/`rolGerente` **no inician sesión en esta app** — no existe flujo de login para ellos aquí. Simplificar el guard para tratar cualquier rol distinto de `rolUser`/`rolDriver` como no soportado en este cliente (mensaje claro, no crash), en vez de mantener ramas muertas para roles que nunca aparecerán.
- **Red**: se mantiene el pipeline de interceptores. `AuthInterceptor` migra a leer el token desde `SecureStorageService`. El formato de error/éxito se estandariza según [`requerimientos_backend.md`](requerimientos_backend.md) — hasta que el backend lo implemente, `ErrorServiceException`/`ServiceResponse` deben tolerar el formato actual sin romper.
- **Base de datos local**: se mantiene sqflite para caché, sin tokens (ver sección 4).

## 3. Capa de tiempo real (decisión: STOMP sobre WebSocket)
Se decide **STOMP sobre WebSocket (con fallback SockJS)** como transporte, por ser la mejor experiencia de usuario posible para negociación de ofertas, tracking en vivo y chat (baja latencia, bidireccional, un solo canal para los tres casos de uso) y el estándar idiomático de Spring Boot. El detalle completo de topics, payloads y fallback de resiliencia se especifica en [`requerimientos_backend.md`](requerimientos_backend.md) — es la fuente de verdad del contrato; este documento solo fija la decisión de arquitectura del lado cliente:
- `RealtimeClient` (nuevo, en `lib/app/core/realtime/`) expone streams tipados (`Stream<OfertaViaje>`, `Stream<UbicacionUpdate>`, `Stream<EstadoViajeUpdate>`, `Stream<MensajeChat>`). Ningún bloc habla STOMP directamente.
- Reconexión automática con backoff (mismo patrón que `RetryControlInterceptor`, no la misma clase). **Durante la reconexión, la UI conserva la última ruta/posición conocida** (mapa, estado del viaje, mensajes ya cargados) y solo superpone un indicador de "reconectando" — nunca limpia el mapa ni el estado ya renderizado (confirmado, aplica a ubicación, chat y estado del viaje por igual, tanto en pasajero como en conductor).
- Si el WebSocket no conecta tras N reintentos, degradar a polling REST de baja frecuencia sobre los mismos datos (nunca dejar al usuario sin actualizaciones silenciosamente).

## 4. Autenticación JWT y almacenamiento seguro
- Migrar `token_access`/`token_refresh` de SQLite a `flutter_secure_storage` (Keystore/Keychain). La tabla `user` de SQLite conserva solo datos de perfil no sensibles.
- Decodificar el `exp` del JWT con `jwt_decoder` (sin verificar firma — responsabilidad exclusiva del backend) para refrescar proactivamente.
- Retirar `dart_jsonwebtoken` del proyecto.
- El mismo JWT autentica la conexión STOMP (ver [`requerimientos_backend.md`](requerimientos_backend.md) para el mecanismo exacto de envío del token en el `CONNECT` frame).
- **Sesión única con confirmación (confirmado, flujo completo en [`flow.md`](flow.md) sección 12)**: el login no es una sola llamada atómica cuando hay una sesión previa — es un flujo de dos pasos: (1) intento de login; si el backend detecta una sesión activa sin viaje en curso, responde pidiendo confirmación (código de error distinguible, ej. `409 sesion-activa-existente`) y el cliente muestra un modal antes de reintentar con un flag de confirmación; (2) si la cuenta tiene un viaje `ASIGNADO`/`EN_CURSO`, el backend **rechaza el login por completo** (ej. `403 viaje-en-curso`), sin ofrecer confirmación — el mensaje se muestra en el dispositivo que intenta entrar. `AuthInterceptor`/`SessionBloc` también deben distinguir, en cualquier request posterior, "token expirado" (reintenta refresh) de "sesión invalidada por otro dispositivo" (fuerza logout con mensaje explicativo, sin reintentar refresh).

## 5. Geolocalización y mapas
- **Mapas**: se decide mantener **`flutter_map`** (OpenStreetMap/CartoDB) como proveedor definitivo — ya está integrado, funcional y sin costo de licenciamiento; es la mejor relación costo-beneficio disponible hoy. **Se retiran** `mapbox_maps_flutter` y `google_maps_flutter` de `pubspec.yaml` (dependencias sin uso desde el inicio del proyecto).
- **Ubicación**: activar `geolocator` (ya declarado) para reemplazar los mocks. Frecuencia baja cuando el conductor está disponible sin viaje activo; alta durante un viaje activo (ver [`functionality.md`](functionality.md) RNF1-3). **GPS obligatorio para ponerse disponible** (confirmado): si el conductor no tiene ubicación habilitada, el toggle de disponibilidad debe bloquearse con un mensaje claro y enlace directo a ajustes del sistema, nunca fallar silenciosamente.
- **Radio de notificación a conductores**: fijo en **10 km** desde el punto de origen de la solicitud (confirmado, ver [`requerimientos_backend.md`](requerimientos_backend.md)) — es un parámetro de backend, el cliente no lo calcula.
- **Geocodificación**: activar `geocoding` (ya declarado) para direcciones legibles.
- **Rutas**: `flutter_polyline_points` para decodificar la geometría que devuelva el backend.
- **Cálculo de precio, distancia y duración**: siempre en el backend — el cliente nunca implementa esta lógica (confirmado, ya no es una decisión abierta). **Límite de 150 km** por viaje validado en cliente (UX inmediata) y backend (fuente de verdad).
- **Detección de desviación de ruta y check-in de seguridad (confirmado, requisito v1)**: el cliente calcula, durante `EN_CURSO`, la distancia perpendicular entre la posición en vivo del conductor y la polyline de la ruta ya decodificada. Umbral: **>500m sostenidos por >90s**, o **parada no planificada >3 min** fuera de origen/destino (estándar tipo Uber RideCheck). Al superarse: (1) se reporta a backend (`POST /trips/{id}/route-deviation`) para que cree una `sos_alerta` automática al administrador **de inmediato, sin esperar al pasajero**; (2) en paralelo, el cliente muestra un check-in discreto y no alarmante al pasajero ("¿Todo bien con tu viaje?"). Prioridad explícita: proteger a un pasajero que sufra un robo/secuestro por encima de evitar falsos positivos — ver [`flow.md`](flow.md) sección 13 y [`security.md`](security.md).
- **Configuración pública dinámica (nuevo)**: valores de negocio que el administrador puede cambiar desde el dashboard (precio mínimo, hoy $0.50) no se hardcodean en el cliente — se obtienen de un endpoint de configuración al arrancar la app y se cachean con una expiración corta (ver [`requerimientos_backend.md`](requerimientos_backend.md)).

## 6. Notificaciones push
El backend **ya tiene integración con FCM** — no se implementa desde cero, se **audita** (checklist completo en [`requerimientos_backend.md`](requerimientos_backend.md)): registro de token FCM tras login, canales de notificación en Android, permisos de notificación en iOS, manejo de payload en foreground (`flutter_local_notifications`) vs. background (handler nativo de FCM). **Contenido de notificaciones de chat (decisión confirmada)**: genérico ("Nuevo mensaje de {nombre}"), sin el texto del mensaje, para proteger la privacidad en la pantalla de bloqueo — el `viaje_id` va en el payload `data` para poder abrir el chat correcto al tocarla. La aprobación de un conductor (`estado_verificacion = APROBADO`) también dispara push obligatoriamente, sin depender de que tenga la app abierta.

## 7. Máquina de estados del viaje
Sin cambios respecto a la versión anterior: `ASIGNADO → CONDUCTOR_EN_CAMINO → CONDUCTOR_LLEGO → EN_CURSO → COMPLETADO`, con salida a `CANCELADO` desde cualquier estado previo a `COMPLETADO`. Modelar como función pura testeable en `domain`. Detalle de transiciones en [`flow.md`](flow.md).

## 7.1 Privacidad de contacto telefónico (regla de seguridad no negociable)
La llamada entre pasajero y conductor nunca marca un número real — el cliente siempre llama a un número intermediario/proxy que el backend debe proveer (integración de un servicio de enmascaramiento de llamadas, ej. Twilio, del lado backend; ver [`requerimientos_backend.md`](requerimientos_backend.md) y [`security.md`](security.md)). El nombre del conductor/pasajero se revela solo parcialmente al asignar el viaje (primer nombre + apellido paterno), nunca completo ni antes de la asignación.

## 8. Verificación de conductores (alcance reducido)
Esta app **no** implementa carga de documentos ni revisión. Solo necesita:
- Mostrar el estado de verificación del conductor (`PENDIENTE`/`APROBADO`/`RECHAZADO`) tras consultar al backend.
- Bloquear el acceso a las pantallas de conductor operativo mientras no esté `APROBADO`.
- Reaccionar en tiempo real (o al reabrir la app) si el estado cambia (ej. el admin lo activa mientras el conductor tiene la app abierta en la pantalla de espera).

## 9. Orden de implementación recomendado
1. Limpieza (retirar dependencias sin uso, eliminar stub de `admin`, quitar mock de login de conductor, simplificar roles en el router).
2. Seguridad base: migrar tokens a `flutter_secure_storage`.
3. Geolocalización real (reemplaza mocks existentes).
4. Capa de tiempo real (`RealtimeClient`), empezando por el caso más simple (tracking de ubicación).
5. Estado de verificación del conductor (solo lectura) + bloqueo de acceso.
6. Negociación de viajes completa (publicar solicitud, ofertas, retirar oferta, aceptar).
7. Ejecución del viaje (tracking, OTP, chat, finalización, cancelación).
8. Calificaciones (con timeout de 15 min).
9. Notificaciones push (auditoría + integración cliente).
10. Ganancias reales con comisión.
11. Internacionalización.

Detalle exacto de tareas en [`task.md`](task.md).
