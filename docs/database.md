# Base de datos

Esquema de referencia que el frontend espera del backend (Spring Boot). Las tablas de **verificación documental y administración** (cooperativas, aprobación de conductores, documentos) son responsabilidad exclusiva del backend/dashboard admin — aquí solo se documentan los **campos de esas tablas que el frontend móvil necesita leer**, no su modelo completo de gestión (ese detalle, si aplica, vive en el proyecto del dashboard admin, fuera de este repositorio).

## 1. Esquema remoto de referencia

### `usuario` (base de toda cuenta — pasajero o conductor)
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| email, telefono | varchar, **UNIQUE** | |
| password_hash | — | nunca viaja al cliente |
| primer_nombre, segundo_nombre, apellido_paterno, apellido_materno | varchar | |
| foto_url | varchar nullable | |
| fecha_nacimiento | date | valida edad mínima: **18 años para todo usuario** (`rol = USER` o `DRIVER` por igual, confirmado — sin excepción para menores) |
| terminos_aceptados_en | timestamp | obligatorio antes de activar la cuenta; registra cuándo aceptó T&C/política de privacidad |
| terminos_version | varchar | versión del texto legal aceptado (v1 usa una versión estándar/genérica como placeholder, reemplazable por la del departamento legal sin romper el historial de aceptaciones ya registradas) |
| rol | enum (`USER`, `DRIVER`) | **fijo al momento del registro, sin conversión posterior** (confirmado); un mismo `email` no puede tener cuentas con distinto rol |
| estado_cuenta | enum (`ACTIVA`, `SUSPENDIDA`, `ELIMINADA`) | `ELIMINADA` soporta el requisito de "eliminar cuenta" disponible desde v1 (soft delete recomendado para conservar integridad referencial del historial de viajes) |
| sesion_activa_id | varchar/UUID nullable | identificador (jti) del refresh token vigente; cualquier token con un `jti` distinto al almacenado aquí se rechaza — implementa la regla de **sesión única**: un nuevo login sobrescribe este valor e invalida el anterior, salvo que exista un `viaje` `ASIGNADO`/`EN_CURSO` para ese usuario, en cuyo caso el nuevo login se bloquea por completo (confirmado, ver [`flow.md`](flow.md) sección 12 y [`architecture.md`](architecture.md) sección 4) |
| calificacion_promedio | decimal(3,2), **default 5.00** | aplica a pasajero y conductor por igual; baja con cancelaciones/solicitudes falsas (pasajero) o mala conducta (conductor) |
| fcm_token | varchar nullable | |
| is_google_user | boolean | |
| created_at, updated_at | timestamp | |

### `conductor` (extiende `usuario` 1—1)
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| usuario_id | FK → `usuario.id`, UNIQUE | |
| cooperativa_id | FK → `cooperativa.id`, nullable hasta ser asignada | **exclusiva**: un conductor pertenece a una sola cooperativa; solo el admin la asigna/cambia |
| vehiculo_id | FK → `vehiculo.id`, UNIQUE, nullable hasta ser asignado | relación **fija**: solo el admin puede reasignar el vehículo de un conductor |
| cedula_licencia | varchar | |
| estado_verificacion | enum (`PENDIENTE`, `APROBADO`, `RECHAZADO`) | gestionado íntegramente por el flujo externo (correo + portal de verificación); el móvil solo lo lee |
| disponibilidad | enum (`DISPONIBLE`, `OCUPADO`, `DESCONECTADO`) | editable por el conductor solo si `estado_verificacion = APROBADO` y GPS activo; el backend lo pasa a `DESCONECTADO` automáticamente tras **3 minutos** sin señal/conexión |
| ubicacion_actual | point (PostGIS `geography`) nullable | |
| ubicacion_actualizada_en | timestamp nullable | |

### `vehiculo` (campos que el móvil necesita mostrar; gestión completa es del dashboard admin)
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| placa, marca, modelo, anio, color, tipo | varchar/int | solo lectura desde el móvil |
| foto_url | varchar nullable | |
| estado_verificacion | enum (`PENDIENTE`, `APROBADO`, `RECHAZADO`) | |

### `cooperativa` (solo lectura desde el móvil — dato de referencia)
| id | nombre | — el móvil solo necesita `nombre` para mostrarlo en el perfil del conductor/insignia de verificado |

