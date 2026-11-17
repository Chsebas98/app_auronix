# Initial Plan (internal analysis)

Se completó la preparación inicial del proyecto Ando-UI (Flutter mobile app). El objetivo es refactorizar, alinear y finalizar la aplicación móvil cliente y conductor contra el backend Spring Boot 3 existente (micro-auronix) que provee servicios REST y WebSockets. Se organizó la arquitectura en Clean Architecture (Feature-First) con Atomic Design para la capa de presentación. Se definieron 9 módulos en product_map cubriendo el 100% de la funcionalidad solicitada (autenticación JWT + Firebase Auth, navegación/places, ciclo de vida del viaje con idempotencia y WebSockets, flujo de conductor por cooperativa, historial, perfil, seguridad y empaquetado multi-ambiente).

## Changes

- Definición de la arquitectura base Flutter Clean Architecture (Feature-First) combinada con Atomic Design.
- Alineación estricta de DTOs y eventos WebSocket de Ando-UI con el backend micro-auronix.
- Incorporación explícita de cabeceras de idempotencia (Idempotency-Key) en las llamadas REST de creación/oferta de viaje.
- Establecimiento del plan de testing con naming de test acoplado a códigos de criterio de aceptación (T<x>-C<y>).

## Mapa del producto

Mnemosine planifica todas las tareas de cada módulo después de este análisis (analysis/product_plan.md).

- **M1** Esqueleto del proyecto y cimientos de arquitectura (foundation)
  - Establecer la estructura base del repositorio Flutter en Clean Architecture Feature-First con Atomic Design, inyección de dependencias, configuración por ambiente (local, dev, prod) y runner de pruebas verificado en CI con endpoint de salud/verificación.
  - Requisitos de producción: PRD-QA-01, PRD-DEP-01, PRD-DOC-01
- **M2** Cimientos de Red, Seguridad y Persistencia Local (foundation)
  - Configurar cliente HTTP (Dio/http), gestión centralizada de tokens JWT, almacenamiento seguro de sesión local (Flutter Secure Storage/Sqflite), gestor de conexión WebSocket y manejo estructurado de errores y logs.
  - Requisitos de producción: PRD-SEC-01, PRD-OPS-01, PRD-DATA-04, MOB-03, WEB-SEC-02
- **M3** Módulo de Autenticación y Onboarding (feature)
  - Implementar flujo completo de inicio de sesión y registro para pasajeros y conductores usando Firebase Auth + JWT, SessionBloc para enrutamiento según rol de usuario y validación inteligente de formularios.
  - Requisitos de producción: PRD-SEC-03, WEB-SEC-02
- **M4** Módulo de Búsqueda y Selección de Ubicaciones (feature)
  - Integrar servicio de Places / Directions API para autocompletado de origen y destino, cálculo de rutas, estimación de tarifas y visualización previa en el mapa.
  - Requisitos de producción: WEB-UX-03
- **M5** Módulo de Gestión y Seguimiento de Viajes del Pasajero (feature)
  - Desarrollar la experiencia del pasajero para solicitar viaje con cabecera de idempotencia, visualizar la búsqueda de conductor, seguir el viaje en tiempo real por WebSocket, manejar restricciones de viaje activo único, confirmar finalización y calificar.
  - Requisitos de producción: PRD-QA-02, WEB-UX-03, MOB-04
- **M6** Módulo de Operaciones y Navegación del Conductor (feature)
  - Implementar el flujo del conductor para cambiar estado a disponible (vía GPS), recibir solicitudes cercanas restringidas a su cooperativa, aceptar/rechazar viajes, navegar al origen/destino, actualizar ciclo de vida secuencial y calificar al pasajero.
  - Requisitos de producción: PRD-QA-02, WEB-UX-03, MOB-04
- **M7** Módulo de Historial de Viajes y Perfil (feature)
  - Permitir la consulta detallada de viajes pasados para pasajeros y conductores con paginación estable, visualización de estado final, montos y calificaciones, junto con la edición básica de perfil.
  - Requisitos de producción: PRD-DATA-05
- **M8** Endurecimiento de Seguridad, Calidad y Limpieza (production)
  - Realizar auditoría de dependencias, eliminar código muerto/desuso fruto de refactorizaciones previas (ej. mapas/libs obsoletas), aplicar comprobación de accesibilidad WCAG y manejo resiliente sin conexión.
  - Requisitos de producción: PRD-QA-03, PRD-SEC-02, WEB-UX-02, MOB-04, MOB-05
- **M9** Preparación para Producción, Multi-Ambiente y Publicación (production)
  - Configurar compilación firmada Android App Bundle e iOS Archive, splash screens, iconos, variables de ambiente (local, dev, prod), guías de despliegue DEPLOY.md, política de privacidad y verificación en dispositivo real/emulador.
  - Requisitos de producción: PRD-DATA-01, PRD-DATA-03, PRD-DEP-03, MOB-01, MOB-02, MOB-06, MOB-07

## Tasks

- Se planifican por módulo.

## Tests

- No tests generated.

## Rationale

- Se organizó el mapa de producto comenzando estrictamente por los cimientos de la aplicación (esqueleto del proyecto, CI, DI, red y persistencia segura) antes de construir las pantallas funcionales.
- Cada uno de los 24 requisitos del perfil de producción (PRD-* y MOB-*) quedó explícitamente mapeado a al menos un módulo del mapa de producto.
- Se incorporó la regla de naming para tests automatizados vinculándolos a los códigos de criterios de aceptación de Mnemosine.

## Assumptions

- Se asume que la API REST y los sockets del backend Spring Boot 3 están completamente desplegados y accesibles en los ambientes de desarrollo y prueba.

## Memory changes

- Aplicado: rules.md — Actualización de reglas para incluir normas obligatorias de Mnemosine relativas a nombramiento de tests y limpieza de código muerto.
- Aplicado: architecture/hierarchy.md — Definición completa de la estructura de carpetas siguiendo Clean Architecture Feature-First y Atomic Design.
- Aplicado: contracts/schemas/database.json — Creación del esquema de base de datos de contexto existente en formato JSON estructurado.
- Aplicado: architecture/overview.md — Actualización del resumen arquitectónico reflejando la integración de Ando-UI con el backend micro-auronix.
