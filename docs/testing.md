# Testing

> Este documento cubre pruebas automatizadas (lógica, blocs, widgets). Para certificar que una pantalla/flujo no tiene fallos de diseño, UX o seguridad más allá de lo que un test automatizado puede verificar, usar en conjunto [`qa_checklist.md`](qa_checklist.md) — ninguna tarea de [`task.md`](task.md) se marca `completo` sin pasar ambos.

## Entorno de pruebas (confirmado)
No existe (ni se planea para v1) un ambiente de staging ni un pipeline de CI/CD que corra tests automáticamente. **Es responsabilidad del propio agente** ejecutar `flutter analyze` y `flutter test` en cada tarea antes de marcarla `completo` (ver [`rules.md`](rules.md) regla 8). Cuando backend y frontend estén ambos listos, la verificación de integración real ocurre **en local**, de forma manual, por una persona — no hay otro entorno compartido en v1. Esto no reduce la exigencia de tests automatizados con mocks (siguen siendo obligatorios por tarea); solo aclara que no hay una segunda red de seguridad automatizada más allá de lo que cada agente ejecuta.

## Cambio de rol: de implementador a QA (confirmado, ver [`role.md`](role.md) rol 12)
Al terminar de implementar una tarea, el mismo agente debe **adoptar explícitamente el rol de QA** y probar la funcionalidad buscando activamente fallas — no autocertificarse solo porque el código compila o porque "así lo escribió". Esto incluye: ejecutar los casos críticos de esta lista relevantes a la tarea, intentar romper la funcionalidad con inputs inválidos/inesperados, y revisar [`qa_checklist.md`](qa_checklist.md) con la misma escrutinio que aplicaría a código ajeno.

## Matriz de dispositivos/OS soportados (confirmado)
Android 7.0 (API 24) e iOS 16 como mínimos. Cualquier feature que dependa de una API nativa más reciente (ej. ciertos comportamientos de `flutter_local_notifications`, `geolocator`, `flutter_secure_storage`) debe verificarse compatible con estas versiones mínimas, no solo con el emulador/simulador más reciente por defecto.

## Estado heredado
Único test existente: `test/widget_test.dart`, el smoke test por defecto de `flutter create` (probablemente roto, busca un contador que no existe). Sin `bloc_test`/`mocktail` configurados. Punto de partida real: cero cobertura.

## Estrategia para el desarrollo v1
Cada tarea de [`task.md`](task.md) cierra con sus propias pruebas — no se acumulan para "una fase de testing al final" (ver [`rules.md`](rules.md) RNF11 en [`functionality.md`](functionality.md)).

### Niveles de prueba por tipo de tarea
- **Lógica pura de dominio** (validaciones, máquina de estados de `viaje`, validación de precio, regla de republicación ≥ precio anterior): unit tests sin Flutter, sin mocks — son funciones puras en `domain`.
- **Blocs/Cubits nuevos** (`NegotiationBloc`, `ChatBloc`, `RatingBloc`, `SosBloc`, ampliaciones de `DriverTripBloc`/`ClientTripBloc`): `bloc_test`, mockeando repositorios y `RealtimeClient` con `mocktail`.
- **Widgets críticos**: widget tests para `AppOtpInput` (validación de formato), `AppPriceInput` (rechaza valores cercanos a cero), modales de confirmación (SOS, cancelar viaje) — verificar que no se ejecuta la acción sin confirmar.
- **Integración ligera**: tests de bloc que simulan una secuencia completa (publicar solicitud → recibir oferta simulada por stream → aceptar → verificar transición de estado), sin necesidad de un backend real (mock del stream de `RealtimeClient`).