> Las tablas de verificación documental (licencia, SOAT, biometría, etc.) viven en el dominio del dashboard admin y **no** forman parte del contrato de este frontend — no se documentan aquí.

### `contacto_emergencia`
| id PK | usuario_id FK | nombre | telefono | relacion | created_at |
**Obligatorio** (confirmado): un `usuario` debe tener al menos una fila aquí antes de poder publicar una solicitud o ponerse `DISPONIBLE` — no es un dato opcional de perfil.

### `solicitud_viaje`
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| pasajero_id | FK → `usuario.id` | |
| origen_lat, origen_lng, origen_direccion | double/varchar | |
| destino_lat, destino_lng, destino_direccion | double/varchar | |
| distancia_km, duracion_estimada_min | decimal/int | calculados por backend; `distancia_km` **no puede superar 150** (límite v1, confirmado) |
| precio_sugerido | decimal | calculado por backend |
| precio_publicado | decimal | precio final que el pasajero publicó (puede ser igual o distinto al sugerido), validado: numérico, decimal permitido, **mínimo $0.50** (configurable por el administrador desde el dashboard — el cliente lo obtiene de un endpoint de configuración pública, no lo hardcodea, ver [`requerimientos_backend.md`](requerimientos_backend.md)) |
| moneda | varchar(3), ISO 4217, **default `USD`** | **confirmado**: determinada automáticamente por el país detectado en `origen_lat/origen_lng` (reverse geocoding) al momento de la solicitud — nunca elegida por el usuario. V1 = `USD` (Ecuador); v2 añade `COP` (Colombia) y `PEN` (Perú). Nunca hardcodear el símbolo "$" en el cliente. **Viajes transfronterizos no permitidos** (confirmado): el backend rechaza la solicitud si el país del destino difiere del país del origen |
| solicitud_original_id | FK → `solicitud_viaje.id`, nullable | si es una republicación; el backend debe validar `precio_publicado >= precio_publicado` de la solicitud original |
| estado | enum (`PUBLICADA`, `NEGOCIANDO`, `ASIGNADA`, `EXPIRADA`, `CANCELADA`) | |
| created_at, expira_en | timestamp | `expira_en = created_at + 5 minutos` (fijo, sin extensión) |
Constraint de negocio: **índice único parcial** sobre `pasajero_id` para filas con `estado IN ('PUBLICADA','NEGOCIANDO','ASIGNADA')` — impide más de una solicitud activa simultánea por pasajero (confirmado, ver [`flow.md`](flow.md)).

### `oferta_viaje`
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| solicitud_id | FK → `solicitud_viaje.id` | |
| conductor_id | FK → `conductor.id` | |
| precio_ofertado | decimal | debe estar entre el **90% y el 130%** de `solicitud_viaje.precio_sugerido` (confirmado) |
| estado | enum (`PENDIENTE`, `ACEPTADA`, `RECHAZADA`, `EXPIRADA`, `RETIRADA`) | `RETIRADA`: la oferta dejó de estar disponible antes de ser aceptada. Una oferta **no se edita**, solo se retira (y opcionalmente se vuelve a crear con otro precio) |
| retirada_por | enum (`CONDUCTOR`, `SISTEMA`) nullable | distingue si el conductor la retiró manualmente o si el backend la retiró automáticamente porque ese conductor fue asignado a otra solicitud (confirmado en [`flow.md`](flow.md)) — el cliente usa este campo para decidir el mensaje de notificación exacto (siempre debe notificar, ver [`flow.md`](flow.md) sección 11.2) |
| orden_prioridad | calculado, no persistido necesariamente | el backend ordena las ofertas devueltas al pasajero combinando precio + cercanía/ETA + bono por `conductor.calificacion_promedio`; el cliente solo respeta el orden recibido, no lo recalcula |
| created_at | timestamp | |
Índice único: `(solicitud_id, conductor_id, estado)` no aplica directo por tener múltiples estados históricos — usar en su lugar un índice parcial/único sobre ofertas con `estado = 'PENDIENTE'` para impedir dos ofertas pendientes simultáneas del mismo conductor sobre la misma solicitud.

