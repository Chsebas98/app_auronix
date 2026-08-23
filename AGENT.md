# AGENT.md — Punto de entrada para agentes de IA

Este archivo es lo primero que debe leer cualquier agente (Claude, Codex, Gemini, Copilot) antes de tocar código en este repo. No explores el resto del proyecto todavía.

## Orden de lectura obligatorio
1. [`README.md`](README.md) — contexto mínimo de la app: qué es, stack, cómo correrla.
2. [`docs/role.md`](docs/role.md) — identifica qué rol desempeñas en la tarea pedida.
3. [`docs/rules.md`](docs/rules.md) — reglas obligatorias para todo agente, sin importar el rol.
4. Según tu rol y la tarea, lee **solo** los docs de la tabla siguiente que apliquen. No leas los demás.
5. Antes de escribir código: revisa [`docs/task.md`](docs/task.md) (¿la tarea ya está registrada?) y [`docs/questions.md`](docs/questions.md) (¿hay una decisión pendiente que bloquea esto?).

## Qué doc leer según la tarea

| Si vas a... | Lee además |
|---|---|
| Tocar DI, router, capa de red, blocs globales | [`docs/architecture.md`](docs/architecture.md) |
| Entender el objetivo de negocio / alcance del producto | [`docs/context.md`](docs/context.md) |
| Tocar la base de datos local (sqflite) o contratos de datos | [`docs/database.md`](docs/database.md) |
| Elegir un patrón (repository, bloc, service locator, either/failure) | [`docs/design_patterns.md`](docs/design_patterns.md) |
| Implementar/entender un flujo de negocio (auth, viaje, sesión, ganancias) | [`docs/flow.md`](docs/flow.md) |
| Saber qué está implementado, mockeado o vacío antes de tocarlo | [`docs/functionality.md`](docs/functionality.md) |
| Crear archivos/carpetas nuevas (dónde va cada cosa) | [`docs/hierarchy.md`](docs/hierarchy.md) |
| Resolver una duda de diseño/producto no zanjada en el código | [`docs/questions.md`](docs/questions.md) (índice) → [`docs/questions_pantallas.md`](docs/questions_pantallas.md) o [`docs/questions_flujos.md`](docs/questions_flujos.md) según aplique |
| Verificar que una pantalla/flujo esté realmente terminado (no solo que compile) | [`docs/qa_checklist.md`](docs/qa_checklist.md) |
| Configurar entorno, dependencias, versiones, flavors | [`docs/requirements.md`](docs/requirements.md) |
| Definir o confirmar un contrato con el backend (endpoints, WebSocket, formato de errores) | [`docs/requerimientos_backend.md`](docs/requerimientos_backend.md) |
| Tocar auth, tokens, cifrado, datos sensibles | [`docs/security.md`](docs/security.md) |
| Escribir o correr tests | [`docs/testing.md`](docs/testing.md) |
| Ver qué tarea está pendiente/en curso/completa | [`docs/task.md`](docs/task.md) |

## Regla de oro
No leas archivos `.dart` fuera del feature/carpeta que vas a modificar hasta haber leído los `.md` relevantes de la tabla. Los `.md` existen para evitarte explorar todo el repo en cada tarea.

## Mantenimiento de esta documentación
Este archivo y todo `docs/*.md` describen el estado **real** del código. Si tu cambio vuelve obsoleta una afirmación de estos docs, actualiza el doc correspondiente en el mismo cambio — no dejes la documentación desincronizada del código.
