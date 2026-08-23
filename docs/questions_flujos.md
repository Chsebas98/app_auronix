# Preguntas — flujos y casos transversales

## Resueltas — 2026-08-22
Las 15 preguntas de este documento fueron respondidas y ya están incorporadas en [`flow.md`](flow.md), [`database.md`](database.md), [`architecture.md`](architecture.md), [`requerimientos_backend.md`](requerimientos_backend.md), [`functionality.md`](functionality.md) y [`security.md`](security.md). Resumen de las reglas de negocio confirmadas:

- **Una sola solicitud activa por pasajero**: no puede publicar una segunda hasta que la anterior finalice, se cancele o expire.
- **Ofertas del conductor**: puede tener ofertas `PENDIENTE` en varias solicitudes a la vez; al ser asignado a una, las demás se retiran **automáticamente** (backend).
- **Sin doble rol**: un email = un usuario = un único rol fijo (pasajero o conductor, nunca ambos en la misma cuenta).
- **Sesión única**: un usuario solo puede tener una sesión activa; iniciar sesión en un dispositivo nuevo invalida la anterior automáticamente. Mecanismo exacto a implementar por backend (ver [`requerimientos_backend.md`](requerimientos_backend.md)).
- **Restauración de viaje activo** al reabrir la app tras un cierre/crash: confirmado como comportamiento obligatorio.
- **GPS obligatorio** para que un conductor pueda ponerse disponible.
- **Reconexión en vivo**: debe mostrar "reconectando" sin perder el estado de la UI, **y seguir mostrando el recorrido/ruta ya conocidos** del vehículo mientras se restablece la conexión (no dejar el mapa en blanco).
- **Notificaciones de chat**: contenido pensado para balancear UX y privacidad (decisión tomada: aviso genérico con el nombre del remitente, sin el texto del mensaje — ver [`architecture.md`](architecture.md) sección 6).
- **Notificación push de aprobación de conductor**: confirmada como requisito.
- **Radio de búsqueda de conductores**: 10 km alrededor del punto de origen de la solicitud (ubicación actual o punto indicado por el pasajero) — valor fijo confirmado.
- **Operación 24/7** desde el lanzamiento.
- **Moneda**: USD en v1, con **peso colombiano (COP) y sol peruano (PEN) previstos para v2** — determinada automáticamente por el país de origen del viaje, nunca elegida por el usuario (confirmado en ronda posterior). La arquitectura debe ser multi-moneda desde ahora (campo `moneda` en las entidades de precio, nunca un símbolo "$" hardcodeado en la UI).
- **Distancia en kilómetros**, confirmado.
- **Fecha/hora**: ISO-8601 UTC desde backend, formateada a hora y formato local del dispositivo en el cliente (uso de `intl` con locale del dispositivo, no un formato fijo).

## Preguntas nuevas que surgieron de estas respuestas
Se agregaron a [`questions_pantallas.md`](questions_pantallas.md) por tocar pantallas/flujos específicos:
- Camino de conversión de rol (pasajero → conductor con la misma cuenta).
- Aviso o confirmación al invalidar una sesión activa desde un nuevo login.
- **Seguridad crítica**: qué pasa si se invalida la sesión de un conductor mientras tiene un viaje `EN_CURSO`.
- Notificación al conductor cuando su oferta se retira automáticamente por asignación a otro.
- Diseño multi-moneda: ¿la moneda depende del mercado/región, o del usuario?
- (Menor) si se debe visualizar el radio de 10 km en el mapa.

Ver [`questions_pantallas.md`](questions_pantallas.md) para el detalle completo de cada una.
