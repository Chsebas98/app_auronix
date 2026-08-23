# Requisitos funcionales y no funcionales

Requisitos del producto objetivo v1, ya acotados tras resolver las decisiones de negocio (ver historial en [`questions.md`](questions.md)). El estado de implementación heredado (qué sigue mockeado en la base de código actual) se gestiona ahora como backlog en [`task.md`](task.md).

## Requisitos funcionales (RF) — v1

### Cuentas y verificación
- RF1. Un pasajero puede autorregistrarse con email/teléfono/password, verificando su cuenta con un código OTP enviado por email (expira en 10 min, reenviable), y usar la app tras verificar.
- RF1.1. Edad mínima validada por fecha de nacimiento: **18 años para todo usuario** (pasajero y conductor). Sin excepción para menores de edad — no requiere flujo de consentimiento parental.
- RF1.2. Registro (ambos roles) requiere aceptación explícita de Términos y Condiciones / Política de Privacidad mediante checkbox.
- RF1.3. Un usuario puede eliminar su cuenta desde la app (disponible desde v1).
- RF1.4. Un usuario puede cambiar su email/teléfono; el valor anterior permanece vigente hasta que el nuevo sea re-verificado.
- RF1.5. Un usuario no puede convertir su cuenta de un rol a otro (pasajero↔conductor); cada rol requiere una cuenta independiente.
- RF1.6. Un usuario debe registrar al menos un contacto de emergencia antes de poder publicar una solicitud o ponerse disponible como conductor.
- RF2. Un conductor puede autorregistrarse con datos personales, licencia y datos básicos de vehículo (placa validada según el formato del país detectado por ubicación), **sin subir documentos en la app**; queda `PENDIENTE` hasta que el administrador (fuera de esta app) le asigne cooperativa, complete la verificación externa (SLA comunicado ~24h, con opción de reenviar el correo de verificación) y lo apruebe. El progreso del formulario se conserva como borrador si se abandona.
- RF3. La app de conductor debe reflejar el estado de verificación (`PENDIENTE`/`APROBADO`/`RECHAZADO`) y bloquear toda función operativa hasta `APROBADO`.
- RF3.1. Un usuario solo puede tener una sesión activa; un login nuevo pide confirmación (si no hay viaje en curso) o se bloquea por completo (si lo hay) — ver [`flow.md`](flow.md) sección 12.

### Solicitud y negociación de viaje
- RF4. Un pasajero puede definir origen/destino (buscando texto o arrastrando un pin) y ver un precio sugerido (calculado por backend, en la moneda determinada por el país del origen) antes de publicar. La distancia no puede superar **150 km**.
- RF5. Un pasajero puede editar el precio sugerido antes de publicar, con validación de valor numérico, decimal permitido, mínimo **$0.50** (configurable por admin, obtenido de un endpoint de configuración pública).
- RF6. Una solicitud publicada es visible 5 minutos para conductores disponibles dentro de **10 km** del punto de origen; si expira sin ofertas, puede republicarse solo con el mismo precio o uno mayor.
- RF6.1. Un pasajero solo puede tener **una** solicitud activa (`PUBLICADA`/`NEGOCIANDO`/`ASIGNADA`) a la vez; debe finalizar, cancelar o dejar expirar la actual antes de publicar otra.
- RF7. Un conductor disponible puede ver solicitudes cercanas en tiempo real y aceptar el precio sugerido o contraofertar dentro de un rango del **90% al 130%** del precio sugerido; puede tener ofertas pendientes en varias solicitudes a la vez.
- RF7.1. Al ser asignado a una solicitud, las demás ofertas pendientes de ese conductor en otras solicitudes se retiran automáticamente, con notificación explícita al conductor.
- RF8. Un conductor puede retirar su oferta antes de que sea aceptada (no editarla).
- RF9. Un pasajero ve las ofertas recibidas ya ordenadas por el backend (precio + cercanía/ETA + bono por calificación del conductor), mostrando solo el precio de cada oferta (identidad del conductor oculta hasta la asignación) y acepta una.
- RF10. Al aceptar una oferta, el resto de ofertas de esa solicitud se invalidan automáticamente.

### Ejecución del viaje
- RF11. El pasajero ve en tiempo real la ubicación y ETA del conductor asignado.
- RF12. El conductor marca "Llegué"; el pasajero muestra un código OTP que el conductor valida para iniciar el viaje.
- RF13. Durante el viaje en curso, ambos ven ruta y ubicación en vivo, y tienen acceso a un **chat de texto en vivo** (requisito v1 confirmado).
- RF13.1. El precio acordado permanece visible de forma persistente durante todo el viaje asignado/en curso.
- RF13.2. El sistema detecta y avisa al pasajero si el conductor se desvía significativamente de la ruta esperada, registrando el evento para auditoría.
- RF14. El conductor marca "Finalizar viaje" al llegar al destino, cerrando el ciclo con precio, distancia y duración.
- RF15. Cualquiera de las dos partes puede cancelar antes de `EN_CURSO`; no existe ventana de gracia ni penalidad monetaria, pero la cancelación impacta la calificación de quien cancela.
- RF16. Al finalizar, ambas partes pueden calificarse mutuamente (1-5 + comentario) dentro de los 15 minutos siguientes; pasado ese plazo, el sistema aplica automáticamente 5 estrellas si no se calificó.

