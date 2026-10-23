# Flujos de negocio

## 1. Sesión / arranque
1. `SessionBloc` recibe `CheckLoggedUserEvent` al arrancar.
2. Con sesión guardada (token en `flutter_secure_storage`), emite `Authenticated`; si no, `Unauthenticated`.
3. Si el usuario es conductor y `estado_verificacion != APROBADO`, el router redirige a `/driver/verification-pending` en vez de a home.
4. **Nuevo**: si el usuario tiene un `viaje` en estado `ASIGNADO`/`CONDUCTOR_EN_CAMINO`/`CONDUCTOR_LLEGO`/`EN_CURSO`, el router redirige directo a la pantalla de viaje activo correspondiente (cliente o conductor) en vez de a Home, reconciliando el estado con backend antes de decidir la ruta. Aplica también si la app se cerró/crasheó a mitad de un viaje: al reabrir debe restaurar esta pantalla automáticamente.
5. Refresh de token en 401 vía `AuthInterceptor`, sin cambios de lógica salvo dónde se lee/escribe el token.
6. **Sesión única por cuenta**: si el backend responde con un error específico de "sesión invalidada por otro dispositivo" (distinto de un 401 por token expirado — ver [`requerimientos_backend.md`](requerimientos_backend.md)), `SessionBloc` fuerza logout local mostrando un mensaje explicativo ("Tu sesión se cerró porque iniciaste sesión en otro dispositivo"), no el mensaje genérico de sesión expirada. Ver sección 12 para el flujo completo de login con sesión única (confirmación previa, y bloqueo total si hay un viaje en curso).

### 1.1 GPS obligatorio para el conductor
Un conductor no puede activar el toggle "disponible" sin ubicación/GPS habilitado en el dispositivo — la app bloquea la acción con un mensaje claro y un enlace directo a los ajustes del sistema.

## 2. Registro de conductor y verificación (alcance simplificado)
0. Aplican las reglas transversales de la sección 11 (OTP, términos, edad mínima 18 años para todo usuario, contacto de emergencia obligatorio) antes de continuar con lo específico de conductor.
1. El conductor se autorregistra igual que un pasajero, con datos personales + número de licencia + datos básicos del vehículo (placa, marca, modelo — **la placa se valida contra el formato oficial del país detectado por la ubicación actual del dispositivo**: Ecuador `^[A-Z]{3}-\d{3,4}$`, Perú `^([A-Z]{3}-\d{3}|[A-Z]\d[A-Z]-\d{3})$`, Colombia `^([A-Z]{3}\d{3}|[A-Z]{2}\d{4})$`, ver [`requerimientos_backend.md`](requerimientos_backend.md) sección 2.1). **No sube ningún documento en la app.** Si abandona el formulario a la mitad, se conserva un borrador local para retomarlo después.
2. El backend crea la cuenta con `estado_verificacion = PENDIENTE`, sin cooperativa ni vehículo definitivo asignado todavía.
3. El administrador (desde el dashboard, fuera de esta app) le asigna una cooperativa y, en paralelo o después, le envía un correo con un enlace a un portal externo donde el conductor sube su documentación (y biometría si aplica). **SLA comunicado al conductor: ~24 horas.** El conductor puede solicitar el reenvío de este correo desde la pantalla "Pendiente de verificación" si no lo recibió.
4. Una vez el administrador aprueba todo, `estado_verificacion = APROBADO` y se le asigna el `vehiculo_id` definitivo (relación fija; solo el admin puede cambiarla después).
5. La app del conductor, al detectar `APROBADO` (por consulta al reabrir la app o por notificación en tiempo real si la tiene abierta en la pantalla de espera), lo lleva a Home y habilita el toggle de disponibilidad. **El cambio a `APROBADO` dispara además una notificación push inmediata** ("¡Tu cuenta fue aprobada!"), sin depender de que el conductor tenga la app abierta.
6. Si es `RECHAZADO`, la pantalla de espera lo indica, pero el reenvío de documentación ocurre en el portal externo, no en esta app.

