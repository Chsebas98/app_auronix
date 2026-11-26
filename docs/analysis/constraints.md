# Constraints

Record mandatory technical, business, security, compatibility and operational constraints.

## Proposed changes (internal analysis)

- Definición de la arquitectura base Flutter Clean Architecture (Feature-First) combinada con Atomic Design.
- Alineación estricta de DTOs y eventos WebSocket de Ando-UI con el backend micro-auronix.
- Incorporación explícita de cabeceras de idempotencia (Idempotency-Key) en las llamadas REST de creación/oferta de viaje.
- Establecimiento del plan de testing con naming de test acoplado a códigos de criterio de aceptación (T<x>-C<y>).

## Proposed changes (internal analysis)

- Incorporación de la especificación de WebSocket local sin SSL (ws://) y protocolo seguro wss:// parametrizable por ambiente en la arquitectura de red.
- Actualización de las pruebas de integración de sockets para contemplar el transporte no-SSL en desarrollo/local y SSL en producción.
- Cierre de dudas técnicas previas al desarrollo, dejando el proyecto completamente listo para la generación detallada de tareas por módulo.

## Proposed changes (internal analysis)

- Consolidación de la arquitectura Clean Architecture (Feature-First) con Atomic Design para presentación en Ando-UI.
- Definición del esquema y documentación de base de datos relacional existente (contracts/schemas/database.md y database.json) como SSOT de solo lectura.
- Configuración de transporte de WebSockets adaptativa por ambiente: ws:// directo sin SSL en ambiente local y wss:// cifrado en entornos de desarrollo y producción.
- Estructuración de product_map en 9 módulos jerárquicos desde los cimientos hasta la distribución productiva sin deuda técnica.

