# Tareas — Ando-UI

Plan de implementación generado por Mnemosine. El estado vivo de cada tarea está en Mnemosine;
este archivo es una foto del plan en el momento de la última publicación.

## Cimientos de arquitectura y tokens de diseño base

- [ ] **Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design** (pendiente)
  - Criterio: El tema AppTheme define esquemas de colores y estilos tipográficos consistentes con Material 3.
  - Criterio: El componente AppButton renderiza el texto especificado y gestiona callbacks de pulsación.

## Enrutamiento declarativo y monitoreo de salud inicial

- [ ] **Enrutamiento base con GoRouter y vista de salud/diagnóstico** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design, Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: La ruta /health navega exitosamente a HealthScreen y muestra el ambiente en ejecución.
  - Criterio: El router gestiona rutas inexistentes redirigiendo a una vista o mensaje de error 404 predeterminado.

## Automatización de calidad en CI y documentación de puesta en marcha

- [ ] **Pipeline de integración continua (CI) y documentación README** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design, Configuración multi-ambiente e inyección de dependencias con GetIt, Enrutamiento base con GoRouter y vista de salud/diagnóstico
  - Criterio: El workflow .github/workflows/ci.yml define las etapas de instalación de Flutter, flutter pub get, flutter analyze y flutter test.
  - Criterio: El archivo README.md describe la arquitectura, instalación, variables de entorno y comandos para correr la app y sus tests.
  - Criterio: Las instrucciones de README.md permiten inicializar y levantar la aplicación en entorno local sin ambigüedades.

## Configuración de entornos e inyección de dependencias

- [ ] **Configuración multi-ambiente e inyección de dependencias con GetIt** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design
  - Criterio: EnvironmentConfig selecciona ws:// para el ambiente local y wss:// para producción a partir de la configuración.
  - Criterio: El contenedor GetIt inicializa y registra dependencias sin dependencias circulares ni errores de resolución.
  - Criterio: El archivo .env.example existe en la raíz y define las variables de entorno sin contener secretos ni valores sensibles reales.

## Infraestructura de comunicación en tiempo real

- [ ] **Gestor de WebSockets para estados de viaje y posición** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt, Configuración de almacenamiento seguro para tokens y sesión
  - Criterio: M2.T3-C1: WebSocketManager selecciona esquema ws:// para ambiente local y wss:// para dev y prod.
  - Criterio: M2.T3-C2: En caso de caída de conexión, el gestor ejecuta reconexión automática con retroceso exponencial sin colapsar la aplicación.
  - Criterio: M2.T3-C3: Los eventos recibidos por los canales de posición y estado de viaje son emitidos a través de Streams fuertemente tipados.

## Observabilidad y tratamiento de errores

- [ ] **Manejo estructurado de errores y logs de red** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M2.T5-C1: ErrorMapper convierte respuestas de error del backend en mensajes claros y comprensibles sin exponer trazas técnicas internas.
  - Criterio: M2.T5-C2: LoggingInterceptor sanitiza y enmascara tokens Bearer, contraseñas y datos sensibles en los logs.
  - Criterio: M2.T5-C3: Los conflictos de idempotencia (código HTTP 409) son tipificados como IdempotencyConflictFailure con mensaje específico de reintento.

## Seguridad de credenciales y persistencia de sesión

- [ ] **Configuración de almacenamiento seguro para tokens y sesión** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M2.T1-C1: SecureStorageService persiste y recupera tokens JWT y datos de sesión utilizando cifrado nativo en Keystore/Keychain.
  - Criterio: M2.T1-C2: El método de borrado de sesión purga por completo tokens y llaves sin dejar remanentes.
  - Criterio: M2.T1-C3: Las excepciones de lectura/escritura de almacenamiento nativo son capturadas y mapeadas a StorageFailure.

## Comunicaciones HTTP seguras e idempotentes

