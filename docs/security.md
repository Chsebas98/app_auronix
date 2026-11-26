# Security Requirements

# Reused Security from Central Memory

## security/defense_in_depth.md

# Defense in Depth

## Intent
Reduce the probability and impact of compromise by combining independent preventive, detective, and containment controls across trust boundaries.

## Applicability
Use for security-sensitive applications, APIs, mobile clients, administrative interfaces, and systems with multiple layers or trust boundaries.

## Non-applicability
Do not add redundant controls without a threat model or evidence that the layers address distinct failure modes.

## Structure / responsibilities
- **Identity layer:** authenticates principals and validates sessions or credentials.
- **Authorization layer:** enforces least privilege at each protected operation.
- **Input/output layer:** validates input and safely encodes output.
- **Data layer:** protects stored and transmitted data and limits direct access.
- **Infrastructure layer:** isolates services, networks, secrets, and runtime privileges.
- **Detection/response layer:** records security-relevant events and supports containment.

## Implementation guidance
1. Model threats and trust boundaries first.
2. Assign at least one independent control to each important attack path.
3. Ensure failure of one control does not automatically bypass all others.
4. Centralize policy where useful, but enforce authorization at the resource boundary.
5. Monitor security-sensitive failures and privilege changes.
6. Test controls independently and as an attack chain.
7. Remove controls that are obsolete or provide no meaningful risk reduction.

## Validation criteria
- Critical threats have preventive and detective controls.
- Authentication and authorization are independently enforced.
- Sensitive operations produce auditable security events without leaking secrets.
- Security tests cover bypass attempts and control failure scenarios.

## Security considerations
This pattern is itself a security strategy: controls must be independent enough to avoid a single point of failure. Never treat client-side controls as sufficient protection for server-side resources.

## Trade-offs
Layering increases resilience but also complexity, latency, maintenance cost, and the chance of inconsistent policy if governance is weak.

## Related skills and patterns
- Skills: `security.web_security_baseline`, `security.mobile_security_baseline`
- Pattern: `security.zero-trust-boundary`

## Example decision signals
Prefer this pattern when a compromise of one control must not immediately expose the protected resource.

## security/zero_trust_boundary.md

# Zero Trust Boundary

## Intent
Treat every request crossing a trust boundary as untrusted until the required identity, authorization, integrity, and policy checks succeed.

## Applicability
Use for distributed systems, APIs, administrative functions, mobile backends, service-to-service calls, and any boundary protecting sensitive resources.

## Non-applicability
Do not interpret zero trust as requiring identical controls for every low-risk internal operation; controls should be proportional to the resource and threat model.

## Structure / responsibilities
- **Requester:** presents the minimum credentials or proof required by policy.
- **Boundary:** authenticates and evaluates authorization, request integrity, and relevant policy.
- **Resource service:** performs its own resource-level authorization rather than trusting upstream labels.
- **Audit layer:** records security decisions and relevant failures without secrets.

## Implementation guidance
1. Enumerate trust boundaries and protected resources.
2. Authenticate every boundary crossing that requires identity.
3. Authorize the requested action against the actual resource and principal.
4. Apply least privilege, explicit deny-by-default rules, and short-lived credentials where appropriate.
5. Validate input and integrity before processing sensitive operations.
6. Re-evaluate authorization after privilege or resource context changes.
7. Log security decisions and monitor anomalous access.

## Validation criteria
- No protected resource depends solely on network location or an upstream trust assertion.
- Unauthorized and cross-tenant/resource access attempts are rejected.
- Privilege escalation and credential replay scenarios are tested.
- Security decisions are observable without logging credentials or sensitive payloads.

## Security considerations
Use secure credential storage and transport, minimize credential lifetime, prevent token leakage, and avoid trusting client-provided role or ownership fields.

## Trade-offs
This pattern strengthens isolation but introduces more authentication, authorization, policy evaluation, and operational observability requirements.

## Related skills and patterns
- Skills: `security.web_security_baseline`, `security.mobile_security_baseline`
- Pattern: `security.defense-in-depth`

## Example decision signals
Prefer this pattern whenever an internal network, gateway, client, or service identity alone must not grant access to a sensitive resource.
