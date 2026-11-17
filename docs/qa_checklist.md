# Checklist de aceptación (Definition of Done)

Esto es lo que convierte "el código compila y pasa sus tests unitarios" en "la pantalla/flujo está realmente terminada, sin fallos de diseño, experiencia de usuario o seguridad". Es un complemento a [`testing.md`](testing.md), no un sustituto: los tests automatizados verifican lógica; este checklist verifica cosas que un test unitario no puede certificar por sí solo (estados visuales, consistencia, seguridad aplicada de punta a punta). Toda tarea de [`task.md`](task.md) que entregue o modifique una pantalla debe pasar este checklist antes de marcarse `completo`.

## A. Checklist de UX por pantalla (aplicar a cada pantalla nueva o modificada)
- [ ] Existe un estado de **carga** (loading) visible mientras se espera una respuesta de red — nunca una pantalla en blanco sin feedback.
- [ ] Existe un estado **vacío** (empty state) con mensaje útil, no solo una lista en blanco (ej. "Aún no tienes viajes" en vez de nada).
- [ ] Existe un estado de **error** con mensaje claro y accionable (reintentar, volver), nunca un mensaje técnico crudo (stack trace, código HTTP sin traducir).
- [ ] Toda acción irreversible o sensible (cancelar viaje, activar SOS, cerrar sesión) tiene **confirmación explícita** antes de ejecutarse.
- [ ] Todo texto visible al usuario está externalizado vía `l10n` (no hardcodeado), salvo que la tarea explícitamente no lo requiera aún (ver [`requirements.md`](requirements.md) sección Internacionalización).
- [ ] La pantalla se ve correctamente en **tema claro y oscuro** (`context.appColors`, no colores hardcodeados).
- [ ] La pantalla respeta la jerarquía de Atomic Design (reutiliza átomos/moléculas existentes en vez de duplicar estilos) — ver [`design_patterns.md`](design_patterns.md).
- [ ] Tamaños de toque de botones/controles son razonables para uso con una mano en movimiento (contexto: usuario parado en la calle esperando un taxi, no sentado con calma).
- [ ] Si la pantalla depende de permisos nativos (ubicación, notificaciones), maneja el caso de **permiso denegado** sin crashear ni quedar en un estado inconsistente.
- [ ] Ningún valor de negocio potencialmente configurable por el administrador (precio mínimo, distancia máxima, radio de búsqueda, rango de contraoferta) está hardcodeado — proviene de `GET /config/public` (ver [`requerimientos_backend.md`](requerimientos_backend.md) sección 4.4).
- [ ] Si la pantalla es un check-in de seguridad o una alerta relacionada con SOS/desviación de ruta, su diseño es **discreto y no alarmante** (ver [`flow.md`](flow.md) sección 13) — nunca una alarma sonora/visual evidente que pueda poner en riesgo al usuario.

## B. Checklist de seguridad por feature (aplicar según lo que la tarea toque)
- [ ] Ninguna llamada de red con datos de usuario va sin verificar que use HTTPS/WSS (ver [`security.md`](security.md) RNF5).
- [ ] Ningún token, contraseña o dato sensible aparece en un `print`/log de depuración que pueda llegar a builds de release.
- [ ] Toda pantalla/acción restringida por rol o por estado (ej. conductor no verificado, viaje ya finalizado) valida ese estado en el cliente **y** asume que el backend la revalida — nunca confía solo en el guard del cliente (ver [`security.md`](security.md) punto 13).
- [ ] Si la tarea toca almacenamiento local, confirma que no se está usando `SharedPreferences`/SQLite para nada que debería ir en `flutter_secure_storage` (tokens, códigos OTP en tránsito).
- [ ] Si la tarea toca el canal de tiempo real (STOMP), confirma que la suscripción a un topic específico de un `viaje_id` solo ocurre si el usuario actual es parte de ese viaje (defensa en profundidad, aunque el backend también lo valide).
- [ ] Si la pantalla muestra datos de la contraparte de un viaje (nombre, foto, vehículo, número de teléfono), confirma que **antes de la asignación** ninguno de esos datos es visible (solo precio durante la negociación), y que la llamada telefónica usa siempre el número proxy, nunca uno real (ver [`flow.md`](flow.md) secciones 4 y 15).
- [ ] Si la tarea introduce un nuevo evento de negocio (oferta retirada, viaje cancelado, conductor aprobado, etc.), confirma que dispara una notificación al usuario afectado — nunca lo deja enterarse solo al refrescar la pantalla (ver [`flow.md`](flow.md) sección 11.2).

