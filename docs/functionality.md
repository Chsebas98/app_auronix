# Functionalities

Un pasajero no puede tener más de un viaje activo a la vez (estados no terminales: SOLICITADO, OFERTADO, ACEPTADO, EN_CURSO) — la UI debe manejar el error correspondiente si se reintenta solicitar un viaje ya activo.
Las solicitudes de creación/oferta de viaje son idempotentes vía un header de idempotencia — reintentos de red no deben crear viajes duplicados.
Un conductor solo ve y puede operar sobre viajes de su propia cooperativa.
El ciclo de vida del viaje es estrictamente secuencial (no se puede saltar estados), y cada cambio de estado se refleja en tiempo real a ambos participantes vía WebSocket.
Pagos y calificaciones solo se habilitan una vez el viaje está completado.
