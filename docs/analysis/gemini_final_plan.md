# Final Plan (internal analysis)

Se finalizó el reanálisis del proyecto Ando-UI tras la confirmación del usuario de que el entorno inicial de desarrollo y pruebas se centrará en el ambiente local, operando sobre WebSockets sin SSL (ws://) y dejando parametrizable el soporte SSL (wss://) para staging y producción mediante variables de entorno. Se consolidó el mapa de producto en 9 módulos estructurados por capas (esqueleto y cimientos, red y persistencia, auth/onboarding, búsqueda/lugares, viajes cliente, viajes conductor, historial/perfil, endurecimiento de seguridad/limpieza y publicación/empaquetado). Se actualizaron los documentos de arquitectura y la suite de pruebas para reflejar la conectividad dual ws/wss según ambiente, cubriendo todos los requisitos de negocio y el perfil de producción.

## Changes

- Incorporación de la especificación de WebSocket local sin SSL (ws://) y protocolo seguro wss:// parametrizable por ambiente en la arquitectura de red.
- Actualización de las pruebas de integración de sockets para contemplar el transporte no-SSL en desarrollo/local y SSL en producción.
- Cierre de dudas técnicas previas al desarrollo, dejando el proyecto completamente listo para la generación detallada de tareas por módulo.

## Mapa del producto

Mnemosine planifica todas las tareas de cada módulo después de este análisis (analysis/product_plan.md).

- **M1** Esqueleto del proyecto y cimientos de arquitectura (foundation)
  - Establecer la estructura base del repositorio Flutter en Clean Architecture Feature-First con Atomic Design, inyección de dependencias (GetIt), configuración por ambiente (local, dev, prod) con soporte .env y runner de pruebas verificado en CI con endpoint/vista de salud.
  - Requisitos de producción: PRD-QA-01, PRD-DEP-01, PRD-DOC-01
- **M2** Cimientos de Red, Seguridad y Persistencia Local (foundation)
  - Configurar cliente HTTP Dio con interceptores JWT e Idempotency-Key, almacenamiento seguro de sesión local (Flutter Secure Storage), persistencia relacional embebida (Sqflite), gestor de conexión WebSocket con soporte ws:// para local y wss:// para producción, y manejo centralizado de errores y logs.
  - Requisitos de producción: PRD-SEC-01, PRD-OPS-01, PRD-DATA-04, MOB-03, WEB-SEC-02
- **M3** Módulo de Autenticación y Onboarding (feature)
  - Implementar flujo completo de inicio de sesión y registro para pasajeros y conductores usando Firebase Auth integrado con JWT de Spring Boot, SessionBloc para gestión reactiva de sesión y enrutamiento según rol de usuario (client_routes, conductor_routes).
  - Requisitos de producción: PRD-SEC-03, WEB-SEC-02
- **M4** Módulo de Búsqueda y Selección de Ubicaciones (feature)
  - Integrar servicio de Places y Directions API para autocompletado con debounce de origen y destino, cálculo y dibujado de polilíneas de ruta, estimación preliminar de tarifas y visualización en mapa interactivo.
  - Requisitos de producción: WEB-UX-03
- **M5** Módulo de Gestión y Seguimiento de Viajes del Pasajero (feature)
  - Desarrollar la experiencia completa del cliente para solicitar viajes utilizando cabecera Idempotency-Key, interfaz de espera 'buscando conductor', seguimiento en vivo del conductor y viaje en curso por WebSocket, bloqueo de solicitudes simultáneas si hay viaje activo, finalización y calificación.
  - Requisitos de producción: PRD-QA-02, WEB-UX-03, MOB-04
- **M6** Módulo de Operaciones y Navegación del Conductor (feature)
  - Implementar el flujo operativo del conductor para disponibilidad geográfica GPS, recepción de solicitudes filtradas por su cooperativa, aceptación o rechazo, navegación guiada, actualización secuencial del ciclo de viaje (ACEPTADO -> EN_CURSO -> COMPLETADO) y calificación al cliente.
  - Requisitos de producción: PRD-QA-02, WEB-UX-03, MOB-04
- **M7** Módulo de Historial de Viajes y Perfil (feature)
  - Construir las vistas de perfil y consulta paginada de historial de viajes para pasajeros y conductores, mostrando detalle de estados finales (COMPLETADO, CANCELADO), desglose de cobro/pago, calificaciones emitidas y recibidas, con almacenamiento seguro y mínimo privilegio.
  - Requisitos de producción: PRD-DATA-05
- **M8** Endurecimiento de Seguridad, Calidad y Limpieza (production)
  - Ejecutar auditoría de dependencias libres de vulnerabilidades, eliminar código muerto de versiones previas (librerías obsoletas de mapas y blocs sin uso), verificar accesibilidad WCAG 2.1 AA en todas las pantallas y dotar a la aplicación de resiliencia con manejo offline y reporte seguro de fallos.
  - Requisitos de producción: PRD-QA-03, PRD-SEC-02, WEB-UX-02, MOB-04, MOB-05
- **M9** Preparación para Producción, Multi-Ambiente y Publicación (production)
  - Configurar empaquetado release firmado (Android AAB e iOS Archive), assets visuales completos (iconos y splash screen), verificación cruzada con contratos y esquema de base de datos existente, suite de smoke testing en emulador y dispositivos físicos, y documentación en DEPLOY.md y política de privacidad.
  - Requisitos de producción: PRD-DATA-01, PRD-DATA-03, PRD-DEP-03, MOB-01, MOB-02, MOB-06, MOB-07

## Tasks

- Se planifican por módulo.

## Tests

- test/unit/app/config/environment_config_test.dart: Comprobar lectura de variables de entorno y selección de esquema ws:// para local y wss:// para producción.
- test/unit/app/network/dio_client_test.dart: Validar inyección automática de Bearer Token en encabezados y generación obligatoria de Idempotency-Key en llamadas POST de viajes.
- test/unit/features/auth/domain/session_bloc_test.dart: Verificar transiciones de estado de autenticación (unauthenticated, authenticating, authenticated, failure) y resolución de rutas por rol (pasajero vs conductor).
- test/unit/features/trips/domain/passenger_trip_bloc_test.dart: Validar rechazo de nueva solicitud cuando el pasajero ya tiene un viaje no terminal (SOLICITADO, OFERTADO, ACEPTADO, EN_CURSO).
- test/unit/features/trips/domain/driver_trip_bloc_test.dart: Comprobar filtrado estricto de solicitudes para permitir solo las pertenecientes a la cooperativa del conductor autenticado.
- test/unit/features/trips/domain/trip_state_machine_test.dart: Verificar que las transiciones de estado del viaje sigan la secuencia estricta SOLICITADO -> OFERTADO -> ACEPTADO -> EN_CURSO -> COMPLETADO sin permitir saltos de estado.
- test/integration/network/websocket_manager_test.dart: Probar suscripción, reconexión automática tras corte de red y recepción de eventos en tiempo real tanto en modo no seguro ws:// (local) como seguro wss://.
- test/integration/flows/passenger_trip_e2e_test.dart: Recorrido E2E del pasajero desde selección de destino en mapa, solicitud con Idempotency-Key, recepción de conductor por socket y calificación final.
- test/integration/flows/driver_trip_e2e_test.dart: Recorrido E2E del conductor recibiendo alerta de viaje, aceptando solicitud, transmitiendo GPS e informando inicio y finalización del viaje.
- test/security/secure_storage_test.dart: Comprobar que los tokens JWT y datos sensibles de sesión se almacenan exclusivamente en Keystore/Keychain y nunca en texto plano.
- test/security/dead_code_audit_test.dart: Comprobar mediante flutter analyze y scripts de verificación de imports que no existen componentes huérfanos ni dependencias no utilizadas en el build final.
- test/accessibility/wcag_compliance_test.dart: Ejecutar escaneo automatizado de contraste, tamaños mínimos de toque (44x44) y etiquetas Semantics para lectores de pantalla en las vistas principales.

## Rationale

- Se integró la respuesta del usuario para el entorno local: los WebSockets se conectan sin requerir SSL en local (ws://), manteniendo la arquitectura preparada para activar wss:// en ambientes superiores mediante variables de entorno.
- Se mantuvo el mapa de producto en 9 módulos coherentes que garantizan un arranque funcional de punta a punta (esqueleto, red, auth, búsqueda, viajes pasajero, viajes conductor, historial, hardening y release).
- Cada uno de los 20 requisitos aplicables del perfil de producción (PRD-*, WEB-*, MOB-*) se encuentra mapeado en el mapa de producto.
- Las tareas permanecen vacías como lo requiere el flujo de Mnemosine para ser planificadas por módulo en la etapa siguiente.

## Assumptions

- Se asume que en el ambiente local el backend Spring Boot expone sus endpoints de WebSocket directamente en el puerto local asignado sobre protocolo ws:// sin capa intermedia de reverse proxy SSL.

## Memory changes

- Aplicado: architecture/overview.md — Actualización para reflejar la especificación de conexión de WebSocket sin SSL (ws://) para local y parametrizada con SSL (wss://) para producción según la aclaración del usuario.
