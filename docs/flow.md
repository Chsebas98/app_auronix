# Requirements and Business Logic

Hay dos roles con flujos distintos pero que comparten el mismo ciclo de viaje:

Pasajero: inicia sesión (JWT, con soporte de Firebase Auth) → selecciona origen/destino (vía servicio de rutas/Directions) → solicita viaje → la app muestra "buscando conductor" mientras el backend asigna uno dentro de la cooperativa → una vez aceptado, sigue al conductor en tiempo real por WebSocket hasta que inicia el viaje → ve el viaje en curso (posición, estado) → al finalizar, confirma/califica al conductor → puede ver su historial de viajes guardados.
Conductor: inicia sesión → queda disponible para recibir solicitudes de viaje cercanas (según posición GPS) → puede aceptar o rechazar cada solicitud → al aceptar, navega hacia el pasajero, inicia el viaje, lo marca en curso y lo completa → al completar, califica al pasajero.
