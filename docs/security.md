# Seguridad

Hallazgos heredados de la base de código actual más los puntos específicos del producto ya acotado (sin panel admin ni carga de documentos en esta app). Lista de trabajo, no un checklist a resolver por iniciativa propia — ver [`rules.md`](rules.md) regla 23.

## A. Heredado de la base de código actual
1. **Tokens en texto plano** (SQLite/SharedPreferences). Acción: migrar a `flutter_secure_storage` (primer paso de la migración, [`architecture.md`](architecture.md)).
2. **Secretos hardcodeados en Dart** (`tokenKey`, `googleMapsApiKey`). Acción: evaluar `--dart-define` en tiempo de build.
3. **`EncryptHelpers`/`encrypt`/`pointycastle`**: se retiran del alcance (ver [`requirements.md`](requirements.md)) — no hay caso de uso confirmado; no reactivar sin una necesidad de negocio explícita.
4. **SSL pinning deshabilitado**: evaluar activarlo para producción, dado que ahora se transmite ubicación en vivo y chat.
5. **Firma de release Android con keystore de debug**: bloqueante para publicar; requiere keystore de producción protegido.
6. **`dart_jsonwebtoken` sin uso real**: se retira, reemplazado por `jwt_decoder` (solo lectura de `exp`, nunca verificación de firma — eso es responsabilidad exclusiva del backend).
7. **Mock de login de conductor con credenciales de prueba**: debe eliminarse al conectar el login real; es en sí mismo un bypass de autenticación si llega a producción.
8. **`RoleHelpers` inconsistente** (`ROL_ADMIN` vs `ROL_SUPER_ADMIN`): de menor relevancia ahora que `rolAdmin` no inicia sesión en esta app, pero conviene limpiarlo para evitar confusión futura.

## B. Específicos del producto ya acotado

### Alcance reducido de datos sensibles en este repositorio
9. Al no implementarse carga de documentos de verificación en esta app, los riesgos de manejo de imágenes de cédula/licencia/SOAT **no aplican a este repositorio** — son responsabilidad del portal externo de verificación y del dashboard admin. Este repo solo maneja el **resultado** (`estado_verificacion`), que no es un dato sensible en sí mismo.
10. La foto de perfil del usuario/conductor (no un documento de identidad, sino una foto de presentación) sí puede cachearse normalmente con `cached_network_image`.

### Ubicación en vivo
11. La ubicación en tiempo real de un conductor solo debe ser visible para el pasajero del viaje activo correspondiente (y viceversa) — el backend debe segmentar los topics STOMP por `viaje_id`.
12. Al finalizar/cancelar un viaje, cortar la suscripción a la ubicación en vivo de la contraparte de inmediato.

### Autenticación y autorización
13. El guard de rutas del cliente es UX, no seguridad — el backend re-valida el rol/estado en cada endpoint sensible (aceptar oferta, iniciar viaje, activar SOS).
14. La conexión STOMP se autentica con el mismo JWT; debe reconectar/rechazar si el token expira a mitad de una sesión de tiempo real.
15. Con `rolAdmin`/`rolGerente` fuera del alcance de login móvil, simplificar el código de roles para no dejar ramas muertas que un futuro cambio pueda reactivar por error (ver [`architecture.md`](architecture.md) sección 2).
16. **Sesión única con confirmación (confirmado como control de seguridad)**: mitiga que una cuenta comprometida/compartida quede activa en un dispositivo ajeno indefinidamente. Flujo de dos pasos (confirmar si no hay viaje activo, bloquear por completo si lo hay) — ver [`flow.md`](flow.md) sección 12 y [`architecture.md`](architecture.md) sección 4. El cliente debe distinguir "sesión invalidada por otro dispositivo" de "token expirado" para no confundir al usuario ni ocultar que alguien más intentó/inició sesión con su cuenta.
17. **Riesgo de invalidar sesión durante un viaje en curso — resuelto**: confirmado que si la cuenta tiene un viaje `ASIGNADO`/`EN_CURSO`, el nuevo login se bloquea por completo (no se permite ni con confirmación) hasta que el viaje termine. Esto evita el riesgo físico de dejar a un pasajero con un conductor "desconectado" a mitad de un viaje real.
18. **Privacidad de contacto telefónico (regla no negociable, confirmada)**: la llamada entre pasajero y conductor nunca expone el número real de ninguna parte — requiere que backend integre un servicio de enmascaramiento de llamadas (ver [`requerimientos_backend.md`](requerimientos_backend.md)). El nombre se revela solo parcialmente (primer nombre + apellido paterno) y solo al asignar el viaje, nunca antes ni completo.
19. **Datos de menores de edad — resuelto**: la edad mínima se fijó en 18 años para todo usuario precisamente para evitar el riesgo legal de tratar datos de menores sin consentimiento parental. No se admite ningún registro de un menor de edad; validar server-side, no solo en el cliente.
20. **Eliminar cuenta**: implementarlo como baja lógica (`estado_cuenta = ELIMINADA`) que preserve la integridad referencial del historial de viajes/calificaciones de la otra parte, pero que anonimice/purgue los datos personales del usuario eliminado según corresponda — no un `DELETE` físico que rompa el historial de viajes de terceros.

