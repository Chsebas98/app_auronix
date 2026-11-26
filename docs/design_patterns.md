# Architecture decisions

ADR files are the SSOT for architectural decisions.

# Reused Design_Pattern from Central Memory

## patterns/api/idempotency_key.md

# Idempotency Key

## Intent
Make retryable state-changing requests safe to repeat without duplicating the logical operation.

## Applicability
Use for operations vulnerable to duplicate submission, especially payments, provisioning, job creation, or network-timeout retries.

## Non-applicability
Do not add idempotency where repetition is already harmless or where the operation cannot define a stable identity.

## Structure / responsibilities
- Client supplies a unique key for a logical operation.
- Server validates key format and scope.
- Server associates the key with the operation result and relevant request fingerprint.
- Repeated valid requests return the prior outcome instead of executing the operation again.

## Implementation guidance
Define key scope, retention, concurrent-request behavior, and mismatch handling. Persist the key atomically with the protected operation when required for correctness.

## Validation criteria
- Duplicate requests do not create duplicate side effects.
- Concurrent reuse is deterministic.
- Reuse with materially different request data is rejected.
- Expired keys follow documented semantics.

## Security considerations
Prevent key guessing, cross-tenant reuse, unbounded storage growth, and leakage of sensitive response data. Bind keys to the authenticated principal and operation scope where appropriate.

## Trade-offs
Improves retry safety but requires durable key storage, lifecycle management, and concurrency handling.

## Related skills and patterns
- `backend.idempotency`
- `security.api_security`

## Example decision signals
Choose when clients may retry after uncertain network outcomes and duplicate side effects would be harmful.

## patterns/api/pagination.md

# Stable Pagination

## Intent
Bound collection responses while providing deterministic navigation through a changing dataset.

## Applicability
Use for endpoints that return potentially large collections or where response size must remain bounded.

## Non-applicability
Avoid pagination for inherently tiny, bounded collections where it adds needless client complexity.

## Structure / responsibilities
- API defines page size limits.
- Ordering is explicit and stable.
- Cursor or offset semantics are documented.
- Response includes enough metadata for the client to continue safely.

## Implementation guidance
Prefer a stable unique ordering key. Cap client-requested page sizes. For mutable large datasets, cursor/keyset pagination is often safer than offsets for consistency and performance.

## Validation criteria
- Repeated requests with the same cursor semantics are deterministic within documented consistency guarantees.
- Page size cannot bypass server limits.
- Items are not unexpectedly duplicated or skipped under supported consistency semantics.

## Security considerations
Authorize access before pagination. Do not expose internal identifiers solely because they are used as cursors. Treat cursors as untrusted input and validate them.

## Trade-offs
Pagination protects performance and payload size but requires more client logic and explicit consistency semantics.

## Related skills and patterns
- `api.pagination`
- `performance.api_optimization`

## Example decision signals
Choose when collection size is unbounded or could grow beyond a safe single response.

## patterns/authentication/implementation.md

# Authentication Pattern — Implementation

## Intent
Establish who is making a request through a verifiable identity proof, before authorization or business logic executes, without coupling every service to one specific credential technology.

## Applicability
Use for any system boundary that must know the identity of the caller: a public API, a user-facing application, or a service-to-service boundary that isn't fully trusted by network location alone.

## Non-applicability
Do not use this pattern to make authorization decisions — authentication only establishes identity; authorization (what the identity is allowed to do) is a separate concern (`security.zero-trust-boundary`). Do not build a custom cryptographic primitive when a vetted standard (OAuth 2.0, OpenID Connect, WebAuthn, TOTP) covers the need.

## Structure / responsibilities
- **Credential verifier**: validates the presented credential (password hash, signed token, TOTP code, WebAuthn assertion) against a trusted source.
- **Session/token issuer**: issues a short-lived, verifiable proof of the authenticated identity (session cookie, JWT, opaque token) after successful verification.
- **Transport boundary**: enforces that credentials and tokens never travel or persist unencrypted (TLS in transit, hashed/encrypted at rest).
- **Second factor (when required)**: an independent verification step (TOTP, WebAuthn, push approval) that does not rely on the same secret as the first factor.
- **Revocation/expiry mechanism**: a way to invalidate a session or token before its natural expiry (logout, credential compromise, policy change).

