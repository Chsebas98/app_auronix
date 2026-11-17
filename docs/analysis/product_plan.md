# Plan del producto — Ando-UI

Mapa del producto final por módulos, con sus tareas en orden y los códigos de sus criterios de aceptación. El estado vivo de cada tarea está en Mnemosine.

## M1 · Esqueleto del proyecto y cimientos de arquitectura

Establecer la estructura base del repositorio Flutter en Clean Architecture Feature-First con Atomic Design, inyección de dependencias, configuración por ambiente (local, dev, prod) y runner de pruebas verificado en CI con endpoint de salud/verificación.

- **T1** Estructura Clean Architecture Feature-First y tokens de diseño base Atomic Design (pending)
  - T1-C1: La estructura de carpetas en lib/app, lib/features y lib/shared respeta la jerarquía Feature-First y Atomic Design.
  - T1-C2: AppTheme proporciona esquemas de color claro y oscuro conformes a Material 3.
- **T2** Configuración multi-ambiente e inyección de dependencias con GetIt (pending)
  - T2-C1: EnvironmentConfig carga correctamente los valores y URLs base según el ambiente seleccionado (local, dev, prod).
  - T2-C2: setupDependencyInjection registra e inicializa los servicios base en el contenedor GetIt sin lanzar excepciones.
- **T3** Enrutamiento base con GoRouter y vista de salud/diagnóstico (pending)
  - T3-C1: El enrutador navega correctamente a la ruta de salud /health.
  - T3-C2: HealthPage muestra el estado del ambiente activo y la versión del sistema.
- **T4** Pipeline de integración continua (CI) y documentación README (pending)
  - T4-C1 (manual): El flujo de CI en .github/workflows/ci.yml ejecuta flutter analyze, dart format y flutter test en cada PR y push a la rama principal.
  - T4-C2: El archivo README.md incluye la descripción del proyecto, guía de instalación, configuración de ambientes y ejecución de tests.

## M2 · Cimientos de Red, Seguridad y Persistencia Local

Configurar cliente HTTP (Dio/http), gestión centralizada de tokens JWT, almacenamiento seguro de sesión local (Flutter Secure Storage/Sqflite), gestor de conexión WebSocket y manejo estructurado de errores y logs.

- **T5** Configuración de almacenamiento seguro para tokens y sesión (pending)
  - T5-C1: M2.T1-C1: El servicio guarda y recupera un valor de prueba cifrado en el llavero del sistema (Keychain/Keystore).
  - T5-C2: M2.T1-C2: El método de borrado elimina todas las claves relacionadas con la sesión durante el cierre de sesión.
- **T6** Cliente HTTP Dio con interceptores de seguridad e idempotencia (pending)
  - T6-C1: M2.T2-C1: Todas las peticiones salientes incluyen la cabecera Authorization si existe un token en el storage.
  - T6-C2: M2.T2-C2: Las peticiones POST incluyen una cabecera 'Idempotency-Key' con un formato UUID válido.
- **T7** Gestor de WebSockets para estados de viaje y posición (pending)
  - T7-C1 (manual): M2.T3-C1: El cliente WebSocket se conecta exitosamente al endpoint de STOMP del backend enviando el JWT de autenticación.
  - T7-C2: M2.T3-C2: El sistema reintenta la conexión automáticamente tras una pérdida de red con backoff exponencial.
- **T9** Persistencia local con Sqflite para caché y modo offline (pending)
  - T9-C1: M2.T5-C1: La base de datos se inicializa correctamente y permite operaciones CRUD básicas.
  - T9-C2: M2.T5-C2: El sistema maneja el versionado y la ejecución de scripts de migración sin pérdida de datos.
- **T8** Manejo estructurado de errores y logs de red (pending)
  - T8-C1: M2.T4-C1: Las respuestas 401 del backend disparan automáticamente el flujo de limpieza de sesión local.
  - T8-C2: M2.T4-C2: Los errores del servidor se registran con el código de error y el mensaje sin exponer trazas internas a la UI.

## M3 · Módulo de Autenticación y Onboarding

Implementar flujo completo de inicio de sesión y registro para pasajeros y conductores usando Firebase Auth + JWT, SessionBloc para enrutamiento según rol de usuario y validación inteligente de formularios.

- **T10** Modelado de entidades de Usuario y Contrato de Auth (pending)
  - T10-C1: M3.T1-C1: El modelo UserData deserializa correctamente un JSON con uuid, email y role (PASAJERO/CONDUCTOR).
  - T10-C2: M3.T1-C2: Los roles están tipados como un Enum estricto en Dart (UserRole.pasajero, UserRole.conductor).
