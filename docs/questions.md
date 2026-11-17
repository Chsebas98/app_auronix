# Preguntas / decisiones pendientes — índice

Este archivo es solo el índice y el historial de lo ya resuelto. Las preguntas activas viven repartidas en archivos temáticos para que cada rol cargue solo lo que necesita (ver [`rules.md`](rules.md) regla 3 y [`AGENT.md`](../AGENT.md)):

- [`questions_pantallas.md`](questions_pantallas.md) — **0 preguntas abiertas** (todas resueltas en 4 rondas). Sigue siendo el lugar donde se agregan preguntas nuevas por pantalla.
- [`questions_flujos.md`](questions_flujos.md) — **0 preguntas abiertas** (todas resueltas). Lugar para preguntas nuevas transversales (concurrencia, sesión, ciclo de vida de la app, notificaciones).
- [`requerimientos_backend.md`](requerimientos_backend.md) sección 9 — **1 punto abierto de bajo riesgo**: redondeo de moneda para v2 (no bloquea v1).

## Resueltas — 2026-08-22 (cuatro rondas, 82 preguntas en total)
Ya incorporadas en [`context.md`](context.md), [`architecture.md`](architecture.md), [`database.md`](database.md), [`design_patterns.md`](design_patterns.md), [`flow.md`](flow.md), [`functionality.md`](functionality.md), [`requirements.md`](requirements.md), [`role.md`](role.md), [`security.md`](security.md), [`requerimientos_backend.md`](requerimientos_backend.md). Decisiones que más cambiaron el alcance, en orden: (1) panel admin fuera de este repo, sin rol "gerente", verificación documental fuera de la app, chat obligatorio, solo efectivo en v1, calificación desde 5 estrellas, i18n real, tiempo real vía STOMP; (2) una sola solicitud activa por pasajero, sesión única, radio 10 km, moneda por país; (3) edad mínima 18 años (sin excepción), sin viajes transfronterizos, identidad del conductor oculta hasta la asignación, enmascaramiento telefónico obligatorio, rango de contraoferta 90%-130%, desviación de ruta con check-in de seguridad tipo Uber RideCheck, regex de placa por país (EC/CO/PE), OTP de registro, T&C con placeholder versionado, eliminar cuenta desde v1.

## Preguntas menores previas (aún no bloqueantes)
1. ~~Idiomas exactos de i18n~~ — resuelto: v1 es solo español, sin proveedor de traducción disponible (ver [`requirements.md`](requirements.md)).
2. Chat: ¿solo texto en v1, o también ubicación/imágenes? Se asume solo texto.
3. Umbral exacto de "prioridad reducida por baja calificación": lo aplica el backend, el cliente solo consume el orden ya calculado — no bloquea al frontend.
4. Micrositio de verificación por correo: si es el mismo dashboard admin o un micrositio aparte — sin impacto en este repositorio Flutter.

## Confirmado — quinta ronda (entorno/proceso, 2026-08-22)
Sin ambiente de staging ni CI/CD en v1 (verificación local manual + `flutter analyze`/`test` por tarea); el mismo agente cambia a rol QA tras implementar (ver [`rules.md`](rules.md) regla 8.1); Android 7.0 (API 24) / iOS 16 como mínimos soportados; v1 se publica solo en Ecuador; **v1 revierte a solo español** (sin proveedor de traducción — descarta el requisito de multi-idioma de la primera ronda).

## Regla
Toda pregunta nueva se agrega al archivo temático que corresponda (pantalla → `questions_pantallas.md`; flujo/transversal → `questions_flujos.md`; depende de infraestructura/backend → `requerimientos_backend.md` sección 9), nunca directamente aquí — este índice solo enlaza y archiva lo ya resuelto.
