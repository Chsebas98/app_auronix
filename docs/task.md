# Tareas — Ando-UI

Plan de implementación generado por Mnemosine. El estado vivo de cada tarea está en Mnemosine;
este archivo es una foto del plan en el momento de la última publicación.

## Configuración inicial de arquitectura y UI

- [ ] **Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design** (pendiente)
  - Criterio: La estructura de carpetas en lib/app, lib/features y lib/shared respeta la jerarquía Feature-First y Atomic Design.
  - Criterio: AppTheme proporciona esquemas de color claro y oscuro conformes a Material 3.

## Infraestructura de software y configuración

- [ ] **Configuración multi-ambiente e inyección de dependencias con GetIt** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design
  - Criterio: EnvironmentConfig carga correctamente los valores y URLs base según el ambiente seleccionado (local, dev, prod).
  - Criterio: setupDependencyInjection registra e inicializa los servicios base en el contenedor GetIt sin lanzar excepciones.

## Navegación y diagnóstico

- [ ] **Enrutamiento base con GoRouter y vista de salud/diagnóstico** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: El enrutador navega correctamente a la ruta de salud /health.
  - Criterio: HealthPage muestra el estado del ambiente activo y la versión del sistema.

## DevOps y Documentación

- [ ] **Pipeline de integración continua (CI) y documentación README** (pendiente)
  - Depende de: Enrutamiento base con GoRouter y vista de salud/diagnóstico
  - Criterio: El flujo de CI en .github/workflows/ci.yml ejecuta flutter analyze, dart format y flutter test en cada PR y push a la rama principal.
  - Criterio: El archivo README.md incluye la descripción del proyecto, guía de instalación, configuración de ambientes y ejecución de tests.

## Como desarrollador, necesito un cliente HTTP que gestione automáticamente la seguridad y la idempotencia según los contratos del backend.

- [ ] **Cliente HTTP Dio con interceptores de seguridad e idempotencia** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión
  - Criterio: M2.T2-C1: Todas las peticiones salientes incluyen la cabecera Authorization si existe un token en el storage.
  - Criterio: M2.T2-C2: Las peticiones POST incluyen una cabecera 'Idempotency-Key' con un formato UUID válido.

## Como usuario, quiero mensajes claros cuando hay problemas de red en lugar de que la app se cierre o quede bloqueada.

- [ ] **Manejo estructurado de errores y logs de red** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M2.T4-C1: Las respuestas 401 del backend disparan automáticamente el flujo de limpieza de sesión local.
  - Criterio: M2.T4-C2: Los errores del servidor se registran con el código de error y el mensaje sin exponer trazas internas a la UI.

## Como sistema, necesito guardar el JWT de forma segura para no obligar al usuario a loguearse tras cerrar la app.

- [ ] **Configuración de almacenamiento seguro para tokens y sesión** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M2.T1-C1: El servicio guarda y recupera un valor de prueba cifrado en el llavero del sistema (Keychain/Keystore).
  - Criterio: M2.T1-C2: El método de borrado elimina todas las claves relacionadas con la sesión durante el cierre de sesión.

## Como usuario, quiero poder ver mi perfil y viajes recientes aunque pierda la conexión a internet momentáneamente.

- [ ] **Persistencia local con Sqflite para caché y modo offline** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design
  - Criterio: M2.T5-C1: La base de datos se inicializa correctamente y permite operaciones CRUD básicas.
  - Criterio: M2.T5-C2: El sistema maneja el versionado y la ejecución de scripts de migración sin pérdida de datos.

## Como usuario, quiero ver cambios en el estado de mi viaje y la posición del conductor sin refrescar manualmente.

- [ ] **Gestor de WebSockets para estados de viaje y posición** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M2.T3-C1: El cliente WebSocket se conecta exitosamente al endpoint de STOMP del backend enviando el JWT de autenticación.
  - Criterio: M2.T3-C2: El sistema reintenta la conexión automáticamente tras una pérdida de red con backoff exponencial.

## Como nuevo usuario, quiero registrarme y elegir si voy a ser pasajero o conductor.

- [ ] **Flujo de Registro y Selección de Rol** (pendiente)
  - Depende de: Pantalla de Login con validación inteligente
  - Criterio: M3.T5-C1: El registro envía el campo 'role' correcto al backend tras la creación exitosa en Firebase.
  - Criterio: M3.T5-C2: No se permite avanzar en el registro sin haber seleccionado un rol.