- [ ] **Cliente HTTP Dio con interceptores de seguridad e idempotencia** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión
  - Criterio: M2.T2-C1: Toda petición saliente authenticated incluye el encabezado Authorization con formato Bearer si existe token en almacenamiento seguro.
  - Criterio: M2.T2-C2: Toda petición HTTP POST hacia endpoints de viaje incluye de forma automática la cabecera Idempotency-Key con formato UUID válido.
  - Criterio: M2.T2-C3: Ante error HTTP 401 Unauthorized, el interceptor emite un evento de expiración de sesión hacia el bus de eventos de autenticación.

## Almacenamiento y caché offline

- [ ] **Persistencia local con Sqflite para caché y modo offline** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M2.T4-C1: AppDatabase inicializa la base de datos local creando las tablas con llaves primarias e índices esperados.
  - Criterio: M2.T4-C2: Las migraciones versionadas se ejecutan de forma secuencial y sin pérdida de datos en actualizaciones de esquema.
  - Criterio: M2.T4-C3: Las semillas de prueba usan datos mockeados y no contienen información real de producción.

## Cierre de Sesión Seguro

- [ ] **Cierre de sesión y limpieza de datos** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Protección de rutas y redirección por Rol
  - Criterio: M3.T7-C1: El cierre de sesión borra de forma exhaustiva los tokens y llaves del almacenamiento seguro local sin dejar artefactos de sesión.
  - Criterio: M3.T7-C2: Tras el logout, el usuario es redirigido a /auth/login y el historial de navegación hacia atrás queda purgado.

## Autenticación y Dominio de Usuario

- [ ] **Modelado de entidades de Usuario y Contrato de Auth** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M3.T1-C1: Las entidades de dominio User y AuthTokens son inmutables y validan nulabilidad estricta según el esquema del backend.
  - Criterio: M3.T1-C2: La deserialización rechaza roles desconocidos o diferentes a PASAJERO y CONDUCTOR arrojando una excepción de dominio.

## Infraestructura de Autenticación

- [ ] **Data Source y Repositorio de Autenticación (Firebase + Backend)** (pendiente)
  - Depende de: Modelado de entidades de Usuario y Contrato de Auth, Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M3.T2-C1: El repositorio intercambia exitosamente el IdToken de Firebase por el JWT del backend Ando y lo guarda en almacenamiento seguro.
  - Criterio: M3.T2-C2: Los errores 401 y 403 del backend se mapean a fallas de autenticación tipadas sin exponer tokens ni datos sensibles.

## Gestión de Estado de Sesión

- [ ] **SessionBloc: Gestión de estado global de la sesión** (pendiente)
  - Depende de: Data Source y Repositorio de Autenticación (Firebase + Backend)
  - Criterio: M3.T3-C1: SessionBloc emite SessionAuthenticated con el rol correcto al encontrar un token válido almacenado en CheckSessionRequested.
  - Criterio: M3.T3-C2: SessionBloc emite SessionUnauthenticated si no hay tokens guardados o si el backend rechaza el token al revalidar.

## Experiencia de Inicio de Sesión

- [ ] **Pantalla de Login con validación inteligente** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Protección de rutas y redirección por Rol
  - Criterio: M3.T5-C1: El botón de inicio de sesión permanece deshabilitado o previene el envío cuando los campos no cumplen el formato requerido.
  - Criterio: M3.T5-C2: La interfaz muestra un indicador de carga y deshabilita los inputs mientras SessionBloc está en estado SessionAuthenticating.

## Experiencia de Registro y Onboarding

- [ ] **Flujo de Registro y Selección de Rol** (pendiente)
  - Depende de: Pantalla de Login con validación inteligente
  - Criterio: M3.T6-C1: El formulario de registro exige la cooperativa únicamente cuando el rol seleccionado es CONDUCTOR.
  - Criterio: M3.T6-C2: Los campos de entrada sanitizan espacios en blanco y validan formatos antes de invocar la creación de cuenta en el backend.

