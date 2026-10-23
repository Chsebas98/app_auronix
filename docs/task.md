# Tareas

Backlog v1 completo, incorporando las 4 rondas de decisiones de negocio (ver historial en [`questions.md`](questions.md)) y el contrato de [`requerimientos_backend.md`](requerimientos_backend.md). Reescrito el 2026-08-22 durante la auditoría cruzada de documentación — la versión anterior solo cubría la primera ronda y omitía OTP, T&C, edad mínima, eliminar cuenta, sesión única con confirmación, enmascaramiento telefónico, autocompletado de direcciones, configuración pública, desviación de ruta/check-in, viajes recurrentes y badge de chat.

Orden = orden de implementación recomendado (cada fase depende en general de la anterior, salvo que se indique lo contrario). Formato de cada tarea: Estado | Feature/área | Descripción | Docs relevantes. Cada tarea cierra con sus pruebas correspondientes (ver [`testing.md`](testing.md)) y pasa [`qa_checklist.md`](qa_checklist.md) antes de marcarse `completo` — no son fases separadas al final.

## Fase 0 — Limpieza (habilita todo lo demás sin arrastrar deuda)
### T0.1 — Retirar dependencias sin uso definitivo
- Estado: pendiente | Feature/área: `pubspec.yaml`
- Descripción: quitar `dart_jsonwebtoken`, `mapbox_maps_flutter`, `google_maps_flutter`, `encrypt`, `pointycastle`.
- Docs: [`requirements.md`](requirements.md), [`security.md`](security.md)

### T0.2 — Eliminar el stub de `lib/features/admin`
- Estado: pendiente | Feature/área: `lib/features/admin/`
- Descripción: el panel de administrador es un dashboard web separado; el stub actual no tiene función en este repo.
- Docs: [`architecture.md`](architecture.md) sección 1, [`context.md`](context.md)

### T0.3 — Simplificar roles en login/router móvil
- Estado: pendiente | Feature/área: `lib/app/router/`, `lib/features/auth/`
- Descripción: el login móvil solo admite `rolUser`/`rolDriver`. Retirar ramas de `rolAdmin`/`rolGerente`. Resolver la inconsistencia de mnemónicos en `RoleHelpers`.
- Docs: [`architecture.md`](architecture.md) sección 2, [`security.md`](security.md) A.8

### T0.4 — Eliminar el mock de login de conductor
- Estado: pendiente | Feature/área: `lib/features/auth/presentation/bloc/auth_bloc.dart`
- Descripción: retirar el bypass con `Future.delayed` + credenciales de prueba; usar la respuesta real del usecase.
- Docs: [`security.md`](security.md) A.7, [`flow.md`](flow.md) sección 1

### T0.5 — Configurar versiones mínimas soportadas
- Estado: pendiente | Feature/área: `android/app/build.gradle.kts`, proyecto iOS
- Descripción: `minSdkVersion = 24` (Android 7.0) y deployment target iOS 16 (confirmado). Verificar que ninguna dependencia ya presente o por agregar (`flutter_secure_storage`, `stomp_dart_client`, `flutter_local_notifications`, `flutter_app_badger`) exija una versión mayor.
- Docs: [`requirements.md`](requirements.md)

## Fase 1 — Seguridad base y sesión
### T1.1 — Migrar tokens a `flutter_secure_storage`
- Estado: pendiente | Feature/área: `lib/app/database/`, `lib/app/core/network/interceptors/auth_interceptor.dart`
- Descripción: `AuthInterceptor`/`AuthLocalDbDataSource` dejan de leer/escribir tokens en SQLite; migran a `SecureStorageService`.
- Docs: [`architecture.md`](architecture.md) sección 4, [`database.md`](database.md) sección 3, [`security.md`](security.md) A.1

### T1.2 — Integrar `jwt_decoder` para refresco proactivo
- Estado: pendiente | Feature/área: `lib/app/core/network/`
- Descripción: leer `exp` del JWT para decidir cuándo refrescar.
- Docs: [`architecture.md`](architecture.md) sección 4

### T1.3 — Sesión única con confirmación en dos pasos
- Estado: pendiente — **bloqueada** hasta que backend implemente el contrato de [`requerimientos_backend.md`](requerimientos_backend.md) sección 2.2
- Feature/área: `lib/features/auth/`, `lib/app/core/bloc/session-bloc/`
- Descripción: login normal → si backend responde "sesión activa existente", mostrar modal de confirmación y reintentar con flag; si responde "viaje en curso", bloquear por completo con mensaje explicativo (sin opción de confirmar). `AuthInterceptor` distingue "token expirado" de "sesión invalidada por otro dispositivo" en cualquier request posterior.
- Docs: [`flow.md`](flow.md) sección 12, [`architecture.md`](architecture.md) sección 4, [`security.md`](security.md) puntos 16-17

