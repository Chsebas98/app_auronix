# Requerimientos para el backend (Spring Boot)

Este documento es la especificación que el equipo de backend necesita para soportar el frontend Flutter de Auronix. Se genera porque varias decisiones de infraestructura se delegaron explícitamente al criterio técnico de quien construye el cliente — este documento traslada esas decisiones al equipo de backend para su implementación y confirmación. No reemplaza [`database.md`](database.md) (esquema de datos) ni [`flow.md`](flow.md) (lógica de negocio) — los complementa con el contrato de comunicación.

## 1. Formato estándar de respuesta (recomendado)

### Éxito
```json
{ "success": true, "data": { /* payload específico del endpoint */ }, "message": "Operación exitosa" }
```

### Error
Se recomienda **RFC 7807 (Problem Details for HTTP APIs)**, soportado nativamente desde Spring Boot 3 (`ProblemDetail`):
```json
{
  "type": "https://auronix.app/errors/oferta-ya-asignada",
  "title": "La solicitud ya fue asignada a otro conductor",
  "status": 409,
  "detail": "La solicitud 123 ya tiene una oferta aceptada.",
  "instance": "/api/v1/solicitudes/123/ofertas/45/aceptar"
}
```
Para errores de validación de campos, extender con un arreglo `errors`:
```json
{
  "type": "https://auronix.app/errors/validacion",
  "title": "Error de validación",
  "status": 400,
  "errors": [{ "field": "precioPublicado", "message": "Debe ser mayor a 0.50" }]
}
```
**Por qué**: permite que `AuthInterceptor`/`ErrorServiceException` en el cliente parseen errores de forma consistente sin heurísticas por código HTTP.

## 2. Autenticación JWT y sesión única
- `POST /auth/clients/login`, `/auth/drivers/login`, `/auth/clients/google-login`, `/auth/clients/register`, `/auth/drivers/register`, `/auth/clients/refresh-token`, `/auth/drivers/refresh-token`, `/auth/logout` — **ya existen**; confirmar que el shape de respuesta se ajusta al formato de la sección 1.
- El JWT debe incluir, como mínimo, el claim `exp` (el cliente lo lee con `jwt_decoder`, sin verificar firma).
- Confirmar tiempo de vida del access token y del refresh token, y si el refresh token rota al usarse.
- El mismo JWT autentica la conexión STOMP (ver sección 3) — confirmar si va en el header `Authorization` del `CONNECT` frame o como parámetro de query en el handshake SockJS.

### 2.1 Registro de pasajero con OTP por email (confirmado)
- `POST /auth/clients/register/send-otp` (email) → envía código de 6 dígitos, expira en **10 minutos**, reenviable con cooldown de 60s.
- `POST /auth/clients/register/verify-otp` (email, código) → habilita continuar el registro.
- El registro (ambos roles) debe persistir `terminos_aceptados_en` (timestamp) — rechazar el registro si no se envía la aceptación explícita.
- Backend debe **validar edad mínima** server-side además de la validación en cliente: **18 años para todo usuario** (pasajero y conductor por igual, confirmado — sin excepción para menores), a partir de `fecha_nacimiento`.
- **Validación de placa por país (confirmado, regex oficial provisto por producto)**: aplicar según el país detectado por la ubicación del conductor al momento del registro.
  - Ecuador: `^[A-Z]{3}-\d{3,4}$`
  - Perú: `^([A-Z]{3}-\d{3}|[A-Z]\d[A-Z]-\d{3})$`
  - Colombia: `^([A-Z]{3}\d{3}|[A-Z]{2}\d{4})$`
- **Términos y condiciones (confirmado)**: v1 usa un texto estándar/genérico como placeholder, versionado (`terminos_version` en [`database.md`](database.md)) para poder reemplazarlo por el del departamento legal sin romper el historial de aceptaciones ya registradas. Si se requiere un endpoint para servir el texto (`GET /legal/terms?version=`) o si el texto vive embebido en el cliente queda a criterio de implementación, siempre que la versión aceptada quede trazada.

