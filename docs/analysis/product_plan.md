# Plan del producto — Ando-UI

Mapa del producto final por módulos, con sus tareas en orden y los códigos de sus criterios de aceptación. El estado vivo de cada tarea está en Mnemosine.

## M1 · Esqueleto del proyecto y cimientos de arquitectura

Establecer la estructura base del repositorio Flutter en Clean Architecture Feature-First con Atomic Design, inyección de dependencias (GetIt), configuración por ambiente (local, dev, prod) con soporte .env y runner de pruebas verificado en CI con vista de diagnóstico y salud.

- **T1** Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design (pending)
  - T1-C5: M1.T1-C1: La estructura de directorios y exportaciones públicas en lib/app, lib/features y lib/shared se resuelve sin errores de importación circular ni referencias huérfanas.
  - T1-C6: M1.T1-C2: AppTheme genera configuraciones ThemeData de Material 3 válidas para modos claro y oscuro con contrastes de color accesibles.
  - T1-C7: M1.T1-C3: Los componentes atómicos AndoButton y AndoTextField respetan los tokens de espaciado y estado deshabilitado.
- **T2** Configuración multi-ambiente e inyección de dependencias con GetIt (pending)
  - T2-C6: M1.T2-C1: EnvironmentConfig inicializa las propiedades según el mapa de entorno y selecciona el esquema ws:// para ambiente local y wss:// para desarrollo/producción.
  - T2-C7: M1.T2-C2: GetIt registra y resuelve correctamente la instancia singleton de EnvironmentConfig tras invocar setupServiceLocator().
  - T2-C8: M1.T2-C3: El repositorio incluye .env.example con las claves de entorno necesarias sin valores de producción y .env se encuentra excluido en .gitignore.
- **T3** Enrutamiento base con GoRouter y vista de salud/diagnóstico (pending)
  - T3-C5: M1.T3-C1: GoRouter resuelve correctamente la ruta inicial '/health_check' y navega sin errores de contexto.
  - T3-C6: M1.T3-C2: HealthCheckScreen muestra la información del ambiente activo (nombre, apiUrl, esquema ws/wss) consumiendo EnvironmentConfig desde GetIt.
  - T3-C7: M1.T3-C3: Las rutas hacia flujos de pasajero y conductor están declaradas como ramas desacopladas listas para los módulos siguientes.
- **T4** Pipeline de integración continua (CI) y documentación README (pending)
  - T4-C6: M1.T4-C1: El flujo de GitHub Actions ci.yml define pasos estrictos de checkout, setup de Flutter, análisis estático y ejecución de pruebas con reporte de cobertura.
  - T4-C7: M1.T4-C2: El archivo README.md contiene secciones de instalación, variables de entorno, ejecución por ambiente y testing para un onboarding sin fricción.
  - T4-C8: M1.T4-C3: flutter analyze se ejecuta sin warnings ni errores de linter sobre todo el código base de M1.

## M2 · Cimientos de Red, Seguridad y Persistencia Local

Configurar cliente HTTP Dio con interceptores JWT e Idempotency-Key, almacenamiento seguro de sesión local (Flutter Secure Storage), persistencia relacional embebida (Sqflite), gestor de conexión WebSocket con soporte ws:// para local y wss:// para producción, y manejo centralizado de errores y logs.

- **T5** Configuración de almacenamiento seguro para tokens y sesión (pending)
  - T5-C6: Los tokens JWT y datos sensibles de sesión se persisten utilizando Flutter Secure Storage (Keychain en iOS / Keystore en Android).
  - T5-C7: Se proporciona un método clearSession() que remueve completamente los tokens en el logout sin dejar residuos.
- **T6** Cliente HTTP Dio con interceptores de seguridad e idempotencia (pending)
  - T6-C6: Todas las peticiones HTTP salientes incluyen el encabezado Authorization Bearer cuando existe un token activo.
  - T6-C7: Las peticiones POST de creación u oferta de viajes generan un UUIDv4 único en el header Idempotency-Key.