## Fase 2 — Registro y cuenta (reglas transversales)
### T2.1 — OTP por email en registro de pasajero
- Estado: pendiente — depende de `POST /auth/clients/register/send-otp` y `/verify-otp` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 2.1)
- Feature/área: `lib/features/auth/` (registro cliente)
- Docs: [`flow.md`](flow.md) sección 11.1

### T2.2 — Checkbox de Términos y Condiciones (placeholder versionado)
- Estado: pendiente | Feature/área: `lib/features/auth/` (registro cliente y conductor)
- Descripción: pantalla/enlace con texto estándar placeholder, checkbox obligatorio, persistir `terminos_version` aceptada.
- Docs: [`flow.md`](flow.md) sección 11.1, [`database.md`](database.md) (`usuario.terminos_aceptados_en`/`terminos_version`)

### T2.3 — Validación de edad mínima (18 años, ambos roles)
- Estado: pendiente | Feature/área: `lib/features/auth/` (registro cliente y conductor)
- Descripción: input de fecha de nacimiento con validación cliente; el backend revalida.
- Docs: [`flow.md`](flow.md) sección 11.1, [`security.md`](security.md) punto 19

### T2.4 — Contacto de emergencia obligatorio
- Estado: pendiente | Feature/área: `lib/features/trips/safety/` (o Perfil)
- Descripción: bloquear "Solicitar taxi" / toggle "Disponible" mientras no exista al menos un contacto de emergencia registrado.
- Docs: [`flow.md`](flow.md) sección 11.1, [`database.md`](database.md) (`contacto_emergencia`)

### T2.5 — Eliminar cuenta
- Estado: pendiente — depende de `DELETE /users/me` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 2.3)
- Feature/área: Perfil/Configuración
- Docs: [`flow.md`](flow.md) sección 11.1, [`security.md`](security.md) punto 20

### T2.6 — Cambio de email/teléfono con re-verificación
- Estado: pendiente — depende de `PATCH /users/me/email` y `/phone` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 2.3)
- Feature/área: Perfil
- Docs: [`flow.md`](flow.md) sección 11.1

## Fase 3 — Geolocalización, mapas y configuración pública
### T3.1 — Activar `geolocator` en Home cliente/conductor
- Estado: pendiente | Feature/área: `lib/features/home/`
- Descripción: reemplazar mocks de ubicación, frecuencia según RNF1-3.
- Docs: [`architecture.md`](architecture.md) sección 5, [`functionality.md`](functionality.md) RNF1-3

### T3.2 — GPS obligatorio para disponibilidad del conductor
- Estado: pendiente | Feature/área: `lib/features/home/` (Home conductor)
- Descripción: bloquear el toggle "disponible" sin GPS habilitado, con enlace a ajustes.
- Docs: [`flow.md`](flow.md) sección 1.1, [`functionality.md`](functionality.md) RNF8.1

### T3.3 — Integrar autocompletado de direcciones (proxy LocationIQ vía backend)
- Estado: pendiente — depende de `GET /geo/autocomplete`/`GET /geo/reverse` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 4.5)
- Feature/área: pantalla "Seleccionar destino"
- Descripción: buscador de texto + mapa con pin arrastrable (ambos métodos).
- Docs: [`design_patterns.md`](design_patterns.md) 3.2, [`flow.md`](flow.md) sección 3

### T3.4 — Consumir `GET /config/public`
- Estado: pendiente — depende de [`requerimientos_backend.md`](requerimientos_backend.md) sección 4.4
- Feature/área: `lib/app/core/` (nuevo servicio de configuración)
- Descripción: obtener y cachear `precioMinimoTrayecto`, `distanciaMaximaKm`, `radioBusquedaKm`, rango de contraoferta — ninguna pantalla hardcodea estos valores.
- Docs: [`architecture.md`](architecture.md) sección 5

## Fase 4 — Estado de verificación del conductor (alcance reducido)
### T4.1 — Formulario de registro de conductor (sin documentos, con borrador local)
- Estado: pendiente | Feature/área: `lib/features/auth/` (registro conductor)
- Descripción: datos personales + licencia + placa (regex por país: EC/PE/CO, ver [`requerimientos_backend.md`](requerimientos_backend.md) 2.1) + datos básicos de vehículo; conserva borrador si se abandona.
- Docs: [`flow.md`](flow.md) sección 2, [`design_patterns.md`](design_patterns.md) 3.3

