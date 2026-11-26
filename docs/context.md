# Project Context

Description: Ando-UI es la aplicación móvil (Flutter) para Ando, un servicio de taxi/viajes operado por cooperativas de transporte. Es la capa de frontend que consume el backend Ando ya construido y completado en el repositorio micro-auronix (Spring Boot 3, Java 21, arquitectura hexagonal, backlog de 56 tareas, 100% terminado y verificado en CI).

La app tiene dos roles principales: pasajero (cliente) y conductor, cada uno con su propio flujo de navegación (client_routes, conductor_routes). El pasajero puede buscar destino, solicitar un viaje, ver la búsqueda de conductor en tiempo real, seguir el viaje en curso, calificarlo al terminar y consultar su historial. El conductor recibe solicitudes de viaje cercanas, las acepta/rechaza, inicia y completa el viaje, y también califica al pasajero.

Autenticación vía JWT contra el backend, con sesión manejada en un SessionBloc y helpers de rol (role_helpers) para enrutar según el tipo de usuario. Se integró recientemente Firebase Auth como parte del flujo de login/registro. El seguimiento en tiempo real del viaje (posición del conductor, estado del viaje) se hace por WebSockets (sockets dedicados para posición del conductor, posición del cliente y estado del viaje), y la selección de origen/destino usa un servicio de "places" (Directions API) para rutas y direcciones.

Arquitectura del código por features (auth, home, trips, client_profile, onboarding), cada una dividida en data/domain/presentation siguiendo el patrón BLoC, con inyección de dependencias centralizada (dependency_injection.dart) y persistencia local (base de datos local embebida vía app_database.dart) para caché/sesión offline.

El objetivo de este proyecto en Mnemosine es exclusivamente de frontend: terminar, pulir y estabilizar las pantallas y flujos ya avanzados (hay bastante código funcional, pero con partes que van a necesitar refactor/alineación con los endpoints reales del backend ya completado), sin tocar ni rehacer el backend ni la base de datos, que ya existen y están en producción/listos.
Development type: frontend
Application type: mobile
Environments in scope: development, local, production
Database: existing (postgresql); the project uses a database the user already has and must not recreate it
Database notes: Es la base de datos PostgreSQL 16 ya existente y en uso del backend Ando (micro-auronix), gestionada por migraciones Flyway versionadas (actualmente hasta V12+). No se crea ninguna base nueva: la app Flutter nunca se conecta a ella directamente, sino siempre a través de la API REST/WebSocket del backend Spring Boot.

Contiene, entre otras, tablas de usuarios (tb_users, con roles pasajero/conductor), cooperativas de transporte (tb_cooperatives), vehículos (tb_vehicles), viajes con su ciclo de vida completo (tb_trips: SOLICITADO → OFERTADO → ACEPTADO → EN_CURSO → finalizado, origen/destino, pagos y calificaciones), invitaciones de registro de conductores, claves de idempotencia para reintentos seguros de creación de viajes (tb_idempotency_keys), y registros de auditoría. También soporta funciones geoespaciales (extensiones earthdistance/cube) para cálculos de cercanía conductor-pasajero.

Desde el punto de vista de este proyecto de frontend, la base de datos es solo contexto: ninguna tarea de Ando-UI debe modificar su esquema ni acceder a ella fuera de los endpoints ya expuestos por el backend.

El backend de Ando (API REST + WebSocket en Spring Boot, repo micro-auronix) ya está 100% construido y en producción: maneja usuarios, cooperativas, vehículos, viajes, pagos, calificaciones, autenticación JWT, auditoría e idempotencia. Lo que falta es la aplicación móvil Flutter (app_auronix) que los pasajeros y conductores realmente usan para interactuar con ese backend.

Ya existe bastante código de frontend avanzado (pantallas de auth, home de cliente/conductor, flujo completo de viaje, sockets de tracking en tiempo real, integración reciente con Firebase Auth), pero fue construido en paralelo al backend y antes de que varias reglas de negocio y endpoints quedaran definitivos. El problema concreto: hay pantallas y blocs que no reflejan exactamente los contratos finales del backend (nombres de campos, estados de viaje, nuevos mecanismos como idempotencia en la creación de viajes), y probablemente partes del flujo que cambiaron de diseño (p. ej. el cambio de librería de mapas) dejaron código muerto o inconsistente.

Resultado esperado: una app Flutter estable, que consuma correctamente cada endpoint real del backend Ando ya terminado, sin duplicar lógica de negocio que debe vivir en el servidor (la app es solo presentación + orquestación de llamadas), con los flujos de pasajero y conductor funcionando de punta a punta contra el backend real (no mocks).