## 3. Publicación de solicitud de viaje (pasajero)
0. Aplican las reglas transversales de la sección 11 antes del primer viaje (contacto de emergencia obligatorio, etc.).
1. Pasajero define origen (por defecto su ubicación actual, o arrastrando un pin/buscando texto — ambas formas permitidas) y destino (buscador de direcciones + mapa, ver [`requerimientos_backend.md`](requerimientos_backend.md) sección 9 para el proveedor elegido). Se valida que la distancia resultante no supere **150 km**; si la excede, se bloquea la publicación con un mensaje claro (viajes interurbanos mayores quedan para v2).
2. El backend calcula distancia, duración y **precio sugerido** (`POST /trips/estimate` o equivalente, ver [`requerimientos_backend.md`](requerimientos_backend.md)), en la moneda que corresponda al país detectado en el origen (ver sección 11.1).
3. El pasajero puede editar el precio antes de publicar; validación en cliente: valor numérico, admite decimales, no puede ser menor a **$0.50** (valor obtenido de un endpoint de configuración pública, no hardcodeado — el administrador puede cambiarlo desde el dashboard). Se muestra siempre como número exacto con 2 decimales, nunca como rango.
4. Al publicar, `solicitud_viaje.estado = PUBLICADA`, visible 5 minutos (`expira_en`, fijo, sin extensión posible) para conductores `DISPONIBLE` dentro de **10 km** del punto de origen de la solicitud (ubicación actual del pasajero o el punto que haya indicado) — radio fijo confirmado.
5. Si expira sin ofertas, el pasajero puede republicarla, pero el precio de la nueva solicitud debe ser **igual o mayor** al de la anterior — nunca menor. El cliente valida esto antes de enviar y el backend es la validación final.
6. **Una sola solicitud activa por pasajero**: mientras exista una `solicitud_viaje` propia en estado `PUBLICADA`/`NEGOCIANDO`/`ASIGNADA`, el pasajero no puede publicar otra — el botón "Solicitar taxi" debe estar deshabilitado o redirigir a la solicitud/viaje ya activo. Solo puede crear una nueva tras `COMPLETADO`, `CANCELADO` o `EXPIRADA`.

## 4. Negociación (núcleo tipo inDrive)
1. Conductores `DISPONIBLE` cercanos ven la solicitud en tiempo real, superpuesta como overlay/bottom sheet sobre el mapa de solicitudes (no como navegación a página aparte).
2. El conductor puede **aceptar tal cual** el precio sugerido, o **contraofertar** un precio distinto (crea `oferta_viaje`) — la contraoferta debe estar entre el **90% y el 130%** del precio sugerido (confirmado).
3. El conductor puede **retirar** su oferta en cualquier momento antes de que el pasajero la acepte (`estado = RETIRADA`) — no puede editarla; si quiere ofrecer otro precio, retira y crea una nueva oferta.
4. El pasajero ve las ofertas entrantes **ya ordenadas por el backend** (combinación de precio + cercanía/ETA + bono por calificación del conductor), mostrando **únicamente el precio ofertado** por cada una — sin nombre, foto, vehículo, ETA ni distancia del conductor, que permanecen ocultos hasta la asignación (ver sección 5). Se muestran las primeras 5 con scroll para el resto. El cliente no reordena ni recalcula el criterio de orden.
5. El pasajero acepta una oferta → se crea `viaje` (`estado = ASIGNADO`), todas las demás ofertas de esa solicitud pasan a `RECHAZADA` automáticamente (invariante garantizada por backend), y se notifica a cada conductor no elegido que su oferta fue rechazada (ver sección 11.4, regla general de notificaciones).
6. Los conductores no elegidos dejan de ver esa solicitud. **Un conductor puede tener ofertas `PENDIENTE` en varias solicitudes distintas a la vez**; en cuanto es asignado a una, el backend retira automáticamente (`estado = RETIRADA`, origen sistema) todas sus demás ofertas pendientes en otras solicitudes, **notificándole explícitamente** ("Tu oferta fue retirada: aceptaste otro viaje" o similar) — nunca debe desaparecer de su lista sin explicación.