### T4.2 — Pantalla "Pendiente de verificación" con reenvío de correo
- Estado: pendiente — depende de `GET /drivers/me/estado-verificacion` y `POST /drivers/me/resend-verification-email`
- Feature/área: `lib/features/verification/`
- Descripción: muestra estado, SLA (~24h), botón de reenvío.
- Docs: [`flow.md`](flow.md) sección 2

### T4.3 — Guard de router por estado de verificación
- Estado: pendiente | Feature/área: `lib/app/router/`
- Descripción: bloquear home/solicitudes de conductor mientras `estado_verificacion != APROBADO`.
- Docs: [`architecture.md`](architecture.md) sección 2

## Fase 5 — Capa de tiempo real
### T5.1 — Implementar `RealtimeClient` (STOMP)
- Estado: pendiente — **bloqueada** hasta que backend confirme STOMP y topics ([`requerimientos_backend.md`](requerimientos_backend.md) sección 3)
- Feature/área: `lib/app/core/realtime/`
- Descripción: cliente STOMP con reconexión/backoff y fallback a polling REST; conserva último estado renderizado durante la reconexión.
- Docs: [`architecture.md`](architecture.md) sección 3

### T5.2 — Tracking de ubicación en vivo sobre `RealtimeClient`
- Estado: pendiente | Feature/área: `lib/features/trips/`
- Docs: [`flow.md`](flow.md) sección 5

## Fase 6 — Negociación de viajes
### T6.1 — Publicar solicitud con precio editable y validaciones (150 km, $0.50 mín., sin cruce de país)
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Docs: [`flow.md`](flow.md) sección 3, [`database.md`](database.md) `solicitud_viaje`

### T6.2 — Recepción de solicitudes cercanas (conductor, tiempo real, radio 10 km)
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Docs: [`flow.md`](flow.md) sección 4

### T6.3 — Enviar oferta / aceptar precio sugerido (rango 90%-130%)
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Docs: [`flow.md`](flow.md) sección 4

### T6.4 — Retirar oferta (manual y automática por sistema, con notificación siempre)
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Docs: [`flow.md`](flow.md) sección 4, [`database.md`](database.md) `oferta_viaje`

### T6.5 — Ver y aceptar ofertas (pasajero) — solo precio visible, identidad oculta
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Descripción: primeras 5 con scroll, overlay sobre el mapa; el cliente no reordena.
- Docs: [`design_patterns.md`](design_patterns.md) sección 2, [`flow.md`](flow.md) sección 4

### T6.6 — Expiración a 5 min + republicar con precio ≥ anterior
- Estado: pendiente | Feature/área: `lib/features/trips/negotiation/`
- Docs: [`flow.md`](flow.md) sección 3, [`database.md`](database.md) `solicitud_original_id`

## Fase 7 — Ejecución del viaje
### T7.1 — Conductor en camino: tracking + revelar identidad parcial + precio siempre visible
- Estado: pendiente | Feature/área: `lib/features/trips/`
- Docs: [`flow.md`](flow.md) sección 5

### T7.2 — Llamada telefónica enmascarada
- Estado: pendiente — depende de `numeroProxyConductor`/`numeroProxyPasajero` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 4.2)
- Feature/área: `lib/features/trips/`
- Descripción: `url_launcher` marca siempre el número proxy, nunca uno real almacenado localmente.
- Docs: [`flow.md`](flow.md) sección 15, [`security.md`](security.md) punto 18

### T7.3 — Validación de OTP de recogida
- Estado: pendiente | Feature/área: `lib/features/trips/`

### T7.4 — Viaje en curso: tracking + desviación de ruta + check-in de seguridad
- Estado: pendiente | Feature/área: `lib/features/trips/safety/`
- Descripción: cálculo local de desviación (>500m/90s o parada >3min) → reporta a `POST /trips/{id}/route-deviation` y muestra check-in discreto al pasajero, en paralelo (no condicionado) a la alerta automática al administrador.
- Docs: [`flow.md`](flow.md) sección 13, [`security.md`](security.md) puntos 29-31, [`requerimientos_backend.md`](requerimientos_backend.md) sección 4.1

### T7.5 — Finalización con desglose bruto/neto
- Estado: pendiente | Feature/área: `lib/features/trips/` | Docs: [`flow.md`](flow.md) sección 9

