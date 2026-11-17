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