### 2.2 Sesión única con confirmación (confirmado, flujo de dos pasos)
1. `POST /auth/{clients|drivers}/login` normal. Si no hay sesión activa previa para esa cuenta → 200 con tokens.
2. Si hay una sesión activa previa **sin** viaje `ASIGNADO`/`EN_CURSO` asociado → responder `409` con `type: ".../sesion-activa-existente"` (sin invalidar nada todavía). El cliente muestra un modal de confirmación y reintenta el mismo login agregando `"confirmarCierreSesion": true` en el body → esta segunda llamada invalida la sesión anterior (nuevo `jti` en `usuario.sesion_activa_id`, ver [`database.md`](database.md)) y devuelve tokens nuevos.
3. Si hay una sesión activa **con** viaje `ASIGNADO`/`EN_CURSO` asociado a esa cuenta → responder `403` con `type: ".../viaje-en-curso"` y un `detail` explicando que hay un viaje en curso — **sin ninguna opción de confirmar**, el login queda bloqueado hasta que el viaje termine. Este mensaje se muestra en el dispositivo que intenta iniciar sesión.
4. En cualquier request posterior (REST o `CONNECT` STOMP), un token cuyo `jti` no coincida con `usuario.sesion_activa_id` debe rechazarse con un error **distinguible** de "token expirado" (ej. `type: ".../sesion-invalidada"`), para que el cliente muestre el mensaje correcto en vez de intentar un refresh normal.

### 2.3 Cuenta
- `DELETE /users/me` — baja lógica (`estado_cuenta = ELIMINADA`), preservando integridad referencial del historial de viajes de terceros; anonimizar datos personales del usuario eliminado según corresponda.
- `PATCH /users/me/email` y `PATCH /users/me/phone` — el valor anterior sigue vigente hasta confirmar el nuevo por verificación (mismo mecanismo de OTP que 2.1).
- `POST /drivers/me/resend-verification-email` — reenvía el correo con el enlace al portal externo de verificación documental.

## 3. Tiempo real: STOMP sobre WebSocket
Decisión de arquitectura del lado cliente (ver [`architecture.md`](architecture.md) sección 3): STOMP sobre WebSocket para negociación, tracking y chat (baja latencia, bidireccional, canal único).
- Endpoint de conexión STOMP (ej. `/ws` con fallback SockJS) protegido por el JWT del usuario.
- **Topics necesarios**:
  - `/topic/conductores/{zonaId}/solicitudes` (o filtrado geoespacial por radio de 10 km) — nuevas `solicitud_viaje` para conductores disponibles cercanos.
  - `/topic/solicitud/{solicitudId}/ofertas` — nuevas ofertas y retiros (incluye retiros por sistema, con motivo), en el orden ya calculado por backend.
  - `/topic/viaje/{viajeId}/ubicacion` — ubicación en vivo, **autorización estricta** solo para el pasajero/conductor de ese `viaje_id`, validada en el `SUBSCRIBE`, no solo en el `CONNECT`.
  - `/topic/viaje/{viajeId}/estado` — cambios de estado del viaje.
  - `/topic/viaje/{viajeId}/chat` — mensajes de chat, misma restricción de autorización.
  - `/topic/conductor/{conductorId}/estado-verificacion` — para que "Pendiente de verificación" reaccione en vivo.
- **Resiliencia**: cada topic debe tener un endpoint REST de respaldo de solo lectura (ej. `GET /trips/requests/{id}/offers`, `GET /trips/{id}/location`) para cuando el cliente degrada a polling.
- Confirmar límites de rate limiting sobre frecuencia de publicación de ubicación desde el cliente.

## 4. Endpoints REST requeridos