- **T7** Gestor de WebSockets para estados de viaje y posición (pending)
  - T7-C6: La conexión WebSocket conmuta dinámicamente entre ws:// en ambiente local y wss:// en staging/producción.
  - T7-C7: El cliente WebSocket se reconecta de manera transparente tras una desconexión accidental de red.
- **T9** Persistencia local con Sqflite para caché y modo offline (pending)
  - T9-C6: La base de datos SQLite embebida inicializa correctamente sus tablas sin perder integridad de datos.
  - T9-C7: Se pueden guardar y consultar registros en caché local durante pérdida de conectividad.
- **T8** Manejo estructurado de errores y logs de red (pending)
  - T8-C6: Cualquier error de red o servidor HTTP es mapeado a un objeto de error estructurado con mensaje amigable.
  - T8-C7: Los logs de red ofuscan automáticamente headers de autorización e información sensible.

## M3 · Módulo de Autenticación y Onboarding

Implementar flujo completo de inicio de sesión y registro para pasajeros y conductores usando Firebase Auth integrado con JWT de Spring Boot, SessionBloc para gestión reactiva de sesión y enrutamiento según rol de usuario (client_routes, conductor_routes).

- **T10** Modelado de entidades de Usuario y Contrato de Auth (pending)
  - T10-C5: Mapeo unitario del DTO AuthResponse con campos id, email, role, token y refreshToken comprobando sound null safety.
  - T10-C6: Validación de tipos de rol válidos (PASAJERO, CONDUCTOR) rechazando valores no reconocidos.
- **T11** Data Source y Repositorio de Autenticación (Firebase + Backend) (pending)
  - T11-C5: Intercambio exitoso del idToken de Firebase con la API de Spring Boot obteniendo el JWT de sesión.
  - T11-C6: Almacenamiento seguro del token JWT recibido en SecureStorageService tras la respuesta exitosa del servidor.
- **T12** SessionBloc: Gestión de estado global de la sesión (pending)
  - T12-C5: Transición automática a Authenticated cuando existe un token válido guardado en SecureStorageService.
  - T12-C6: Transición a Unauthenticated cuando no hay token persistido o la sesión expiró.