## Como sistema, debo asegurar que cada rol vea únicamente su interfaz correspondiente.

- [ ] **Protección de rutas y redirección por Rol** (pendiente)
  - Depende de: Enrutamiento base con GoRouter y vista de salud/diagnóstico, SessionBloc: Gestión de estado global de la sesión
  - Criterio: M3.T6-C1: Al intentar acceder a una ruta de pasajero siendo conductor, el router bloquea el acceso o redirige correctamente.
  - Criterio: M3.T6-C2: Un usuario no logueado es enviado a /login al intentar abrir cualquier ruta privada.

## Como sistema, necesito modelos de datos claros para manejar la identidad del usuario.

- [ ] **Modelado de entidades de Usuario y Contrato de Auth** (pendiente)
  - Depende de: Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design
  - Criterio: M3.T1-C1: El modelo UserData deserializa correctamente un JSON con uuid, email y role (PASAJERO/CONDUCTOR).
  - Criterio: M3.T1-C2: Los roles están tipados como un Enum estricto en Dart (UserRole.pasajero, UserRole.conductor).

## Como usuario, quiero que mis credenciales se validen contra Firebase y se vinculen con mi cuenta de Ando.

- [ ] **Data Source y Repositorio de Autenticación (Firebase + Backend)** (pendiente)
  - Depende de: Configuración de almacenamiento seguro para tokens y sesión, Cliente HTTP Dio con interceptores de seguridad e idempotencia, Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: M3.T2-C1: La llamada al repositorio devuelve el JWT del backend tras un login exitoso en Firebase.
  - Criterio: M3.T2-C2: El JWT recibido se persiste en Flutter Secure Storage tras la autenticación.

## Como desarrollador, necesito un estado global que me diga quién está logueado y qué rol tiene.

- [ ] **SessionBloc: Gestión de estado global de la sesión** (pendiente)
  - Depende de: Data Source y Repositorio de Autenticación (Firebase + Backend)
  - Criterio: M3.T3-C1: El estado cambia a Authenticated y expone el objeto User al recibir un token válido.
  - Criterio: M3.T3-C2: El estado cambia a Unauthenticated si no hay token o la verificación falla.

## Como usuario, quiero poder cerrar mi sesión de forma segura y borrar mis datos del dispositivo.

- [ ] **Cierre de sesión y limpieza de datos** (pendiente)
  - Depende de: Persistencia local con Sqflite para caché y modo offline, SessionBloc: Gestión de estado global de la sesión
  - Criterio: M3.T7-C1: Tras el logout, el token JWT desaparece del almacenamiento seguro.
  - Criterio: M3.T7-C2: La aplicación redirige a la pantalla de Login y no permite volver atrás a la pantalla privada.

## Como usuario, quiero una interfaz clara para ingresar a la aplicación.

- [ ] **Pantalla de Login con validación inteligente** (pendiente)
  - Depende de: Enrutamiento base con GoRouter y vista de salud/diagnóstico, SessionBloc: Gestión de estado global de la sesión
  - Criterio: M3.T4-C1: El botón de login se deshabilita mientras los campos no cumplen el formato (email válido, pass > 6 car).
  - Criterio: M3.T4-C2: Se muestra un mensaje de error legible si el backend o Firebase rechazan las credenciales.

## Como pasajero, quiero conocer la distancia, duración y costo estimado de mi viaje antes de solicitarlo.

- [ ] **Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)** (pendiente)
  - Depende de: Modelado y Repositorio de Autocompletado de Lugares (Places API)
  - Criterio: M4.T2-C1: DirectionsRepositoryImpl calcula la distancia, el tiempo y la polilínea codificada entre dos puntos geográficos.
  - Criterio: M4.T2-C2: EstimateFareUseCase retorna el precio estimado calculado según la distancia y duración provistas.

## Como pasajero, quiero ingresar o intercambiar origen y destino de forma cómoda y clara en la pantalla.

- [ ] **Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones** (pendiente)
  - Depende de: LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino
  - Criterio: M4.T4-C1: LocationPickerPage renderiza el skeleton loader mientras se realiza la consulta de autocompletado.
  - Criterio: M4.T4-C2: Al presionar el botón de intercambio, las descripciones y datos de origen y destino invierten sus posiciones.
  - Criterio: M4.T4-C3: Comprobar visualmente que la lista de sugerencias resalta la coincidencia de texto ingresada y se adapta a pantallas pequeñas.