- **T11** Data Source y Repositorio de Autenticación (Firebase + Backend) (pending)
  - T11-C1: M3.T2-C1: La llamada al repositorio devuelve el JWT del backend tras un login exitoso en Firebase.
  - T11-C2: M3.T2-C2: El JWT recibido se persiste en Flutter Secure Storage tras la autenticación.
- **T12** SessionBloc: Gestión de estado global de la sesión (pending)
  - T12-C1: M3.T3-C1: El estado cambia a Authenticated y expone el objeto User al recibir un token válido.
  - T12-C2: M3.T3-C2: El estado cambia a Unauthenticated si no hay token o la verificación falla.
- **T15** Protección de rutas y redirección por Rol (pending)
  - T15-C1: M3.T6-C1: Al intentar acceder a una ruta de pasajero siendo conductor, el router bloquea el acceso o redirige correctamente.
  - T15-C2: M3.T6-C2: Un usuario no logueado es enviado a /login al intentar abrir cualquier ruta privada.
- **T13** Pantalla de Login con validación inteligente (pending)
  - T13-C1: M3.T4-C1: El botón de login se deshabilita mientras los campos no cumplen el formato (email válido, pass > 6 car).
  - T13-C2 (manual): M3.T4-C2: Se muestra un mensaje de error legible si el backend o Firebase rechazan las credenciales.
- **T14** Flujo de Registro y Selección de Rol (pending)
  - T14-C1: M3.T5-C1: El registro envía el campo 'role' correcto al backend tras la creación exitosa en Firebase.
  - T14-C2: M3.T5-C2: No se permite avanzar en el registro sin haber seleccionado un rol.
- **T16** Cierre de sesión y limpieza de datos (pending)
  - T16-C1: M3.T7-C1: Tras el logout, el token JWT desaparece del almacenamiento seguro.
  - T16-C2 (manual): M3.T7-C2: La aplicación redirige a la pantalla de Login y no permite volver atrás a la pantalla privada.

## M4 · Módulo de Búsqueda y Selección de Ubicaciones

Integrar servicio de Places / Directions API para autocompletado de origen y destino, cálculo de rutas, estimación de tarifas y visualización previa en el mapa.

- **T17** Modelado y Repositorio de Autocompletado de Lugares (Places API) (pending)
  - T17-C1: M4.T1-C1: El modelo PlacePrediction deserializa correctamente sugerencias desde el payload JSON de la API.
  - T17-C2: M4.T1-C2: PlacesRepositoryImpl retorna una lista de predicciones dada una cadena de búsqueda válida.
- **T18** Data Source y Repositorio de Rutas y Estimación de Tarifas (Directions API) (pending)
  - T18-C1: M4.T2-C1: DirectionsRepositoryImpl calcula la distancia, el tiempo y la polilínea codificada entre dos puntos geográficos.
  - T18-C2: M4.T2-C2: EstimateFareUseCase retorna el precio estimado calculado según la distancia y duración provistas.
- **T19** LocationSearchBloc: Gestión de estado para la búsqueda de origen y destino (pending)
  - T19-C1: M4.T3-C1: LocationSearchBloc emite estado con predicciones tras recibir el evento de cambio de texto superado el tiempo de debounce.
  - T19-C2: M4.T3-C2: LocationSearchBloc emite estado de error comprensible cuando falla el servicio de direcciones o la conectividad.
  - T19-C3: M4.T3-C3: LocationSearchBloc emite estado de resultados vacíos cuando la consulta de autocompletado no retorna coincidencias.
- **T20** Pantalla y Componentes de Autocompletado e Intercambio de Ubicaciones (pending)
  - T20-C1: M4.T4-C1: LocationPickerPage renderiza el skeleton loader mientras se realiza la consulta de autocompletado.
  - T20-C2: M4.T4-C2: Al presionar el botón de intercambio, las descripciones y datos de origen y destino invierten sus posiciones.
  - T20-C3 (manual): M4.T4-C3: Comprobar visualmente que la lista de sugerencias resalta la coincidencia de texto ingresada y se adapta a pantallas pequeñas.