## Casos críticos a cubrir explícitamente (por ser fuente probable de bugs sutiles)
1. **Condición de carrera en aceptación de oferta**: el bloc del pasajero debe manejar con gracia una respuesta 409 del backend (otra oferta ya fue aceptada) sin crashear ni dejar la UI en estado inconsistente.
2. **Retiro de oferta después de que el pasajero ya la está viendo**: la oferta debe desaparecer de la lista del pasajero en tiempo real sin error si intenta aceptarla justo después de retirada.
3. **Republicación con precio menor al anterior**: debe bloquearse en el cliente antes de llamar al backend, y manejar correctamente si igual el backend la rechaza.
4. **Expiración de solicitud a los 5 minutos exactos**: el bloc debe transicionar a "expirada" sin depender de que el usuario tenga la app en foreground en ese instante exacto (reconciliar estado al volver a foreground).
5. **OTP incorrecto**: permitir reintento sin romper el flujo; no avanzar a `EN_CURSO` si el backend rechaza el código.
6. **Calificación no enviada dentro de 15 minutos**: si el usuario reabre la pantalla de calificación después del timeout, debe reflejar que ya se aplicó automáticamente (consultando al backend), no seguir mostrando el modal como si aún se pudiera calificar manualmente.
7. **Cancelación en cada estado válido** (`ASIGNADO`, `CONDUCTOR_EN_CAMINO`, `CONDUCTOR_LLEGO`) y **rechazo de cancelación en `EN_CURSO`** (no debe ser posible desde la UI, y si el backend la rechaza igual, mostrar el error correctamente).
8. **Reconexión de `RealtimeClient`**: simular caída de conexión y verificar que el fallback a polling se activa y que al reconectar no se duplican eventos ya procesados.
9. **Migración de tokens**: verificar que tras la migración a `flutter_secure_storage` no queda ningún token residual en SQLite/SharedPreferences de instalaciones previas (test de migración, no solo de la escritura nueva).
10. **Guard de verificación de conductor**: un conductor con `estado_verificacion = PENDIENTE` o `RECHAZADO` nunca debe poder llegar a una pantalla operativa (home conductor, solicitudes) ni siquiera navegando manualmente por deep link.
11. **Chat de solo lectura tras finalizar/cancelar**: verificar que el input de envío se deshabilita inmediatamente al cambiar el estado del viaje, no solo al recargar la pantalla.
12. **Cálculo de monto neto mostrado**: el cliente debe mostrar exactamente `montoBruto` y `montoNeto` tal como los devuelve el backend, sin recalcular la comisión localmente (test de que no existe lógica de cálculo de comisión en el cliente).
13. **Sesión única — flujo completo**: login con sesión activa sin viaje en curso muestra modal de confirmación y solo invalida la anterior tras confirmar; login con viaje `ASIGNADO`/`EN_CURSO` en la cuenta se bloquea por completo, sin ofrecer confirmación, mostrando el mensaje en el dispositivo que intenta entrar.
14. **Llamada telefónica enmascarada**: el botón de llamada siempre marca el número proxy recibido del backend; test de que ningún número de teléfono real (del `usuario` o cacheado localmente) se usa para iniciar la llamada.
15. **Desviación de ruta / check-in de seguridad**: simular una posición fuera de la polyline por más de 90s debe (a) reportar el evento a backend y (b) mostrar el check-in discreto al pasajero, **como dos acciones en paralelo**, sin que una espere el resultado de la otra ni sin que el check-in sea condición para el reporte.
16. **Validación de placa por país**: el mismo valor de placa debe aceptarse o rechazarse según el país detectado — probar los tres regex (Ecuador, Perú, Colombia) con valores válidos e inválidos de cada uno.
17. **Gates de registro independientes**: el registro debe bloquearse si falta cualquiera de: OTP verificado, checkbox de T&C, edad ≥18 (fecha de nacimiento), contacto de emergencia — probar cada bloqueo de forma aislada, no solo la combinación feliz.
18. **Viajes recurrentes**: el mismo par origen-destino debe marcarse como "recurrente" exactamente al tercer intento (más de 2 veces), no en el segundo ni antes.
19. **Config pública no disponible**: si `GET /config/public` falla al arrancar, el cliente no debe usar un valor inventado (ej. precio mínimo en 0) ni crashear — debe usar el último valor cacheado o bloquear la acción dependiente con un mensaje claro.
20. **Rechazo de viaje transfronterizo**: si backend rechaza una solicitud por cruce de país, el cliente debe mostrar un mensaje específico ("tu destino está fuera del país de origen"), no un error genérico de red.
21. **Badge de chat**: se incrementa en tiempo real al llegar un mensaje nuevo y se limpia al abrir/leer el chat correspondiente — no debe quedar un badge fantasma tras leer los mensajes.
22. **Rango de contraoferta (90%-130%)**: rechazar en cliente valores fuera de rango antes de enviar, y manejar correctamente el error si el backend igual lo rechaza (ej. si `precioSugerido` cambió entre que se cargó la pantalla y se envió la oferta).

## Pendiente de definir junto con cada tarea
Los criterios de aceptación detallados (qué inputs/outputs exactos testear) se afinan al tomar cada tarea de [`task.md`](task.md), una vez que el contrato exacto de backend esté confirmado (ver [`requerimientos_backend.md`](requerimientos_backend.md)) — no se escriben tests contra un contrato de API todavía no confirmado (ver [`rules.md`](rules.md) regla 4).