## Como pasajero, quiero ver el trazado de la ruta en el mapa y el valor estimado antes de confirmar la solicitud del viaje.

- [ ] **Mapa de Previsualización de Ruta y Card de Estimación de Tarifa** (pendiente)
  - Depende de: LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino, Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones
  - Criterio: M4.T5-C1: RoutePreviewMapWidget dibuja los marcadores de origen y destino y la polilínea recibida en sus propiedades.
  - Criterio: M4.T5-C2: FareEstimateCard muestra el monto estimado y el tiempo de viaje en minutos de manera clara.
  - Criterio: M4.T5-C3: Probar manualmente en emulador que el zoom del mapa se ajusta automáticamente para encuadrar la ruta completa al seleccionar origen y destino.

## Como pasajero, quiero una búsqueda interactiva y fluida de direcciones con estados claros de carga y error.

- [ ] **LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino** (pendiente)
  - Depende de: Modelado y Repositorio de Autocompletado de Lugares (Places API), Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API)
  - Criterio: M4.T3-C1: LocationSearchBloc emite estado con predicciones tras recibir el evento de cambio de texto superado el tiempo de debounce.
  - Criterio: M4.T3-C2: LocationSearchBloc emite estado de error comprensible cuando falla el servicio de direcciones o la conectividad.
  - Criterio: M4.T3-C3: LocationSearchBloc emite estado de resultados vacíos cuando la consulta de autocompletado no retorna coincidencias.

## Como pasajero, quiero buscar direcciones por texto para seleccionar mi punto de partida y de llegada.

- [ ] **Modelado y Repositorio de Autocompletado de Lugares (Places API)** (pendiente)
  - Depende de: Configuración multi-ambiente e inyección de dependencias con GetIt
  - Criterio: M4.T1-C1: El modelo PlacePrediction deserializa correctamente sugerencias desde el payload JSON de la API.
  - Criterio: M4.T1-C2: PlacesRepositoryImpl retorna una lista de predicciones dada una cadena de búsqueda válida.

## Como pasajero, quiero que la app mantenga el estado de mi viaje aunque cambie de pantalla o pierda conexión.

- [ ] **PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje** (pendiente)
  - Depende de: Repositorio de Viajes y DataSource con Idempotencia
  - Criterio: El Bloc emite TripSearchingState tras una solicitud exitosa.
  - Criterio: El Bloc emite TripErrorState con mensaje amigable si ya existe un viaje activo (409).

## Como pasajero, quiero saber que mi solicitud está siendo procesada y tener la opción de cancelarla.

- [ ] **Pantalla de Búsqueda de Conductor y Espera** (pendiente)
  - Depende de: PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje, Mapa de Previsualización de Ruta y Card de Estimación de Tarifa
  - Criterio: La pantalla muestra un indicador de carga visual mientras el estado es SOLICITADO.
  - Criterio: El botón 'Cancelar Viaje' invoca la acción correspondiente y regresa al Home.

## Como pasajero, quiero calificar mi experiencia una vez que el viaje ha terminado.

- [ ] **Finalización de Viaje y Calificación del Conductor** (pendiente)
  - Depende de: Seguimiento de Viaje en Mapa en Tiempo Real
  - Criterio: El formulario de calificación solo es visible si el estado del viaje es exactamente COMPLETADO.
  - Criterio: Se valida que la calificación sea obligatoria antes de permitir el envío.

## Como pasajero, quiero ver dónde viene mi conductor en el mapa para estar listo.

- [ ] **Seguimiento de Viaje en Mapa en Tiempo Real** (pendiente)
  - Depende de: Integración de WebSocket para Actualizaciones en Tiempo Real, Pantalla de Búsqueda de Conductor y Espera
  - Criterio: El marcador del conductor se mueve en el mapa sin saltos bruscos al recibir coordenadas.
  - Criterio: Se muestran los detalles del vehículo (placa, modelo) una vez el viaje está ACEPTADO.

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

## Como desarrollador, quiero asegurar que todo el flujo del pasajero es estable y resiliente.

