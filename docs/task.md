# Tareas — Ando-UI

Plan de implementación generado por Mnemosine. El estado vivo de cada tarea está en Mnemosine;
este archivo es una foto del plan en el momento de la última publicación.

## Cimientos de arquitectura y diseño

- [ ] **Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design** (pendiente)
  - Criterio: M1.T1-C1: La estructura de directorios y exportaciones públicas en lib/app, lib/features y lib/shared se resuelve sin errores de importación circular ni referencias huérfanas.
  - Criterio: M1.T1-C2: AppTheme genera configuraciones ThemeData de Material 3 válidas para modos claro y oscuro con contrastes de color accesibles.
  - Criterio: M1.T1-C3: Los componentes atómicos AndoButton y AndoTextField respetan los tokens de espaciado y estado deshabilitado.

## Integración continua y documentación

- [ ] **Pipeline de integración continua (CI) y documentación README** (pendiente)
  - Depende de: Enrutamiento base con GoRouter y vista de salud/diagnóstico
  - Criterio: M1.T4-C1: El flujo de GitHub Actions ci.yml define pasos estrictos de checkout, setup de Flutter, análisis estático y ejecución de pruebas con reporte de cobertura.
  - Criterio: M1.T4-C2: El archivo README.md contiene secciones de instalación, variables de entorno, ejecución por ambiente y testing para un onboarding sin fricción.
  - Criterio: M1.T4-C3: flutter analyze se ejecuta sin warnings ni errores de linter sobre todo el código base de M1.

## Navegación y diagnóstico

- [ ] **Enrutamiento base con GoRouter y vista de salud/diagnóstico** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M1.T3-C1: GoRouter resuelve correctamente la ruta inicial '/health_check' y navega sin errores de contexto.
  - Criterio: M1.T3-C2: HealthCheckScreen muestra la información del ambiente activo (nombre, apiUrl, esquema ws/wss) consumiendo EnvironmentConfig desde GetIt.
  - Criterio: M1.T3-C3: Las rutas hacia flujos de pasajero y conductor están declaradas como ramas desacopladas listas para los módulos siguientes.

## Configuración y DI

- [ ] **Configuración multi-ambiente e inyección de dependencias con GetIt** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design
  - Criterio: M1.T2-C1: EnvironmentConfig inicializa las propiedades según el mapa de entorno y selecciona el esquema ws:// para ambiente local y wss:// para desarrollo/producción.
  - Criterio: M1.T2-C2: GetIt registra y resuelve correctamente la instancia singleton de EnvironmentConfig tras invocar setupServiceLocator().
  - Criterio: M1.T2-C3: El repositorio incluye .env.example con las claves de entorno necesarias sin valores de producción y .env se encuentra excluido en .gitignore.

## Base de Datos Embebida y Caché

- [ ] **Persistencia local con Sqflite para caché y modo offline** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: La base de datos SQLite embebida inicializa correctamente sus tablas sin perder integridad de datos.
  - Criterio: Se pueden guardar y consultar registros en caché local durante pérdida de conectividad.

## Manejo de Errores y Observabilidad

- [ ] **Manejo estructurado de errores y logs de red** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, Gestor de WebSockets para estados de viaje y posición
  - Criterio: Cualquier error de red o servidor HTTP es mapeado a un objeto de error estructurado con mensaje amigable.
  - Criterio: Los logs de red ofuscan automáticamente headers de autorización e información sensible.

## Comunicación en Tiempo Real

- [ ] **Gestor de WebSockets para estados de viaje y posición** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: La conexión WebSocket conmuta dinámicamente entre ws:// en ambiente local y wss:// en staging/producción.
  - Criterio: El cliente WebSocket se reconecta de manera transparente tras una desconexión accidental de red.

## Cliente de Red REST

- [ ] **Cliente HTTP Dio con interceptores de seguridad e idempotencia** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión
  - Criterio: Todas las peticiones HTTP salientes incluyen el encabezado Authorization Bearer cuando existe un token activo.
  - Criterio: Las peticiones POST de creación u oferta de viajes generan un UUIDv4 único en el header Idempotency-Key.