### `viaje`
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| solicitud_id | FK → `solicitud_viaje.id`, **UNIQUE** | |
| oferta_aceptada_id | FK → `oferta_viaje.id` nullable | |
| pasajero_id, conductor_id, vehiculo_id | FK | |
| precio_acordado | decimal | |
| moneda | varchar(3), ISO 4217, **default `USD`** | copiada de `solicitud_viaje.moneda` al crear el viaje |
| comision_porcentaje_aplicada | decimal | **snapshot** del porcentaje vigente al momento del viaje (el valor configurable puede cambiar después; el histórico no debe recalcularse) |
| monto_neto_conductor | decimal | `precio_acordado - (precio_acordado * comision_porcentaje_aplicada)`, calculado y persistido por backend |
| estado | enum (`ASIGNADO`, `CONDUCTOR_EN_CAMINO`, `CONDUCTOR_LLEGO`, `EN_CURSO`, `COMPLETADO`, `CANCELADO`) | |
| codigo_otp | varchar(4-6) | |
| motivo_cancelacion, cancelado_por | text nullable / FK nullable | sin ventana de gracia: cualquier cancelación post-asignación impacta la calificación de quien cancela |
| hora_asignacion, hora_llegada_conductor, hora_inicio, hora_fin | timestamp nullable | |
| distancia_recorrida_km, duracion_real_min | decimal/int nullable | |
| metodo_pago | enum (`EFECTIVO`) | único valor válido en v1; el enum se amplía en v2 sin romper compatibilidad |
| created_at | timestamp | |

### `viaje_tracking`
| id PK | viaje_id FK | tipo (`UBICACION`, `CAMBIO_ESTADO`) | lat, lng nullable | estado_anterior, estado_nuevo nullable | timestamp |

### `calificacion`
| id PK | viaje_id FK | calificador_id FK usuario | calificado_id FK usuario | puntuacion (1-5) | comentario nullable | fue_automatica (boolean) | created_at |
`fue_automatica = true` cuando el backend la generó automáticamente en 5 estrellas por vencimiento del plazo de 15 minutos. Constraint único: `(viaje_id, calificador_id)`.

### `mensaje_chat`
| id PK | viaje_id FK | remitente_id FK usuario | contenido (texto) | leido (boolean) | created_at |
Habilitado desde `viaje.estado = ASIGNADO` hasta `COMPLETADO`; de solo lectura después.

### `sos_alerta`
| Columna | Tipo | Notas |
|---|---|---|
| id | PK | |
| viaje_id | FK nullable | |
| usuario_id | FK | |
| origen | enum (`MANUAL`, `DESVIACION_AUTOMATICA`) | `MANUAL` = botón SOS presionado; `DESVIACION_AUTOMATICA` = disparada por el sistema al detectar desviación de ruta o parada no planificada (ver [`flow.md`](flow.md) sección 13), sin intervención del usuario |
| lat, lng | double | |
| estado | enum (`ACTIVA`, `ATENDIDA`, `FALSA_ALARMA`) | |
| atendido_por | FK nullable | |
| created_at | timestamp | |
Al crearse (de cualquier origen), el backend notifica al `contacto_emergencia` del usuario y al administrador (vía el sistema del dashboard, fuera de esta app). Una alerta `DESVIACION_AUTOMATICA` se crea de inmediato al superar el umbral, sin esperar respuesta del usuario en el check-in de la app (ver [`flow.md`](flow.md) sección 13).

### `notificacion` (historial de push)
| id PK | usuario_id FK | tipo | titulo | cuerpo | data_json | leido | created_at |

## 2. Índices recomendados
- Geoespacial (PostGIS `GIST`) sobre `conductor.ubicacion_actual` y sobre el punto de origen de `solicitud_viaje` — usado para el filtro de **10 km** confirmado en [`flow.md`](flow.md).
- B-tree en toda FK y en los `UNIQUE` ya listados (`usuario.email`, `usuario.telefono`, `vehiculo.placa`).
- B-tree compuesto en `solicitud_viaje(estado, created_at)`, `oferta_viaje(solicitud_id, estado)`, `viaje(pasajero_id, estado)`, `viaje(conductor_id, estado)`.
- Índice en `calificacion(viaje_id)` para el job que detecta calificaciones pendientes a los 15 minutos.

## 3. Caché local (sqflite, cliente Flutter)
Se mantiene la tabla `user` existente, **sin tokens** (migran a `flutter_secure_storage`, ver [`architecture.md`](architecture.md) y [`security.md`](security.md)). Tablas de caché de solo lectura: `trip_history_cache`, `active_trip_cache`. No se cachea localmente ninguna tabla de verificación documental (no aplica a esta app) ni de cooperativas más allá del nombre ya incluido en el perfil del conductor.
