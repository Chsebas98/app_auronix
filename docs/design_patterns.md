# Patrones de diseño y pantallas

## 1. Patrones ya establecidos (se mantienen)
Clean Architecture por feature, Repository pattern, `Either<Failure, T>` (dartz), BLoC (`flutter_bloc`), Service Locator (`get_it`), Atomic Design. Ver [`architecture.md`](architecture.md).

## 2. Patrones nuevos requeridos
- **Observer/Stream pattern** para `RealtimeClient` (STOMP): streams tipados por evento (ofertas, ubicación, estado de viaje, chat); los blocs se suscriben, nunca hablan STOMP directo.
- **State machine explícita** para `viaje.estado`, como función pura testeable en `domain`.
- **Orden de listas controlado por backend**: las listas de ofertas y de solicitudes cercanas llegan ya ordenadas/priorizadas (precio + ETA + calificación) — el cliente **no** reordena ni reimplementa ese criterio, solo renderiza en el orden recibido.
- **Debounce/throttle** en búsqueda de dirección de destino y en el envío de actualizaciones de ubicación en vivo.

## 3. Inventario de pantallas, modales y vistas
Alcance acotado: **sin pantallas de administrador ni de carga de documentos** (ambas fuera de este repo).

### 3.1 Autenticación (existente + ajustes)
Login, Registro cliente (3 pasos + paso de OTP por email + checkbox de T&C + fecha de nacimiento con validación de edad mínima **18 años**), Registro conductor (simplificado, ver 3.3, edad mínima 18 años), Recuperar contraseña (nuevo usecase). Se elimina cualquier rama de UI para `rolAdmin`/`rolGerente` en el flujo de login — no aplican a este cliente.
**Nuevo — Términos y condiciones**: se usa una versión estándar/genérica de T&C y Política de Privacidad como placeholder v1 (texto a definir, ver [`flow.md`](flow.md) sección 11), versionada (`terminos_version`) para poder reemplazarla por la del departamento legal sin duplicar lógica — la pantalla de registro debe apuntar a esta versión, no a un texto embebido sin control de versión.
**Nuevo — Modal de confirmación de sesión**: al hacer login con una sesión activa en otro dispositivo sin viaje en curso, mostrar modal "Esto cerrará tu sesión en tu otro dispositivo, ¿continuar?" antes de proceder. Si la cuenta tiene un viaje en curso, mostrar un mensaje de bloqueo (no un modal de confirmación) — ver [`flow.md`](flow.md) sección 12.
**Nuevo — Eliminar cuenta**: acción disponible desde Perfil/Configuración, con confirmación explícita (ver [`qa_checklist.md`](qa_checklist.md)).

### 3.2 Pasajero (cliente)
| Pantalla/Modal | Tipo | Notas |
|---|---|---|
| Home cliente | Page | ubicación real, botón pedir taxi, redirige directo a viaje activo si existe uno, muestra "viajes recurrentes" si aplica |
| Seleccionar destino | Page | buscador de direcciones (ver proveedor elegido en [`requerimientos_backend.md`](requerimientos_backend.md) sección 9) + mapa con pin arrastrable (ambos métodos permitidos) + validación de distancia máxima 150 km |
| Confirmar viaje y precio | Page/Organism | precio sugerido (número exacto, 2 decimales) + input editable con validación de mínimo (obtenido de config pública, no hardcodeado) |
| Buscando conductores | Page | mapa con círculo de 10 km de cobertura y vehículos cercanos (íconos/animación realista), indicador de tiempo de espera estimado y distancia, lista de ofertas entrantes como **overlay/bottom sheet sobre el mapa** (no página aparte) — primeras 5 visibles, resto con scroll |
| Tarjeta de oferta recibida | Molecule | **solo precio ofertado** (sin foto/nombre/vehículo/ETA — ocultos hasta la asignación, ver [`flow.md`](flow.md) sección 4) |
| Modal aceptar oferta | Modal (Organism) | confirmación antes de aceptar |
| Solicitud expirada / republicar | Modal/Page | al republicar, el input de precio no permite un valor menor al anterior (validación visible antes de enviar) |
| Viaje asignado (conductor en camino) | Page | tracking en vivo, ETA, **ahora sí** datos conductor (nombre parcial + foto) y vehículo, botón llamar (número enmascarado, nunca real), botón chat con badge de no leídos, botón cancelar (con aviso de impacto en calificación), código OTP visible, **precio acordado siempre visible** |
| Chat de viaje | Page | texto en vivo, habilitado desde asignación hasta fin del viaje, contador de no leídos |
| Viaje en curso | Page | mapa con ruta en vivo, botón SOS (visible siempre, funcional solo aquí), acceso a chat, precio siempre visible |
| Check-in de seguridad | Modal (discreto, no alarmante) | aparece si se detecta desviación/parada no planificada; "¿Todo bien con tu viaje?" con opción de confirmar o pedir ayuda; la alerta al administrador ya se disparó independientemente de esta respuesta (ver [`flow.md`](flow.md) sección 13) |
| Viaje finalizado — resumen | Page | precio final, distancia, duración |
| Modal calificar conductor | Modal (Organism) | estrellas 1-5 + comentario opcional; si no se completa en 15 min, el backend la autocompleta en 5 y el cliente deja de mostrar el prompt |
| Historial de viajes | Page + lista | resalta viajes recurrentes (misma ruta solicitada más de 2 veces) con opción de repetir en un toque |
| Detalle de viaje pasado | Page | |
| Perfil | Page | datos, foto, contacto de emergencia (obligatorio, no se puede dejar vacío), cambio de email/teléfono con re-verificación, eliminar cuenta |
| Modal SOS | Modal (Organism) | confirmación previa obligatoria; botón visible en toda la UI del viaje pero solo habilitado si hay viaje activo |
| Configuración | Page | tema, notificaciones. **Sin selector de idioma en v1** (la app solo tiene español, ver [`requirements.md`](requirements.md)) — no construir este control hasta que exista un segundo idioma real |