- **T21** Mapa de Previsualización de Ruta y Card de Estimación de Tarifa (pending)
  - T21-C1: M4.T5-C1: RoutePreviewMapWidget dibuja los marcadores de origen y destino y la polilínea recibida en sus propiedades.
  - T21-C2: M4.T5-C2: FareEstimateCard muestra el monto estimado y el tiempo de viaje en minutos de manera clara.
  - T21-C3 (manual): M4.T5-C3: Probar manualmente en emulador que el zoom del mapa se ajusta automáticamente para encuadrar la ruta completa al seleccionar origen y destino.

## M5 · Módulo de Gestión y Seguimiento de Viajes del Pasajero

Desarrollar la experiencia del pasajero para solicitar viaje con cabecera de idempotencia, visualizar la búsqueda de conductor, seguir el viaje en tiempo real por WebSocket, manejar restricciones de viaje activo único, confirmar finalización y calificar.

- **T22** Modelado de Entidades y Contratos de Viaje para Pasajero (pending)
  - T22-C1: El modelo TripModel mapea correctamente todos los estados del enum del backend.
  - T22-C2: La entidad Trip incluye campos para conductor, vehículo y coordenadas de seguimiento.
- **T23** Repositorio de Viajes y DataSource con Idempotencia (pending)
  - T23-C1: El repositorio envía el header 'Idempotency-Key' en cada POST de creación de viaje.
  - T23-C2: Se lanza ActiveTripException cuando el backend responde con error 409.
- **T24** PassengerTripBloc: Orquestación del Ciclo de Vida del Viaje (pending)
  - T24-C1: El Bloc emite TripSearchingState tras una solicitud exitosa.
  - T24-C2: El Bloc emite TripErrorState con mensaje amigable si ya existe un viaje activo (409).
- **T25** Integración de WebSocket para Actualizaciones en Tiempo Real (pending)
  - T25-C1: El Bloc actualiza el estado del viaje automáticamente al recibir un mensaje del WebSocket.
  - T25-C2: La app reconecta la suscripción al WebSocket si se pierde la conexión durante un viaje activo.
- **T26** Pantalla de Búsqueda de Conductor y Espera (pending)
  - T26-C1 (manual): La pantalla muestra un indicador de carga visual mientras el estado es SOLICITADO.
  - T26-C2: El botón 'Cancelar Viaje' invoca la acción correspondiente y regresa al Home.
- **T27** Seguimiento de Viaje en Mapa en Tiempo Real (pending)
  - T27-C1 (manual): El marcador del conductor se mueve en el mapa sin saltos bruscos al recibir coordenadas.
  - T27-C2: Se muestran los detalles del vehículo (placa, modelo) una vez el viaje está ACEPTADO.
- **T28** Finalización de Viaje y Calificación del Conductor (pending)
  - T28-C1: El formulario de calificación solo es visible si el estado del viaje es exactamente COMPLETADO.
  - T28-C2: Se valida que la calificación sea obligatoria antes de permitir el envío.
- **T29** Test de Integración: Flujo Completo del Pasajero (pending)
  - T29-C1: El flujo completo desde solicitud hasta calificación se completa sin errores inesperados.
  - T29-C2: La app muestra un aviso de 'Sin conexión' si se pierde la red durante el seguimiento del mapa.

## M6 · Módulo de Operaciones y Navegación del Conductor

Implementar el flujo del conductor para cambiar estado a disponible (vía GPS), recibir solicitudes cercanas restringidas a su cooperativa, aceptar/rechazar viajes, navegar al origen/destino, actualizar ciclo de vida secuencial y calificar al pasajero.

- **T30** Modelos y contratos del dominio para operaciones del conductor (pending)
  - T30-C1: Validar que TripStatus rechaza transiciones ilegales que no respeten el orden secuencial (ej. ACEPTADO directo a COMPLETADO sin pasar por EN_CURSO).
  - T30-C2: Comprobar que DriverTripRequest valida la correspondencia de cooperativeId y no permite campos obligatorios nulos.
- **T31** DataSource y Repositorio de Conductor con filtrado por Cooperativa (pending)
  - T31-C1: Aceptar o iniciar viaje envía las cabeceras de autorización correctas y mapea adecuadamente el DTO devuelto por el backend.
  - T31-C2: Lanzar CooperativeMismatchException cuando se detecta un viaje de una cooperativa diferente a la del conductor.
- **T32** Servicio de Geolocalización y Transmisión de Posición por WebSocket (pending)
  - T32-C1: Emitir coordenadas serializadas al WebSocket únicamente cuando el conductor se encuentre en estado disponible o con viaje activo.
  - T32-C2: Manejar la denegación de permisos de ubicación emitiendo un fallo de dominio LocationPermissionDeniedException sin congelar la aplicación.