## Enrutamiento y Control de Acceso

- [ ] **Protección de rutas y redirección por Rol** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Enrutamiento base con GoRouter y vista de salud/diagnóstico
  - Criterio: M3.T4-C1: Un usuario autenticado con rol CONDUCTOR intentando acceder a una ruta de cliente es redirigido a /conductor/home.
  - Criterio: M3.T4-C2: Un usuario no autenticado intentando acceder a cualquier ruta protegida es redirigido automáticamente a /auth/login.

## Búsqueda y selección de ubicaciones

- [ ] **LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino** (pendiente)
  - Depende de: Modelado y Repositorio de Autocompletado de Lugares (Places API), Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)
  - Criterio: M4.T3-C1: Las consultas consecutivas de texto aplican debounce de 300 ms antes de emitir la llamada al repositorio.
  - Criterio: M4.T3-C2: Al seleccionar origen y destino válidos, el Bloc transiciona a RouteCalculating y emite RouteReady con polilínea y tarifa.
  - Criterio: M4.T3-C3: El evento SwapLocations invierte origen y destino y recalcula la ruta si ambos estaban establecidos.
  - Criterio: M4.T3-C4: En caso de error de red o timeout, emite ErrorState con mensaje amigable sin crash.
- [ ] **Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)** (pendiente)
  - Depende de: Modelado y Repositorio de Autocompletado de Lugares (Places API)
  - Criterio: M4.T2-C1: DirectionsRepository decodifica la polilínea de ruta en una secuencia válida de coordenadas LatLng.
  - Criterio: M4.T2-C2: La estimación de tarifa calcula distancia, duración estimada y precio base según los parámetros devueltos por el backend.
  - Criterio: M4.T2-C3: Las excepciones ante rutas no encontradas se traducen en RouteNotFoundFailure.
- [ ] **Mapa de Previsualización de Ruta y Card de Estimación de Tarifa** (pendiente)
  - Depende de: Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones
  - Criterio: M4.T5-C1: El mapa dibuja los marcadores de origen y destino junto con la polilínea de la ruta calculada.
  - Criterio: M4.T5-C2: La tarjeta de estimación muestra correctamente el desglose de distancia, tiempo estimado y costo aproximado.
  - Criterio: M4.T5-C3: Muestra estado de error con botón de reintento si falla la obtención de la ruta o la tarifa.
  - Criterio: M4.T5-C4: El botón 'Confirmar ruta' queda deshabilitado mientras se calcula la ruta o si hay error, y habilitado cuando RouteReady está activo.
- [ ] **Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones** (pendiente)
  - Depende de: LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino
  - Criterio: M4.T4-C1: La pantalla renderiza los campos de origen, destino y botón de intercambio accesibles.
  - Criterio: M4.T4-C2: Se visualizan skeletons de carga mientras se obtienen las predicciones de autocompletado.
  - Criterio: M4.T4-C3: Muestra mensaje y diseño de estado vacío comprensible cuando no se encuentran lugares coincidentes.
  - Criterio: M4.T4-C4: Permite seleccionar un elemento de la lista y rellenar automáticamente el campo correspondiente.
- [ ] **Modelado y Repositorio de Autocompletado de Lugares (Places API)** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M4.T1-C1: PlacesRepository mapea correctamente la respuesta JSON a lista de entidades PlacePrediction.
  - Criterio: M4.T1-C2: PlacesRepository devuelve lista vacía sin error cuando no hay coincidencias.
  - Criterio: M4.T1-C3: Los errores de red se capturan y devuelven un objeto de falla de dominio PlacesFailure tipado.

## Como desarrollador, quiero asegurar que todo el flujo del pasajero es estable y resiliente.