## C. Checklist de consistencia de producto
- [ ] El comportamiento implementado coincide exactamente con lo descrito en [`flow.md`](flow.md) — si difiere, se corrigió el código o se actualizó el doc, nunca quedaron desalineados.
- [ ] Si la pantalla depende de una decisión que estaba en [`questions_pantallas.md`](questions_pantallas.md) o [`questions_flujos.md`](questions_flujos.md), esa pregunta ya fue respondida y movida al historial de [`questions.md`](questions.md) antes de implementar — no se implementó sobre un supuesto.
- [ ] Si la tarea introduce un nuevo estado visual o de error, se agregó al inventario correspondiente (`functionality.md` si cambia el alcance, o el propio `flow.md` si es un caso de negocio nuevo).

## D. Checklist de cumplimiento para tiendas de apps (verificar antes de cualquier release, no por tarea)
> V1 se publica **solo en Ecuador** (confirmado) — este checklist cubre ese alcance único, no una publicación multi-país simultánea.
- [ ] Opción de "eliminar cuenta" accesible y funcional (confirmado como requisito v1, ver [`flow.md`](flow.md) sección 11.1).
- [ ] Enlace a Política de Privacidad visible en la ficha de la tienda y dentro de la app (aunque sea el texto placeholder v1).
- [ ] Descripciones de permisos nativos (ubicación en segundo plano, notificaciones) justifican su uso en el texto que exige cada tienda.
- [ ] Clasificación de edad de la ficha coincide con el mínimo real de la app (18 años, sin contenido para menores).
- [ ] Firma de release real configurada para Android (no el keystore de debug, ver [`security.md`](security.md) A.5) antes de cualquier build de distribución.
- [ ] `minSdkVersion` Android = 24 (Android 7.0) y deployment target iOS = 16 configurados en el proyecto (ver [`requirements.md`](requirements.md)) — probar en (o emular) los mínimos, no asumir compatibilidad solo por probar en el dispositivo/simulador más nuevo.
- [ ] Ficha de la tienda en español (único idioma soportado en v1, ver [`functionality.md`](functionality.md) RF23).

## E. Verificación previa a considerar una fase completa (ver [`task.md`](task.md))
Antes de dar por cerrada una fase completa (no una tarea individual):
- [ ] Se ejecutaron los casos críticos correspondientes de [`testing.md`](testing.md) para esa fase.
- [ ] Se revisó el checklist A-D en cada pantalla nueva de esa fase, no solo en la última.
- [ ] Ningún `// TODO` de esa fase quedó sin una entrada correspondiente en `task.md`/`questions.md` (ver [`rules.md`](rules.md) regla 7).

## Cómo usar este documento
No es una lista para marcar mecánicamente al final — se revisa por pantalla, en el momento de implementarla, como parte de la misma tarea. Un agente que reporte una tarea como `completo` sin haber podido verificar un ítem de este checklist (ej. porque depende de un servidor real que aún no existe) debe decirlo explícitamente en vez de marcarlo como cumplido.

**Cambio de rol obligatorio (confirmado)**: quien implementa la tarea no se autocertifica en el mismo modo mental en que escribió el código. Al terminar, debe conscientemente adoptar el rol de QA ([`role.md`](role.md) rol 12) y recorrer este checklist como si revisara el trabajo de otra persona — buscando activamente cómo romperlo, no confirmando que "se ve bien". No existe un pipeline de CI ni un ambiente de staging en v1 (ver [`testing.md`](testing.md)): este checklist, ejecutado con esa disciplina, es la única red de seguridad antes de que un humano pruebe todo en local.