## 5. Viaje asignado → en curso → finalizado
1. `ASIGNADO`: se revela al pasajero el nombre parcial del conductor (primer nombre + apellido paterno, nunca el nombre completo), foto, datos del vehículo, tiempo de llegada y distancia actual — toda esta información estaba oculta durante la negociación (sección 4). El conductor navega hacia el origen con tracking en vivo; el pasajero ve el mapa con ETA. **El chat de texto se habilita desde este momento**, con contador de mensajes no leídos visible. El **precio acordado permanece visible de forma persistente** en la UI a partir de aquí y durante todo el resto del viaje.
2. El conductor marca "Llegué" → `CONDUCTOR_LLEGO`; se muestra el `codigo_otp` al pasajero.
3. El conductor ingresa el OTP → si coincide, `EN_CURSO` (`hora_inicio`); si no, puede reintentar (límite de intentos lo define backend).
4. Durante `EN_CURSO`: mapa con ruta al destino, ubicación en vivo, chat activo, botón SOS disponible (visible siempre en la UI, funcional solo en este estado y en `ASIGNADO`/`CONDUCTOR_EN_CAMINO`/`CONDUCTOR_LLEGO`). Si se pierde conexión (WebSocket o GPS), la UI muestra "reconectando" **sin borrar** la última ruta/posición conocida — el vehículo debe seguir viéndose en su último punto conocido mientras se restablece, nunca un mapa en blanco. Se monitorea desviación de ruta (ver sección 13).
5. El conductor marca "Finalizar viaje" al llegar → `COMPLETADO` (`hora_fin`, distancia y duración reales calculadas por backend).
6. Chat pasa a solo lectura. Resumen para ambos: `precio_acordado` y, del lado del conductor, `monto_neto_conductor` (tras `comision_porcentaje_aplicada`, ya calculado por backend — el cliente nunca calcula la comisión).
7. Modal de calificación mutua (1-5 + comentario opcional), disponible 15 minutos. Si cualquiera de las partes no califica en ese plazo, el backend registra automáticamente una calificación de 5 estrellas (`fue_automatica = true`) para esa parte. El cliente no necesita implementar temporizador propio: simplemente deja de ofrecer el modal si el usuario reabre la pantalla después de que el backend ya haya cerrado la ventana.
8. El viaje pasa al historial de ambos usuarios.

## 6. Cancelación
- El pasajero puede cancelar mientras el viaje está `ASIGNADO`/`CONDUCTOR_EN_CAMINO`/`CONDUCTOR_LLEGO` (antes de `EN_CURSO`). El conductor puede cancelar en cualquier estado previo a `EN_CURSO`.
- **No existe ventana de gracia ni penalidad monetaria.** Toda cancelación posterior a la asignación impacta la calificación de quien cancela (el backend la reduce; el cliente debe advertir esto antes de confirmar la cancelación — ver modal de confirmación en [`design_patterns.md`](design_patterns.md)).
- Se registra `motivo_cancelacion` y `cancelado_por`. La solicitud original no se reabre automáticamente.

## 7. SOS
1. Usuario pulsa SOS (disponible desde `ASIGNADO` en adelante) → modal de confirmación → al confirmar, se crea `sos_alerta` con ubicación actual.
2. El backend notifica al **contacto de emergencia** del usuario y **al administrador** (vía el sistema del dashboard, fuera de esta app). Esta app solo dispara la alerta y muestra confirmación de envío; no gestiona el flujo de atención.

## 8. Chat de viaje
Chat de texto simple asociado a `viaje_id`, habilitado desde `ASIGNADO` hasta `COMPLETADO`, después de lo cual queda de solo lectura. Es un requisito v1 confirmado — no opcional. Coexiste con la opción de llamar por teléfono (`url_launcher`), que se mantiene siempre disponible como alternativa.

