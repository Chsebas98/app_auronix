# Test Strategy

- Define test requirements during the internal analysis.

# Reused Testing from Central Memory

## testing/contract_testing.md

# Contract Testing

## Intent
Detect interface drift between independently developed or deployed consumers and providers before integration failures reach production.

## Applicability
Use when systems communicate through APIs, events or messages and the participating components can evolve independently.

## Non-applicability
Do not use contract tests as a replacement for unit tests, domain tests, security tests or end-to-end validation of complete business journeys.

## Structure / responsibilities
- **Contract owner:** defines the authoritative interface expectations.
- **Consumer:** expresses the interactions and guarantees it depends on.
- **Provider:** verifies that its implementation satisfies the agreed contract.
- **Contract artifact:** versioned request, response, event or message expectations.
- **Compatibility gate:** blocks incompatible changes according to the evolution policy.

## Implementation guidance
1. Establish the authoritative API/event contract.
2. Define required fields, types, formats, status semantics and compatibility rules.
3. Capture consumer expectations without over-specifying irrelevant implementation details.
4. Verify provider behavior against the contract.
5. Version contracts when compatibility policy requires it.
6. Run contract verification in CI before release or deployment.
7. Record intentional breaking changes through the project decision process.

## Validation criteria
- Contract artifacts are versioned and traceable.
- Required request and response behavior is verified.
- Provider changes cannot silently remove required consumer behavior.
- Contract tests run automatically at an appropriate quality gate.
- Intentional breaking changes have explicit migration/version decisions.

## Security considerations
Contracts must not contain real credentials, production secrets or unnecessary personal data. Include security-relevant requirements such as authentication, authorization, validation and safe error semantics where they are part of the interface contract.

## Trade-offs
Contract testing catches boundary drift earlier than full system tests and is usually faster, but it requires clear ownership and disciplined contract evolution. Overly strict contracts can block harmless provider improvements.

## Related skills and patterns
- `api.contract_design`
- `api.request_model`
- `api.response_model`
- `api.backward_compatibility`
- `testing.integration_testing`
- `api.versioned-contract`

## Example decision signals
- **Independent frontend/backend releases:** contract testing is valuable.
- **Microservice API:** verify consumer/provider compatibility.
- **Event schema shared by teams:** verify message contract.
- **Single internal function:** prefer unit tests rather than a contract test.

## testing/test_pyramid.md

# Test Pyramid

## Intent
Balance fast feedback and broad confidence by using many focused tests, fewer integration tests and a smaller set of end-to-end tests.

## Applicability
Use as a planning heuristic for automated verification of software where different test levels provide different cost, speed and isolation characteristics.

## Non-applicability
Do not treat the pyramid as a fixed percentage rule. Systems dominated by integration boundaries, distributed behavior or user journeys may require a different distribution based on risk.

## Structure / responsibilities
- **Unit tests:** verify small units in isolation.
- **Integration tests:** verify real interactions between components or infrastructure boundaries.
- **End-to-end tests:** verify critical user-visible workflows across the system.
- **Test strategy:** maps risk and requirements to the appropriate level.
- **Quality gate:** prevents release when required critical behavior is unverified.

## Implementation guidance
1. Identify critical business and security risks.
2. Cover deterministic business logic with fast unit tests.
3. Use integration tests for persistence, APIs, queues and important boundaries.
4. Reserve end-to-end tests for critical workflows that require system-level confidence.
5. Add regression tests for defects at the lowest level that reproduces the failure reliably.
6. Keep tests deterministic and independent.
7. Measure useful coverage and mutation/risk signals rather than chasing a percentage alone.

## Validation criteria
- Critical requirements map to explicit tests.
- Unit tests remain fast and isolated.
- Integration tests exercise important real boundaries.
- Critical user journeys have appropriate end-to-end coverage.
- Defects gain durable regression tests.

## Security considerations
Security-sensitive behavior must be tested at the boundary where controls actually operate. Include authentication, authorization, validation, injection resistance, sensitive-data handling and security regression tests according to risk.

## Trade-offs
More unit tests usually improve speed and diagnosis, while integration and end-to-end tests provide stronger boundary confidence at higher cost and fragility. The optimal distribution follows system risk rather than a universal ratio.

## Related skills and patterns
- `testing.test_strategy`
- `testing.unit_testing`
- `testing.integration_testing`
- `testing.e2e_testing`
- `testing.quality_gate`
- `testing.contract_testing`

## Example decision signals
- **Pure deterministic logic:** prioritize unit tests.
- **Database transaction behavior:** add integration coverage.
- **Critical login journey:** add end-to-end coverage.
- **API provider/consumer boundary:** add contract tests.

## Tests required by the internal analysis