### 3.3 Conductor
| Pantalla/Modal | Tipo | Notas |
|---|---|---|
| Registro conductor | Page (un solo formulario, sin wizard de documentos) | datos personales (edad mínima 18) + licencia + placa (validada según país detectado) + datos básicos de vehículo. **No incluye carga de documentos** — al enviar, la cuenta queda `PENDIENTE`. Conserva un borrador local si se abandona a mitad |
| Pendiente de verificación | Page | mensaje claro con SLA estimado ("~24 horas"), botón para solicitar reenvío del correo de verificación. Si `estado_verificacion = RECHAZADO`, el motivo y el reenvío de documentación ocurren en el portal externo, no aquí |
| Home conductor | Page | mapa real, toggle disponible/no disponible (solo habilitado si `APROBADO` **y GPS activo**), redirige directo a viaje activo si existe uno |
| Solicitudes cercanas | Page | mapa con círculo de 10 km y marcadores de solicitudes cercanas + lista en tiempo real como overlay, primeras 5 con scroll |
| Detalle de solicitud | Organism/Modal | origen, destino, distancia, precio sugerido — **sin datos del pasajero** hasta la asignación |
| Modal enviar oferta | Modal (Organism) | aceptar precio sugerido o contraofertar dentro del rango permitido (90%-130% del sugerido, ver [`flow.md`](flow.md) sección 4) |
| Retirar oferta | Acción (no pantalla nueva) | botón sobre la oferta ya enviada mientras esté `PENDIENTE` |
| Esperando respuesta del pasajero | Page/Organism | |
| Viaje asignado — ir a recoger | Page | mapa, botón "Llegué", **ahora sí** se revela nombre parcial del pasajero (primer nombre + apellido paterno), precio acordado siempre visible |
| Validar OTP de recogida | Modal (Organism) | input de 4-6 dígitos |
| Chat de viaje | Page | igual patrón que pasajero, con badge de no leídos |
| Viaje en curso | Page | botón "Finalizar viaje", aviso de desviación de ruta si aplica, SOS (visible siempre, funcional solo aquí), chat, precio siempre visible |
| Viaje finalizado — resumen | Page | muestra `precio_acordado` y `monto_neto_conductor` (tras comisión) por separado, con etiqueta clara de cuál es cuál |
| Modal calificar pasajero | Modal (Organism) | |
| Historial de viajes | Page | resalta viajes recurrentes del mismo pasajero si aplica |
| Ganancias / Métricas | Page | filtro por rango de fechas, datos reales, desglose bruto/neto. **Sin exportación** en v1, solo visualización |
| Perfil / Vehículo | Page | solo lectura de datos del vehículo y estado de verificación (no editable desde aquí), contacto de emergencia (obligatorio), eliminar cuenta |

> **Eliminado de esta app** (vs. versión anterior de este documento): todas las pantallas de "Administrador" y "Gerente de cooperativa" — viven en el dashboard web separado. Eliminado también cualquier componente de carga de documentos (`DocumentUploadTile`).

## 4. Componentes atómicos nuevos en `lib/shared/`
- `AppRatingStars` (atom) — construido con componentes existentes, sin nueva dependencia.
- `AppOtpInput` (atom/molecule) — input de código numérico segmentado.
- `AppPriceInput` (atom) — input numérico con formato de moneda y validación de mínimo (evitar valores cercanos a cero).
- `VerificationStatusBadge` (atom) — chip `PENDIENTE`/`APROBADO`/`RECHAZADO`.
- `SosButton` (atom, con confirmación) + `SosConfirmModal` (organism).
- `ChatBubble` (molecule, en `trips/chat/presentation/molecules/` por ser específico del dominio de chat).
- `OfferCard` (molecule, en `trips/negotiation/presentation/molecules/`).
- `LiveTrackingMap` (organism, en `trips/presentation/organisms/`, extiende el patrón de `driver_nearby_map.dart`).

Regla: componente reutilizable entre features → `lib/shared/`; específico de un dominio → dentro de la feature (ver [`hierarchy.md`](hierarchy.md)).
