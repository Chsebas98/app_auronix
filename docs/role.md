# Roles de agente

Un mismo agente puede asumir distintos roles según la tarea pedida. Identifica el rol antes de leer más código que el estrictamente necesario. **El panel de administrador y la verificación documental no viven en este repositorio** — ningún rol de esta lista construye esas pantallas aquí.

## 1. Arquitecto / Core
Toca `lib/app/**` o `lib/core/**` (DI, router, red, blocs globales, DB local).
Lee: [`architecture.md`](architecture.md), [`design_patterns.md`](design_patterns.md), [`hierarchy.md`](hierarchy.md).

## 2. Desarrollador de Feature (negocio general)
Implementa lógica dentro de `lib/features/<feature>/**` que no encaje en un rol más específico.
Lee: [`flow.md`](flow.md), [`functionality.md`](functionality.md), [`hierarchy.md`](hierarchy.md).

## 3. Ingeniero de negociación y viajes
Publicación de solicitudes, ofertas (aceptar/contraofertar/retirar), aceptación, máquina de estados del viaje, viajes recurrentes (`trips/negotiation/`).
Lee: [`flow.md`](flow.md) secciones 3-6 y 14 (viajes recurrentes), [`architecture.md`](architecture.md) sección 3, [`database.md`](database.md) (`solicitud_viaje`, `oferta_viaje`, `viaje`), [`rules.md`](rules.md).

## 4. Ingeniero de tiempo real
Implementa `RealtimeClient` (STOMP), reconexión, streams que consumen los blocs.
Lee: [`architecture.md`](architecture.md) sección 3, [`requerimientos_backend.md`](requerimientos_backend.md), [`requirements.md`](requirements.md).

## 5. Ingeniero de geolocalización y mapas
Activa `geolocator`/`geocoding` reales, dibuja rutas, gestiona frecuencia de actualización.
Lee: [`architecture.md`](architecture.md) sección 5, [`functionality.md`](functionality.md) (RNF1-3).

## 6. Ingeniero de estado de verificación (alcance reducido)
Muestra el estado del conductor (`PENDIENTE`/`APROBADO`/`RECHAZADO`) y bloquea acceso operativo — **no implementa carga de documentos ni panel de revisión**, eso vive fuera de este repo.
Lee: [`flow.md`](flow.md) sección 2, [`database.md`](database.md) (campos de `conductor`/`vehiculo` relevantes), [`context.md`](context.md).

## 7. Ingeniero de chat y notificaciones
Chat de texto en vivo (`trips/chat/`) sobre el mismo `RealtimeClient`, y consumo de push (FCM ya integrado en backend, solo se audita e integra del lado cliente).
Lee: [`flow.md`](flow.md) sección 8, [`architecture.md`](architecture.md) sección 6, [`requerimientos_backend.md`](requerimientos_backend.md).

## 8. Ingeniero de seguridad del usuario (SOS)
OTP de recogida, SOS, contacto de emergencia, compartir viaje en vivo, desviación de ruta/check-in de seguridad, privacidad de contacto telefónico.
Lee: [`flow.md`](flow.md) secciones 5, 7, 13 (desviación/check-in) y 15 (privacidad telefónica), [`database.md`](database.md) (`sos_alerta`, `contacto_emergencia`), [`security.md`](security.md), [`requerimientos_backend.md`](requerimientos_backend.md) sección 4.2.

## 9. Desarrollador UI / Design System
Toca `lib/shared/**` o `lib/app/design/**`, componentes atómicos nuevos.
Lee: [`design_patterns.md`](design_patterns.md), [`hierarchy.md`](hierarchy.md).

## 10. Integrador de datos / Backend
Conecta datasources con el API REST de Spring Boot, define contratos, maneja JWT.
Lee: [`database.md`](database.md), [`flow.md`](flow.md), [`requerimientos_backend.md`](requerimientos_backend.md) (incluida su sección 9 de puntos abiertos), [`security.md`](security.md).

## 11. Revisor de seguridad
Audita autenticación, cifrado, almacenamiento de tokens/secretos, exposición de datos sensibles.
Lee: [`security.md`](security.md), [`architecture.md`](architecture.md).

## 12. QA / Testing
Rol que **todo agente adopta obligatoriamente al terminar de implementar una tarea** (ver [`rules.md`](rules.md) regla 8.1), además de aplicar cuando se le pide explícitamente escribir/correr pruebas. Prueba activamente buscando fallas — no autocertifica el propio código recién escrito. No hay ambiente de staging ni CI en v1: la verificación final es local y manual (ver [`testing.md`](testing.md)).
Lee: [`testing.md`](testing.md), [`qa_checklist.md`](qa_checklist.md), [`functionality.md`](functionality.md).

## 13. Ingeniero de cuentas y registro
Registro con OTP por email, checkbox de T&C, validación de edad mínima (18 años), cambio de email/teléfono con re-verificación, eliminar cuenta.
Lee: [`flow.md`](flow.md) sección 11, [`database.md`](database.md) (campos de `usuario`: `fecha_nacimiento`, `terminos_aceptados_en`, `estado_cuenta`), [`requerimientos_backend.md`](requerimientos_backend.md) secciones 2.1 y 2.3.

## 14. Localización (i18n) — alcance reducido en v1
V1 es solo español (sin proveedor de traducción disponible, confirmado) — este rol en v1 se limita a mantener `lib/l10n/arb/app_es.arb` y migrar strings hardcodeados a claves de `l10n` (para que agregar idiomas después sea traducción, no refactor). No crear archivos `.arb` de otros idiomas ni selector de idioma en Configuración hasta que se confirme un proveedor de traducción.
Lee: [`requirements.md`](requirements.md) (sección Internacionalización), [`functionality.md`](functionality.md) RF23/RNF10.

## 15. Product / Planificación
Prioriza funcionalidades, resuelve ambigüedades de negocio.
Lee: [`context.md`](context.md), [`questions.md`](questions.md) (índice) + [`questions_pantallas.md`](questions_pantallas.md) + [`questions_flujos.md`](questions_flujos.md), [`task.md`](task.md).

## Regla
Si la tarea cruza más de un rol, lee los docs de cada rol involucrado, pero solo esos. Ningún rol está habilitado para tomar una decisión de negocio no confirmada por su cuenta — ver [`rules.md`](rules.md).