## Implementation guidance
1. Never store plaintext passwords; use a memory-hard hash (Argon2id, scrypt, or bcrypt with an adequate cost factor).
2. Encrypt sensitive secrets end-to-end when the transport alone is not trusted enough for the data's sensitivity (e.g. client-side encryption before a password reaches the server).
3. Bind sessions/tokens to an expiry and, where applicable, to a client context, without breaking legitimate mobility.
4. When mandatory 2FA is required, enforce it at the authentication boundary itself — never as an optional client-side step that can be bypassed by calling the API directly.
5. Rate-limit and lock out credential verification attempts to blunt brute-force and credential-stuffing attacks.
6. Log authentication successes and failures (without secrets) for detection and audit; never log passwords, tokens, or TOTP secrets.
7. Provide an explicit, tested logout/revocation path that invalidates the session server-side, not just client-side.

## Validation criteria
- No plaintext credential exists in logs, databases, or transport payloads at rest.
- A session/token cannot be replayed after logout or expiry.
- 2FA, when mandatory, cannot be bypassed by calling an underlying endpoint directly.
- Failed-attempt rate limiting is verifiably enforced (tested, not assumed).
- Authentication failures return a generic error that does not reveal whether the username or the credential was wrong (prevents enumeration).

## Security considerations
Authentication is the highest-value target for attackers; treat every implementation detail as security-relevant. Apply `security.web_security_baseline` in full. Never roll a custom crypto primitive. Assume credential databases will eventually leak and design so a leak of hashes does not equal a leak of plaintext credentials. Coordinate any change to this pattern with `cyber_security` before merge.

## Trade-offs
Stronger authentication (mandatory 2FA, short-lived tokens, strict rate limiting) increases security but adds friction and support burden (lockouts, recovery flows). Session-based auth simplifies revocation but complicates horizontal scaling without shared session storage; token-based auth scales more easily but makes immediate revocation harder without an additional check.

## Related skills and patterns
- `security.web_security_baseline`
- `security.zero-trust-boundary`
- `security.defense-in-depth`
- `error.fail-fast-validation`

## Example decision signals
- **User-facing web application with sensitive data**: session-based auth with mandatory 2FA and short expiry.
- **Public third-party API**: OAuth 2.0 / OpenID Connect with scoped, short-lived access tokens.
- **Service-to-service inside a private network**: mutual TLS or signed service tokens; never rely on network location alone (`security.zero-trust-boundary`).
- **Password reset flow**: treat as an authentication event; require re-verification and invalidate all existing sessions after a successful reset.

## patterns/error_handling/fail_fast_validation.md

# Fail-Fast Validation

## Intent
Reject invalid or unsafe input at the earliest trusted boundary so invalid state does not propagate through the system.

## Applicability
Use at API, command, task, file and domain boundaries where input can violate a contract, schema, constraint or security rule.

## Non-applicability
Do not use early rejection to replace business workflows that legitimately require collecting multiple validation errors or asynchronous verification. Domain validation may still be required after transport validation.

## Structure / responsibilities
- **Boundary validator:** checks syntax, type, size and required fields.
- **Domain validator:** checks business invariants that require domain knowledge.
- **Error contract:** returns stable, non-sensitive error identifiers and field information.
- **Normalizer:** canonicalizes permitted input before validation where safe.
- **Audit/telemetry:** records relevant failures without sensitive payloads.

## Implementation guidance
1. Define the input contract before implementation.
2. Reject unexpected fields when the contract requires a closed schema.
3. Validate types, lengths, ranges, formats and allowed values.
4. Apply security validation before expensive processing or privileged operations.
5. Keep transport and domain validation responsibilities explicit.
6. Return structured errors using a stable contract.
7. Never trust client-side validation as the security boundary.
8. Test malformed, boundary, oversized and adversarial inputs.

## Validation criteria
- Invalid input is rejected before privileged or expensive work.
- Validation behavior is deterministic.
- Error responses do not reveal internal implementation details.
- Boundary cases are covered by automated tests.
- Client-side validation is treated only as usability support.

## Security considerations
Treat all external input as untrusted. Validate allowlists where practical, constrain sizes, prevent path traversal/injection, and encode output for the destination context. Do not expose stack traces, database details, secrets or internal paths in client-facing errors.

## Trade-offs
Early validation reduces downstream complexity and attack surface, but duplicated validation can become inconsistent if responsibilities are not clearly separated. Keep shared contracts and domain invariants explicit.

## Related skills and patterns
- `security.web_security_baseline`
- `security.mobile_security_baseline`
- `security.input_validation`
- `api.contract_design`
- `error.retry-with-backoff`

## Example decision signals
- **Malformed API payload:** reject at the API boundary.
- **Invalid business state:** reject at the domain boundary.
- **Oversized upload:** reject before storage or parsing.
- **Unsafe path supplied by a client:** reject before filesystem access.

## patterns/error_handling/retry_with_backoff.md

# Retry with Bounded Backoff

## Intent
Retry transient operations without creating an uncontrolled retry storm or hiding permanent failures.