- **T33** DriverTripBloc: Máquina de estados para disponibilidad y ciclo de vida de viaje (pending)
  - T33-C1: Cambiar el estado a DriverTripInProgress únicamente tras recibir confirmación exitosa de StartTripRequested.
  - T33-C2: Rechazar o descartar una solicitud tras timeout emitiendo DriverAvailable sin afectar el estado general de disponibilidad.
- **T34** Pantalla Principal del Conductor y Panel de Disponibilidad (pending)
  - T34-C1: Renderizar el switch de disponibilidad y disparar el evento ToggleAvailabilityRequested al cambiar su estado.
  - T34-C2: Mostrar banner de alerta cuando la conexión de red se pierde o el GPS está deshabilitado.
- **T35** Modal y Notificación de Solicitud de Viaje Entrante (Aceptar/Rechazar) (pending)
  - T35-C1: El botón Aceptar dispara AcceptTripRequested y cierra el modal de oferta pasando a navegación en ruta.
  - T35-C2: El botón Rechazar emite RejectTripRequested y descarta el modal de inmediato.
- **T36** Pantalla de Navegación del Conductor y Gestión Secuencial del Viaje (pending)
  - T36-C1: Habilitar el botón de 'Completar Viaje' únicamente cuando el estado actual es EN_CURSO y deshabilitarlo durante ACEPTADO.
  - T36-C2: Deslizar o pulsar 'Iniciar Viaje' emite StartTripRequested y actualiza la UI al tramo hacia el destino.
- **T37** Flujo de Finalización de Viaje y Calificación del Pasajero (pending)
  - T37-C1: El botón de confirmar calificación se mantiene deshabilitado hasta que se selecciona una puntuación entre 1 y 5 estrellas.
  - T37-C2: Tras registrar la calificación con éxito, el sistema limpia el viaje activo y regresa a la vista de conductor disponible.
- **T38** Prueba de Integración E2E: Ciclo de Vida Completo del Conductor (pending)
  - T38-C1: El test de integración completa todo el ciclo secuencial del viaje del conductor desde disponibilidad hasta calificación final con backend/mock de integración.
  - T38-C2 (manual): Verificar en emulador/dispositivo que la UI del conductor muestra adecuadamente los estados de reconexión y transiciones de viaje fluidas.

## M7 · Módulo de Historial de Viajes y Perfil

Permitir la consulta detallada de viajes pasados para pasajeros y conductores con paginación estable, visualización de estado final, montos y calificaciones, junto con la edición básica de perfil.

- **T39** Modelado de entidades de dominio y contratos para Historial de Viajes y Perfil (pending)
  - T39-C1: M7.T1-C1: Las entidades y modelos de TripSummary y UserProfile deserializan correctamente payloads de respuesta según el SSOT del backend.
  - T39-C2: M7.T1-C2: Los campos de paginación (page, size, totalElements, totalPages, content) se mapean adecuadamente a TripHistoryPage.
- **T40** Data Sources y Repositorios de Historial de Viajes y Perfil (pending)
  - T40-C1: M7.T2-C1: TripHistoryRemoteDataSource invoca /api/v1/trips/history con parámetros de paginación y cabecera de autenticación JWT.
  - T40-C2: M7.T2-C2: ProfileRepository actualiza los datos del usuario mediante PUT /api/v1/users/profile y retorna la entidad actualizada o propaga el fallo de dominio.
- **T41** TripHistoryBloc: Gestión reactiva de listado paginado y detalle de viajes pasados (pending)
  - T41-C1: M7.T3-C1: El evento TripHistoryFetchRequested emite estados Loading y Loaded con los primeros elementos obtenidos.
  - T41-C2: M7.T3-C2: El evento TripHistoryNextPageRequested concatena los nuevos resultados a la lista existente sin duplicar registros.
  - T41-C3: M7.T3-C3: Los errores en la petición de historial emiten TripHistoryError con mensaje comprensible.
- **T42** ProfileBloc: Gestión de estado para lectura y actualización del perfil de usuario (pending)
  - T42-C1: M7.T4-C1: ProfileFetchRequested recupera el perfil actual del usuario y emite ProfileLoaded.
  - T42-C2: M7.T4-C2: ProfileUpdateSubmitted procesa la actualización y emite ProfileUpdateSuccess con los nuevos datos.