## 9. Ganancias del conductor
`viaje.estado = COMPLETADO` alimenta el reporte de ganancias, mostrando siempre el desglose **bruto** (`precio_acordado`) y **neto** (`monto_neto_conductor`, tras comisión) por separado y con etiqueta clara. El porcentaje de comisión en sí (configurable desde el dashboard admin) no se expone como dato editable en esta app — el conductor solo ve el resultado ya aplicado.

## 10. Sistema de calificación como mecanismo de prioridad (no de penalidad monetaria)
Todos los usuarios y conductores arrancan en 5.0. Cada cancelación o "solicitud falsa" reduce la calificación del pasajero; cada viaje mal calificado reduce la del conductor. No hay penalidad monetaria ni bloqueo automático, pero:
- Un pasajero con calificación baja pierde prioridad al publicar una solicitud (el backend decide cómo se refleja esto en la visibilidad/orden hacia los conductores).
- Un conductor con calificación baja queda al final del orden de ofertas mostrado al pasajero, incluso si está más cerca o su precio es mejor.
El cliente no implementa esta lógica de ranking — solo consume el resultado ya ordenado que el backend entrega (ver [`design_patterns.md`](design_patterns.md) sección 2).

## 11. Registro y gestión de cuenta (reglas transversales, pasajero y conductor)
1. **Verificación por OTP**: solo en la **creación** de la cuenta (pasajero), por código enviado al email; expira en 10 minutos, reenviable con un cooldown de 60 segundos (valores por defecto razonables, ajustables por backend). El login en v1 **no** usa doble factor.
2. **Términos y condiciones**: checkbox de aceptación explícita obligatorio en el registro de ambos roles. V1 usa un texto estándar/genérico como placeholder, versionado (`terminos_version`), reemplazable por el del departamento legal sin romper el historial de aceptaciones (confirmado, ver [`database.md`](database.md) y [`requerimientos_backend.md`](requerimientos_backend.md) sección 2.1).
3. **Edad mínima**: **18 años para todo usuario** (pasajero y conductor por igual), validada por fecha de nacimiento en el formulario de registro. Confirmado en ronda final de preguntas — reemplaza la regla anterior de 15 años para pasajero; al fijar el mínimo en 18, **no aplica ningún flujo de consentimiento parental** (no se admiten menores de edad en la plataforma).
4. **Contacto de emergencia obligatorio**: no se puede completar el registro (o, como mínimo, no se puede publicar una solicitud/ponerse disponible) sin al menos un contacto de emergencia registrado — es un requisito, no una opción.
5. **Cambio de email/teléfono**: permitido después del registro, pero requiere re-verificación; el valor anterior sigue siendo el vigente hasta que el nuevo se confirme.
6. **Eliminar cuenta**: disponible desde v1, accesible desde Perfil/Configuración (requisito de las tiendas de apps para publicar).
7. **Sin conversión de rol**: un pasajero no puede solicitar convertirse en conductor (ni viceversa) con la misma cuenta — debe ser una cuenta nueva con otro email si aplica, y ambas cuentas son independientes entre sí.

### 11.1 Moneda determinada por ubicación
Al momento de calcular el precio sugerido (sección 3), el backend determina el país a partir de la ubicación de origen de la solicitud y fija la `moneda` correspondiente (USD en Ecuador; en v2, peso colombiano o sol peruano según el país). El usuario nunca elige la moneda. **Viajes transfronterizos no permitidos** (confirmado): si el destino cae en un país distinto al de origen, el backend rechaza la solicitud (validado con reverse geocoding de ambos puntos, ver [`requerimientos_backend.md`](requerimientos_backend.md) sección 4.1) — el cliente debe mostrar un mensaje claro si esto ocurre, no un error genérico.