## Applicability
Use when an operation can fail temporarily because of network interruption, service unavailability, throttling, or another explicitly classified transient condition. The operation must be safe to retry or protected by idempotency.

## Non-applicability
Do not retry validation failures, authentication/authorization failures that will not change, malformed requests, deterministic business-rule failures, or non-idempotent operations without an explicit duplicate-prevention mechanism.

## Structure / responsibilities
- **Classifier:** distinguishes transient from permanent failures.
- **Retry policy:** defines maximum attempts, delay and optional jitter.
- **Operation:** performs the work and exposes a clear success/failure result.
- **Telemetry:** records attempts, final outcome and reason without exposing secrets.
- **Boundary:** enforces an overall timeout/deadline.

## Implementation guidance
1. Classify the failure before retrying.
2. Set a small explicit maximum attempt count.
3. Use bounded exponential backoff rather than immediate repeated calls.
4. Add jitter when many clients may retry concurrently.
5. Respect server-provided retry guidance such as `Retry-After` when applicable.
6. Stop when the overall deadline is reached.
7. Preserve the original failure context for diagnosis.
8. For state-changing operations, require idempotency or another duplicate-prevention mechanism.

## Validation criteria
- Permanent errors are not retried.
- Attempt count cannot exceed the configured limit.
- Delay is bounded and deterministic under a fixed test configuration.
- Overall timeout is enforced.
- Retry attempts are observable.
- Repeated state-changing requests do not create unintended duplicate effects.

## Security considerations
Retry policy must not become a denial-of-service amplifier. Never retry rejected credentials indefinitely. Avoid logging authorization headers, tokens, request bodies containing secrets, or sensitive response data. Respect upstream rate limits and retry-after instructions.

## Trade-offs
Bounded retries improve resilience but increase latency and can amplify load when applied incorrectly. Jitter reduces synchronized retries but makes exact timing less predictable.

## Related skills and patterns
- `backend.design_patterns`
- `api.idempotency-key`
- `security.defense-in-depth`
- `error.fail-fast-validation`

## Example decision signals
- **Transient dependency outage:** use bounded retries.
- **HTTP 429 with retry guidance:** retry within the allowed deadline.
- **HTTP 400 caused by invalid input:** fail immediately.
- **Payment-like state change:** combine retry with idempotency protection.

## patterns/frontend/component-composition.md

# Component Composition

## Intent
Build UI behavior from small composable units with explicit boundaries instead of inheritance-heavy structures.

## Applicability
Use when UI behavior, presentation, or interaction is shared across screens and can be expressed through composition.

## Non-applicability
Avoid when abstraction would obscure a small, local component or when shared behavior is not actually stable.

## Structure / responsibilities
- Small components own one coherent responsibility.
- Parent components compose children through explicit inputs and outputs.
- Shared behavior lives in reusable components or utilities with stable contracts.

## Implementation guidance
Keep component APIs narrow. Prefer composition and explicit data flow. Avoid creating generic abstractions before two or more real use cases justify them.

## Validation criteria
- Components can be reused without hidden global state.
- Data and events have explicit boundaries.
- Tests cover important composed behavior.

## Security considerations
Do not trust UI validation as the security boundary. Validate and authorize sensitive operations at the server/API boundary and encode untrusted output appropriately.

## Trade-offs
Composition improves reuse and isolation, but excessive decomposition can increase indirection and cognitive load.

## Related skills and patterns
- `frontend.design_patterns`
- Container and Presentational

## Example decision signals
Choose when several screens need the same behavior and the shared contract is stable enough to justify composition.

## patterns/mobile/unidirectional_data_flow.md

# Unidirectional Data Flow

## Intent
Make mobile state changes explicit and predictable through one-way data flow.

## Applicability
Use when multiple UI states, asynchronous operations, or shared mutable state make transitions difficult to reason about.

## Non-applicability
Avoid adding a state-management layer to a simple screen with trivial local state.

## Structure / responsibilities
- State is represented explicitly.
- Events/actions describe requested changes.
- A deterministic update path produces the next state.
- UI observes state and emits events rather than mutating shared state implicitly.

## Implementation guidance
Keep state transitions deterministic and serializable where practical. Make loading, success, empty, and error states explicit. Handle lifecycle recreation without losing required state.

## Validation criteria
- Every important state transition has a defined trigger.
- Concurrent/asynchronous results cannot silently overwrite newer state.
- Tests cover success, failure, loading, and cancellation paths.

## Security considerations
Never place secrets in client state or logs. Treat persisted client state as potentially recoverable by an attacker and enforce authorization on the API.

## Trade-offs
Predictability and testability improve, but explicit events and state models add ceremony.