### 4.1 Núcleo de viaje
- **Verificación de conductor**: `GET /drivers/me/estado-verificacion` → `{ estadoVerificacion, cooperativaNombre, vehiculo: {...} }`.
- **Estimación de viaje**: `POST /trips/estimate` (origen, destino) → `{ distanciaKm, duracionEstimadaMin, precioSugerido, moneda }`. Rechazar con error claro si `distanciaKm > 150` **o si el país del destino es distinto al país del origen** (viajes transfronterizos no permitidos, confirmado — validar con reverse geocoding de ambos puntos).
- **Publicar solicitud**: `POST /trips/requests` — valida `precioPublicado` numérico ≥ precio mínimo vigente (sección 4.4), si es republicación valida `precioPublicado >= precio de la solicitud original`, y rechaza con 409 si el pasajero ya tiene una solicitud activa.
- **Listar/recibir ofertas**: vía STOMP + `GET /trips/requests/{id}/offers` de respaldo — **la respuesta nunca incluye datos identificables del conductor** (nombre, foto, vehículo, ETA, distancia), solo `{ ofertaId, precioOfertado, ordenPrioridad }` por oferta (identidad oculta hasta la asignación, confirmado).
- **Enviar oferta** (conductor): `POST /trips/requests/{id}/offers` — valida que `precioOfertado` esté entre el 90% y el 130% de `precioSugerido`.
- **Retirar oferta** (conductor): `DELETE /trips/requests/{id}/offers/{offerId}`.
- **Aceptar oferta** (pasajero): `POST /trips/requests/{id}/offers/{offerId}/accept` → 409 si otra oferta ya fue aceptada primero. La respuesta de asignación (o el evento STOMP de cambio a `ASIGNADO`) es el primer punto donde se revelan `conductorNombreParcial` (primer nombre + apellido paterno), foto, vehículo, ETA y distancia — nunca antes.
- **Ciclo de viaje**: `POST /trips/{id}/arrived`, `POST /trips/{id}/verify-otp`, `POST /trips/{id}/start`, `POST /trips/{id}/complete`, `POST /trips/{id}/cancel` (con `motivo`).
- **Reporte de desviación de ruta / check-in de seguridad** (confirmado, prioridad: proteger a un pasajero que sufra un robo/secuestro): `POST /trips/{id}/route-deviation` (lat, lng, distanciaDesviacionM, timestamp). Umbral: **desviación >500m sostenida por más de 90 segundos**, o **parada no planificada >3 minutos** fuera de origen/destino (valores basados en el estándar de la industria, ej. Uber RideCheck — ajustables si el backend detecta demasiados falsos positivos). Al superar el umbral: (1) se crea automáticamente una `sos_alerta` con `origen = DESVIACION_AUTOMATICA` visible de inmediato para el administrador, **sin esperar confirmación del pasajero** (para no depender de que pueda actuar si está siendo coaccionado); (2) en paralelo, el cliente del pasajero muestra un check-in discreto ("¿Todo bien con tu viaje?" con opción de confirmar o pedir ayuda) — deliberadamente no alarmante, para no poner en riesgo al pasajero si alguien más controla el dispositivo. Si el pasajero no responde en un plazo corto (ej. 60s) o pide ayuda, se mantiene/escala la alerta ya creada.
- **Viajes recurrentes** (nuevo): `GET /trips/frequent` → lista de pares origen-destino solicitados más de 2 veces por el pasajero autenticado, con datos suficientes para re-publicar en un toque.
- **Chat**: `GET /trips/{id}/messages` (historial, paginado — ver 4.3) + envío vía STOMP.
- **Calificación**: `POST /trips/{id}/ratings`; confirmar job programado que aplica 5 estrellas automáticas a los 15 minutos si no se calificó (`fue_automatica = true`).
- **SOS**: `POST /trips/{id}/sos` → notifica a contacto de emergencia + administrador, y persiste el registro con fecha/hora para el dashboard admin (confirmado como requisito explícito).
- **Contactos de emergencia**: `GET/POST/DELETE /users/me/emergency-contacts` — el backend debe rechazar acciones que dejen a un usuario sin ningún contacto de emergencia (es obligatorio tener al menos uno).
- **Ganancias**: `GET /drivers/me/earnings?desde=&hasta=` → `{ montoBruto, montoNeto }` (sin endpoint de exportación, solo visualización).
- **Registro de token FCM**: `POST /users/me/fcm-token` (ver sección 5).

### 4.2 Llamada telefónica enmascarada (nuevo, requisito de seguridad no negociable)
La llamada entre pasajero y conductor **nunca** debe exponer el número real de ninguna parte. Se solicita integrar un servicio de enmascaramiento de llamadas (ej. Twilio Programmable Voice u equivalente) que provisione un **número proxy por viaje** al momento de la asignación. Contrato sugerido: el número proxy viaja como parte de la respuesta de asignación del viaje (`numeroProxyConductor` visible para el pasajero, `numeroProxyPasajero` visible para el conductor), sin necesidad de un endpoint adicional en el momento de la llamada. El proxy debe expirar/desactivarse al finalizar o cancelar el viaje.