### T7.6 — Cancelación sin ventana de gracia, con aviso de impacto en calificación
- Estado: pendiente | Feature/área: `lib/features/trips/` | Docs: [`flow.md`](flow.md) sección 6

## Fase 8 — Chat
### T8.1 — Chat de texto en vivo (ASIGNADO→COMPLETADO)
- Estado: pendiente | Feature/área: `lib/features/trips/chat/`
- Docs: [`flow.md`](flow.md) sección 8, [`requerimientos_backend.md`](requerimientos_backend.md) sección 3

### T8.2 — Badge de mensajes no leídos
- Estado: pendiente — depende de `badgeCount` en el payload FCM ([`requerimientos_backend.md`](requerimientos_backend.md) sección 5)
- Feature/área: `lib/features/trips/chat/`
- Docs: [`requirements.md`](requirements.md) (`flutter_app_badger`)

## Fase 9 — Calificaciones
### T9.1 — Modal de calificación mutua post-viaje
- Estado: pendiente | Feature/área: `lib/features/trips/ratings/`

### T9.2 — Manejo de timeout de 15 min (solo lectura del resultado)
- Estado: pendiente | Feature/área: `lib/features/trips/ratings/` | Docs: [`flow.md`](flow.md) sección 5.7, [`security.md`](security.md) punto 32

## Fase 10 — Seguridad del usuario (SOS)
### T10.1 — Botón SOS con confirmación (visible siempre, funcional solo en viaje activo)
- Estado: pendiente | Feature/área: `lib/features/trips/safety/`

### T10.2 — Gestión de contactos de emergencia
- Estado: pendiente | Feature/área: `lib/features/trips/safety/` (nota: el mínimo de 1 contacto ya se cubre en T2.4; esta tarea es el CRUD completo)

### T10.3 — Compartir viaje en vivo (`share_plus`)
- Estado: pendiente | Feature/área: `lib/features/trips/safety/`

## Fase 11 — Notificaciones push
### T11.1 — Registrar token FCM tras login
- Estado: pendiente — depende de la auditoría de [`requerimientos_backend.md`](requerimientos_backend.md) sección 5

### T11.2 — Manejo de notificaciones foreground/background
- Estado: pendiente | Docs: [`architecture.md`](architecture.md) sección 6

### T11.3 — Auditoría de cobertura de notificaciones ("nunca dejar un evento sin avisar")
- Estado: pendiente | Descripción: checklist final que recorre cada evento de negocio de `flow.md` (oferta retirada/rechazada, viaje cancelado, conductor aprobado, mensaje de chat, etc.) y confirma que dispara push. Docs: [`flow.md`](flow.md) sección 11.2

## Fase 12 — Ganancias y comisión
### T12.1 — Reemplazar mocks de ganancias por datos reales (bruto/neto, filtro por fecha)
- Estado: pendiente | Feature/área: `lib/features/home/` (o mover a `trips/`) | Docs: [`flow.md`](flow.md) sección 9

## Fase 13 — Viajes recurrentes
### T13.1 — Detección y re-solicitud en un toque
- Estado: pendiente — depende de `GET /trips/frequent` ([`requerimientos_backend.md`](requerimientos_backend.md) sección 4.1)
- Feature/área: `lib/features/trips/negotiation/`, Historial
- Docs: [`flow.md`](flow.md) sección 14

## Fase 14 — Localización (alcance reducido: solo español en v1)
### T14.1 — Mantener `app_es.arb` como única fuente de strings
- Estado: pendiente | Descripción: no crear `.arb` de otros idiomas ni selector de idioma en v1 (revertido — sin proveedor de traducción, ver [`requirements.md`](requirements.md) sección Internacionalización).

### T14.2 — Migrar strings hardcodeados a claves de `l10n` (progresivo, por pantalla tocada)
- Estado: pendiente | Descripción: por buena práctica, para que agregar idiomas en v2 sea trabajo de traducción, no refactor de UI.

## Fase 15 — Testing
Ver [`testing.md`](testing.md) — cada tarea de las fases 1-14 cierra con sus pruebas correspondientes antes de marcarse `completo`, no como una fase separada al final.

## Cómo registrar una tarea nueva
```
### T<fase>.<n> — <nombre corto>
- Estado: pendiente | en curso | completo
- Feature/área: <ruta o feature>
- Descripción: <qué hay que hacer, 1-3 líneas>
- Docs relevantes: <links>
```
No dejes tareas completadas indefinidamente aquí sin aportar contexto — si el hecho sigue siendo relevante, muévelo a [`functionality.md`](functionality.md) y elimina la entrada de tarea.