- [ ] **Test de Integración: Flujo Completo del Pasajero** (pendiente)
  - Depende de: Finalización de Viaje y Calificación del Conductor
  - Criterio: El flujo completo desde solicitud hasta calificación se completa sin errores inesperados.
  - Criterio: La app muestra un aviso de 'Sin conexión' si se pierde la red durante el seguimiento del mapa.

## Como pasajero, quiero que la app mantenga el estado de mi viaje aunque cambie de pantalla o pierda conexión.

- [ ] **PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje** (pendiente)
  - Depende de: Repositorio de Viajes y DataSource con Idempotencia
  - Criterio: El Bloc emite TripSearchingState tras una solicitud exitosa.
  - Criterio: El Bloc emite TripErrorState con mensaje amigable si ya existe un viaje activo (409).

## Como pasajero, necesito que la app entienda los datos de un viaje para poder solicitarlo y seguirlo.

- [ ] **Modelado de Entidades y Contratos de Viaje para Pasajero** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: El modelo TripModel mapea correctamente todos los estados del enum del backend.
  - Criterio: La entidad Trip incluye campos para conductor, vehículo y coordenadas de seguimiento.

## Como sistema, debo asegurar que no se dupliquen solicitudes de viaje por problemas de red.

- [ ] **Repositorio de Viajes y DataSource con Idempotencia** (pendiente)
  - Depende de: Modelado de Entidades y Contratos de Viaje para Pasajero, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: El repositorio envía el header 'Idempotency-Key' en cada POST de creación de viaje.
  - Criterio: Se lanza ActiveTripException cuando el backend responde con error 409.

## Como pasajero, quiero ver en tiempo real cuándo un conductor acepta mi viaje sin refrescar la pantalla.

- [ ] **Integración de WebSocket para Actualizaciones en Tiempo Real** (pendiente)
  - Depende de: PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje, Gestor de WebSockets para estados de viaje y posición
  - Criterio: El Bloc actualiza el estado del viaje automáticamente al recibir un mensaje del WebSocket.
  - Criterio: La app reconecta la suscripción al WebSocket si se pierde la conexión durante un viaje activo.

## Como pasajero, quiero saber que mi solicitud está siendo procesada y tener la opción de cancelarla.

- [ ] **Pantalla de Búsqueda de Conductor y Espera** (pendiente)
  - Depende de: PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje, Mapa de Previsualización de Ruta y Card de Estimación de Tarifa
  - Criterio: La pantalla muestra un indicador de carga visual mientras el estado es SOLICITADO.
  - Criterio: El botón 'Cancelar Viaje' invoca la acción correspondiente y regresa al Home.

## Como pasajero, quiero ver dónde viene mi conductor en el mapa para estar listo.

- [ ] **Seguimiento de Viaje en Mapa en Tiempo Real** (pendiente)
  - Depende de: Integración de WebSocket para Actualizaciones en Tiempo Real, Pantalla de Búsqueda de Conductor y Espera
  - Criterio: El marcador del conductor se mueve en el mapa sin saltos bruscos al recibir coordenadas.
  - Criterio: Se muestran los detalles del vehículo (placa, modelo) una vez el viaje está ACEPTADO.

## Como pasajero, quiero calificar mi experiencia una vez que el viaje ha terminado.

- [ ] **Finalización de Viaje y Calificación del Conductor** (pendiente)
  - Depende de: Seguimiento de Viaje en Mapa en Tiempo Real
  - Criterio: El formulario de calificación solo es visible si el estado del viaje es exactamente COMPLETADO.
  - Criterio: Se valida que la calificación sea obligatoria antes de permitir el envío.

## Navegación y Ejecución de Viaje

- [ ] **Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje** (pendiente)
  - Depende de: DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje, Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar)
  - Criterio: T7-C1: Habilitar el botón de 'Completar Viaje' únicamente cuando el estado actual es EN_CURSO y deshabilitarlo durante ACEPTADO.
  - Criterio: T7-C2: Deslizar o pulsar 'Iniciar Viaje' emite StartTripRequested y actualiza la UI al tramo hacia el destino.