- **T43** Pantalla y componentes de Listado de Historial de Viajes con paginación (pending)
  - T43-C1: M7.T5-C1: La pantalla renderiza el estado vacío TripHistoryEmptyState cuando la lista de viajes está vacía.
  - T43-C2: M7.T5-C2: Al hacer scroll al final de la lista se despacha el evento para cargar la siguiente página.
  - T43-C3: M7.T5-C3: Cada elemento renderiza fecha, dirección de origen/destino, tarifa formateada y badge de estado.
- **T44** Pantalla de Detalle de Viaje Pasado (Completed / Cancelled) (pending)
  - T44-C1: M7.T6-C1: La pantalla muestra todos los detalles del viaje completado incluyendo monto total, conductor/pasajero, cooperativa y rating.
  - T44-C2: M7.T6-C2: Si el viaje fue cancelado, se ocultan datos de tarifa y calificación y se visualiza claramente el motivo de cancelación y el estado CANCELADO.
- **T45** Pantalla de Perfil de Usuario y Edición de Datos (pending)
  - T45-C1: M7.T7-C1: Los campos editables reflejan los valores iniciales del usuario y validan formato de teléfono antes del envío.
  - T45-C2: M7.T7-C2: Al enviar cambios válidos, se invoca el evento de actualización y se muestra indicador de carga mientras procesa.
- **T46** Integración en Rutas y Menú de Navegación para Pasajero y Conductor (pending)
  - T46-C1: M7.T8-C1: La ruta '/trips/history' y '/profile' son accesibles tanto para rol PASAJERO como CONDUCTOR.
  - T46-C2: M7.T8-C2: La ruta '/trips/:id' abre TripDetailPage con el identificador de viaje proporcionado como parámetro.

## M8 · Endurecimiento de Seguridad, Calidad y Limpieza

Realizar auditoría de dependencias, eliminar código muerto/desuso fruto de refactorizaciones previas (ej. mapas/libs obsoletas), aplicar comprobación de accesibilidad WCAG y manejo resiliente sin conexión.

- **T47** Auditoría de seguridad y depuración de dependencias en pubspec (pending)
  - T47-C1: M8.T1-C1: pubspec.yaml contiene únicamente dependencias activas del proyecto sin paquetes heredados en desuso.
  - T47-C2: M8.T1-C2: El comando de auditoría y análisis de paquetes finaliza exitosamente con código de salida 0 sin advertencias críticas ni incompatibilidades de versión.
- **T48** Detección y eliminación exhaustiva de código muerto, imports obsoletos y contratos legacy (pending)
  - T48-C1: M8.T2-C1: El analizador estático de Dart finaliza sin ningún warning, error o linter issue en todo el árbol de lib/ y test/.
  - T48-C2: M8.T2-C2: Todos los archivos y clases huérfanas de versiones previas quedan completamente eliminados sin referencias rotas.
- **T51** Auditoría y adaptación de accesibilidad WCAG 2.1 AA en flujos clave (pending)
  - T51-C1: M8.T5-C1: Los botones y controles interactivos principales cuentan con nodos Semantics y etiquetas accesibles no vacías.
  - T51-C2: M8.T5-C2: La paleta de colores del tema garantiza un contraste superior a 4.5:1 entre colores de texto y fondo en modo claro y oscuro.
  - T51-C3 (manual): M8.T5-C3: Los campos de formulario y cards de estado de viaje exponen estados y roles semánticos correctos para lectores de pantalla.
- **T49** Servicio de conectividad de red reactivo y banner de desconexión/reconexión (pending)
  - T49-C1: M8.T3-C1: ConnectivityBloc emite estado desconectado al cesar la conectividad y estado conectado al restablecerse.
  - T49-C2: M8.T3-C2: NetworkStatusBanner se renderiza informando pérdida de red cuando el estado es desconectado y desaparece con animación al reconectar.
  - T49-C3: M8.T3-C3: Al volver la conexión, el gestor de red reintenta automáticamente la reconexión de sockets y peticiones pendientes.
- **T50** Servicio de reporte de fallos y sanitización de registros de error (pending)
  - T50-C1: M8.T4-C1: CrashReportingService captura errores síncronos y asíncronos no manejados reportándolos a la plataforma de monitoreo configurada.
  - T50-C2: M8.T4-C2: El sanitizador de errores elimina encabezados Authorization, tokens bearer y campos sensibles de los metadatos del crash.

## M9 · Preparación para Producción, Multi-Ambiente y Publicación

Configurar compilación firmada Android App Bundle e iOS Archive, splash screens, iconos, variables de ambiente (local, dev, prod), guías de despliegue DEPLOY.md, política de privacidad y verificación en dispositivo real/emulador.