### 4.3 Paginación (decisión: cursor-based)
Para `GET /trips/history` y `GET /trips/{id}/messages`, se solicita paginación por **cursor opaco** (no offset/limit): más robusta ante inserciones concurrentes que un esquema offset/limit, que puede duplicar o saltar elementos cuando hay nuevos registros durante el scroll. Contrato:
```json
{ "items": [ /* ... */ ], "nextCursor": "eyJjcmVhdGVkQXQiOiIuLi4iLCJpZCI6Ii4uLiJ9" }
```
`nextCursor` es `null` cuando no hay más páginas. Tamaño de página por defecto 20, máximo 50 (parámetro `limit`). Orden `created_at DESC`.

### 4.4 Configuración pública (nuevo)
`GET /config/public` → valores de negocio que el cliente no debe hardcodear porque el administrador los cambia desde el dashboard:
```json
{ "precioMinimoTrayecto": 0.50, "moneda": "USD", "distanciaMaximaKm": 150, "radioBusquedaKm": 10, "rangoContraofertaMinPct": 0.90, "rangoContraofertaMaxPct": 1.30 }
```
El cliente lo consulta al arrancar y cachea con expiración corta (ej. 1 hora) — evita repetir un round-trip en cada pantalla que use estos valores.

### 4.5 Búsqueda de direcciones (decisión tomada por el cliente, solicitada a backend)
Dado que se delegó la elección del proveedor: se recomienda **LocationIQ** (Autocomplete + Search API) como mejor relación costo-beneficio para operar en Ecuador/Colombia/Perú (cobertura Latinoamérica adecuada, tier gratuito amplio, API simple, evita autohospedar Photon/Elasticsearch). Alternativa aceptable: HERE Geocoding & Search. **La clave de API no debe vivir en el cliente móvil** — se solicita que el backend actúe como proxy:
- `GET /geo/autocomplete?q={texto}&lat={lat}&lng={lng}` → `[{ "label": "Av. Amazonas 123, Quito", "lat": ..., "lng": ... }, ...]`.
- `GET /geo/reverse?lat={lat}&lng={lng}` → `{ "label": "..." }` (complementa a `geocoding` nativo cuando se necesite consistencia con el mismo proveedor de autocompletado).
Esta abstracción (normalizar la respuesta del proveedor externo antes de devolverla al cliente) protege al frontend de un futuro cambio de proveedor sin tocar código de la app.

### 4.6 Motor de ruteo
`flutter_polyline_points` decodifica una geometría de ruta, pero alguien debe calcularla. Se solicita confirmar si el backend ya tiene un motor de ruteo (ej. OSRM autohospedado, GraphHopper) integrado, o si debe implementarse — prerequisito de "Estimación de viaje" y del tracking con ruta dibujada.

## 5. Auditoría de la integración FCM existente
- Endpoint para registrar/actualizar el token FCM del dispositivo tras login (¿ya existe? ¿cuál es?).
- Eventos que disparan push: nueva solicitud cercana, nueva oferta recibida, oferta retirada/rechazada, conductor llegó, viaje cancelado por la otra parte, conductor aprobado, nuevo mensaje de chat.
- Formato del payload: usar siempre `data` (no `notification`) para manejo consistente foreground/background con `flutter_local_notifications`.
- **Chat (confirmado)**: payload genérico ("Nuevo mensaje de {nombre}"), sin el texto del mensaje, con `viaje_id` en `data` para abrir el chat correcto.
- **Badge de no leídos (nuevo, confirmado como requisito)**: el payload de notificaciones de chat debe incluir el conteo de mensajes no leídos (`badgeCount`) para que el cliente lo refleje en el ícono de la app.
- Certificados/configuración APNs vigentes para iOS — validar antes de release si no se ha probado.
- Canales de notificación en Android con prioridad alta para "nueva oferta"/"conductor llegó".