## Finalización y Calificación

- [ ] **Flujo de Finalización de Viaje y Calificación del Pasajero** (pendiente)
  - Depende de: Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje
  - Criterio: T8-C1: El botón de confirmar calificación se mantiene deshabilitado hasta que se selecciona una puntuación entre 1 y 5 estrellas.
  - Criterio: T8-C2: Tras registrar la calificación con éxito, el sistema limpia el viaje activo y regresa a la vista de conductor disponible.

## Validación E2E Conductor

- [ ] **Prueba de Integración E2E: Ciclo de Vida Completo del Conductor** (pendiente)
  - Depende de: Pantalla Principal del Conductor y Panel de Disponibilidad, Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar), Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje, Flujo de Finalización de Viaje y Calificación del Pasajero
  - Criterio: T9-C1: El test de integración completa todo el ciclo secuencial del viaje del conductor desde disponibilidad hasta calificación final con backend/mock de integración.
  - Criterio: T9-C2: Verificar en emulador/dispositivo que la UI del conductor muestra adecuadamente los estados de reconexión y transiciones de viaje fluidas.

## Gestión de Operaciones del Conductor

- [ ] **Modelos y contratos del dominio para operaciones del conductor** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, SessionBloc: Gestión de estado global de la sesión
  - Criterio: T1-C1: Validar que TripStatus rechaza transiciones ilegales que no respeten el orden secuencial (ej. ACEPTADO directo a COMPLETADO sin pasar por EN_CURSO).
  - Criterio: T1-C2: Comprobar que DriverTripRequest valida la correspondencia de cooperativeId y no permite campos obligatorios nulos.
- [ ] **DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje** (pendiente)
  - Depende de: DataSource y Repositorio de Conductor con filtrado por Cooperativa, Servicio de Geolocalización y Transmisión de Posición por WebSocket
  - Criterio: T4-C1: Cambiar el estado a DriverTripInProgress únicamente tras recibir confirmación exitosa de StartTripRequested.
  - Criterio: T4-C2: Rechazar o descartar una solicitud tras timeout emitiendo DriverAvailable sin afectar el estado general de disponibilidad.

## Integración con Backend Ando

- [ ] **DataSource y Repositorio de Conductor con filtrado por Cooperativa** (pendiente)
  - Depende de: Modelos y contratos del dominio para operaciones del conductor, Cliente HTTP Dio con interceptores de seguridad e idempotencia, Protección de rutas y redirección por Rol
  - Criterio: T2-C1: Aceptar o iniciar viaje envía las cabeceras de autorización correctas y mapea adecuadamente el DTO devuelto por el backend.
  - Criterio: T2-C2: Lanzar CooperativeMismatchException cuando se detecta un viaje de una cooperativa diferente a la del conductor.

## Interfaz del Conductor

- [ ] **Pantalla Principal del Conductor y Panel de Disponibilidad** (pendiente)
  - Depende de: DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje
  - Criterio: T5-C1: Renderizar el switch de disponibilidad y disparar el evento ToggleAvailabilityRequested al cambiar su estado.
  - Criterio: T5-C2: Mostrar banner de alerta cuando la conexión de red se pierde o el GPS está deshabilitado.

## Seguimiento GPS en Tiempo Real

- [ ] **Servicio de Geolocalización y Transmisión de Posición por WebSocket** (pendiente)
  - Depende de: Modelos y contratos del dominio para operaciones del conductor, Gestor de WebSockets para estados de viaje y posición
  - Criterio: T3-C1: Emitir coordenadas serializadas al WebSocket únicamente cuando el conductor se encuentre en estado disponible o con viaje activo.
  - Criterio: T3-C2: Manejar la denegación de permisos de ubicación emitiendo un fallo de dominio LocationPermissionDeniedException sin congelar la aplicación.

## Aceptación de Solicitudes