- test/unit/app/config/environment_config_test.dart: Comprobar lectura de variables de entorno y selección de esquema ws:// para local y wss:// para producción.
- test/unit/app/network/dio_client_test.dart: Validar inyección automática de Bearer Token en encabezados y generación obligatoria de Idempotency-Key en llamadas POST de viajes.
- test/unit/features/auth/domain/session_bloc_test.dart: Verificar transiciones de estado de autenticación (unauthenticated, authenticating, authenticated, failure) y resolución de rutas por rol (pasajero vs conductor).
- test/unit/features/trips/domain/passenger_trip_bloc_test.dart: Validar rechazo de nueva solicitud cuando el pasajero ya tiene un viaje no terminal (SOLICITADO, OFERTADO, ACEPTADO, EN_CURSO).
- test/unit/features/trips/domain/driver_trip_bloc_test.dart: Comprobar filtrado estricto de solicitudes para permitir solo las pertenecientes a la cooperativa del conductor autenticado.
- test/unit/features/trips/domain/trip_state_machine_test.dart: Verificar que las transiciones de estado del viaje sigan la secuencia estricta SOLICITADO -> OFERTADO -> ACEPTADO -> EN_CURSO -> COMPLETADO sin permitir saltos de estado.
- test/integration/network/websocket_manager_test.dart: Probar suscripción, reconexión automática tras corte de red y recepción de eventos en tiempo real tanto en modo no seguro ws:// (local) como seguro wss://.
- test/integration/flows/passenger_trip_e2e_test.dart: Recorrido E2E del pasajero desde selección de destino en mapa, solicitud con Idempotency-Key, recepción de conductor por socket y calificación final.
- test/integration/flows/driver_trip_e2e_test.dart: Recorrido E2E del conductor recibiendo alerta de viaje, aceptando solicitud, transmitiendo GPS e informando inicio y finalización del viaje.
- test/security/secure_storage_test.dart: Comprobar que los tokens JWT y datos sensibles de sesión se almacenan exclusivamente en Keystore/Keychain y nunca en texto plano.
- test/security/dead_code_audit_test.dart: Comprobar mediante flutter analyze y scripts de verificación de imports que no existen componentes huérfanos ni dependencias no utilizadas en el build final.
- test/accessibility/wcag_compliance_test.dart: Ejecutar escaneo automatizado de contraste, tamaños mínimos de toque (44x44) y etiquetas Semantics para lectores de pantalla en las vistas principales.

## Tests required by the internal analysis

- test/unit/app/config/environment_config_test.dart: Comprobar lectura de variables de entorno y selección de esquema ws:// para local y wss:// para producción.
- test/unit/app/network/dio_client_test.dart: Validar inyección automática de Bearer Token en encabezados y generación obligatoria de Idempotency-Key en llamadas POST de viajes.
- test/unit/features/auth/domain/session_bloc_test.dart: Verificar transiciones de estado de autenticación (unauthenticated, authenticating, authenticated, failure) y resolución de rutas por rol (pasajero vs conductor).
- test/unit/features/trips/domain/passenger_trip_bloc_test.dart: Validar rechazo de nueva solicitud cuando el pasajero ya tiene un viaje no terminal (SOLICITADO, OFERTADO, ACEPTADO, EN_CURSO).
- test/unit/features/trips/domain/driver_trip_bloc_test.dart: Comprobar filtrado estricto de solicitudes para permitir solo las pertenecientes a la cooperativa del conductor autenticado.
- test/unit/features/trips/domain/trip_state_machine_test.dart: Verificar que las transiciones de estado del viaje sigan la secuencia estricta SOLICITADO -> OFERTADO -> ACEPTADO -> EN_CURSO -> COMPLETADO sin permitir saltos de estado.
- test/integration/network/websocket_manager_test.dart: Probar suscripción, reconexión automática tras corte de red y recepción de eventos en tiempo real tanto en modo no seguro ws:// (local) como seguro wss://.
- test/integration/flows/passenger_trip_e2e_test.dart: Recorrido E2E del pasajero desde selección de destino en mapa, solicitud con Idempotency-Key, recepción de conductor por socket y calificación final.
- test/integration/flows/driver_trip_e2e_test.dart: Recorrido E2E del conductor recibiendo alerta de viaje, aceptando solicitud, transmitiendo GPS e informando inicio y finalización del viaje.
- test/security/secure_storage_test.dart: Comprobar que los tokens JWT y datos sensibles de sesión se almacenan exclusivamente en Keystore/Keychain y nunca en texto plano.
- test/security/dead_code_audit_test.dart: Comprobar mediante flutter analyze y scripts de verificación de imports que no existen componentes huérfanos ni dependencias no utilizadas en el build final.
- test/accessibility/wcag_compliance_test.dart: Ejecutar escaneo automatizado de contraste, tamaños mínimos de toque (44x44) y etiquetas Semantics para lectores de pantalla en las vistas principales.