- **T15** Protección de rutas y redirección por Rol (pending)
  - T15-C5: Redirección de un usuario autenticado con rol PASAJERO a /client/home e imposibilidad de acceder a /driver/*.
  - T15-C6: Redirección de un usuario no autenticado a la pantalla de login al intentar ingresar a cualquier ruta protegida.
- **T16** Cierre de sesión y limpieza de datos (pending)
  - T16-C5: Eliminación completa de los tokens en Flutter Secure Storage al ejecutar el evento de Logout.
  - T16-C6: Redirección inmediata de la UI a la pantalla de login tras el cierre de sesión exitoso.
- **T13** Pantalla de Login con validación inteligente (pending)
  - T13-C5: Manejo visual de errores de credenciales con mensajes entendibles para el usuario sin mostrar excepciones ni trazas del backend.
  - T13-C6: Deshabilitar el botón de login y mostrar indicador de carga visual durante la llamada asíncrona de autenticación.
- **T14** Flujo de Registro y Selección de Rol (pending)
  - T14-C5: Rechazo del registro en el formulario cuando no se ha seleccionado un rol (PASAJERO o CONDUCTOR).
  - T14-C6: Creación exitosa de cuenta e iniciación de sesión automática tras un registro válido en el backend.

## M4 · Módulo de Búsqueda y Selección de Ubicaciones

Integrar servicio de Places y Directions API para autocompletado con debounce de origen y destino, cálculo y dibujado de polilíneas de ruta, estimación preliminar de tarifas y visualización en mapa interactivo.

- **T17** Modelado y Repositorio de Autocompletado de Lugares (Places API) (pending)
  - T17-C6: M4.T1-C1: PlacePredictionDto deserializa correctamente un JSON de autocompletado y maneja campos secundarios ausentes con fallback seguro.
  - T17-C7: M4.T1-C2: PlacesRepositoryImpl retorna lista de predicciones en llamadas exitosas y mapea códigos HTTP 4xx/5xx a fallos tipados ServerFailure.
  - T17-C8: M4.T1-C3: Se sanitizan consultas vacías o con puros espacios retornando lista vacía sin emitir petición HTTP.
- **T18** Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API) (pending)
  - T18-C6: M4.T2-C1: DirectionsRepositoryImpl decodifica cadenas de polilínea en listas de LatLng sin pérdida de precisión de coordenadas.
  - T18-C7: M4.T2-C2: estimateFare calcula el importe total en base a distancia y tiempo aplicando tarifa base con redondeo a dos decimales.
  - T18-C8: M4.T2-C3: Si el servicio de rutas devuelve un error de ruta no transitable, el repositorio retorna RouteNotFoundFailure manejado.
- **T19** LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino (pending)
  - T19-C8: M4.T3-C1: Las emisiones repetidas de SearchQueryChanged en menos de 300ms ejecutan una única llamada al repositorio debido al debounce.
  - T19-C9: M4.T3-C2: Al emitir SwapLocations con origen y destino cargados, se intercambian las posiciones y se recalcula la ruta.
  - T19-C10: M4.T3-C3: Si la búsqueda no arroja coincidencias, el estado emite predictions vacía y bandera hasNoResults en verdadero.
  - T19-C11: M4.T3-C4: Cuando ambos puntos (origen y destino) están seleccionados, se transiciona a estado isCalculatingRoute y luego a routeReady con routeInfo y fareEstimate.
- **T20** Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones (pending)
  - T20-C8: M4.T4-C1: Los inputs de origen y destino y el botón de swap tienen un área táctil mínima de 44x44 dp y etiquetas Semantics válidas.
  - T20-C9: M4.T4-C2: Mientras se obtienen las sugerencias se muestra el skeleton loader, y si no hay resultados se muestra el widget de estado vacío.
  - T20-C10: M4.T4-C3: Al presionar una predicción se selecciona el lugar y el input correspondiente refleja el nombre del lugar elegido.
- **T21** Mapa de Previsualización de Ruta y Card de Estimación de Tarifa (pending)
  - T21-C8: M4.T5-C1: El componente route_map_preview renderiza los marcadores de origen y destino y ajusta los límites de la cámara según los puntos extremos de la ruta.
  - T21-C9: M4.T5-C2: fare_estimate_card muestra el desglose de distancia, duración y precio estimado, mostrando un spinner o skeleton si la tarifa está calculándose.
  - T21-C10: M4.T5-C3: Al presionar 'Confirmar ruta' con origen, destino y ruta válidos, se invoca el callback o navegación hacia el flujo de confirmación/solicitud.
  - T21-C11: M4.T5-C4: En caso de error de cálculo de ruta, la tarjeta muestra mensaje explicativo con botón para reintentar sin cerrar la vista.

## M5 · Módulo de Gestión y Seguimiento de Viajes del Pasajero

Desarrollar la experiencia completa del cliente para solicitar viajes utilizando cabecera Idempotency-Key, interfaz de espera 'buscando conductor', seguimiento en vivo del conductor y viaje en curso por WebSocket, bloqueo de solicitudes simultáneas si hay viaje activo, finalización y calificación.

- **T22** Modelado de Entidades y Contratos de Viaje para Pasajero (pending)
  - T22-C3: La entidad Trip contiene todos los campos necesarios según el esquema tb_trips.
  - T22-C4: El TripModel realiza la conversión de JSON correctamente respetando tipos de datos y nulos.
- **T23** Repositorio de Viajes y DataSource con Idempotencia (pending)
  - T23-C3: La petición POST a /trips incluye el header Idempotency-Key.
  - T23-C4: El repositorio lanza ActiveTripException cuando el backend devuelve 409.
- **T24** PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje (pending)
  - T24-C3: El Bloc bloquea nuevas solicitudes si ya existe un viaje en curso en el estado.
  - T24-C4: El Bloc emite FailureState ante errores de red o idempotencia.
- **T25** Integración de WebSocket para Actualizaciones en Tiempo Real (pending)
  - T25-C3: La suscripción al tópico del viaje se realiza tras la creación exitosa del viaje.
  - T25-C4: Los eventos del socket provocan transiciones de estado en el PassengerTripBloc.
- **T26** Pantalla de Búsqueda de Conductor y Espera (pending)
  - T26-C3 (manual): La pantalla muestra el estado de búsqueda mientras el viaje está en SOLICITADO.
  - T26-C4: El botón de cancelar detiene el proceso y vuelve a la pantalla de inicio.
- **T27** Seguimiento de Viaje en Mapa en Tiempo Real (pending)
  - T27-C3 (manual): El icono del conductor se mueve en el mapa al recibir coordenadas por WebSocket.
  - T27-C4: La información del vehículo y conductor es visible y correcta.
- **T28** Finalización de Viaje y Calificación del Conductor (pending)
  - T28-C3: El diálogo de calificación aparece inmediatamente al finalizar el viaje.
  - T28-C4: La llamada de calificación envía los datos correctos y gestiona errores de red.
- **T29** Test de Integración: Flujo Completo del Pasajero (pending)
  - T29-C3: El flujo completo se ejecuta sin errores de navegación ni pérdida de estado.
  - T29-C4: Se verifica que no hay fugas de memoria al cerrar los sockets al final del flujo.

## M6 · Módulo de Operaciones y Navegación del Conductor

Implementar el flujo operativo del conductor para disponibilidad geográfica GPS, recepción de solicitudes filtradas por su cooperativa, aceptación o rechazo, navegación guiada, actualización secuencial del ciclo de viaje (ACEPTADO -> EN_CURSO -> COMPLETADO) y calificación al cliente.

- **T30** Modelos y contratos del dominio para operaciones del conductor (pending)
  - T30-C3: DriverTrip modela los estados válidos de viaje según el contrato backend
  - T30-C4: TripOffer valida obligatoriamente que cooperativaId no sea nulo ni vacío
- **T31** DataSource y Repositorio de Conductor con filtrado por Cooperativa (pending)
  - T31-C3: Filtrado estricto descarta ofertas que no pertenecen a la cooperativa del conductor
  - T31-C4: Transiciones REST envían id de conductor y token en cabeceras HTTP
- **T32** Servicio de Geolocalización y Transmisión de Posición por WebSocket (pending)
  - T32-C3: Posición GPS se transmite al canal WebSocket con formato JSON esperado por el backend
  - T32-C4: Manejo de errores sin conexión almacena la última posición y reanuda el envío al reconectar
- **T33** DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje (pending)
  - T33-C3: Máquina de estados rechaza saltos no secuenciales de estado de viaje
  - T33-C4: DriverTripBloc pasa a DriverOnlineWaiting al activar disponibilidad geográfica
- **T34** Pantalla Principal del Conductor y Panel de Disponibilidad (pending)
  - T34-C3: Switch de disponibilidad cambia estado reactivo y muestra feedback visual
  - T34-C4: Indicador de cooperativa muestra el nombre correspondiente obtenido del perfil autenticado
- **T35** Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar) (pending)
  - T35-C3: Botón Aceptar dispara evento de aceptación en DriverTripBloc y cierra modal
  - T35-C4: Expiración del temporizador ejecuta rechazo automático de la solicitud
- **T36** Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje (pending)
  - T36-C3: Botón de acción principal muta de acuerdo con el estado secuencial del viaje
  - T36-C4: Pérdida temporal de red no resetea la pantalla y muestra alerta de reconexión
- **T37** Flujo de Finalización de Viaje y Calificación del Pasajero (pending)
  - T37-C3: Envío de calificación ejecuta llamada REST y transiciona a estado disponible
  - T37-C4: Diálogo muestra resumen financiero de tarifa y desglosa el pago completado
- **T38** Prueba de Integración E2E: Ciclo de Vida Completo del Conductor (pending)
  - T38-C3: Flujo E2E completo del conductor se ejecuta sin errores respetando la secuencia del ciclo
  - T38-C4 (manual): Verificación visual y fluidez de transiciones en dispositivo o emulador

## M7 · Módulo de Historial de Viajes y Perfil

Construir las vistas de perfil y consulta paginada de historial de viajes para pasajeros y conductores, mostrando detalle de estados finales (COMPLETADO, CANCELADO), desglose de cobro/pago, calificaciones emitidas y recibidas, con almacenamiento seguro y mínimo privilegio.

- **T39** Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil (pending)
  - T39-C3: Las entidades TripDetail y TripSummary modelan con precisión estados finales COMPLETADO y CANCELADO, métricas de tarifa, fechas y datos de calificación.
  - T39-C4: La entidad PaginatedTrips encapsula la lista de viajes, página actual, total de páginas y si existen páginas subsecuentes.
  - T39-C5: UserProfile modela nombre, teléfono, correo, rol y avatar sin exponer campos confidenciales o no autorizados.
- **T40** Data Sources y Repositorios de Historial de Viajes y Perfil (pending)
  - T40-C3: TripHistoryRemoteDataSource realiza peticiones GET paginadas incluyendo query params page y size con Bearer token en headers.
  - T40-C4: ProfileRemoteDataSource obtiene y actualiza el perfil del usuario autenticado sin filtrar datos de terceros.
  - T40-C5: Los repositorios convierten excepciones de red o HTTP 403/404 en fallos de dominio tipados (TripNotFoundFailure, UnauthorizedAccessFailure).
- **T41** TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados (pending)
  - T41-C4: TripHistoryBloc emite TripHistoryLoading y luego TripHistoryLoaded con la lista inicial al recibir LoadTripHistory.
  - T41-C5: El evento LoadMoreTrips concatena la siguiente página de viajes sin duplicar registros ya existentes.
  - T41-C6: El evento LoadTripDetail carga correctamente la información extendida de viajes COMPLETADO o CANCELADO.
- **T42** ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario (pending)
  - T42-C3: ProfileBloc carga los datos del usuario autenticado emitiendo ProfileLoaded ante LoadUserProfile.
  - T42-C4: ProfileBloc valida los datos modificados y emite ProfileUpdateSuccess tras confirmación del repositorio.
  - T42-C5: Cualquier error de autorización o fallo de red emite ProfileError sin corromper el estado anterior del perfil.
- **T43** Pantalla y componentes de Listado de Historial de Viajes con paginación (pending)
  - T43-C4: TripHistoryScreen muestra skeleton loading mientras se cargan los viajes y renderiza TripSummaryCards al completarse.
  - T43-C5: Hacer scroll al final de la lista dispara la solicitud de la página siguiente al bloc.
  - T43-C6: Si el usuario no tiene viajes registrados, se presenta EmptyTripHistoryWidget con mensaje descriptivo y acción de solicitar viaje.
- **T44** Pantalla de Detalle de Viaje Pasado (Completed / Cancelled) (pending)
  - T44-C3: TripDetailScreen renderiza el desglose completo de cobro/pago, estado final y participantes del viaje.
  - T44-C4: Si el viaje tiene estado CANCELADO, la pantalla muestra la razón de cancelación y ajusta el desglose financiero acorde.
  - T44-C5: TripRatingDisplayWidget muestra la calificación por estrellas y comentario si existen para el viaje.
- **T45** Pantalla de Perfil de Usuario y Edición de Datos (pending)
  - T45-C3: ProfileScreen visualiza correctamente la información de usuario distinguiendo entre campos editables y no editables.
  - T45-C4: EditProfileModal valida teléfono y nombre antes de permitir el envío del formulario.
  - T45-C5: El botón de cerrar sesión invoca el evento de desautenticación en SessionBloc y limpia la sesión.
- **T46** Integración en Rutas y Menú de Navegación para Pasajero y Conductor (pending)
  - T46-C3: La ruta /trips/history es navegable tanto desde el menú del pasajero como desde el menú del conductor con sus respectivos permisos.
  - T46-C4: La ruta /trips/:id navega a TripDetailScreen cargando el viaje especificado por parámetro.
  - T46-C5: El acceso a /profile permite consultar y actualizar datos desde ambos flujos de rol.

## M8 · Endurecimiento de Seguridad, Calidad y Limpieza

Ejecutar auditoría de dependencias libres de vulnerabilidades, eliminar código muerto de versiones previas (librerías obsoletas de mapas y blocs sin uso), verificar accesibilidad WCAG 2.1 AA en todas las pantallas y dotar a la aplicación de resiliencia con manejo offline y reporte seguro de fallos.

- **T47** Auditoría de seguridad y depuración de dependencias en pubspec (pending)
  - T47-C3: El archivo pubspec.lock no contiene dependencias con vulnerabilidades de severidad alta o crítica según el análisis de seguridad de dependencias.
  - T47-C4: Se eliminan todas las dependencias directas no utilizadas en el código fuente de lib/.
  - T47-C5: Todas las dependencias son estrictamente compatibles con Dart SDK >=3.12.0 <4.0.0 y Flutter 3.44 sin advertencias de deprecación críticas.
- **T48** Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy (pending)
  - T48-C3: flutter analyze no reporta ningún aviso de unused_element, unused_import ni dead_code en todo el directorio lib/ ni test/.
  - T48-C4: No existen archivos dart no referenciados ni blocs antiguos sin registro en dependency_injection.dart ni consumo en rutas.
  - T48-C5: Los modelos de datos y endpoints en lib/features/trips/ y lib/features/auth/ coinciden exactamente con los contratos SSOT del backend sin restos de payloads legacy.
- **T49** Servicio de conectividad de red reactivo y banner de desconexión/reconexión (pending)
  - T49-C4: Al detectarse pérdida de conectividad a internet, se emite el estado offline y la interfaz muestra el banner visible de desconexión.
  - T49-C5: Al restablecerse la conexión de red, el banner muestra estado de reconexión y se oculta tras confirmar enlace activo.
  - T49-C6: Las peticiones fallidas por timeout o falta de red durante un intento de sincronización no borran el estado local de formularios de solicitud de viaje.
- **T50** Servicio de reporte de fallos y sanitización de registros de error (pending)
  - T50-C3: Las excepciones no controladas de Flutter y de la plataforma son capturadas por el servicio centralizado sin provocar caídas silenciosas de la aplicación.
  - T50-C4: Los registros y trazas de error enviados al servicio de reporte son sanitizados, reemplazando tokens JWT, passwords y credenciales con máscaras.
  - T50-C5: Las excepciones de aplicación se presentan al usuario mediante mensajes comprensibles y con opciones de reintento, sin exhibir trazas internas de error.
- **T51** Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave (pending)
  - T51-C4: Todos los botones, iconos de interacción y campos de entrada en las pantallas principales cumplen con el tamaño mínimo de pulsación táctil (44x44 dp).
  - T51-C5: Todos los controles interactivos y estados informativos cuentan con etiquetas Semantics válidas para lectores de pantalla.
  - T51-C6: Las combinaciones de color de texto y fondo en tokens de diseño cumplen el ratio de contraste mínimo 4.5:1.

## M9 · Preparación para Producción, Multi-Ambiente y Publicación

Configurar empaquetado release firmado (Android AAB e iOS Archive), assets visuales completos (iconos y splash screen), verificación cruzada con contratos y esquema de base de datos existente, suite de smoke testing en emulador y dispositivos físicos, y documentación en DEPLOY.md y política de privacidad.

- **T52** Configuración de App Launcher Icons y Native Splash Screen para Android e iOS (pending)
  - T52-C4: Verificar la presencia y estructura de los archivos de íconos y splash screen generados en android/app/src/main/res/ y ios/Runner/Assets.xcassets.
  - T52-C5 (manual): Verificar visualmente en emulador/dispositivo Android e iOS que el ícono de la app se muestra correctamente alineado y el splash screen nativo se despliega sin distorsiones.
- **T53** Declaración y justificación contextual de permisos móviles mínimos en Android e iOS (pending)
  - T53-C4: Comprobar que el servicio de permisos de la app solo solicita permisos declarados en la lista blanca de producción.
  - T53-C5 (manual): Probar en dispositivo iOS y Android que al pulsar sobre la búsqueda de viajes o activación de conductor aparece el diálogo explicativo antes de la solicitud de sistema.
- **T54** Configuración de compilación firmada Android (AAB) y scripts de release (pending)
  - T54-C4: Ejecutar script de validación de compilación que verifique la generación exitosa del paquete AAB firmado en build/app/outputs/bundle/release/app-release.aab.
  - T54-C5 (manual): Inspeccionar el archivo AAB generado e intentar su instalación preliminar mediante bundletool para asegurar que la firma es válida.
- **T55** Configuración de compilación para iOS Archive y exportación de release (pending)
  - T55-C4: Verificar mediante test de integración de CI la generación del archivo ipa o archive en build/ios/archive/Runner.xcarchive sin credenciales hardcodeadas.
  - T55-C5 (manual): Cargar el paquete generado a TestFlight a través de Transporter o Xcode Organizer y comprobar que supera las validaciones automáticas de Apple.
- **T59** Suite de verificación de smoke testing en emulador y validación en dispositivos reales (pending)
  - T59-C4: Ejecución exitosa de test/integration/flows/release_smoke_test.dart en emulador headless sin fallos en el runner de Flutter.
  - T59-C5 (manual): Probar la compilación de release firmada en al menos un teléfono Android real y un iPhone real, verificando fluidez visual, conexión de socket y GPS.
- **T56** Integración de Política de Privacidad dentro de la app y pantalla informativa (pending)
  - T56-C4: Test de widget que comprueba la renderización de PrivacyPolicyScreen, presencia de títulos y enlaces legales sin errores de navegación.
  - T56-C5 (manual): Acceder desde el menú de usuario a la política de privacidad y comprobar que la información es legible y cumple con los requerimientos de divulgación de datos de las tiendas.
- **T57** Documentación exhaustiva de despliegue y distribución en DEPLOY.md (pending)
  - T57-C3: Test de documentación que escanea DEPLOY.md verificando la presencia de las secciones obligatorias: Prerequisites, Environment Variables, Android Release, iOS Release, Rollback Procedure, Backup/Restore.
  - T57-C4 (manual): Leer la guía DEPLOY.md y ejecutar paso a paso en una máquina limpia los comandos descritos verificando su correcto funcionamiento.
- **T58** Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT (pending)
  - T58-C4: Ejecutar test/unit/database/schema_validation_test.dart comprobando la versión de esquema, creación limpia de tablas y ejecución idempotente de migraciones.
  - T58-C5 (manual): Simular una actualización de base de datos en la app migrando datos antiguos y comprobando que no se pierden sesiones ni historial guardado.
- **T60** Limpieza final de versión y depuración de código muerto y dependencias (pending)
  - T60-C3: Ejecución de flutter analyze y test/security/dead_code_audit_test.dart reportando 0 advertencias y sin dependencias no utilizadas.
  - T60-C4: Test de integración CI que realiza un build limpio desatendido y verifica que el repositorio no tiene archivos sin seguimiento ni sobrantes tras la compilación.