- [ ] **Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar)** (pendiente)
  - Depende de: DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje, Pantalla Principal del Conductor y Panel de Disponibilidad
  - Criterio: T6-C1: El botón Aceptar dispara AcceptTripRequested y cierra el modal de oferta pasando a navegación en ruta.
  - Criterio: T6-C2: El botón Rechazar emite RejectTripRequested y descarta el modal de inmediato.

## Gestión de Historial y Perfil

- [ ] **Pantalla y componentes de Listado de Historial de Viajes con paginación** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: M7.T5-C1: La pantalla renderiza el estado vacío TripHistoryEmptyState cuando la lista de viajes está vacía.
  - Criterio: M7.T5-C2: Al hacer scroll al final de la lista se despacha el evento para cargar la siguiente página.
  - Criterio: M7.T5-C3: Cada elemento renderiza fecha, dirección de origen/destino, tarifa formateada y badge de estado.
- [ ] **Pantalla de Perfil de Usuario y Edición de Datos** (pendiente)
  - Depende de: ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario
  - Criterio: M7.T7-C1: Los campos editables reflejan los valores iniciales del usuario y validan formato de teléfono antes del envío.
  - Criterio: M7.T7-C2: Al enviar cambios válidos, se invoca el evento de actualización y se muestra indicador de carga mientras procesa.
- [ ] **Integración en Rutas y Menú de Navegación para Pasajero y Conductor** (pendiente)
  - Depende de: Pantalla y componentes de Listado de Historial de Viajes con paginación, Pantalla de Detalle de Viaje Pasado (Completed / Cancelled), Pantalla de Perfil de Usuario y Edición de Datos, Protección de rutas y redirección por Rol
  - Criterio: M7.T8-C1: La ruta '/trips/history' y '/profile' son accesibles tanto para rol PASAJERO como CONDUCTOR.
  - Criterio: M7.T8-C2: La ruta '/trips/:id' abre TripDetailPage con el identificador de viaje proporcionado como parámetro.
- [ ] **Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: M7.T1-C1: Las entidades y modelos de TripSummary y UserProfile deserializan correctamente payloads de respuesta según el SSOT del backend.
  - Criterio: M7.T1-C2: Los campos de paginación (page, size, totalElements, totalPages, content) se mapean adecuadamente a TripHistoryPage.
- [ ] **Data Sources y Repositorios de Historial de Viajes y Perfil** (pendiente)
  - Depende de: Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M7.T2-C1: TripHistoryRemoteDataSource invoca /api/v1/trips/history con parámetros de paginación y cabecera de autenticación JWT.
  - Criterio: M7.T2-C2: ProfileRepository actualiza los datos del usuario mediante PUT /api/v1/users/profile y retorna la entidad actualizada o propaga el fallo de dominio.
- [ ] **TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados** (pendiente)
  - Depende de: Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: M7.T3-C1: El evento TripHistoryFetchRequested emite estados Loading y Loaded con los primeros elementos obtenidos.
  - Criterio: M7.T3-C2: El evento TripHistoryNextPageRequested concatena los nuevos resultados a la lista existente sin duplicar registros.
  - Criterio: M7.T3-C3: Los errores en la petición de historial emiten TripHistoryError con mensaje comprensible.
- [ ] **ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario** (pendiente)
  - Depende de: Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: M7.T4-C1: ProfileFetchRequested recupera el perfil actual del usuario y emite ProfileLoaded.
  - Criterio: M7.T4-C2: ProfileUpdateSubmitted procesa la actualización y emite ProfileUpdateSuccess con los nuevos datos.
- [ ] **Pantalla de Detalle de Viaje Pasado (Completed / Cancelled)** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: M7.T6-C1: La pantalla muestra todos los detalles del viaje completado incluyendo monto total, conductor/pasajero, cooperativa y rating.
  - Criterio: M7.T6-C2: Si el viaje fue cancelado, se ocultan datos de tarifa y calificación y se visualiza claramente el motivo de cancelación y el estado CANCELADO.