- [ ] **Test de Integración: Flujo Completo del Pasajero** (pendiente)
  - Depende de: Finalización de Viaje y Calificación del Conductor
  - Criterio: El flujo completo desde solicitud hasta calificación se completa sin errores inesperados.
  - Criterio: La app muestra un aviso de 'Sin conexión' si se pierde la red durante el seguimiento del mapa.

## Como pasajero, quiero ver en tiempo real cuándo un conductor acepta mi viaje sin refrescar la pantalla.

- [ ] **Integración de WebSocket para Actualizaciones en Tiempo Real** (pendiente)
  - Depende de: PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje, Gestor de WebSockets para estados de viaje y posición
  - Criterio: El Bloc actualiza el estado del viaje automáticamente al recibir un mensaje del WebSocket.
  - Criterio: La app reconecta la suscripción al WebSocket si se pierde la conexión durante un viaje activo.

## Validación E2E Conductor

- [ ] **Prueba de Integración E2E: Ciclo de Vida Completo del Conductor** (pendiente)
  - Depende de: Pantalla Principal del Conductor y Panel de Disponibilidad, Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar), Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje, Flujo de Finalización de Viaje y Calificación del Pasajero
  - Criterio: T9-C1: El test de integración completa todo el ciclo secuencial del viaje del conductor desde disponibilidad hasta calificación final con backend/mock de integración.
  - Criterio: T9-C2: Verificar en emulador/dispositivo que la UI del conductor muestra adecuadamente los estados de reconexión y transiciones de viaje fluidas.

## Seguimiento GPS en Tiempo Real

- [ ] **Servicio de Geolocalización y Transmisión de Posición por WebSocket** (pendiente)
  - Depende de: Modelos y contratos del dominio para operaciones del conductor, Gestor de WebSockets para estados de viaje y posición
  - Criterio: T3-C1: Emitir coordenadas serializadas al WebSocket únicamente cuando el conductor se encuentre en estado disponible o con viaje activo.
  - Criterio: T3-C2: Manejar la denegación de permisos de ubicación emitiendo un fallo de dominio LocationPermissionDeniedException sin congelar la aplicación.

## Gestión de Operaciones del Conductor

- [ ] **DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje** (pendiente)
  - Depende de: DataSource y Repositorio de Conductor con filtrado por Cooperativa, Servicio de Geolocalización y Transmisión de Posición por WebSocket
  - Criterio: T4-C1: Cambiar el estado a DriverTripInProgress únicamente tras recibir confirmación exitosa de StartTripRequested.
  - Criterio: T4-C2: Rechazar o descartar una solicitud tras timeout emitiendo DriverAvailable sin afectar el estado general de disponibilidad.
- [ ] **Modelos y contratos del dominio para operaciones del conductor** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, SessionBloc: Gestión de estado global de la sesión
  - Criterio: T1-C1: Validar que TripStatus rechaza transiciones ilegales que no respeten el orden secuencial (ej. ACEPTADO directo a COMPLETADO sin pasar por EN_CURSO).
  - Criterio: T1-C2: Comprobar que DriverTripRequest valida la correspondencia de cooperativeId y no permite campos obligatorios nulos.

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

## Aceptación de Solicitudes

- [ ] **Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar)** (pendiente)
  - Depende de: DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje, Pantalla Principal del Conductor y Panel de Disponibilidad
  - Criterio: T6-C1: El botón Aceptar dispara AcceptTripRequested y cierra el modal de oferta pasando a navegación en ruta.
  - Criterio: T6-C2: El botón Rechazar emite RejectTripRequested y descarta el modal de inmediato.

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

## Gestión de Historial y Perfil

- [ ] **ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario** (pendiente)
  - Depende de: Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: M7.T4-C1: ProfileFetchRequested recupera el perfil actual del usuario y emite ProfileLoaded.
  - Criterio: M7.T4-C2: ProfileUpdateSubmitted procesa la actualización y emite ProfileUpdateSuccess con los nuevos datos.
- [ ] **Pantalla y componentes de Listado de Historial de Viajes con paginación** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: M7.T5-C1: La pantalla renderiza el estado vacío TripHistoryEmptyState cuando la lista de viajes está vacía.
  - Criterio: M7.T5-C2: Al hacer scroll al final de la lista se despacha el evento para cargar la siguiente página.
  - Criterio: M7.T5-C3: Cada elemento renderiza fecha, dirección de origen/destino, tarifa formateada y badge de estado.