## 6. Reglas de negocio a garantizar en backend (no delegables al cliente)
- Cálculo de `precioSugerido`, distancia, duración y moneda — siempre en backend, moneda determinada por el país detectado en el origen (reverse geocoding), nunca elegida por el usuario.
- Invariante de negociación: al aceptar una oferta, todas las demás de la misma solicitud pasan a `RECHAZADA` de forma atómica, con notificación a cada conductor afectado.
- Validación de republicación (`precioPublicado >= precio original`) y de distancia máxima (150 km).
- Expiración automática de solicitudes a los 5 minutos exactos sin ofertas.
- Orden de ofertas: precio + cercanía/ETA + bono por calificación — pesos exactos a definir por backend/producto.
- Snapshot de `comisionPorcentajeAplicada`/`montoNetoConductor` al completar el viaje.
- Job programado de calificación automática a los 15 minutos.
- Actualización de calificación: reducir la del pasajero en cancelaciones/solicitudes falsas, la del conductor según calificación recibida — sin penalidad monetaria; usuarios con calificación baja pierden prioridad en el matching/orden.
- Exclusividad: un conductor pertenece a una sola cooperativa y tiene un solo vehículo asignado de forma fija; solo el administrador (fuera de esta app) puede modificar esa asignación.
- Autorización estricta por `viaje_id` en los topics STOMP de ubicación y chat.
- Una sola solicitud activa por pasajero; retiro automático de ofertas al asignar a otra solicitud, con notificación.
- Sesión única con confirmación (sección 2.2); bloqueo total de nuevo login si hay viaje en curso.
- Radio de búsqueda fijo en 10 km; contraoferta limitada al 90%-130% del precio sugerido; precio mínimo configurable (default $0.50) expuesto vía `GET /config/public`.
- Sin doble rol y sin conversión de rol: un email = un usuario = un rol fijo para siempre.
- Validación de formato de placa según el país detectado por la ubicación del conductor al momento del registro (regex confirmado, ver sección 2.1).
- Desconexión automática de un conductor a `DESCONECTADO` tras 3 minutos sin señal/conexión.
- Nunca dejar un evento relevante sin notificación al usuario afectado (oferta retirada, rechazada, viaje cancelado, aprobación de cuenta, etc.).

## 7. Consideraciones de seguridad para backend
- Rate limiting en endpoints de negociación para prevenir spam.
- Autorización estricta por `viaje_id` en cada `SUBSCRIBE` STOMP, no solo en el `CONNECT`.
- Los datos de verificación documental (fuera de esta app) deben servirse con URLs firmadas de corta duración si se almacenan en un bucket tipo S3/GCS.
- Confirmar expiración/rotación del refresh token y comportamiento esperado si ambos tokens expiran a mitad de un viaje activo (no debe perderse el estado del viaje).
- El servicio de enmascaramiento telefónico (sección 4.2) debe garantizar que el número proxy no pueda usarse para inferir el número real de ninguna parte, y que expire al finalizar el viaje.
- Los eventos de desviación de ruta (sección 4.1) deben registrar solo lo necesario para auditoría (coordenadas + timestamp), sin convertirse en un canal de tracking adicional no cubierto por `viaje_tracking`.

## 8. Resumen de lo que el frontend necesita confirmado antes de empezar cada fase
| Fase (ver [`task.md`](task.md)) | Depende de que backend confirme |
|---|---|
| Seguridad base (tokens) | Tiempos de expiración de access/refresh token, contrato de sesión única (2.2) |
| Geolocalización / selección de destino | Proveedor de autocompletado (4.5), motor de ruteo (4.6) |
| Tiempo real | Disponibilidad de STOMP, topics exactos, mecanismo de auth del socket |
| Verificación (solo lectura) | Endpoint `GET /drivers/me/estado-verificacion` |
| Negociación | Endpoints de 4.1, `GET /config/public` (4.4), formato de error (sección 1) |
| Ejecución del viaje | Enmascaramiento telefónico (4.2), endpoint de desviación de ruta |
| Chat | Topic STOMP de chat + endpoint de historial paginado (4.3) |
| Notificaciones | Resultado de la auditoría FCM (sección 5) |
| Ganancias | Endpoint de ganancias con desglose bruto/neto |

## 9. Puntos abiertos que siguen sin resolver

> Actualizado 2026-08-22 (cuarta ronda): **todas** las preguntas legales, de producto y de seguridad que estaban aquí fueron resueltas y se movieron a las secciones 2-6 como reglas confirmadas (edad mínima 18 años sin excepción, sin viajes transfronterizos, umbral y escalación de desviación de ruta, regex de placa por país, T&C con versión placeholder). Solo queda un detalle menor de formato, de bajo riesgo:

### Redondeo de moneda
Confirmar si el redondeo de `precioSugerido`/`precioPublicado` es a centavos exactos o a un múltiplo (ej. $0.25/$0.50), y si esta regla es igual para USD/COP/PEN en v2. No bloquea el desarrollo de v1 (USD ya confirmado con 2 decimales exactos); solo relevante para el diseño fino de v2.