## Monitoreo y Reporte Seguro de Fallos

- [ ] **Servicio de reporte de fallos y sanitización de registros de error** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T4-C1: CrashReportingService captura errores síncronos y asíncronos no manejados reportándolos a la plataforma de monitoreo configurada.
  - Criterio: M8.T4-C2: El sanitizador de errores elimina encabezados Authorization, tokens bearer y campos sensibles de los metadatos del crash.

## Limpieza y Cero Código Muerto

- [ ] **Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec
  - Criterio: M8.T2-C1: El analizador estático de Dart finaliza sin ningún warning, error o linter issue en todo el árbol de lib/ y test/.
  - Criterio: M8.T2-C2: Todos los archivos y clases huérfanas de versiones previas quedan completamente eliminados sin referencias rotas.

## Resiliencia y Modo Sin Conexión

- [ ] **Servicio de conectividad de red reactivo y banner de desconexión/reconexión** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T3-C1: ConnectivityBloc emite estado desconectado al cesar la conectividad y estado conectado al restablecerse.
  - Criterio: M8.T3-C2: NetworkStatusBanner se renderiza informando pérdida de red cuando el estado es desconectado y desaparece con animación al reconectar.
  - Criterio: M8.T3-C3: Al volver la conexión, el gestor de red reintenta automáticamente la reconexión de sockets y peticiones pendientes.

## Accesibilidad e Inclusión

- [ ] **Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T5-C1: Los botones y controles interactivos principales cuentan con nodos Semantics y etiquetas accesibles no vacías.
  - Criterio: M8.T5-C2: La paleta de colores del tema garantiza un contraste superior a 4.5:1 entre colores de texto y fondo en modo claro y oscuro.
  - Criterio: M8.T5-C3: Los campos de formulario y cards de estado de viaje exponen estados y roles semánticos correctos para lectores de pantalla.

## Calidad y Seguridad de Dependencias

- [ ] **Auditoría de seguridad y depuración de dependencias en pubspec** (pendiente)
  - Depende de: Test de Integración: Flujo Completo del Pasajero, Prueba de Integración E2E: Ciclo de Vida Completo del Conductor, Integración en Rutas y Menú de Navegación para Pasajero y Conductor
  - Criterio: M8.T1-C1: pubspec.yaml contiene únicamente dependencias activas del proyecto sin paquetes heredados en desuso.
  - Criterio: M8.T1-C2: El comando de auditoría y análisis de paquetes finaliza exitosamente con código de salida 0 sin advertencias críticas ni incompatibilidades de versión.

## Gestión y versionado de datos locales

- [ ] **Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: Las migraciones de la base de datos local Sqflite se ejecutan en orden secuencial sin pérdida de integridad.
  - Criterio: El procedimiento de recuperación ante base de datos local corrupta recrea el esquema sin bloquear la apertura de la aplicación.
  - Criterio: Existe la documentación docs/database_local_model.md con el mapeo claro de entidades y contratos.

## Control de calidad y verificación en dispositivos reales

- [ ] **Suite de verificación de smoke testing en emulador y validación en dispositivos reales** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release, Integración de Política de Privacidad dentro de la app y pantalla informativa, Documentación exhaustiva de despliegue y distribución en DEPLOY.md
  - Criterio: El test de integración integration_test/smoke_release_test.dart compila y ejecuta exitosamente en emulador Android.
  - Criterio: El checklist docs/REAL_DEVICE_TESTING_CHECKLIST.md detalla los criterios de aceptación físicos (sensores GPS, suspensión en segundo plano, reconexión móvil 4G/5G).
  - Criterio: La app es instalada y verificada en un teléfono Android y un teléfono iPhone físico siguiendo el checklist de prueba.

## Identidad visual y branding nativo de la aplicación