- **T52** Configuración de App Launcher Icons y Native Splash Screen para Android e iOS (pending)
  - T52-C1: Los archivos de configuración de flutter_launcher_icons y flutter_native_splash están definidos en pubspec.yaml con rutas válidas de assets.
  - T52-C2: El nombre de visualización de la app está fijado a 'Ando' en AndroidManifest.xml e Info.plist.
  - T52-C3 (manual): La pantalla de splash nativa y los iconos de la app se visualizan correctamente en Android e iOS sin deformaciones de aspecto.
- **T53** Declaración y justificación contextual de permisos móviles mínimos en Android e iOS (pending)
  - T53-C1: AndroidManifest.xml e Info.plist contienen únicamente los permisos de geolocalización y red estrictamente requeridos.
  - T53-C2: PermissionService maneja correctamente los estados granted, denied y permanentlyDenied sin lanzar excepciones no controladas.
  - T53-C3: Las descripciones en Info.plist justifican el propósito de uso de ubicación de forma comprensible para el usuario.
- **T54** Configuración de compilación firmada Android (AAB) y scripts de release (pending)
  - T54-C1: android/app/build.gradle obtiene las credenciales de firma de release desde variables de entorno o key.properties sin contener contraseñas en texto plano.
  - T54-C2: El archivo de reglas ProGuard android/app/proguard-rules.pro preserva los modelos de serialización JSON y componentes de WebSocket requeridos para release.
  - T54-C3 (manual): El script tool/build_android_bundle.sh ejecuta la compilación del bundle para el flavor de producción.
- **T55** Configuración de compilación para iOS Archive y exportación de release (pending)
  - T55-C1: ExportOptions.plist y Release.xcconfig están configurados para distribución App Store / Ad-Hoc sin incluir certificados privados en Git.
  - T55-C2: El bundle identifier de iOS coincide con el applicationId de Android configurado para el flavor de producción.
  - T55-C3 (manual): La compilación del archivo de iOS se genera correctamente con flutter build ipa en entorno macOS con Xcode.
- **T56** Integración de Política de Privacidad dentro de la app y pantalla informativa (pending)
  - T56-C1: PrivacyPolicyScreen carga y renderiza el contenido de assets/legal/privacy_policy.md sin errores ni estado de carga infinito.
  - T56-C2: El archivo docs/PRIVACY_POLICY.md existe en la raíz del repositorio y contiene las secciones requeridas por Google Play y App Store (datos recolectados, ubicación en segundo plano, contacto del responsable).
  - T56-C3: El enlace a la Política de Privacidad es accesible tanto desde el flujo de registro como desde el perfil de usuario.
- **T57** Documentación exhaustiva de despliegue y distribución en DEPLOY.md (pending)
  - T57-C1: El archivo DEPLOY.md existe en la raíz y describe los pasos de compilación y despliegue para Android e iOS en los ambientes local, dev y prod.
  - T57-C2: DEPLOY.md no contiene tokens, contraseñas ni rutas absolutas privadas de desarrolladores.
- **T59** Suite de verificación de smoke testing en emulador y validación en dispositivos reales (pending)
  - T59-C1: El test de integración integration_test/smoke_release_test.dart compila y ejecuta exitosamente en emulador Android.
  - T59-C2: El checklist docs/REAL_DEVICE_TESTING_CHECKLIST.md detalla los criterios de aceptación físicos (sensores GPS, suspensión en segundo plano, reconexión móvil 4G/5G).
  - T59-C3 (manual): La app es instalada y verificada en un teléfono Android y un teléfono iPhone físico siguiendo el checklist de prueba.
- **T58** Alineación y verificación del esquema de datos y persistencia SQLite según contratos SSOT (pending)
  - T58-C1: Las migraciones de la base de datos local Sqflite se ejecutan en orden secuencial sin pérdida de integridad.
  - T58-C2: El procedimiento de recuperación ante base de datos local corrupta recrea el esquema sin bloquear la apertura de la aplicación.
  - T58-C3: Existe la documentación docs/database_local_model.md con el mapeo claro de entidades y contratos.
- **T60** Limpieza final de versión y depuración de código muerto y dependencias (pending)
  - T60-C1: El analizador de Dart (`dart analyze`) finaliza con cero advertencias y cero errores de código o imports no utilizados.
  - T60-C2: No existen dependencias o paquetes declarados en `pubspec.yaml` que no sean importados en el código fuente de `lib/`.