### Negociación y precio
21. `precio_publicado`/`precio_ofertado` deben validarse en cliente (numérico, mínimo $0.50 obtenido de configuración pública, dentro del rango 90%-130% para contraofertas) como UX, pero la validación real y final es del backend — no confiar solo en el cliente.
22. Manejar con gracia el caso en que el backend rechace "aceptar oferta" porque ya se asignó otra (condición de carrera resuelta por backend, visible en el cliente como mensaje claro, no como error genérico o crash).
23. La regla "republicar solo con precio ≥ anterior" y el límite de 150 km se validan en cliente para UX inmediata, pero el backend es la fuente de verdad — no asumir que el cliente puede bloquear un intento malicioso de bypass.

### Chat
24. Los mensajes de chat viajan sobre WSS (mismo canal STOMP autenticado); no deben quedar en logs de red (`LogInterceptor`/logs de STOMP) en texto plano en builds de producción.
25. El chat se cierra a solo lectura tras `COMPLETADO`/`CANCELADO` — el cliente no debe permitir enviar mensajes nuevos en ese estado aunque la UI quede en pantalla.

### SOS
26. La alerta SOS no debe depender exclusivamente de que la app esté en foreground con conexión estable — evaluar con backend un mecanismo de respaldo si no se confirma el envío en un tiempo corto.
27. El botón SOS requiere confirmación previa (ver [`design_patterns.md`](design_patterns.md)) para evitar activaciones accidentales. Cada activación queda auditada (fecha/hora, ubicación) para el dashboard admin — confirmado como requisito, no un "nice to have".
28. Contacto de emergencia obligatorio (confirmado): reduce el riesgo de que un SOS quede sin destinatario útil más allá del administrador.

### Desviación de ruta y check-in de seguridad (confirmado)
29. Reportar la desviación detectada al backend no debe incluir más información de la necesaria para el registro de auditoría (coordenadas y timestamp) — no convertir este canal en un mecanismo de tracking adicional fuera de lo ya cubierto por `viaje_tracking`.
30. **La alerta automática al administrador se dispara de inmediato al superar el umbral, sin esperar confirmación del pasajero** — diseñado así deliberadamente para cubrir el escenario de robo/secuestro donde el pasajero no puede actuar con libertad. El check-in en la app es un canal adicional para el pasajero, nunca una condición previa para notificar al administrador.
31. El check-in debe ser visualmente discreto (no una alarma sonora/visual evidente) para no poner en riesgo al pasajero si otra persona controla el dispositivo en ese momento.

### Calificaciones
32. La calificación automática a los 15 minutos es responsabilidad del backend (job programado) — el cliente no debe implementar su propio temporizador que pueda desincronizarse del servidor y mostrar información inconsistente.

## Antes de tocar código de seguridad
No corrijas los puntos de esta lista como efecto colateral de otra tarea. Cada uno es una tarea propia y trazable en [`task.md`](task.md).
