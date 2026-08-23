# Reglas obligatorias

Aplican a todo agente (Claude, Codex, Gemini, Copilot) sin importar el rol asumido. Esta versión añade reglas específicas para el desarrollo de las features nuevas (negociación, tiempo real, verificación, seguridad) con foco en **no romper código existente** y **no alucinar contratos o decisiones no confirmadas**.

## Documentación
1. Estos `.md` describen el estado real o el objetivo confirmado del sistema. Si tu cambio de código vuelve obsoleta una afirmación, actualiza el `.md` correspondiente en el mismo cambio.
2. No dupliques información entre archivos `.md`. Enlaza (`[texto](otro.md)`) en vez de copiar.
3. No leas `.dart` innecesariamente — usa los `.md` para no explorar todo el repo en cada tarea.

## Determinismo y alcance (crítico para esta fase del proyecto)
4. **Nunca inventes un contrato de API** (nombre de endpoint, forma del JSON de request/response, nombre de un topic WebSocket) que no esté ya confirmado en [`database.md`](database.md), [`flow.md`](flow.md) o [`architecture.md`](architecture.md). Si falta el dato, agrégalo como pregunta nueva en [`questions.md`](questions.md) y usa un mock/interfaz claramente marcada como temporal — no continúes como si el contrato estuviera confirmado.
5. **Nunca tomes una decisión de negocio pendiente en [`questions.md`](questions.md)** (ej. método de pago, política de cancelación, fórmula de precio) por tu cuenta. Si una tarea requiere esa decisión para avanzar, detente y repórtalo en vez de asumir un valor por defecto.
6. No agregues alcance no pedido. Si una tarea dice "implementar publicar solicitud de viaje", no aproveches para también implementar la negociación de ofertas salvo que se pida explícitamente — cada tarea debe quedar acotada a lo que [`task.md`](task.md) describe.
7. No generes código "de relleno" para que algo "se vea completo" (pantallas con datos de ejemplo permanentes, botones sin acción real presentados como funcionales). Si algo queda pendiente de una integración real, márcalo explícitamente con `// TODO(<motivo>, ver docs/questions.md#N)` y regístralo en el inventario de estado — nunca lo dejes simulando funcionalidad real sin dejar rastro.

## No dejar código roto o incompleto
8. Ninguna tarea se da por terminada si `flutter analyze` reporta errores nuevos introducidos por el cambio, o si el proyecto no compila. No hay CI/CD en v1 — esta verificación es responsabilidad manual del agente en cada tarea (ver [`testing.md`](testing.md)).
8.1. **Cambio de rol obligatorio al terminar de implementar (confirmado)**: quien codificó una tarea debe, antes de marcarla `completo`, adoptar explícitamente el rol de QA ([`role.md`](role.md) rol 12) y probarla buscando activamente fallas — nunca autocertificarse en el mismo modo mental en que escribió el código, ni asumir que algo es correcto solo porque compila. Ver [`qa_checklist.md`](qa_checklist.md).
9. No dejes una función/clase a medio implementar sin que el compilador lo señale como incompleto de forma explícita (`throw UnimplementedError('<qué falta y por qué>')`) — nunca un `return null`/`return []` silencioso que oculte que falta lógica real.
10. Si tu cambio modifica un modelo de datos (`domain/models`) usado por múltiples blocs/pantallas, actualiza todos los usos en el mismo cambio — no dejes referencias rotas para "una tarea futura".
11. No remuevas ni deshabilites una funcionalidad existente que ya funciona de verdad (ej. login cliente real, refresh de token) al implementar una nueva, salvo que la tarea lo pida explícitamente.

## Arquitectura
12. Respeta la separación por capas dentro de cada feature (`data → domain → presentation`); no saltes capas.
13. Todo resultado que pueda fallar se modela con `Failure`/`Either<Failure, T>` (dartz). No lances excepciones crudas fuera de `data/datasources`.
14. La lógica de tiempo real (WebSocket/STOMP) se accede siempre a través de `RealtimeClient` y sus streams tipados — ningún bloc debe importar el cliente STOMP directamente (ver [`architecture.md`](architecture.md) sección 3).
15. El cálculo de precio sugerido, distancia y duración es responsabilidad del backend. No implementes esa lógica en el cliente salvo que [`questions.md`](questions.md) se resuelva explícitamente en sentido contrario.
16. Nuevas dependencias globales se registran en `lib/app/di/dependency_injection.dart` respetando el orden ya existente y documentado.

## Seguridad (no negociable)
17. Ningún token de autenticación se escribe en SQLite, `SharedPreferences` sin cifrar, logs, o cualquier almacenamiento no diseñado para secretos — usar siempre `flutter_secure_storage` una vez migrado (ver [`security.md`](security.md)).
18. No hardcodees credenciales, tokens de prueba, ni bypasses de autenticación (como el mock actual de login de conductor) en código que se vaya a fusionar como definitivo — si necesitas datos de prueba, deben venir de un entorno de desarrollo controlado, nunca de una rama que se considere "lista para producción".
19. No dejes documentos de verificación (fotos de cédula, licencia) cacheados en disco más tiempo del necesario para completar la subida.

## Convenciones de código (mantener por consistencia)
20. Prefijo `App` para widgets compartidos nuevos en `lib/shared/`, salvo patrones con nombre propio ya establecido.
21. Carpetas compuestas en kebab-case (`profile-drawer`, `bottom-appbar`, `driver-bloc`) — no introducir un tercer estilo en carpetas nuevas.
22. Componentes específicos de un dominio (negociación, verificación, seguridad) van dentro de su feature, no en `lib/shared/` — ver [`hierarchy.md`](hierarchy.md).

## Antes de tocar código sensible
23. No "arregles" hallazgos de [`security.md`](security.md) como efecto colateral de otra tarea sin que se te pida explícitamente — cada corrección de seguridad es su propia tarea, trazable en [`task.md`](task.md).
24. No borres código "muerto" aparente sin confirmarlo — puede ser trabajo en progreso.
25. No agregues una dependencia nueva si ya existe una equivalente sin usar declarada en [`requirements.md`](requirements.md) — usa o retira la existente primero.