- [ ] **Pantalla de Detalle de Viaje Pasado (Completed / Cancelled)** (pendiente)
  - Depende de: TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados
  - Criterio: M7.T6-C1: La pantalla muestra todos los detalles del viaje completado incluyendo monto total, conductor/pasajero, cooperativa y rating.
  - Criterio: M7.T6-C2: Si el viaje fue cancelado, se ocultan datos de tarifa y calificación y se visualiza claramente el motivo de cancelación y el estado CANCELADO.
- [ ] **Pantalla de Perfil de Usuario y Edición de Datos** (pendiente)
  - Depende de: ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario
  - Criterio: M7.T7-C1: Los campos editables reflejan los valores iniciales del usuario y validan formato de teléfono antes del envío.
  - Criterio: M7.T7-C2: Al enviar cambios válidos, se invoca el evento de actualización y se muestra indicador de carga mientras procesa.
- [ ] **Integración en Rutas y Menú de Navegación para Pasajero y Conductor** (pendiente)
  - Depende de: Pantalla y componentes de Listado de Historial de Viajes con paginación, Pantalla de Detalle de Viaje Pasado (Completed / Cancelled), Pantalla de Perfil de Usuario y Edición de Datos, Protección de rutas y redirección por Rol
  - Criterio: M7.T8-C1: La ruta '/trips/history' y '/profile' son accesibles tanto para rol PASAJERO como CONDUCTOR.
  - Criterio: M7.T8-C2: La ruta '/trips/:id' abre TripDetailPage con el identificador de viaje proporcionado como parámetro.
- [ ] **Data Sources y Repositorios de Historial de Viajes y Perfil** (pendiente)
  - Depende de: Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil, Cliente HTTP Dio con interceptores de seguridad e idempotencia
  - Criterio: M7.T2-C1: TripHistoryRemoteDataSource invoca /api/v1/trips/history con parámetros de paginación y cabecera de autenticación JWT.
  - Criterio: M7.T2-C2: ProfileRepository actualiza los datos del usuario mediante PUT /api/v1/users/profile y retorna la entidad actualizada o propaga el fallo de dominio.
- [ ] **Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil** (pendiente)
  - Depende de: Cliente HTTP Dio con interceptores de seguridad e idempotencia, Modelado de entidades de Usuario y Contrato de Auth
  - Criterio: M7.T1-C1: Las entidades y modelos de TripSummary y UserProfile deserializan correctamente payloads de respuesta según el SSOT del backend.
  - Criterio: M7.T1-C2: Los campos de paginación (page, size, totalElements, totalPages, content) se mapean adecuadamente a TripHistoryPage.
- [ ] **TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados** (pendiente)
  - Depende de: Data Sources y Repositorios de Historial de Viajes y Perfil
  - Criterio: M7.T3-C1: El evento TripHistoryFetchRequested emite estados Loading y Loaded con los primeros elementos obtenidos.
  - Criterio: M7.T3-C2: El evento TripHistoryNextPageRequested concatena los nuevos resultados a la lista existente sin duplicar registros.
  - Criterio: M7.T3-C3: Los errores en la petición de historial emiten TripHistoryError con mensaje comprensible.

## Accesibilidad e Inclusión

- [ ] **Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T5-C1: Los botones y controles interactivos principales cuentan con nodos Semantics y etiquetas accesibles no vacías.
  - Criterio: M8.T5-C2: La paleta de colores del tema garantiza un contraste superior a 4.5:1 entre colores de texto y fondo en modo claro y oscuro.
  - Criterio: M8.T5-C3: Los campos de formulario y cards de estado de viaje exponen estados y roles semánticos correctos para lectores de pantalla.

## Resiliencia y Modo Sin Conexión

- [ ] **Servicio de conectividad de red reactivo y banner de desconexión/reconexión** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T3-C1: ConnectivityBloc emite estado desconectado al cesar la conectividad y estado conectado al restablecerse.
  - Criterio: M8.T3-C2: NetworkStatusBanner se renderiza informando pérdida de red cuando el estado es desconectado y desaparece con animación al reconectar.
  - Criterio: M8.T3-C3: Al volver la conexión, el gestor de red reintenta automáticamente la reconexión de sockets y peticiones pendientes.

## Limpieza y Cero Código Muerto