### Seguridad del usuario
- RF17. Cualquiera de las dos partes puede activar una alerta SOS (con confirmación previa) durante un viaje asignado o en curso; se notifica al contacto de emergencia del usuario y al administrador.
- RF18. Un pasajero puede registrar contactos de emergencia.
- RF19. El sistema conserva un historial auditable del viaje (tracking + cambios de estado).

### Otros
- RF20. Un conductor puede consultar sus ganancias (bruto y neto tras comisión) por rango de fechas, con datos reales, solo visualización in-app (sin exportación en v1).
- RF21. Pasajero y conductor pueden consultar su historial de viajes.
- RF21.1. El chat de viaje muestra un contador/badge de mensajes no leídos, incluido en el ícono de la app.
- RF22. Pasajero y conductor pueden llamarse telefónicamente durante un viaje activo, siempre a través de un **número intermediario/enmascarado** (nunca el número real de ninguna parte) — regla de seguridad no negociable.
- RF22.1. Un pasajero con el mismo origen-destino solicitado más de 2 veces ve la opción de "viaje recurrente" con re-solicitud en un toque.
- RF23. **La app se publica en v1 únicamente en español** (revertido — no hay proveedor de traducción disponible; se descarta el requisito previo de multi-idioma para este lanzamiento). Los strings siguen externalizados vía `l10n` para no requerir un refactor cuando se agreguen idiomas en el futuro, pero no se traduce a ningún otro idioma en v1.
- RF24. Un usuario solo puede tener **una sesión activa**: iniciar sesión en un dispositivo nuevo invalida la sesión anterior tras confirmación explícita, salvo que exista un viaje `ASIGNADO`/`EN_CURSO` en la cuenta, en cuyo caso el nuevo login se bloquea por completo hasta que el viaje termine (confirmado, ver [`flow.md`](flow.md) sección 12; duplica RF3.1, mantenido aquí por completitud de la sección).
- RF25. Al abrir la app con un viaje `ASIGNADO`/`EN_CURSO` pendiente, el usuario es llevado directo a la pantalla de viaje activo, sin pasar por Home.
- RF26. La app está preparada para múltiples monedas desde el modelo de datos (campo `moneda` en toda entidad de precio), aunque en v1 solo se opera en USD.

## Fuera de alcance de v1 (explícito)
- Panel de administrador (dashboard web separado, fuera de este repo).
- Carga de documentos de verificación dentro de esta app.
- Pagos con tarjeta/billetera (previsto v2).
- Flujo de reporte de incidencias post-viaje más allá de la calificación con comentario (previsto v2).
- Rol "gerente de cooperativa" (descartado).

## Requisitos no funcionales (RNF)

### Rendimiento y tiempo real
- RNF1. Una nueva solicitud debe llegar a conductores cercanos en menos de 3-5 segundos desde su publicación (WebSocket/STOMP, no polling lento).
- RNF2. La ubicación del conductor en un viaje activo debe actualizarse al menos cada 3-5 segundos en el mapa del pasajero.
- RNF3. Fuera de un viaje activo, la frecuencia de ubicación del conductor disponible debe reducirse (ej. cada 10-30s o por distancia mínima) para preservar batería.

### Seguridad
- RNF4. Ningún token de sesión se almacena en texto plano (ver [`security.md`](security.md)).
- RNF5. Toda comunicación con el backend va sobre HTTPS/WSS.
- RNF6. El acceso a acciones sensibles (aceptar/cancelar viaje, SOS) se valida también en backend, nunca solo en el cliente.

### Disponibilidad y resiliencia
- RNF7. Si la conexión de tiempo real se cae, la app degrada a un mecanismo de respaldo sin dejar al usuario sin información crítica.
- RNF8. La app maneja sin fallar la pérdida de señal GPS o de red durante un viaje activo, mostrando un estado de "reconectando" **sin borrar** la última ruta/posición/mensajes ya conocidos — el mapa nunca queda en blanco durante una reconexión.
- RNF8.1. El conductor no puede ponerse `DISPONIBLE` sin GPS habilitado (bloqueo explícito con enlace a ajustes, no fallo silencioso).

### Usabilidad
- RNF9. Acciones sensibles (cancelar viaje, activar SOS) requieren confirmación explícita, con mensaje claro del impacto (ej. "cancelar puede afectar tu calificación").
- RNF10. Los textos de la UI están externalizados vía `l10n` desde el inicio de cada pantalla nueva, no hardcodeados, para soportar el requisito real de multi-idioma (RF23).

### Mantenibilidad
- RNF11. Todo nuevo modelo de datos (solicitud, oferta, viaje, calificación, etc.) tiene pruebas unitarias de su lógica pura antes de considerarse completo (ver [`testing.md`](testing.md)).
- RNF12. Ninguna pantalla nueva se entrega con datos mock de forma silenciosa — debe quedar marcada explícitamente en código y registrada como pendiente (ver [`rules.md`](rules.md)).

### Escalabilidad
- RNF13. Las listas de ofertas y solicitudes cercanas se paginan/limitan razonablemente para no degradar el rendimiento del mapa con muchos marcadores.