## Related skills and patterns
- `mobile.navigation`
- `mobile.state_management`

## Example decision signals
Choose when screen behavior contains several interacting states or asynchronous operations whose ordering matters.

## patterns/error_handling/implementation.md

# Structured Error Handling — Implementation

## Intent
Make failures explicit, classifiable and actionable across every layer of a system, instead of leaking raw exceptions, silent failures, or inconsistent ad-hoc error shapes to callers.

## Applicability
Use in any service, API, or application layer that can fail (I/O, validation, external dependency, business rule) and that has at least one caller — human or machine — who needs to react differently depending on the failure type.

## Non-applicability
Do not use this as a substitute for `error.fail-fast-validation` at input boundaries, nor for `error.retry-with-backoff` for transient failures — those are specific implementations this pattern coordinates, not replacements for it. Do not wrap every exception in a generic error just to satisfy a schema; preserve enough information to diagnose the real cause.

## Structure / responsibilities
- **Error taxonomy**: a small, closed set of error categories (validation, authorization, not-found, conflict, transient/upstream, internal) that every layer maps into.
- **Error contract**: a stable, documented shape for errors returned across a boundary (status/type, machine-readable code, human-readable message, optional details) — see `contracts/schemas/error.schema.json`.
- **Translation boundary**: each layer translates internal/low-level failures (driver exceptions, network errors) into the taxonomy above before they cross into the next layer.
- **Observability hook**: every error is logged or traced with enough context to diagnose it, without leaking secrets or internal implementation details to the caller.

## Implementation guidance
1. Define the closed error taxonomy once per system and reuse it everywhere — do not invent a new shape per endpoint.
2. Translate exceptions at architectural boundaries (e.g. persistence → domain → API), not deep inside business logic.
3. Attach a stable machine-readable error code in addition to a human-readable message so callers can branch on it reliably.
4. Preserve the original cause internally (for logs/traces) even when the external message is generic.
5. Never expose stack traces, internal paths, or driver-specific error text to an external caller.
6. Distinguish client errors (bad input, not found, conflict) from server errors (internal, upstream failure) consistently.
7. Compose with `error.fail-fast-validation` for input boundaries and `error.retry-with-backoff` for transient/upstream failures — this pattern is the umbrella that keeps their outputs consistent.

## Validation criteria
- Every error returned across a documented boundary conforms to `contracts/schemas/error.schema.json`.
- No response leaks a stack trace, internal file path, or raw driver error message.
- Two different failure causes in the same category produce the same error shape (only the details differ).
- Errors are observable (logged/traced) with enough context to reproduce the failure.

## Security considerations
Error messages are a common information-disclosure vector: verbose stack traces or database error text can reveal schema, technology, or internal paths to an attacker. Apply `security.web_security_baseline`. Authentication and authorization failures must return generic, non-enumerable errors (see `authentication.implementation`).

## Trade-offs
A strict taxonomy and contract add upfront design cost and a translation step at every boundary, but remove ambiguity for callers and prevent inconsistent, ad-hoc error formats from proliferating as the system grows.

## Related skills and patterns
- `error.fail-fast-validation`
- `error.retry-with-backoff`
- `authentication.implementation`
- `security.web_security_baseline`

## Example decision signals
- **A database driver throws a connection error**: translate to a `transient` category error; consider `error.retry-with-backoff`.
- **A request references a resource that does not exist**: translate to a `not-found` category error with no internal detail exposed.
- **An unexpected internal exception occurs**: return a generic `internal` error externally, but log the full original exception internally.

## patterns/frontend/container_presentational.md

# Container and Presentational

## Intent
Separate data/state orchestration from visual presentation when that separation improves reuse and clarity.

## Applicability
Use for screens where fetching, state coordination, or workflow logic is materially more complex than rendering.

## Non-applicability
Do not split small components merely to follow the pattern mechanically.

## Structure / responsibilities
- Container/orchestrator handles state, data loading, and actions.
- Presentational component receives explicit data and callbacks.
- Contracts remain small and predictable.

## Implementation guidance
Keep business rules outside purely visual components. Avoid containers becoming unbounded service objects; extract cohesive logic when it grows.

## Validation criteria
- Presentation can be tested independently.
- State transitions are explicit.
- No hidden dependency on global mutable state is required.

## Security considerations
Client-side separation does not establish trust boundaries. Enforce authorization, validation, and output encoding on trusted server boundaries.

## Trade-offs
The pattern can improve testability and reuse, but unnecessary separation can fragment simple UI code.

## Related skills and patterns
- `frontend.design_patterns`
- Component Composition

## Example decision signals
Choose when the same presentation can consume different data sources or when orchestration is significantly more complex than rendering.