- [ ] **Configuración de App Launcher Icons y Native Splash Screen para Android e iOS** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec, Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: Los archivos de configuración de flutter_launcher_icons y flutter_native_splash están definidos en pubspec.yaml con rutas válidas de assets.
  - Criterio: El nombre de visualización de la app está fijado a 'Ando' en AndroidManifest.xml e Info.plist.
  - Criterio: La pantalla de splash nativa y los iconos de la app se visualizan correctamente en Android e iOS sin deformaciones de aspecto.

## Seguridad y permisos de plataforma

- [ ] **Declaración y justificación contextual de permisos móviles mínimos en Android e iOS** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec
  - Criterio: AndroidManifest.xml e Info.plist contienen únicamente los permisos de geolocalización y red estrictamente requeridos.
  - Criterio: PermissionService maneja correctamente los estados granted, denied y permanentlyDenied sin lanzar excepciones no controladas.
  - Criterio: Las descripciones en Info.plist justifican el propósito de uso de ubicación de forma comprensible para el usuario.

## Empaquetado y distribución móvil

- [ ] **Configuración de compilación firmada Android (AAB) y scripts de release** (pendiente)
  - Depende de: Configuración de App Launcher Icons y Native Splash Screen para Android e iOS, Declaración y justificación contextual de permisos móviles mínimos en Android e iOS
  - Criterio: android/app/build.gradle obtiene las credenciales de firma de release desde variables de entorno o key.properties sin contener contraseñas en texto plano.
  - Criterio: El archivo de reglas ProGuard android/app/proguard-rules.pro preserva los modelos de serialización JSON y componentes de WebSocket requeridos para release.
  - Criterio: El script tool/build_android_bundle.sh ejecuta la compilación del bundle para el flavor de producción.
- [ ] **Configuración de compilación para iOS Archive y exportación de release** (pendiente)
  - Depende de: Configuración de App Launcher Icons y Native Splash Screen para Android e iOS, Declaración y justificación contextual de permisos móviles mínimos en Android e iOS
  - Criterio: ExportOptions.plist y Release.xcconfig están configurados para distribución App Store / Ad-Hoc sin incluir certificados privados en Git.
  - Criterio: El bundle identifier de iOS coincide con el applicationId de Android configurado para el flavor de producción.
  - Criterio: La compilación del archivo de iOS se genera correctamente con flutter build ipa en entorno macOS con Xcode.

## Cumplimiento legal y normativo para tiendas

- [ ] **Integración de Política de Privacidad dentro de la app y pantalla informativa** (pendiente)
  - Depende de: Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave
  - Criterio: PrivacyPolicyScreen carga y renderiza el contenido de assets/legal/privacy_policy.md sin errores ni estado de carga infinito.
  - Criterio: El archivo docs/PRIVACY_POLICY.md existe en la raíz del repositorio y contiene las secciones requeridas por Google Play y App Store (datos recolectados, ubicación en segundo plano, contacto del responsable).
  - Criterio: El enlace a la Política de Privacidad es accesible tanto desde el flujo de registro como desde el perfil de usuario.

## Documentación de operaciones y despliegue

- [ ] **Documentación exhaustiva de despliegue y distribución en DEPLOY.md** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release
  - Criterio: El archivo DEPLOY.md existe en la raíz y describe los pasos de compilación y despliegue para Android e iOS en los ambientes local, dev y prod.
  - Criterio: DEPLOY.md no contiene tokens, contraseñas ni rutas absolutas privadas de desarrolladores.

## Limpieza de versión y depuración final

- [ ] **Limpieza final de versión y depuración de código muerto y dependencias** (pendiente)
  - Depende de: Suite de verificación de smoke testing en emulador y validación en dispositivos reales
  - Criterio: El analizador de Dart (`dart analyze`) finaliza con cero advertencias y cero errores de código o imports no utilizados.
  - Criterio: No existen dependencias o paquetes declarados en `pubspec.yaml` que no sean importados en el código fuente de `lib/`.
