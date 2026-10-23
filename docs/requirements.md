# Requerimientos del sistema

## SDK y lenguaje
Flutter, Dart SDK `^3.9.0`. Null safety habilitado.

## Backend (contexto — no vive en este repo)
API REST en **Spring Boot**, JWT emitido tras login. Tiempo real vía **STOMP sobre WebSocket** (decisión de arquitectura, ver [`architecture.md`](architecture.md)). FCM **ya integrado** en backend (se audita, no se reimplementa). Contrato exacto en [`requerimientos_backend.md`](requerimientos_backend.md).

## Dependencias existentes y su rol final

| Categoría | Paquete | Decisión final |
|---|---|---|
| Estado | flutter_bloc | Se mantiene |
| Routing | go_router | Se mantiene, rutas admin/gerente planificadas se descartan |
| DI | get_it | Se mantiene |
| Red | dio, dio_cache_interceptor, http_cache_hive_store | Se mantiene |
| Persistencia local | sqflite, rx_shared_preferences | Se mantiene, sin tokens |
| Errores funcionales | dartz | Se mantiene |
| Firebase | firebase_core | Se mantiene, se amplía con messaging/crashlytics |
| Auth social | google_sign_in | Se mantiene |
| Cripto | encrypt, pointycastle | **Se retiran** — no hay caso de uso confirmado; el frontend no necesita cifrado adicional propio sobre HTTPS/WSS |
| Cripto | dart_jsonwebtoken | **Se retira** — reemplazado por `jwt_decoder` |
| Mapas | flutter_map | **Se mantiene como definitivo** (ya funcional, mejor costo-beneficio) |
| Mapas | mapbox_maps_flutter, google_maps_flutter | **Se retiran** — nunca se usaron y no hay requisito de negocio que los justifique |
| Geo | geolocator, geocoding | **Se activan** (reemplazan mocks) |
| Rutas en mapa | flutter_polyline_points | Se activa (decodifica geometría del backend) |
| Gráficos | fl_chart | Se mantiene (ganancias, con desglose bruto/neto) |

## Dependencias nuevas a incorporar

| Paquete | Propósito |
|---|---|
| `flutter_secure_storage` | Almacenamiento cifrado de JWT (Keystore/Keychain). Prioridad más alta. |
| `stomp_dart_client` | Cliente STOMP sobre WebSocket para negociación, tracking y chat en tiempo real. |
| `firebase_messaging` | Consumir las notificaciones push que el backend ya envía (auditar contrato, ver [`requerimientos_backend.md`](requerimientos_backend.md)). |
| `firebase_crashlytics` | Monitoreo de crashes en producción — hoy no existe ninguna telemetría de errores. |
| `flutter_local_notifications` | Mostrar notificaciones en foreground (FCM no las muestra automáticamente ahí). |
| `jwt_decoder` | Leer el claim `exp` del JWT localmente, sin verificar firma. |
| `cached_network_image` | Fotos de conductor/vehículo y avatares de chat, con cacheo eficiente. |
| `share_plus` | Compartir el estado del viaje en vivo con un contacto de emergencia. |
| `url_launcher` | Llamada telefónica directa entre pasajero y conductor. |
| `json_annotation` + `json_serializable` (dev: `build_runner`) | Reduce boilerplate y errores de parseo manual en los modelos nuevos (`SolicitudViaje`, `OfertaViaje`, `Viaje`, `MensajeChat`, `Calificacion`, etc.). |
| `flutter_app_badger` (o equivalente vigente) | Badge de mensajes no leídos en el ícono de la app (confirmado como requisito v1) — verificar soporte Android por fabricante/launcher, degradar sin error si no está disponible. |

No se incorpora `image_picker`/carga de archivos: la app **no** implementa subida de documentos (fuera de alcance, ver [`context.md`](context.md)).

## Dependencias de testing (dev_dependencies)
- `bloc_test` — testear blocs/cubits.
- `mocktail` — mockear repositorios/datasources/`RealtimeClient` sin generación de código.

## Internacionalización — revertido a solo español para v1 (confirmado)
No hay proveedor de traducción disponible actualmente. **Decisión final**: v1 se lanza únicamente en español — se descarta el requisito previo de inglés/francés/alemán/idiomas asiáticos para este lanzamiento. Sí se recomienda seguir externalizando strings vía `lib/l10n/arb/app_es.arb` (una sola clave por texto, sin traducir a otros idiomas todavía) para que agregar idiomas en una versión futura sea un trabajo de traducción, no un refactor de la UI. No crear `app_en.arb`/`app_fr.arb`/`app_de.arb` en v1 — se pospone por completo hasta que exista un proveedor de traducción.

## Configuración de entorno / secretos requeridos
- `flutter_secure_storage` no requiere configuración adicional más allá de las plataformas nativas ya soportadas por el paquete.
- Endpoint(s) de WebSocket/STOMP por entorno, a añadir en `lib/app/environments/flavors/env_{dev,prod}_config.dart` junto al `apiBaseUrl` existente (una vez confirmado por backend según [`requerimientos_backend.md`](requerimientos_backend.md)).
- Credenciales de Firebase ya cubiertas por los `firebase_options_dev.dart`/`firebase_options.dart` existentes; solo se activan servicios adicionales (Messaging, Crashlytics) en la consola de Firebase.

## Plataformas / flavors
Android/iOS, flavors dev/prod, Firebase separado por entorno. **Versiones mínimas soportadas (confirmado)**: Android 7.0 (API 24), iOS 16 — configurar `minSdkVersion` en `android/app/build.gradle.kts` y el deployment target en el proyecto iOS; verificar que ninguna dependencia nueva (`flutter_secure_storage`, `flutter_local_notifications`, `geolocator`, etc.) exija una versión mayor sin confirmarlo aquí primero. **V1 se publica solo en Ecuador** (confirmado) — no se preparan fichas de tienda para Colombia/Perú en este lanzamiento. Pendiente: firma de release real de Android antes de publicar (ver [`security.md`](security.md)).