- [ ] **Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec
  - Criterio: M8.T2-C1: El analizador estático de Dart finaliza sin ningún warning, error o linter issue en todo el árbol de lib/ y test/.
  - Criterio: M8.T2-C2: Todos los archivos y clases huérfanas de versiones previas quedan completamente eliminados sin referencias rotas.

## Calidad y Seguridad de Dependencias

- [ ] **Auditoría de seguridad y depuración de dependencias en pubspec** (pendiente)
  - Depende de: Test de Integración: Flujo Completo del Pasajero, Prueba de Integración E2E: Ciclo de Vida Completo del Conductor, Integración en Rutas y Menú de Navegación para Pasajero y Conductor
  - Criterio: M8.T1-C1: pubspec.yaml contiene únicamente dependencias activas del proyecto sin paquetes heredados en desuso.
  - Criterio: M8.T1-C2: El comando de auditoría y análisis de paquetes finaliza exitosamente con código de salida 0 sin advertencias críticas ni incompatibilidades de versión.

## Monitoreo y Reporte Seguro de Fallos

- [ ] **Servicio de reporte de fallos y sanitización de registros de error** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: M8.T4-C1: CrashReportingService captura errores síncronos y asíncronos no manejados reportándolos a la plataforma de monitoreo configurada.
  - Criterio: M8.T4-C2: El sanitizador de errores elimina encabezados Authorization, tokens bearer y campos sensibles de los metadatos del crash.

## Seguridad y permisos de plataforma

- [ ] **Declaración y justificación contextual de permisos móviles mínimos en Android e iOS** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec
  - Criterio: AndroidManifest.xml e Info.plist contienen únicamente los permisos de geolocalización y red estrictamente requeridos.
  - Criterio: PermissionService maneja correctamente los estados granted, denied y permanentlyDenied sin lanzar excepciones no controladas.
  - Criterio: Las descripciones en Info.plist justifican el propósito de uso de ubicación de forma comprensible para el usuario.

## Identidad visual y branding nativo de la aplicación

- [ ] **Configuración de App Launcher Icons y Native Splash Screen para Android e iOS** (pendiente)
  - Depende de: Auditoría de seguridad y depuración de dependencias en pubspec, Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: Los archivos de configuración de flutter_launcher_icons y flutter_native_splash están definidos en pubspec.yaml con rutas válidas de assets.
  - Criterio: El nombre de visualización de la app está fijado a 'Ando' en AndroidManifest.xml e Info.plist.
  - Criterio: La pantalla de splash nativa y los iconos de la app se visualizan correctamente en Android e iOS sin deformaciones de aspecto.

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

## Control de calidad y verificación en dispositivos reales

- [ ] **Suite de verificación de smoke testing en emulador y validación en dispositivos reales** (pendiente)
  - Depende de: Configuración de compilación firmada Android (AAB) y scripts de release, Configuración de compilación para iOS Archive y exportación de release, Integración de Política de Privacidad dentro de la app y pantalla informativa, Documentación exhaustiva de despliegue y distribución en DEPLOY.md
  - Criterio: El test de integración integration_test/smoke_release_test.dart compila y ejecuta exitosamente en emulador Android.
  - Criterio: El checklist docs/REAL_DEVICE_TESTING_CHECKLIST.md detalla los criterios de aceptación físicos (sensores GPS, suspensión en segundo plano, reconexión móvil 4G/5G).
  - Criterio: La app es instalada y verificada en un teléfono Android y un teléfono iPhone físico siguiendo el checklist de prueba.

## Gestión y versionado de datos locales

- [ ] **Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT** (pendiente)
  - Depende de: Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy
  - Criterio: Las migraciones de la base de datos local Sqflite se ejecutan en orden secuencial sin pérdida de integridad.
  - Criterio: El procedimiento de recuperación ante base de datos local corrupta recrea el esquema sin bloquear la apertura de la aplicación.
  - Criterio: Existe la documentación docs/database_local_model.md con el mapeo claro de entidades y contratos.

## Limpieza de versión y depuración final

- [ ] **Limpieza final de versión y depuración de código muerto y dependencias** (pendiente)
  - Depende de: Suite de verificación de smoke testing en emulador y validación en dispositivos reales
  - Criterio: El analizador de Dart (`dart analyze`) finaliza con cero advertencias y cero errores de código o imports no utilizados.
  - Criterio: No existen dependencias o paquetes declarados en `pubspec.yaml` que no sean importados en el código fuente de `lib/`.
