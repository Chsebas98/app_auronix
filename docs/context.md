# Contexto y alcance

## Visión del producto
Auronix es una app de **taxis seguros** para solicitar viajes bajo demanda, con un modelo de negociación de tarifa inspirado en **inDrive** (el pasajero ve un precio sugerido y puede ajustarlo, los conductores lo aceptan o contraofertan) pero con una capa de confianza que inDrive no tiene: **solo conductores afiliados a una cooperativa de taxis convenida, asignados y activados por un administrador de plataforma, pueden operar.**

## Comparación con apps de referencia

| Aspecto | Uber / Didi | inDrive | **Auronix** |
|---|---|---|---|
| Precio | Algorítmico, sin negociación | Pasajero propone, conductor contraoferta | Backend sugiere un precio; pasajero puede editarlo (validado, sin ceros/negativos); conductores aceptan o contraofertan |
| Alta de conductores | Autoservicio, verificación automatizada | Autoservicio, verificación ligera | Conductor se autorregistra; **el administrador** le asigna cooperativa y activa la cuenta tras verificación por un flujo externo (correo + portal web, fuera de esta app) |
| Matching | Automático por cercanía | El pasajero elige entre ofertas | El pasajero elige entre ofertas, ordenadas por el backend combinando precio + cercanía/ETA + bono por calificación del conductor |
| Flota | Privada | Privada | Solo vehículos de taxi vinculados de forma fija y exclusiva a un conductor de una cooperativa |
| Pago | Tarjeta/billetera in-app | Variable por país | Solo efectivo en v1; comisión de plataforma configurable, descontada del monto que ve el conductor |
| Confianza | Calificación + verificación propia | Calificación, verificación variable | Calificación (todos arrancan en 5 estrellas) + verificación documental manual gestionada fuera de la app + insignia de conductor verificado |

## Actores del sistema
- **Pasajero (cliente)** — se autorregistra con datos de contacto. Publica solicitudes de viaje de inmediato tras verificar su cuenta. Rol `rolUser`. Empieza con calificación 5.0; cancelaciones o solicitudes falsas la reducen.
- **Conductor** — se autorregistra igual que un pasajero (no existe un rol "gerente de cooperativa" que lo registre por él). Queda en estado `PENDIENTE` hasta que **el administrador** le asigna una cooperativa y aprueba su verificación. La verificación de documentos (licencia, SOAT, biometría si aplica) ocurre **fuera de esta app**: el administrador envía al conductor un correo con un enlace a un portal web de verificación (parte del dashboard admin, fuera de este repositorio). Esta app móvil solo necesita mostrar el **estado** (`PENDIENTE`/`APROBADO`/`RECHAZADO`) y bloquear el acceso a funciones de conductor hasta `APROBADO`. Rol `rolDriver`.
- **Vehículo** — relación **fija y exclusiva** con un conductor; solo el administrador puede reasignar un vehículo a otro conductor (no es una acción disponible en esta app).
- **Cooperativa de taxis** — entidad convenida, gestionada íntegramente desde el dashboard admin. Para esta app es solo un dato de referencia (nombre) que se muestra en el perfil del conductor.
- **Administrador de plataforma** — **no usa esta app móvil**. Opera desde un dashboard web separado (fuera de este repositorio) donde asigna cooperativas, activa conductores/vehículos, configura el porcentaje de comisión, y recibe alertas SOS. Ver [`requerimientos_backend.md`](requerimientos_backend.md) para lo que ese dashboard necesita del backend.
- No existe rol "gerente de cooperativa" — descartado.

## Ciclo de vida de un viaje (resumen — detalle completo en [`flow.md`](flow.md))
1. Pasajero define origen/destino → ve un precio sugerido (calculado siempre por backend) → puede ajustarlo (validado: numérico, decimal permitido, no puede acercarse a cero) → publica la solicitud.
2. La solicitud queda visible 5 minutos para conductores disponibles cercanos. Si nadie oferta, expira; el pasajero puede republicarla solo con el mismo precio o uno mayor, nunca menor.
3. Conductores aceptan al precio sugerido o contraofertan; pueden retirar su oferta antes de que sea aceptada (no editarla). El pasajero ve las ofertas ya ordenadas por el backend (combinación de precio, cercanía/ETA y bono por calificación del conductor) y elige una.
4. Conductor viaja al punto de recogida (tracking en vivo) → confirma llegada → el pasajero le muestra un código OTP que el conductor valida → viaje en curso, con **chat de texto en vivo** habilitado desde la asignación hasta el fin del viaje → conductor finaliza al llegar al destino.
5. Pago en efectivo (v1). Se calcula el monto neto para el conductor tras aplicar la comisión de plataforma (porcentaje global, configurable por el admin, no visible como configuración en esta app — solo se muestra el resultado). Ambas partes pueden calificarse mutuamente en los 15 minutos siguientes; si no lo hacen, el backend aplica automáticamente 5 estrellas.

## Seguridad y confianza ("taxi seguro")
- Insignia de conductor verificado (foto, placa, cooperativa, calificación).
- Código OTP de recogida.
- Chat de texto en vivo (no solo llamada) durante el viaje.
- Botón SOS: notifica al **contacto de emergencia del usuario** y al **administrador** (vía el sistema del dashboard, fuera de esta app).
- Sistema de calificación como mecanismo de moderación: sin penalidad monetaria, pero un usuario o conductor con calificación baja pierde prioridad en el matching (el backend decide el orden; el cliente solo lo consume).
- Historial y auditoría de eventos del viaje.

## Fuera de alcance de la v1 (explícito, para no generar de más — ver [`rules.md`](rules.md))
- Panel de administrador (dashboard web separado).
- Carga de documentos de verificación dentro de la app móvil.
- Pagos con tarjeta/billetera (previsto para v2).
- Reporte de incidencias post-viaje más allá de la calificación con comentario (previsto para v2).

## Internacionalización — revertido a solo español (confirmado)
El requisito de multi-idioma por turismo se descartó para v1: no hay proveedor de traducción disponible actualmente. **V1 se lanza únicamente en español.** Se mantiene la externalización de strings vía `l10n` como buena práctica (para no requerir refactor cuando se agreguen idiomas en el futuro), pero no se traduce a ningún otro idioma en este lanzamiento.

## Alcance de publicación
**V1 se publica solo en Ecuador** (confirmado) — Colombia y Perú quedan como mercados de v2, aunque el modelo de datos (moneda, formato de placa) ya está preparado para ellos (ver [`database.md`](database.md)).

## Alcance de este repositorio
Este repositorio contiene **solo el frontend Flutter** para pasajeros y conductores. El backend es una API REST en **Spring Boot** con JWT emitido tras el login, más un canal de tiempo real y FCM ya existente (a auditar). El panel de administrador y el portal de verificación documental **no** viven aquí. El contrato exacto que el frontend necesita del backend se especifica en [`requerimientos_backend.md`](requerimientos_backend.md).