## Persistencia y Almacenamiento Seguro

- [ ] **Configuración de almacenamiento seguro para tokens y sesión** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: Los tokens JWT y datos sensibles de sesión se persisten utilizando Flutter Secure Storage (Keychain en iOS / Keystore en Android).
  - Criterio: Se proporciona un método clearSession() que remueve completamente los tokens en el logout sin dejar residuos.

## Onboarding de Usuario

- [ ] **Flujo de Registro y Selección de Rol** (pendiente)
  - Depende de: Data Source y Repositorio de Autenticación (Firebase + Backend), Pantalla de Login con validación inteligente
  - Criterio: Rechazo del registro en el formulario cuando no se ha seleccionado un rol (PASAJERO o CONDUCTOR).
  - Criterio: Creación exitosa de cuenta e iniciación de sesión automática tras un registro válido en el backend.

## Enrutamiento por Rol

- [ ] **Protección de rutas y redirección por Rol** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Enrutamiento base con GoRouter y vista de salud/diagnóstico
  - Criterio: Redirección de un usuario autenticado con rol PASAJERO a /client/home e imposibilidad de acceder a /driver/*.
  - Criterio: Redirección de un usuario no autenticado a la pantalla de login al intentar ingresar a cualquier ruta protegida.

## Autenticación de Pasajeros y Conductores

- [ ] **Pantalla de Login con validación inteligente** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Protección de rutas y redirección por Rol
  - Criterio: Manejo visual de errores de credenciales con mensajes entendibles para el usuario sin mostrar excepciones ni trazas del backend.
  - Criterio: Deshabilitar el botón de login y mostrar indicador de carga visual durante la llamada asíncrona de autenticación.
- [ ] **Data Source y Repositorio de Autenticación (Firebase + Backend)** (pendiente)
  - Depende de: Modelado de entidades de Usuario y Contrato de Auth, Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: Intercambio exitoso del idToken de Firebase con la API de Spring Boot obteniendo el JWT de sesión.
  - Criterio: Almacenamiento seguro del token JWT recibido en SecureStorageService tras la respuesta exitosa del servidor.
- [ ] **Modelado de entidades de Usuario y Contrato de Auth** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: Mapeo unitario del DTO AuthResponse con campos id, email, role, token y refreshToken comprobando sound null safety.
  - Criterio: Validación de tipos de rol válidos (PASAJERO, CONDUCTOR) rechazando valores no reconocidos.

## Gestión de Estado de Sesión

- [ ] **Cierre de sesión y limpieza de datos** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Protección de rutas y redirección por Rol
  - Criterio: Eliminación completa de los tokens en Flutter Secure Storage al ejecutar el evento de Logout.
  - Criterio: Redirección inmediata de la UI a la pantalla de login tras el cierre de sesión exitoso.
- [ ] **SessionBloc: Gestión de estado global de la sesión** (pendiente)
  - Depende de: Data Source y Repositorio de Autenticación (Firebase + Backend)
  - Criterio: Transición automática a Authenticated cuando existe un token válido guardado en SecureStorageService.
  - Criterio: Transición a Unauthenticated cuando no hay token persistido o la sesión expiró.

## Como pasajero quiero ver visualmente en el mapa el recorrido de mi viaje y el costo aproximado antes de confirmar la solicitud.

- [ ] **Mapa de Previsualización de Ruta y Card de Estimación de Tarifa** (pendiente)
  - Depende de: Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones
  - Criterio: M4.T5-C1: El componente route_map_preview renderiza los marcadores de origen y destino y ajusta los límites de la cámara según los puntos extremos de la ruta.
  - Criterio: M4.T5-C2: fare_estimate_card muestra el desglose de distancia, duración y precio estimado, mostrando un spinner o skeleton si la tarifa está calculándose.
  - Criterio: M4.T5-C3: Al presionar 'Confirmar ruta' con origen, destino y ruta válidos, se invoca el callback o navegación hacia el flujo de confirmación/solicitud.
  - Criterio: M4.T5-C4: En caso de error de cálculo de ruta, la tarjeta muestra mensaje explicativo con botón para reintentar sin cerrar la vista.

## Como pasajero quiero una gestión de estado rápida y sin congelamientos que busque ubicaciones mientras escribo y actualice mi ruta de viaje.

- [ ] **LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino** (pendiente)
  - Depende de: Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)
  - Criterio: M4.T3-C1: Las emisiones repetidas de SearchQueryChanged en menos de 300ms ejecutan una única llamada al repositorio debido al debounce.
  - Criterio: M4.T3-C2: Al emitir SwapLocations con origen y destino cargados, se intercambian las posiciones y se recalcula la ruta.
  - Criterio: M4.T3-C3: Si la búsqueda no arroja coincidencias, el estado emite predictions vacía y bandera hasNoResults en verdadero.
  - Criterio: M4.T3-C4: Cuando ambos puntos (origen y destino) están seleccionados, se transiciona a estado isCalculatingRoute y luego a routeReady con routeInfo y fareEstimate.

## Como pasajero quiero ver la ruta entre origen y destino y saber la estimación preliminar del costo de mi viaje antes de solicitarlo.

- [ ] **Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)** (pendiente)
  - Depende de: Modelado y Repositorio de Autocompletado de Lugares (Places API)
  - Criterio: M4.T2-C1: DirectionsRepositoryImpl decodifica cadenas de polilínea en listas de LatLng sin pérdida de precisión de coordenadas.
  - Criterio: M4.T2-C2: estimateFare calcula el importe total en base a distancia y tiempo aplicando tarifa base con redondeo a dos decimales.
  - Criterio: M4.T2-C3: Si el servicio de rutas devuelve un error de ruta no transitable, el repositorio retorna RouteNotFoundFailure manejado.

## Como pasajero quiero obtener sugerencias de lugares mientras escribo para seleccionar mi origen y destino de manera rápida.

- [ ] **Modelado y Repositorio de Autocompletado de Lugares (Places API)** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M4.T1-C1: PlacePredictionDto deserializa correctamente un JSON de autocompletado y maneja campos secundarios ausentes con fallback seguro.
  - Criterio: M4.T1-C2: PlacesRepositoryImpl retorna lista de predicciones en llamadas exitosas y mapea códigos HTTP 4xx/5xx a fallos tipados ServerFailure.
  - Criterio: M4.T1-C3: Se sanitizan consultas vacías o con puros espacios retornando lista vacía sin emitir petición HTTP.

## Como pasajero quiero escribir mi origen y destino en campos limpios y accesibles con soporte visual para intercambiarlos con un toque.

- [ ] **Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones** (pendiente)
  - Depende de: LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino
  - Criterio: M4.T4-C1: Los inputs de origen y destino y el botón de swap tienen un área táctil mínima de 44x44 dp y etiquetas Semantics válidas.
  - Criterio: M4.T4-C2: Mientras se obtienen las sugerencias se muestra el skeleton loader, y si no hay resultados se muestra el widget de estado vacío.
  - Criterio: M4.T4-C3: Al presionar una predicción se selecciona el lugar y el input correspondiente refleja el nombre del lugar elegido.

## Como pasajero, quiero ver el progreso de mi solicitud en tiempo real sin recargar la pantalla.

- [ ] **Integración de WebSocket para Actualizaciones en Tiempo Real** (pendiente)
  - Depende de: PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje, Gestor de WebSockets para estados de viaje y posición
  - Criterio: La suscripción al tópico del viaje se realiza tras la creación exitosa del viaje.
  - Criterio: Los eventos del socket provocan transiciones de estado en el PassengerTripBloc.

## Como pasajero, quiero saber que el sistema está buscando un conductor para mí.

- [ ] **Pantalla de Búsqueda de Conductor y Espera** (pendiente)
  - Depende de: Integración de WebSocket para Actualizaciones en Tiempo Real, Mapa de Previsualización de Ruta y Card de Estimación de Tarifa
  - Criterio: La pantalla muestra el estado de búsqueda mientras el viaje está en SOLICITADO.
  - Criterio: El botón de cancelar detiene el proceso y vuelve a la pantalla de inicio.

## Como pasajero, quiero ver dónde está mi conductor y seguir el trayecto en el mapa.

- [ ] **Seguimiento de Viaje en Mapa en Tiempo Real** (pendiente)
  - Depende de: Integración de WebSocket para Actualizaciones en Tiempo Real, Pantalla de Búsqueda de Conductor y Espera
  - Criterio: El icono del conductor se mueve en el mapa al recibir coordenadas por WebSocket.
  - Criterio: La información del vehículo y conductor es visible y correcta.

## Como pasajero, quiero que la app represente fielmente la información de mi viaje según el backend.

- [ ] **Modelado de Entidades y Contratos de Viaje para Pasajero** (pendiente)
  - Depende de: Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: La entidad Trip contiene todos los campos necesarios según el esquema tb_trips.
  - Criterio: El TripModel realiza la conversión de JSON correctamente respetando tipos de datos y nulos.

## Como pasajero, quiero solicitar viajes de forma segura sin duplicar solicitudes por fallos de red.

- [ ] **Repositorio de Viajes y DataSource con Idempotencia** (pendiente)
  - Depende de: Modelado de Entidades y Contratos de Viaje para Pasajero, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: La petición POST a /trips incluye el header Idempotency-Key.
  - Criterio: El repositorio lanza ActiveTripException cuando el backend devuelve 409.

## Como pasajero, quiero calificar mi experiencia al terminar el viaje.

- [ ] **Finalización de Viaje y Calificación del Conductor** (pendiente)
  - Depende de: Seguimiento de Viaje en Mapa en Tiempo Real
  - Criterio: El diálogo de calificación aparece inmediatamente al finalizar el viaje.
  - Criterio: La llamada de calificación envía los datos correctos y gestiona errores de red.

## Como equipo de desarrollo, quiero asegurar que el flujo principal del pasajero funciona de punta a punta.

- [ ] **Test de Integración: Flujo Completo del Pasajero** (pendiente)
  - Depende de: Finalización de Viaje y Calificación del Conductor
  - Criterio: El flujo completo se ejecuta sin errores de navegación ni pérdida de estado.
  - Criterio: Se verifica que no hay fugas de memoria al cerrar los sockets al final del flujo.

## Como pasajero, mi app debe controlar lógicamente en qué fase del viaje me encuentro.

- [ ] **PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje** (pendiente)
  - Depende de: Repositorio de Viajes y DataSource con Idempotencia, SessionBloc: Gestión de estado global de la sesión
  - Criterio: El Bloc bloquea nuevas solicitudes si ya existe un viaje en curso en el estado.
  - Criterio: El Bloc emite FailureState ante errores de red o idempotencia.

## Finalización y calificación de clientes

- [ ] **Flujo de Finalización de Viaje y Calificación del Pasajero** (pendiente)
  - Depende de: Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje
  - Criterio: T8-C1: Envío de calificación ejecuta llamada REST y transiciona a estado disponible
  - Criterio: T8-C2: Diálogo muestra resumen financiero de tarifa y desglosa el pago completado

## Lógica de estado y orquestación del conductor

- [ ] **DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje** (pendiente)
  - Depende de: DataSource y Repositorio de Conductor con filtrado por Cooperativa, Servicio de Geolocalización y Transmisión de Posición por WebSocket
  - Criterio: T4-C1: Máquina de estados rechaza saltos no secuenciales de estado de viaje
  - Criterio: T4-C2: DriverTripBloc pasa a DriverOnlineWaiting al activar disponibilidad geográfica

## Modelado de datos del conductor

- [ ] **Modelos y contratos del dominio para operaciones del conductor** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: T1-C1: DriverTrip modela los estados válidos de viaje según el contrato backend
  - Criterio: T1-C2: TripOffer valida obligatoriamente que cooperativaId no sea nulo ni vacío

## Validación integral del flujo del conductor

- [ ] **Prueba de Integración E2E: Ciclo de Vida Completo del Conductor** (pendiente)
  - Depende de: Flujo de Finalización de Viaje y Calificación del Pasajero
  - Criterio: T9-C1: Flujo E2E completo del conductor se ejecuta sin errores respetando la secuencia del ciclo
  - Criterio: T9-C2: Verificación visual y fluidez de transiciones en dispositivo o emulador

## Interfaz principal y disponibilidad del conductor

- [ ] **Pantalla Principal del Conductor y Panel de Disponibilidad** (pendiente)
  - Depende de: Protección de rutas y redirección por Rol, DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje
  - Criterio: T5-C1: Switch de disponibilidad cambia estado reactivo y muestra feedback visual
  - Criterio: T5-C2: Indicador de cooperativa muestra el nombre correspondiente obtenido del perfil autenticado

## Integración de datos de viajes del conductor

- [ ] **DataSource y Repositorio de Conductor con filtrado por Cooperativa** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, SessionBloc: Gestión de estado global de la sesión, Modelos y contratos del dominio para operaciones del conductor
  - Criterio: T2-C1: Filtrado estricto descarta ofertas que no pertenecen a la cooperativa del conductor
  - Criterio: T2-C2: Transiciones REST envían id de conductor y token en cabeceras HTTP

## Telemetría y disponibilidad GPS del conductor

- [ ] **Servicio de Geolocalización y Transmisión de Posición por WebSocket** (pendiente)
  - Depende de: Gestor de WebSockets para estados de viaje y posición, Modelos y contratos del dominio para operaciones del conductor
  - Criterio: T3-C1: Posición GPS se transmite al canal WebSocket con formato JSON esperado por el backend
  - Criterio: T3-C2: Manejo de errores sin conexión almacena la última posición y reanuda el envío al reconectar

## Gestión de solicitudes entrantes

- [ ] **Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar)** (pendiente)
  - Depende de: DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje, Pantalla Principal del Conductor y Panel de Disponibilidad
  - Criterio: T6-C1: Botón Aceptar dispara evento de aceptación en DriverTripBloc y cierra modal
  - Criterio: T6-C2: Expiración del temporizador ejecuta rechazo automático de la solicitud

## Navegación y controles durante el viaje

- [ ] **Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje** (pendiente)
  - Depende de: Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API), DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje, Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar)
  - Criterio: T7-C1: Botón de acción principal muta de acuerdo con el estado secuencial del viaje
  - Criterio: T7-C2: Pérdida temporal de red no resetea la pantalla y muestra alerta de reconexión

## Historial y Perfil - Lógica de Estado de Historial

- [ ] **TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados** (pendiente)
  - Depende de: Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: TripHistoryBloc emite TripHistoryLoading y luego TripHistoryLoaded con la lista inicial al recibir LoadTripHistory.
  - Criterio: El evento LoadMoreTrips concatena la siguiente página de viajes sin duplicar registros ya existentes.
  - Criterio: El evento LoadTripDetail carga correctamente la información extendida de viajes COMPLETADO o CANCELADO.

## Historial y Perfil - Enrutamiento y Navegación

- [ ] **Integración en Rutas y Menú de Navegación para Pasajero y Conductor** (pendiente)
  - Depende de: Protección de rutas y redirección por Rol, Pantalla y componentes de Listado de Historial de Viajes con paginación, Pantalla de Detalle de Viaje Pasado (Completed / Cancelled), Pantalla de Perfil de Usuario y Edición de Datos
  - Criterio: La ruta /trips/history es navegable tanto desde el menú del pasajero como desde el menú del conductor con sus respectivos permisos.
  - Criterio: La ruta /trips/:id navega a TripDetailScreen cargando el viaje especificado por parámetro.
  - Criterio: El acceso a /profile permite consultar y actualizar datos desde ambos flujos de rol.

## Historial y Perfil - UI de Perfil de Usuario

- [ ] **Pantalla de Perfil de Usuario y Edición de Datos** (pendiente)
  - Depende de: Cierre de sesión y limpieza de datos, ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario
  - Criterio: ProfileScreen visualiza correctamente la información de usuario distinguiendo entre campos editables y no editables.
  - Criterio: EditProfileModal valida teléfono y nombre antes de permitir el envío del formulario.
  - Criterio: El botón de cerrar sesión invoca el evento de desautenticación en SessionBloc y limpia la sesión.

## Historial y Perfil - UI de Detalle de Viaje

- [ ] **Pantalla de Detalle de Viaje Pasado (Completed / Cancelled)** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: TripDetailScreen renderiza el desglose completo de cobro/pago, estado final y participantes del viaje.
  - Criterio: Si el viaje tiene estado CANCELADO, la pantalla muestra la razón de cancelación y ajusta el desglose financiero acorde.
  - Criterio: TripRatingDisplayWidget muestra la calificación por estrellas y comentario si existen para el viaje.

## Historial y Perfil - UI de Historial de Viajes

- [ ] **Pantalla y componentes de Listado de Historial de Viajes con paginación** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: TripHistoryScreen muestra skeleton loading mientras se cargan los viajes y renderiza TripSummaryCards al completarse.
  - Criterio: Hacer scroll al final de la lista dispara la solicitud de la página siguiente al bloc.
  - Criterio: Si el usuario no tiene viajes registrados, se presenta EmptyTripHistoryWidget con mensaje descriptivo y acción de solicitar viaje.

## Historial y Perfil - Lógica de Estado de Perfil

- [ ] **ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario** (pendiente)
  - Depende de: SessionBloc: Gestión de estado global de la sesión, Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: ProfileBloc carga los datos del usuario autenticado emitiendo ProfileLoaded ante LoadUserProfile.
  - Criterio: ProfileBloc valida los datos modificados y emite ProfileUpdateSuccess tras confirmación del repositorio.
  - Criterio: Cualquier error de autorización o fallo de red emite ProfileError sin corromper el estado anterior del perfil.

## Historial y Perfil - Capa de Datos y Repositorios

- [ ] **Data Sources y Repositorios de Historial de Viajes y Perfil** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil
  - Criterio: TripHistoryRemoteDataSource realiza peticiones GET paginadas incluyendo query params page y size con Bearer token en headers.
  - Criterio: ProfileRemoteDataSource obtiene y actualiza el perfil del usuario autenticado sin filtrar datos de terceros.
  - Criterio: Los repositorios convierten excepciones de red o HTTP 403/404 en fallos de dominio tipados (TripNotFoundFailure, UnauthorizedAccessFailure).

## Historial y Perfil - Modelado y Contratos de Dominio

- [ ] **Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: Las entidades TripDetail y TripSummary modelan con precisión estados finales COMPLETADO y CANCELADO, métricas de tarifa, fechas y datos de calificación.
  - Criterio: La entidad PaginatedTrips encapsula la lista de viajes, página actual, total de páginas y si existen páginas subsecuentes.
  - Criterio: UserProfile modela nombre, teléfono, correo, rol y avatar sin exponer campos confidenciales o no autorizados.

## Seguridad y Salud del Repositorio

- [ ] **Auditoría de seguridad y depuración de dependencias en pubspec** (pendiente)
  - Depende de: Test de Integración: Flujo Completo del Pasajero, Prueba de Integración E2E: Ciclo de Vida Completo del Conductor, Integración en Rutas y Menú de Navegación para Pasajero y Conductor
  - Criterio: T1-C1: El archivo pubspec.lock no contiene dependencias con vulnerabilidades de severidad alta o crítica según el análisis de seguridad de dependencias.
  - Criterio: T1-C2: Se eliminan todas las dependencias directas no utilizadas en el código fuente de lib/.
  - Criterio: T1-C3: Todas las dependencias son estrictamente compatibles con Dart SDK >=3.12.0 <4.0.0 y Flutter 3.44 sin advertencias de deprecación críticas.

## Resiliencia Offline y Red

- [ ] **Servicio de conectividad de red reactivo y banner de desconexión/reconexión** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: T4-C1: Al detectarse pérdida de conectividad a internet, se emite el estado offline y la interfaz muestra el banner visible de desconexión.
  - Criterio: T4-C2: Al restablecerse la conexión de red, el banner muestra estado de reconexión y se oculta tras confirmar enlace activo.
  - Criterio: T4-C3: Las peticiones fallidas por timeout o falta de red durante un intento de sincronización no borran el estado local de formularios de solicitud de viaje.

## Calidad y Mantenibilidad del Código

- [ ] **Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec
  - Criterio: T2-C1: flutter analyze no reporta ningún aviso de unused_element, unused_import ni dead_code en todo el directorio lib/ ni test/.
  - Criterio: T2-C2: No existen archivos dart no referenciados ni blocs antiguos sin registro en dependency_injection.dart ni consumo en rutas.
  - Criterio: T2-C3: Los modelos de datos y endpoints en lib/features/trips/ y lib/features/auth/ coinciden exactamente con los contratos SSOT del backend sin restos de payloads legacy.

## Observabilidad y Manejo Seguro de Errores

- [ ] **Servicio de reporte de fallos y sanitización de registros de error** (pendiente)
  - Depende de: Servicio de conectividad de red reactivo y banner de desconexión/reconexión
  - Criterio: T5-C1: Las excepciones no controladas de Flutter y de la plataforma son capturadas por el servicio centralizado sin provocar caídas silenciosas de la aplicación.
  - Criterio: T5-C2: Los registros y trazas de error enviados al servicio de reporte son sanitizados, reemplazando tokens JWT, passwords y credenciales con máscaras.
  - Criterio: T5-C3: Las excepciones de aplicación se presentan al usuario mediante mensajes comprensibles y con opciones de reintento, sin exhibir trazas internas de error.

## Accesibilidad Universal

- [ ] **Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: T3-C1: Todos los botones, iconos de interacción y campos de entrada en las pantallas principales cumplen con el tamaño mínimo de pulsación táctil (44x44 dp).
  - Criterio: T3-C2: Todos los controles interactivos y estados informativos cuentan con etiquetas Semantics válidas para lectores de pantalla.
  - Criterio: T3-C3: Las combinaciones de color de texto y fondo en tokens de diseño cumplen el ratio de contraste mínimo 4.5:1.

## Como QA, quiero ejecutar una suite de pruebas de humo sobre dispositivos reales y emuladores para garantizar la estabilidad release.

- [ ] **Suite de verificación de smoke testing en emulador y validación en dispositivos reales** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release
  - Criterio: Ejecución exitosa de test/integration/flows/release_smoke_test.dart en emulador headless sin fallos en el runner de Flutter.
  - Criterio: Probar la compilación de release firmada en al menos un teléfono Android real y un iPhone real, verificando fluidez visual, conexión de socket y GPS.

## Como usuario de Ando-UI, quiero identificar visualmente la aplicación en la pantalla de inicio de mi dispositivo y ver una pantalla de carga nativa adecuada al abrirla.

- [ ] **Configuración de App Launcher Icons y Native Splash Screen para Android e iOS** (pendiente)
  - Depende de: Servicio de reporte de fallos y sanitización de registros de error
  - Criterio: Verificar la presencia y estructura de los archivos de íconos y splash screen generados en android/app/src/main/res/ y ios/Runner/Assets.xcassets.
  - Criterio: Verificar visualmente en emulador/dispositivo Android e iOS que el ícono de la app se muestra correctamente alineado y el splash screen nativo se despliega sin distorsiones.

## Como usuario, quiero entender por qué la aplicación solicita permisos de ubicación o notificación antes de concederlos.

- [ ] **Declaración y justificación contextual de permisos móviles mínimos en Android e iOS** (pendiente)
  - Depende de: Configuración de App Launcher Icons y Native Splash Screen para Android e iOS
  - Criterio: Comprobar que el servicio de permisos de la app solo solicita permisos declarados en la lista blanca de producción.
  - Criterio: Probar en dispositivo iOS y Android que al pulsar sobre la búsqueda de viajes o activación de conductor aparece el diálogo explicativo antes de la solicitud de sistema.

## Como equipo de DevOps/Despliegue, quiero exportar un paquete iOS Archive (.ipa) firmado para la distribución en TestFlight y App Store.

- [ ] **Configuración de compilación para iOS Archive y exportación de release** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release
  - Criterio: Verificar mediante test de integración de CI la generación del archivo ipa o archive en build/ios/archive/Runner.xcarchive sin credenciales hardcodeadas.
  - Criterio: Cargar el paquete generado a TestFlight a través de Transporter o Xcode Organizer y comprobar que supera las validaciones automáticas de Apple.

## Como desarrollador, quiero asegurar que el esquema de base de datos local SQLite y migraciones coincida exactamente con la memoria del proyecto.

- [ ] **Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT** (pendiente)
  - Depende de: Suite de verificación de smoke testing en emulador y validación en dispositivos reales
  - Criterio: Ejecutar test/unit/database/schema_validation_test.dart comprobando la versión de esquema, creación limpia de tablas y ejecución idempotente de migraciones.
  - Criterio: Simular una actualización de base de datos en la app migrando datos antiguos y comprobando que no se pierden sesiones ni historial guardado.

## Como desarrollador o administrador, quiero seguir una guía paso a paso para compilar, probar y desplegar la app en producción.

- [ ] **Documentación exhaustiva de despliegue y distribución en DEPLOY.md** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release
  - Criterio: Test de documentación que escanea DEPLOY.md verificando la presencia de las secciones obligatorias: Prerequisites, Environment Variables, Android Release, iOS Release, Rollback Procedure, Backup/Restore.
  - Criterio: Leer la guía DEPLOY.md y ejecutar paso a paso en una máquina limpia los comandos descritos verificando su correcto funcionamiento.

## Como equipo de DevOps/Despliegue, quiero generar un artefacto Android App Bundle (AAB) firmado para la distribución en Google Play Store.

- [ ] **Configuración de compilación firmada Android (AAB) y scripts de release** (pendiente)
  - Depende de: Declaración y justificación contextual de permisos móviles mínimos en Android e iOS
  - Criterio: Ejecutar script de validación de compilación que verifique la generación exitosa del paquete AAB firmado en build/app/outputs/bundle/release/app-release.aab.
  - Criterio: Inspeccionar el archivo AAB generado e intentar su instalación preliminar mediante bundletool para asegurar que la firma es válida.

## Como usuario, quiero acceder a la política de privacidad de Ando desde la app para conocer el tratamiento de mis datos personales.

- [ ] **Integración de Política de Privacidad dentro de la app y pantalla informativa** (pendiente)
  - Depende de: Declaración y justificación contextual de permisos móviles mínimos en Android e iOS
  - Criterio: Test de widget que comprueba la renderización de PrivacyPolicyScreen, presencia de títulos y enlaces legales sin errores de navegación.
  - Criterio: Acceder desde el menú de usuario a la política de privacidad y comprobar que la información es legible y cumple con los requerimientos de divulgación de datos de las tiendas.

## Como responsable de calidad del código, quiero garantizar que la rama principal de producción no contenga código muerto, archivos temporales ni dependencias obsoletas.

- [ ] **Limpieza final de versión y depuración de código muerto y dependencias** (pendiente)
  - Depende de: Configuración de App Launcher Icons y Native Splash Screen para Android e iOS, Declaración y justificación contextual de permisos móviles mínimos en Android e iOS, Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release, Integración de Política de Privacidad dentro de la app y pantalla informativa, Documentación exhaustiva de despliegue y distribución en DEPLOY.md, Suite de verificación de smoke testing en emulador y validación en dispositivos reales, Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT
  - Criterio: Ejecución de flutter analyze y test/security/dead_code_audit_test.dart reportando 0 advertencias y sin dependencias no utilizadas.
  - Criterio: Test de integración CI que realiza un build limpio desatendido y verifica que el repositorio no tiene archivos sin seguimiento ni sobrantes tras la compilación.