### 11.2 Notificaciones — principio general
Ningún evento relevante para un usuario debe ocurrir sin que se le informe explícitamente: oferta retirada o rechazada, viaje cancelado por la contraparte, conductor aprobado, mensaje de chat nuevo, etc. Antes de dar por completa una tarea que introduce un nuevo evento de negocio, verificar que dispare la notificación correspondiente (ver también checklist en [`qa_checklist.md`](qa_checklist.md)).

## 12. Sesión única — flujo de login con confirmación
1. El usuario introduce credenciales válidas. Si no existe otra sesión activa para esa cuenta, el login procede normalmente.
2. Si existe una sesión activa en otro dispositivo **y esa cuenta no tiene un viaje `ASIGNADO`/`EN_CURSO`**, el backend responde pidiendo confirmación (sin invalidar todavía la sesión anterior). El cliente muestra un modal: *"Esto cerrará tu sesión en tu otro dispositivo, ¿continuar?"*. Si el usuario confirma, se reintenta el login con un flag de confirmación y el backend invalida la sesión anterior y emite tokens nuevos para el dispositivo actual.
3. Si existe una sesión activa **y esa cuenta tiene un viaje `ASIGNADO`/`EN_CURSO`**, el login se **bloquea por completo** — no se ofrece ni la opción de confirmar. El mensaje de bloqueo se muestra en el **dispositivo que intenta iniciar sesión** ("No puedes iniciar sesión: hay un viaje en curso con esta cuenta"), nunca se interrumpe la sesión ya activa que está atendiendo el viaje.

## 13. Detección de desviación de ruta y check-in de seguridad (confirmado, requisito de seguridad v1)
Prioridad explícita del producto: proteger a un pasajero que pueda estar sufriendo un robo o secuestro, por encima de la conveniencia de evitar falsos positivos.

1. Durante `EN_CURSO`, el cliente compara la posición en vivo del conductor contra la geometría de la ruta ya trazada (polyline decodificada al aceptar el viaje).
2. Umbral (basado en el estándar de la industria, ej. Uber RideCheck): **desviación mayor a 500 metros sostenida por más de 90 segundos**, o **una parada no planificada de más de 3 minutos** fuera del origen/destino.
3. Al superarse el umbral, ocurren dos cosas **en paralelo**, no una condicionada a la otra:
   - Se crea automáticamente una alerta de seguridad visible de inmediato para el administrador (`sos_alerta` con `origen = DESVIACION_AUTOMATICA`), **sin depender de que el pasajero confirme nada** — si está siendo coaccionado, no se puede asumir que pueda reaccionar.
   - El cliente del pasajero muestra un **check-in discreto y no alarmante** ("¿Todo bien con tu viaje?" con opción de confirmar que está bien o pedir ayuda) — deliberadamente de bajo perfil, para no escalar una situación de riesgo si otra persona tiene el control del dispositivo. Si no responde en ~60 segundos o pide ayuda, la alerta ya creada se mantiene/escala; si confirma que está bien, se marca la alerta como posible falso positivo pero no se elimina el registro (queda para auditoría).
4. El evento (sea o no confirmado como real) se registra en `viaje_tracking` para trazabilidad completa del viaje.

## 14. Viajes recurrentes
Si un mismo par origen-destino fue solicitado más de 2 veces por el mismo pasajero, se muestra en Home/Historial como "viaje recurrente" con opción de repetirlo en un toque, precargando origen y destino y reutilizando el flujo de la sección 3 desde el paso de precio sugerido.

## 15. Privacidad de contacto telefónico (regla de seguridad no negociable)
La llamada entre pasajero y conductor **nunca** expone el número de teléfono real de ninguna de las dos partes. El backend debe proveer un mecanismo de número intermediario/enmascarado (ver [`requerimientos_backend.md`](requerimientos_backend.md) y [`security.md`](security.md)); el botón de llamada del cliente siempre marca a ese número intermedio, nunca a un número personal almacenado localmente.
