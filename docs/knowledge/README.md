# Project knowledge

Store project-specific knowledge that should be reusable by future agents.

# Reused Skill from Central Memory

## skills/architecture/mobile.md

# Architecture Option: Mobile

Use for native or cross-platform mobile applications.

## Required decisions
- platform scope
- application state and navigation
- API/backend boundary
- secure local storage
- offline/synchronization behavior
- release and update strategy

## Security
Apply the central mobile security baseline to local data, credentials, transport and API access.

## skills/frontend/api_integration.md

# Frontend API Integration

- **ID:** `frontend.api_integration`
- **Purpose:** connect a frontend feature to a backend API with correct loading/error handling, caching, and request lifecycle management — not a bare fetch call dropped into a component.
- **When:** a component needs data from, or needs to send data to, a backend service.

## Procedure
1. Confirm the API contract (`api.contract_design`) before wiring the client — request/response shape, pagination, error format.
2. Use a data-fetching layer that handles caching, deduplication, and refetch (`frontend.state_management`) rather than manual fetch-plus-state-plus-effect per component.
3. Model every request's lifecycle explicitly: idle, loading, success, error — and render each state (`frontend.loading_states`, `frontend.error_handling`).
4. Handle cancellation: abort in-flight requests when the component unmounts or query params change before the previous request resolves.
5. Centralize the HTTP client's cross-cutting concerns (auth headers, base URL, error normalization) in one place instead of duplicating them per call site.
6. Map API error shapes to user-facing messages once, centrally, so every call site doesn't reinvent error text.
7. Verify retry/backoff behavior for transient failures matches the backend's expectations (`error_handling.implementation`) — don't blindly retry non-idempotent writes.

## Validation
- No component fetches data with a raw, uncancelled call directly inside a render-triggered effect.
- Every API call site renders loading, error, and success states distinctly.
- Stale in-flight requests are cancelled or ignored when superseded by a newer request.
- Auth/error handling for API calls is centralized, not duplicated per component.

## Common failure modes
- Race conditions from firing a new request on every keystroke/param change without cancelling the previous one, letting a stale response overwrite fresher state.
- Silent failures: a rejected promise with no error handling, leaving the UI stuck on a loading spinner forever.

## Outputs
API client/hook wired to the feature, with documented loading/error/success handling per call.

## Related
`api.contract_design`, `frontend.state_management`, `frontend.loading_states`, `frontend.error_handling`, `error_handling.implementation`

## skills/mobile/accessibility.md

# Mobile Accessibility

- **ID:** `mobile.accessibility`
- **Purpose:** make screens usable with platform accessibility services (screen readers, dynamic text sizing, sufficient contrast, switch/voice control) rather than only visually functional.
- **When:** building or reviewing any user-facing screen, and especially before a release that a store/legal accessibility audit will check.

## Procedure
1. Label every interactive element (buttons, icon-only controls, images that convey meaning) with a screen-reader-accessible description, not just visual text/icon.
2. Verify focus order matches visual/logical reading order, and that custom components expose the correct accessibility role/traits, not just a generic container.
3. Support dynamic text scaling without truncating or clipping content at the largest supported system font size.
4. Check color contrast ratios meet the platform/WCAG minimum for text and meaningful icons, not just aesthetic preference.
5. Ensure all functionality reachable by touch is also reachable via screen reader navigation and, where supported, switch control — no touch-only gestures for core actions.
6. Test with the platform's actual screen reader (VoiceOver/TalkBack) enabled end-to-end on at least the primary user flows, not just an automated linter pass.

## Validation
- Every interactive control has a non-empty, accurate accessibility label.
- The primary user flow is fully completable with a screen reader enabled and no mouse/touch shortcuts.
- Text remains readable (not clipped/overlapping) at the largest supported system font scale.
- Automated accessibility lint passes, supplemented by at least one manual screen-reader walkthrough.

## Common failure modes
- An icon-only button (e.g., a trash icon) with no accessible label, announced to screen reader users as just "button."
- A custom swipe-to-delete gesture with no accessible equivalent action, making the feature unreachable for screen reader/switch users.
- Passing an automated accessibility linter while the actual reading order is scrambled because of an absolute-positioned custom layout.

## Outputs
Accessibility-labeled components, verified focus order, screen-reader-tested primary flow, contrast audit results.

## Related
`mobile.state_management`, `ui_ux.design_component`, `mobile.architecture`

## skills/mobile/api_integration.md

# Mobile API Integration

- **ID:** `mobile.api_integration`
- **Purpose:** integrate the app with backend APIs through a typed client layer that handles auth, retries, and versioning without leaking transport details into UI code.
- **When:** adding a new backend integration, or a screen needs data from an API not already wrapped by an existing client layer.

## Procedure
1. Generate or hand-write a typed client from the API contract (`api.contract_design`) rather than hand-parsing raw JSON per call site.
2. Centralize auth token attachment and refresh (`mobile.authentication`) in one interceptor/middleware layer, not per-request.
3. Apply retry-with-backoff for idempotent/transient failures only (`error.retry-with-backoff`); never blindly retry non-idempotent writes.
4. Map API error responses into the app's own error taxonomy (`error_handling.implementation`) before they reach UI/state code.
5. Version-check or feature-flag against breaking API changes (`api.versioned_contract`) so an old app build degrades gracefully instead of crashing.
6. Decide caching/offline behavior per endpoint together with `mobile.offline_mode`, rather than caching everything uniformly.
7. Add contract tests against a mock/staging server so client and server drift is caught before release (`testing.contract_testing`).

## Validation
- No screen/view code directly constructs raw HTTP requests or parses raw JSON.
- Expired/invalid tokens trigger a single centralized refresh-or-logout path, not per-call-site handling.
- Non-idempotent requests (POST without an idempotency key) are never automatically retried.
- Contract tests catch a breaking server response shape change before it reaches a release build.

## Common failure modes
- Duplicate network calls firing because retry logic and a user-triggered pull-to-refresh both fire independently.
- Silent auth failures: a 401 is treated as a generic error and shown as "something went wrong" instead of triggering re-authentication.
- Client and server drifting on an enum/field rename with no contract test catching it until production.

## Outputs
Typed API client layer, auth interceptor, error-mapping layer, contract tests.

## Related
`api.contract_design`, `error.retry-with-backoff`, `error_handling.implementation`, `mobile.authentication`, `mobile.offline_mode`, `testing.contract_testing`

## skills/mobile/authentication.md

# Mobile Authentication

- **ID:** `mobile.authentication`
- **Purpose:** implement client-side login/session handling (credential capture, token storage, refresh, logout) that correctly delegates identity verification to the backend and never trusts client-side state as proof of authorization.
- **When:** implementing or modifying login, session refresh, logout, or multi-account switching in a mobile app.

## Procedure
1. Delegate all identity verification to the backend (`authentication.implementation`); the client only captures credentials and presents the resulting session/token.
2. Store issued tokens exclusively in secure platform storage (`mobile.local_storage`), never in plain preferences or app memory-dumped logs.
3. Implement silent token refresh centrally (`mobile.api_integration` interceptor) so individual screens never handle raw token expiry.
4. On refresh failure, force a full re-authentication and clear all locally cached sensitive data, not just the token.
5. Treat biometric unlock (`mobile.biometric_authentication`) as a local re-entry convenience layered on top of a still-valid session, not a replacement for server-side authentication.
6. Implement a real logout that revokes the session server-side and wipes local secure storage, not just navigates back to a login screen.
7. Test session expiry, forced logout, and multi-account switch paths explicitly, including what happens to in-flight requests during token refresh.

## Validation
- No client-only state can grant access to a protected screen without a currently valid server-verified session.
- Logout revokes the session server-side and is verified to remove locally cached tokens.
- Concurrent in-flight requests during a token refresh do not fail permanently or duplicate the refresh call.
- Session expiry mid-use degrades gracefully to a re-authentication prompt, not a raw error screen or silent data loss.

## Common failure modes
- Client trusting a locally cached "isLoggedIn" flag as sufficient proof of session validity after the actual token has expired server-side.
- Multiple simultaneous 401 responses each triggering their own token-refresh call, causing a refresh-token race that invalidates the session.
- Logout leaving a valid refresh token in secure storage because only the access token was cleared.

## Outputs
Login/session flow implementation, token refresh interceptor, verified logout path, session-expiry UX.

## Related
`authentication.implementation`, `security.mobile_security_baseline`, `mobile.local_storage`, `mobile.biometric_authentication`, `mobile.api_integration`

## skills/mobile/architecture.md

# Mobile App Architecture

- **ID:** `mobile.architecture`
- **Purpose:** choose and structure the app's layering (presentation/domain/data) and module boundaries so features can be built, tested, and replaced independently.
- **When:** starting a new mobile app or a major module, or when feature coupling is making changes risky.

## Procedure
1. Pick a layering approach (MVVM/MVI/Clean) matching team size and platform idioms; do not mix idioms across screens.
2. Define module boundaries (feature modules, core/shared modules) so unrelated features don't share build/runtime state.
3. Establish the data flow direction (`mobile.unidirectional-data-flow`) so state changes are traceable.
4. Decide navigation ownership (`mobile.navigation`) and where cross-feature navigation contracts live.
5. Decide the local persistence boundary (`mobile.local_storage`) and API boundary (`mobile.api_integration`) so domain logic doesn't import platform SDKs directly.
6. Document the chosen architecture in a short ADR (`architecture.adr`) so future contributors don't reinvent or silently diverge.
7. Validate the architecture against at least one "hard" feature (offline + push notification + deep link) before locking it in.

## Validation
- A new feature can be added without modifying unrelated modules.
- Domain/business logic has no direct import of platform UI or SDK classes.
- Navigation and persistence boundaries are enforced by module visibility, not convention alone.
- The ADR documenting the decision exists and is discoverable.

## Common failure modes
- Copying a web MVC pattern onto mobile without accounting for lifecycle recreation, backgrounding, and process death.
- Over-modularizing a small app, creating build overhead that outweighs the isolation benefit.
- Letting one screen's ViewModel directly call another feature's repository, silently coupling modules the module graph claims are independent.

## Outputs
Architecture ADR, module/dependency diagram, layering conventions doc.

## Related
`mobile.navigation`, `mobile.state_management`, `mobile.unidirectional-data-flow`, `architecture.adr`, `architecture.system_design`

## skills/mobile/background_tasks.md

# Mobile Background Tasks

- **ID:** `mobile.background_tasks`
- **Purpose:** schedule and execute work (sync, upload, cleanup) while the app is backgrounded or not running, within each platform's execution-time and battery constraints.
- **When:** a feature needs to complete work after the user leaves the app (finishing an upload, periodic sync, scheduled reminders).

## Procedure
1. Classify the task by urgency and duration: immediate short-lived (finish an in-progress upload), deferred (periodic sync), or exact-time (scheduled reminder) — each maps to a different platform API.
2. Use the platform's background task scheduler (not a busy-loop or held wake lock) and request only the execution budget the task actually needs.
3. Make the task idempotent and resumable, since the OS can suspend or kill it before completion at any point.
4. Persist task progress/state (`mobile.local_storage`) so a killed background task resumes rather than restarts or duplicates work on next launch.
5. Respect platform battery-optimization/Doze-style restrictions; do not attempt to defeat them with workarounds that get the app flagged or throttled.
6. Surface failures to the user or a retry queue (`mobile.offline_mode`) instead of failing silently with no visible trace.

## Validation
- The task correctly resumes or safely no-ops if killed mid-execution and relaunched, without duplicating side effects.
- No background task holds a wake lock or runs a busy-loop beyond the platform's allowed execution window.
- Task scheduling respects battery-optimization APIs rather than working around them.
- A failed background task is visible in a retry queue or user-facing status, not silently dropped.

## Common failure modes
- An upload task duplicating a partially-completed upload because it restarted from scratch instead of resuming or checking for prior completion.
- Excess background wake-ups draining battery, triggering the OS to restrict the app's background execution entirely.
- Background sync writing to shared local storage concurrently with a foreground operation, causing a data race.

## Outputs
Background task scheduling implementation, idempotent resume logic, failure/retry surfacing.

## Related
`mobile.offline_mode`, `mobile.local_storage`, `mobile.push_notifications`, `error.retry-with-backoff`

## skills/mobile/biometric_authentication.md

# Mobile Biometric Authentication

- **ID:** `mobile.biometric_authentication`
- **Purpose:** gate access to an already-authenticated session or sensitive local action behind platform biometric verification (Face/Touch ID, fingerprint) without making biometrics the sole proof of identity to the backend.
- **When:** adding a biometric app-lock, or gating a sensitive local action (viewing saved payment info, approving a transaction) behind biometric re-verification.

## Procedure
1. Use only the platform's biometric APIs (backed by secure enclave/hardware keystore); never implement custom biometric capture or matching.
2. Treat a successful biometric check as unlocking access to an existing, still-valid server session/local secret — never as itself issuing a new session with the backend.
3. Bind the biometric-gated secret to hardware-backed storage so it can't be extracted even with root/jailbreak, and invalidate it automatically if the device's enrolled biometrics change.
4. Provide a non-biometric fallback (PIN/password) for devices/users without biometrics enrolled, and equalize the security level of both paths.
5. Re-require biometric/fallback verification after a defined inactivity timeout, not just once at app launch.
6. Fail closed: any biometric API error (hardware unavailable, too many attempts) must deny access, never silently grant it.

## Validation
- Enrolling a new fingerprint/face on the device invalidates previously bound biometric-gated secrets.
- A biometric API failure or exception results in access being denied, never granted by default.
- The non-biometric fallback path enforces equivalent security (rate limiting, lockout) to the biometric path.
- Biometric success alone cannot be replayed to obtain a new backend session without the underlying token still being valid.

## Common failure modes
- Treating "biometric check passed" as equivalent to "user authenticated with the server," letting an attacker with the unlocked device but an expired session bypass the backend entirely.
- Not invalidating hardware-bound secrets when the device's biometric enrollment changes, allowing a newly enrolled fingerprint (e.g., after device theft) to unlock another user's data.
- No fallback path, locking out users whose biometric hardware fails or who revoked biometric permission.

## Outputs
Biometric-gated unlock flow, hardware-backed secret binding, fallback authentication path, inactivity re-lock policy.

## Related
`mobile.authentication`, `mobile.local_storage`, `security.mobile_security_baseline`, `mobile.permissions`

## skills/mobile/deep_links.md

# Mobile Deep Links

- **ID:** `mobile.deep_links`
- **Purpose:** handle universal/app links and custom URI schemes so they route to the correct in-app destination securely, including when the app is cold-started.
- **When:** adding a new shareable/linkable screen, or a deep link is misrouting, being hijacked, or bypassing auth checks.

## Procedure
1. Prefer platform-verified links (Universal Links / App Links) over custom URI schemes where possible, since custom schemes can be claimed by other apps.
2. Register the domain association file (apple-app-site-association / assetlinks.json) and verify it resolves correctly for the production domain.
3. Route every incoming link through the same navigation graph and auth/authorization checks as in-app navigation (`mobile.navigation`) — never a separate unguarded handler.
4. Validate and sanitize all link parameters as untrusted input before using them to fetch data or take action.
5. Handle cold-start deep links (app not running) and warm-start deep links (app backgrounded) as distinct code paths, both landing on the same resulting state.
6. Define a safe fallback destination for a malformed, expired, or unauthorized deep link, rather than crashing or exposing an error with internal detail.

## Validation
- A deep link to an authenticated screen cannot be used to bypass the app's authentication/authorization checks.
- Custom URI scheme links to sensitive actions are rejected or downgraded when Universal/App Links verification is unavailable.
- Malformed or unauthorized deep link parameters produce a safe fallback screen, not a crash or raw error.
- Cold-start and warm-start deep link handling produce identical resulting navigation state.

## Common failure modes
- A custom URI scheme claimed by a second, malicious app intercepting sensitive links intended for the real app (scheme hijacking).
- Deep link handler trusting a userId or resourceId parameter directly without checking the current session is authorized for it.
- Cold-start deep link arriving before the app's auth state is initialized, causing it to silently drop or misroute.

## Outputs
Verified Universal/App Links configuration, deep-link parameter validation, cold/warm start handling, safe fallback screen.

## Related
`mobile.navigation`, `mobile.authentication`, `security.mobile_security_baseline`, `mobile.push_notifications`

## skills/mobile/local_storage.md

# Mobile Local Storage

- **ID:** `mobile.local_storage`
- **Purpose:** persist app data locally using the right storage tier per sensitivity (plain preferences, database, or secure/encrypted keystore) so sensitive data can't be trivially extracted from the device.
- **When:** storing any data across app restarts — user preferences, cached API data, credentials/tokens, or offline queue data.

## Procedure
1. Classify data sensitivity first: public/UI-preference, business data, or credential/PII — this determines which storage tier is allowed.
2. Store credentials, tokens, and other secrets only in the platform's secure storage (Keychain/Keystore-backed), never in plain preferences, plain SQLite, or app-readable files.
3. Use a structured local database for queryable business data, not ad-hoc file serialization, so offline queries and `mobile.offline_mode` sync stay consistent.
4. Encrypt sensitive cached data at rest even outside the secure keystore tier when OS-level secure storage isn't suited to bulk data.
5. Exclude sensitive local files from OS-level backups (cloud backup exclusion flags) so a compromised backup doesn't leak them.
6. Define and implement a data wipe path (logout, account deletion) that actually deletes local sensitive data, not just marks it inactive.

## Validation
- No credential, token, or PII appears in plaintext in preferences files, plain SQLite, or app logs.
- Sensitive local data is excluded from device/cloud backups.
- Logout/account-deletion verifiably removes locally cached sensitive data (checked on-device, not assumed).
- Local storage access is scoped to the app sandbox; no world-readable file permissions.

## Common failure modes
- Caching an auth token in a plain key-value store "temporarily" during development, which survives into production.
- Sensitive data surviving in a database file after "logout" because only an in-memory flag was cleared.
- Relying on OS sandboxing alone on a rooted/jailbroken device where sandbox guarantees don't fully hold.

## Outputs
Storage tier classification, secure-storage integration for secrets, backup-exclusion configuration, verified wipe-on-logout path.

## Related
`security.mobile_security_baseline`, `mobile.authentication`, `mobile.offline_mode`, `mobile.biometric_authentication`

## skills/mobile/mobile_security.md

# Mobile Client Security Hardening

- **ID:** `mobile.mobile_security`
- **Purpose:** apply device- and client-level security hardening (root/jailbreak detection posture, code/tamper protection, secure inter-process communication) beyond the baseline API/auth controls, appropriate to the app's actual risk profile.
- **When:** shipping an app that handles payment data, health data, or other high-value targets, or after a security review flags client-side exposure.

## Procedure
1. Start from the mandatory baseline (`security.mobile_security_baseline`) — this skill adds hardening beyond it for higher-risk apps, it doesn't replace it.
2. Decide the actual response to root/jailbreak detection (warn, restrict sensitive features, or allow) based on real risk — outright blocking often just drives away legitimate power users without stopping a motivated attacker.
3. Lock down inter-process communication: exported components, custom URI scheme handlers, and clipboard/share usage should not leak sensitive data to other apps.
4. Apply code/tamper protection (obfuscation, integrity checks) only where it meaningfully raises attacker cost, understanding it's a deterrent layer, not a substitute for server-side enforcement.
5. Audit third-party SDKs for excessive permissions or data collection before integrating them; a single ad/analytics SDK can undermine the app's entire security posture.
6. Re-run this hardening review whenever a new sensitive feature (payments, health data, biometrics) is added, not just once at initial release.

## Validation
- Sensitive data cannot be exfiltrated via an exported component, clipboard leak, or unvalidated custom URI scheme.
- Root/jailbreak detection response is a deliberate, documented decision, not a default library setting left unreviewed.
- Third-party SDKs integrated into the app have been reviewed for the permissions and data they actually collect.
- Client-side hardening measures are confirmed not to be the only line of defense for any sensitive action (server-side checks still apply).

## Common failure modes
- Treating client-side obfuscation as sufficient protection for business logic that should be enforced server-side (e.g., price calculation done and trusted client-side).
- An exported Activity/Intent filter or clipboard write leaking a session token to another app on the device.
- Integrating an analytics/ad SDK that silently harvests device identifiers or contact data beyond what the app's own privacy policy discloses.

## Outputs
Hardening decisions log, IPC/export audit, third-party SDK data-collection review.

## Related
`security.mobile_security_baseline`, `mobile.local_storage`, `mobile.authentication`, `mobile.deep_links`

## skills/mobile/navigation.md

# Mobile Navigation

- **ID:** `mobile.navigation`
- **Purpose:** define a navigation graph and back-stack model that handles deep links, tab/stack composition, and state restoration without duplicating screens or losing state.
- **When:** adding a new screen/flow, restructuring the nav graph, or debugging back-stack/duplicate-screen bugs.

## Procedure
1. Model navigation as a declarative graph (destinations + arguments), not ad-hoc imperative pushes scattered through screens.
2. Type navigation arguments explicitly; never pass untyped bundles/maps across screen boundaries.
3. Decide back-stack behavior per flow (single-top, clear-on-login, nested stacks for tabs) before implementing it ad hoc per screen.
4. Wire deep links (`mobile.deep_links`) into the same graph so a cold-start deep link and an in-app navigation reach the same destination and state.
5. Preserve navigation state across process death (save the back-stack/route, not just scroll position).
6. Test the graph for orphaned back-stacks (e.g., a login flow left on the stack after successful auth).

## Validation
- Every destination is reachable both via in-app navigation and its deep link with identical resulting state.
- No screen appears twice in the back-stack after a flow that should replace it (e.g., login to home).
- Process death and restoration return the user to the same screen with the same arguments.
- Tab/nested navigation preserves each tab's own back-stack independently.

## Common failure modes
- Pushing the same screen repeatedly on rapid taps because navigation isn't debounced/guarded against duplicate events.
- Clearing the wrong part of the back-stack after login/logout, leaving sensitive screens reachable via the back button.
- Deep link handling bypassing the same validation/auth checks that in-app navigation applies.

## Outputs
Navigation graph definition, back-stack policy per flow, deep-link-to-destination mapping.

## Related
`mobile.deep_links`, `mobile.architecture`, `mobile.state_management`, `mobile.unidirectional-data-flow`

## skills/mobile/offline_mode.md

# Mobile Offline Mode

- **ID:** `mobile.offline_mode`
- **Purpose:** keep the app usable and data-consistent when the network is unavailable or unreliable, with a clear reconciliation strategy once connectivity returns.
- **When:** the app must function (fully or degraded) without connectivity, or intermittent connectivity is causing data loss or duplicate writes.

## Procedure
1. Classify each feature's offline requirement explicitly: read-only cache, queued writes, or online-only with a clear blocked state.
2. Persist the minimum data needed for offline reads in local storage (`mobile.local_storage`), with an explicit staleness/expiry policy shown to the user.
3. Queue writes made offline with enough metadata (timestamp, idempotency key) to replay them safely later (`api.idempotency_key`).
4. Define a conflict resolution strategy for queued writes that succeed against stale server state (last-write-wins, merge, or user-prompted) — never assume it can't happen.
5. Detect connectivity transitions reliably and trigger sync automatically, with visible sync status rather than silent background failure.
6. Test the offline-to-online transition explicitly: queue writes offline, restore connectivity, verify replay order and conflict handling.

## Validation
- The app clearly communicates when displayed data is cached/stale versus live.
- Queued offline writes are never silently dropped on app restart or a connectivity flap.
- Conflicting writes (local queued vs. server-side change) are resolved by a defined, tested strategy, not whichever request lands last.
- Sync failures are surfaced to the user or retried, never swallowed silently.

## Common failure modes
- Duplicate submissions because a queued write is replayed twice after a partial sync failure with no idempotency key.
- The UI showing an empty state instead of cached data because the offline cache path wasn't wired into the same render path as the online path.
- Sync silently failing in the background with no user-visible indicator, leading to data loss the user believes was saved.

## Outputs
Offline data classification, write queue implementation, conflict resolution policy, sync status UI.

## Related
`mobile.local_storage`, `mobile.api_integration`, `api.idempotency_key`, `database.optimistic_concurrency`, `mobile.state_management`

## skills/mobile/performance.md

# Mobile Performance

- **ID:** `mobile.performance`
- **Purpose:** identify and fix mobile-specific performance issues (frame drops, slow cold start, memory growth, excessive battery/network use) that generic backend profiling doesn't catch.
- **When:** users or store reviews report jank/lag, cold start time regresses, or memory/battery usage climbs in a release.

## Procedure
1. Measure before optimizing: capture frame timing (dropped/janky frames), cold start time, and memory profile with platform tooling, not guesswork.
2. Profile the actual regression against a previous known-good build/version to isolate what changed, not the whole app at once.
3. Fix main/UI-thread blocking first (heavy work on the main thread) since it's the most common cause of visible jank.
4. Reduce cold start cost by deferring non-critical initialization (analytics, non-visible feature setup) until after first frame.
5. Check for memory leaks from retained Context/View references, unclosed streams, or uncancelled subscriptions tied to a destroyed screen.
6. Re-measure after each fix in isolation to confirm the specific change caused the improvement, not an unattributable combination.

## Validation
- Frame timing shows no regression against the previous release's baseline on the target device tier.
- Cold start time is measured on a representative low/mid-tier device, not only a high-end development device.
- Memory profile shows no unbounded growth over a repeated navigate-in/navigate-out cycle on the same screen.
- Each performance fix has a before/after measurement attributing the improvement to that specific change.

## Common failure modes
- Optimizing on a high-end development device while the regression is only visible on low/mid-tier devices most users actually have.
- Fixing a symptom (adding a loading spinner) instead of the cause (main-thread blocking work) — the app is still slow, just perceived differently.
- A screen's ViewModel/state holder retained by a leaked subscription, causing memory to grow on every navigation in/out cycle.

## Outputs
Performance baseline, profiling results, isolated fixes with before/after measurements.

## Related
`mobile.state_management`, `mobile.architecture`, `mobile.background_tasks`, `mobile.accessibility`

## skills/mobile/permissions.md

# Mobile Runtime Permissions

- **ID:** `mobile.permissions`
- **Purpose:** request, handle, and gracefully degrade around OS-level runtime permissions (camera, location, notifications, contacts) using least-privilege and contextual timing.
- **When:** a feature needs a new device permission, or users are reporting permission-denial crashes or confusing repeated prompts.

## Procedure
1. Request each permission only immediately before the feature that needs it is used, with an explanation of why, not in a batch at app launch.
2. Request the minimum permission scope available (e.g., "while using the app" location instead of "always", limited photo access instead of full library).
3. Handle every permission state explicitly: granted, denied, denied-permanently ("don't ask again"), and provisional/limited where the platform supports it.
4. Provide a graceful degraded experience when permission is denied, not a dead-end screen or crash.
5. Deep-link users to system settings when they need to change a permanently-denied permission, rather than re-prompting in a loop.
6. Re-check permission state on app resume, since it can change outside the app (user revokes it in system settings).

## Validation
- Denying any requested permission leaves the app in a usable, non-crashing state.
- No permission is requested before the feature that needs it is actually invoked.
- Permanently-denied state is detected and handled distinctly from a first-time denial (no infinite re-prompt loop).
- Permission state is re-validated on resume, not cached for the life of the app session.

## Common failure modes
- Requesting camera, location, and notifications all at first launch, causing most users to deny everything reflexively.
- Crashing or silently no-op'ing a feature when a permission is revoked mid-session instead of re-checking state.
- Treating "denied once" the same as "denied permanently," repeatedly showing the OS prompt until the user disables it at the OS level.

## Outputs
Per-feature permission request flow, denial/degraded-state UX, settings deep-link for permanently denied permissions.

## Related
`mobile.push_notifications`, `mobile.deep_links`, `security.mobile_security_baseline`, `mobile.background_tasks`

## skills/mobile/push_notifications.md

# Mobile Push Notifications

- **ID:** `mobile.push_notifications`
- **Purpose:** deliver and handle push notifications (registration, permission, deep-linked tap handling, and payload validation) reliably across foreground/background/killed app states.
- **When:** adding a new notification type, or notifications are failing to arrive, duplicating, or mis-navigating when tapped.

## Procedure
1. Register for push tokens after (not before) explaining the value to the user, and re-register on token rotation/app reinstall.
2. Request notification permission (`mobile.permissions`) with context, respecting the platform's provisional/soft-ask patterns where available.
3. Treat the notification payload as untrusted input: validate/sanitize it server-side and again on receipt before acting on it.
4. Route notification taps through the same navigation graph as in-app navigation (`mobile.navigation`), not a separate ad-hoc handler.
5. Handle all three app states explicitly (foreground, background, killed) since each platform delivers/handles notifications differently in each.
6. Deduplicate notifications by a server-issued ID so retried push delivery doesn't show duplicates.
7. Test token invalidation/expiry handling so a stale token doesn't silently blackhole notifications.

## Validation
- A tapped notification navigates to the correct destination in all three app lifecycle states.
- Duplicate push deliveries (server retries) do not produce duplicate visible notifications.
- Notification payloads cannot trigger unintended actions (e.g., silent data deletion) without further authorization.
- Token rotation/reinstall is detected and re-registered without user intervention.

## Common failure modes
- A deep link inside a notification bypassing auth checks because it was wired directly instead of through the guarded navigation graph.
- Silent notifications used for background sync draining battery because they're not rate-limited or coalesced.
- Notification permission requested at first app launch with no context, causing most users to deny it permanently.

## Outputs
Push registration flow, payload validation logic, notification-to-navigation mapping, foreground/background/killed handling.

## Related
`mobile.permissions`, `mobile.deep_links`, `mobile.navigation`, `mobile.background_tasks`, `security.mobile_security_baseline`

## skills/mobile/release_management.md

# Mobile Release Management

- **ID:** `mobile.release_management`
- **Purpose:** ship app releases through staged rollout with monitored health metrics and a fast rollback path, instead of a single all-users release with no safety net.
- **When:** preparing any store release, especially one containing a risky change (data migration, new auth flow, SDK upgrade).

## Procedure
1. Version and stage the release (internal to beta/TestFlight to a staged percentage rollout) rather than releasing to 100% at once.
2. Gate any risky change behind a remote feature flag so it can be disabled without a new store submission.
3. Define the health metrics that gate rollout progression (crash-free rate, ANR rate, key funnel completion) before starting the rollout, not after seeing a problem.
4. Handle backward compatibility explicitly: an in-progress rollout means multiple app versions hit the API simultaneously (`api.versioned_contract`) — the backend must support both.
5. Prepare the rollback path before release: halting/rolling back the staged percentage and disabling the remote feature flag, without requiring a new binary submission for the common case.
6. Monitor the staged cohort actively during rollout and only progress to the next percentage once health metrics hold for a defined window.
7. Capture release notes and a changelog entry tied to the version for support/debugging traceability.

## Validation
- A staged rollout can be halted or rolled back without waiting on app-store review for a new binary.
- Crash-free rate and ANR rate are monitored per rollout stage against a defined threshold before progressing.
- The backend correctly serves both the new and previous app version during the rollout window.
- A risky new feature is behind a remote-disableable flag, not hard-compiled into the release with no kill switch.

## Common failure modes
- Releasing to 100% of users immediately, so a crash-causing bug reaches the entire user base before it's caught.
- A staged rollout halted in the store console while the risky code path is still hard-enabled for everyone already updated, with no remote flag to turn it off.
- Backend deploying a breaking API change timed to "match" the app release, breaking users still on the previous app version mid-rollout.

## Outputs
Staged rollout plan, remote feature flag for risky changes, rollout health-metric thresholds, rollback runbook.

## Related
`api.versioned_contract`, `devops.deployment`, `git.release_tagging`, `mobile.performance`

## skills/mobile/state_management.md

# Mobile State Management

- **ID:** `mobile.state_management`
- **Purpose:** choose and implement a state container per screen/feature that survives configuration changes and makes async results (loading/success/error) explicit.
- **When:** a screen has more than trivial local state, or async operations (network, sensors, background tasks) can race or arrive after the screen is gone.

## Procedure
1. Model each screen's state as one explicit type covering loading, success, empty, and error — never as a scatter of independent booleans.
2. Route all state changes through a single update path driven by events (`mobile.unidirectional-data-flow`), not direct mutation from multiple call sites.
3. Scope state ownership to survive configuration changes (rotation) but not process navigation away from the screen, unless it's meant to persist longer.
4. Guard async results against being applied after the screen/view is destroyed or a newer request has superseded them (cancellation, request tokens).
5. Keep state serializable where feasible so it can be saved/restored across process death.
6. Test state transitions directly at the unit level, independent of the UI framework, so tests don't require rendering.

## Validation
- Loading, success, empty, and error are each independently representable and tested.
- A slow, stale async response cannot overwrite state produced by a newer request.
- State survives rotation without re-triggering network calls.
- State transition logic has unit tests that don't require instantiating a UI component.

## Common failure modes
- Two in-flight requests for the same screen racing, with the slower one overwriting the faster one's more recent result.
- Leaking a previous screen's error state into a freshly navigated instance of the same screen type.
- Storing state that includes non-serializable platform objects (Context, View references), causing restoration failures or leaks.

## Outputs
State model per screen/feature, unit tests for transitions, cancellation/guarding logic for async updates.

## Related
`mobile.unidirectional-data-flow`, `mobile.architecture`, `mobile.api_integration`, `mobile.offline_mode`

## skills/security/mobile_security.md

# Mobile Application Risk Management

- **ID:** `security.mobile_security`
- **Purpose:** Manage the cross-cutting risk categories specific to distributing an application binary to an untrusted client device — reverse engineering, client-side tampering, insecure platform storage — as the design-level complement to the mobile release checklist.
- **When:** Whenever scoping the threat model or architecture for a mobile application, distinct from per-release checklist execution.
- **Security level:** `critical`

## Procedure
1. Treat the device as fully attacker-controlled: assume the binary will be decompiled (APK unpacking, IPA class-dump) and that client-side checks (root/jailbreak detection, pinning, business-logic validation) are speed bumps, not boundaries — the server must independently enforce every rule the client enforces.
2. Assess platform-specific data-at-rest exposure: Android backups, Keychain/Keystore access scope, shared-preferences/plist plaintext storage, and data collection by third-party SDKs embedded in the binary.
3. Evaluate the inter-app attack surface: exported Android components (activities/services/broadcast receivers/content providers) and iOS universal links/URL schemes another installed app or malicious link can invoke.
4. Assess third-party SDK and advertising/analytics library risk separately from first-party code — these run with the app's full permission set and are a common mobile-specific data-leak vector.
5. Model the "compromised device" scenario explicitly (rooted/jailbroken, malware-infected, stolen while unlocked) and decide, per sensitive operation, what must still hold true server-side under that assumption.
6. Plan for binary distribution risk: side-loaded/re-signed tampered app copies reaching users, and what server-side attestation (Play Integrity, DeviceCheck/App Attest) can detect this.
7. Feed findings into the release-gate checklist execution in `security.mobile_security_baseline`.

## Validation
- A documented threat model covers device-compromise, reverse-engineering, and third-party SDK data flows.
- Every security-relevant client-side check has a server-side enforcement that doesn't depend on client honesty.
- Third-party SDKs embedded in the binary are inventoried with the data each collects/transmits.
- Platform attestation is evaluated for high-value flows (payments, account-takeover-sensitive actions).

## Common failure modes
- Relying on certificate pinning or root detection as the sole defense for a sensitive flow, bypassed via Frida/instrumentation in minutes.
- Auditing only first-party code for data leaks while an embedded ad/analytics SDK exfiltrates device identifiers independently.
- Treating the mobile threat model as one-time instead of revisiting it when a new deep link, SDK, or export component is added.

## Outputs
Mobile threat model (device-compromise, reverse-engineering, SDK data-flow), server-side enforcement mapping, attestation decision per sensitive flow.

## Related
`security.mobile_security_baseline`, `security.web_security_baseline`, `security.data_protection`, `security.api_security`

## skills/security/mobile_security_baseline.md

# Skill: Mobile Security Baseline

- **ID:** `security.mobile_security_baseline`
- **Purpose:** aplicar controles mínimos de seguridad a aplicaciones móviles y sus APIs.
- **Security level:** `critical`

## Mandatory controls
1. No almacenar secretos, claves maestras o credenciales permanentes en texto plano dentro de la app.
2. Usar almacenamiento seguro del sistema para tokens y material sensible.
3. Aplicar autenticación, autorización, expiración y revocación de credenciales.
4. Validar certificados/TLS y evitar configuraciones inseguras de transporte.
5. No confiar en datos provenientes del cliente; validar todo en backend.
6. Revisar permisos solicitados y aplicar mínimo privilegio.
7. Proteger deep links y app links contra abuso y validarlos antes de acciones sensibles.
8. Evitar exposición de datos sensibles en logs, screenshots, backups y notificaciones.
9. Proteger interfaces locales, intents/deep links y comunicación entre componentes.
10. Aplicar rate limiting, anti-replay e idempotencia para operaciones sensibles en API.
11. Ofuscar/proteger binarios cuando el riesgo lo justifique, entendiendo que ofuscación no reemplaza controles del servidor.
12. Probar escenarios offline, pérdida de dispositivo, sesión expirada y manipulación del cliente.

## Validation
Toda funcionalidad móvil sensible debe pasar revisión de almacenamiento, transporte, autenticación, autorización, permisos y exposición de datos.

## Outputs
Threat checklist móvil, controles aplicados, pruebas y riesgos residuales.

## skills/frontend/accessibility.md

# Frontend Accessibility

- **ID:** `frontend.accessibility`
- **Purpose:** make a UI operable and understandable via keyboard and assistive technology, meeting WCAG-level expectations rather than only visual/mouse-driven usability.
- **When:** building or reviewing any interactive component, form, or navigation flow — scoped to a component or flow, not deferred to a final audit pass.

## Procedure
1. Use semantic HTML elements (`button`, `nav`, `label`, ordered headings) before reaching for ARIA — ARIA supplements semantics, it doesn't replace them.
2. Ensure every interactive element is reachable and operable via keyboard alone, in a logical tab order, with a visible focus indicator.
3. Provide accessible names for every control (labels, `aria-label`, or visible text) — an icon-only button with no accessible name is unusable by screen reader users.
4. Manage focus explicitly for dynamic UI: move focus into opened modals/dialogs, return it on close, and announce async content changes via live regions where appropriate.
5. Verify color is never the only signal for state (error, success, required) — pair it with text or an icon.
6. Check contrast ratios for text and meaningful UI elements against the project's design tokens (`frontend.design_system`).
7. Test with an actual screen reader, using automated checks (`testing.accessibility_testing`) as a baseline only — visual review alone misses most issues.

## Validation
- Every interactive element is reachable and operable by keyboard, with a visible focus state.
- Automated accessibility checks (axe or equivalent) report no critical violations on the component/page.
- Dynamic content changes (modals, toasts, validation errors) are announced to assistive technology.
- No information is conveyed by color alone.

## Common failure modes
- Custom-styled controls (divs styled as buttons) with click handlers but no keyboard support or semantic role, invisible to keyboard and screen reader users.
- Focus not managed on modal open/close, leaving keyboard/screen reader users disoriented or trapped outside the dialog's content.

## Outputs
Accessible component/flow implementation, verified against automated checks and manual keyboard/screen-reader testing.

## Related
`testing.accessibility_testing`, `frontend.component_design`, `frontend.design_system`, `ui_ux.design_component`, `frontend.forms`

## skills/frontend/component_design.md

# Frontend Component Design

- **ID:** `frontend.component_design`
- **Purpose:** design a reusable, composable frontend component with a clear prop contract and a clean separation between presentation and logic.
- **When:** building a new UI component, or refactoring one that has accumulated multiple responsibilities or ad-hoc props.

## Procedure
1. Define the component's single responsibility and its prop contract (inputs, callbacks, children) before writing markup.
2. Separate presentational rendering from data-fetching/business logic using the container/presentational split (`frontend.container-presentational`) so the visual component can be tested and reused with any data source.
3. Enumerate every visual state (default, loading, empty, error, disabled) per `ui_ux.design_component` — don't implement only the happy path.
4. Decide composition strategy: children/slots for flexible layout vs fixed props for constrained, predictable usage.
5. Keep the component controlled or uncontrolled deliberately (who owns the state) and document which, so consumers don't guess.
6. Wire accessibility semantics (`frontend.accessibility`) and responsive behavior (`frontend.responsive_design`) into the component itself, not left to each consumer.
7. Add or update component tests (`frontend.component_testing`) covering each defined state.

## Validation
- The prop contract has no more than one "mode" flag doing double duty (a sign it should be two components).
- Presentational logic contains no direct API calls or global state access.
- Every defined visual state renders correctly in isolation (e.g., in a story or test).
- The component is reused in at least a second location without prop hacks, or its single-use nature is justified.

## Common failure modes
- God components that accept a growing list of boolean props (`isCompact`, `isModal`, `isInline`...) instead of being split into distinct components.
- Presentational components that silently depend on a specific global store or router context, blocking reuse and isolated testing.

## Outputs
Component implementation, prop/type contract, and test coverage for each defined state.

## Related
`ui_ux.design_component`, `frontend.container-presentational`, `frontend.accessibility`, `frontend.component_testing`, `frontend.design_system`

## skills/frontend/component_testing.md

# Frontend Component Testing

- **ID:** `frontend.component_testing`
- **Purpose:** verify a frontend component's behavior (rendering, interaction, state transitions) in isolation with fast, reliable tests, catching regressions before they reach integration or manual QA.
- **When:** adding a new component with non-trivial logic/states, or after a bug is found in an existing component that lacked test coverage for that case.

## Procedure
1. Test behavior from the user's perspective (what renders, what happens on interaction) rather than implementation details, keeping tests stable across refactors.
2. Cover every defined state from the component's design (`ui_ux.design_component`): default, loading, empty, error, disabled — not only the happy path.
3. Mock the network/data boundary, not the component's own internals, so the test exercises real component logic against controlled inputs.
4. Test keyboard interaction and accessible queries (by role/label, not by CSS class or test-id when avoidable) so tests also catch accessibility regressions.
5. Keep each test focused on one behavior; a test with many assertions across unrelated states makes failures hard to diagnose.
6. Add a regression test for every bug fixed in a component, tied to the specific scenario that broke.
7. Balance component tests against end-to-end coverage (`testing.e2e_testing`) — don't re-test integration-level flows at the unit level, and vice versa.

## Validation
- Tests query by accessible role/label rather than brittle implementation details (class names, internal state).
- Every state defined in the component's design (loading, empty, error, disabled) has at least one test.
- Tests fail when the component's user-facing behavior breaks, and don't fail on unrelated internal refactors.
- Every previously shipped bug in the component has a corresponding regression test.

## Common failure modes
- Snapshot tests that assert the entire rendered output, breaking on every trivial markup change and getting rubber-stamp-updated without real review.
- Tests that reach into component internals (state, instance methods) instead of observable behavior, passing even when actual user-facing behavior is broken.

## Outputs
Test suite for the component covering all defined states and interactions.

## Related
`testing.unit_testing`, `testing.e2e_testing`, `frontend.accessibility`, `frontend.component_design`, `ui_ux.design_component`

## skills/frontend/error_handling.md

# Frontend Error Handling

- **ID:** `frontend.error_handling`
- **Purpose:** surface and recover from runtime errors (render errors, failed requests, unexpected data) so the rest of the app stays usable instead of blanking or failing silently.
- **When:** any component that renders data from an external source, performs a side effect that can fail, or is deep enough in the tree that an unhandled error would blank the whole page.

## Procedure
1. Wrap feature boundaries in error boundaries so a render error in one feature doesn't blank the entire application (`error_handling.implementation`).
2. Distinguish error types explicitly: network/API errors, validation errors, and unexpected/programming errors each need different UI and recovery.
3. Design the error UI per context: inline field error, toast/notification (`frontend.notifications`) for transient failures, full-page fallback for boundary-level failures.
4. Provide a recovery path where possible (retry button, "go back") rather than a dead-end error screen.
5. Log/report unexpected errors to an observability tool with enough context (route, user action) to debug, without leaking sensitive data to the console/UI.
6. Never surface raw error objects, stack traces, or backend exception messages directly to the end user (`security.web_security_baseline`).
7. Test the error path deliberately (simulate failed requests, thrown render errors), not just the happy path.

## Validation
- A thrown error in one feature's component tree does not blank pages/features outside its error boundary.
- Every user-facing error message is actionable and free of raw stack traces or internal identifiers.
- Errors that warrant retry expose a retry action; errors that don't (e.g., 404) explain what happened instead.
- Unexpected errors are logged with enough context to reproduce, without including secrets or PII.

## Common failure modes
- No error boundaries anywhere, so one component's render-time exception white-screens the whole app.
- Generic "Something went wrong" messages used for every error type, giving the user no way to distinguish retry-worthy failures from access or not-found errors.

## Outputs
Error boundaries, typed error states per feature, and user-facing error UI with recovery actions.

## Related
`error_handling.implementation`, `frontend.notifications`, `frontend.api_integration`, `security.web_security_baseline`, `error.fail-fast-validation`

## skills/frontend/form_validation.md

# Frontend Form Validation

- **ID:** `frontend.form_validation`
- **Purpose:** validate form input on the client with rules that match the server's validation exactly, giving the user immediate, specific feedback without treating the client as the security boundary.
- **When:** any form field with format, range, required, or cross-field constraints (e.g., password confirmation, date ranges).

## Procedure
1. Define validation rules as a schema, not scattered inline conditionals, so rules are reusable across fields/forms and ideally shared with the backend's contract (`api.contract_design`).
2. Decide validation timing per field type: required/format errors on blur, cross-field errors on submit, availability checks (e.g., username taken) debounced on change.
3. Never treat client validation as the security boundary — the server must re-validate everything (`error.fail-fast-validation`); client validation is purely UX.
4. Write error messages that state what's wrong and how to fix it ("must be at least 8 characters"), not generic messages ("invalid input").
5. Handle async validation (uniqueness checks) with a pending state and cancel in-flight checks when the field changes again.
6. Support cross-field validation (e.g., end date after start date) as a documented rule set, not a one-off condition buried in the submit handler.
7. Confirm the validation schema/version matches what's used for the equivalent server-side check, if shared.

## Validation
- Every field with a server-side constraint has a matching client-side check, described in plain language.
- Async validations show a pending indicator and don't race (a stale response can't overwrite a newer one).
- Removing client-side validation (e.g., via devtools) does not allow invalid data to be persisted — the server still rejects it.
- Error messages are specific enough that a user can fix the issue without guessing.

## Common failure modes
- Duplicated, drifting validation logic between two forms that should share a schema, causing inconsistent rules for the same field across the app.
- Treating client-side validation as sufficient and skipping server-side re-validation, opening a direct-API bypass of business rules.

## Outputs
Validation schema/rules, wired field- and form-level error states, and documented timing per field.

## Related
`frontend.forms`, `error.fail-fast-validation`, `api.contract_design`, `frontend.accessibility`, `backend.input_validation`

## skills/frontend/forms.md

# Frontend Forms

- **ID:** `frontend.forms`
- **Purpose:** build a form with predictable state handling, submission flow, and error surfacing that scales beyond a couple of fields.
- **When:** building any user input form — creation/edit flows, filters, multi-step wizards, or settings screens.

## Procedure
1. Choose controlled vs uncontrolled field strategy deliberately; for forms beyond roughly 5 fields, use a form library or structured reducer instead of ad-hoc state per field.
2. Model form state as a single object (values, touched, errors, submitting) rather than independent state variables that drift out of sync.
3. Separate field-level validation from submit-time validation (`frontend.form_validation`) so errors surface at the right moment (on blur vs on submit).
4. Implement the submission lifecycle explicitly: idle -> submitting -> success/error, disabling the submit control and showing feedback during the in-flight request (`frontend.loading_states`).
5. Map server-side validation errors back to the specific field, not just a generic banner, when the API returns field-level errors.
6. For multi-step forms, persist in-progress state (memory or `frontend.browser_storage`) so a refresh doesn't lose the user's input.
7. Verify accessible labeling, error announcement, and keyboard submission (`frontend.accessibility`) work end to end.

## Validation
- Form state is centralized (one source of truth), not multiple independent state variables that can desync.
- Submit control is disabled and shows a busy state during the in-flight request; double-submit is not possible.
- Server-side field errors render next to the relevant field, not only as a generic top-level message.
- Screen readers announce validation errors when they appear.

## Common failure modes
- Independent state per field with no single source of truth, making "is the form valid" and "reset the form" both awkward and bug-prone.
- No submit-in-flight guard, allowing a slow network to let the user submit the same form twice.

## Outputs
Form component/hook, validation wiring, and submission state handling.

## Related
`frontend.form_validation`, `frontend.loading_states`, `frontend.accessibility`, `frontend.api_integration`, `error.fail-fast-validation`

## skills/frontend/loading_states.md

# Frontend Loading States

- **ID:** `frontend.loading_states`
- **Purpose:** represent in-progress asynchronous work (data fetching, submission, navigation) with UI that communicates progress and prevents duplicate actions, instead of a frozen or ambiguous screen.
- **When:** any operation that isn't instantaneous — initial data fetch, form submission, route transition, pagination/infinite scroll.

## Procedure
1. Distinguish the loading context: initial load (nothing to show yet) vs refetch/background update (stale data still visible) vs action-in-flight (button/form submission).
2. For initial loads, use skeleton screens that match the eventual layout rather than a generic spinner, to reduce perceived layout shift.
3. For background refetches, keep existing data visible and show a subtle indicator instead of replacing content with a spinner.
4. Disable and visually mark the triggering control (button, form) during an in-flight action to prevent duplicate submissions.
5. Set a minimum display time or debounce for very fast loads so the UI doesn't flash a skeleton for 50ms — but don't add artificial delay for its own sake.
6. Define a timeout/fallback for loads that take unusually long, distinct from a hard error.
7. Verify loading state clears correctly on both success and error paths — a stuck spinner on error is a common regression.

## Validation
- Every async action has a visibly distinct in-flight state, not a frozen UI with no feedback.
- The loading indicator always resolves to either success or error state — no path leaves it spinning indefinitely.
- Background refetches don't discard already-rendered data while the new request is pending.
- Buttons that trigger async actions are disabled for the duration of the request.

## Common failure modes
- Loading state cleared only in the success branch, so a failed request leaves the spinner running forever because the error path forgot to reset it.
- Full-content-replacing spinners on every refetch (e.g., pagination), causing jarring layout resets for what should be a subtle update.

## Outputs
Loading/skeleton components wired to each async operation's state.

## Related
`frontend.api_integration`, `frontend.error_handling`, `frontend.forms`, `ui_ux.design_component`, `frontend.performance`

## skills/frontend/notifications.md

# Frontend Notifications

- **ID:** `frontend.notifications`
- **Purpose:** surface transient, non-blocking feedback (toasts, banners, badges) for system events without interrupting the user's current task or stacking into unreadable noise.
- **When:** an action completes asynchronously and the user needs feedback not tied to a specific form field, or a background event (new data, connection lost) needs to be surfaced.

## Procedure
1. Choose the right pattern per severity: inline/toast for transient info and success, persistent banner for ongoing states (e.g., offline), modal only for something that truly blocks progress.
2. Queue and deduplicate notifications — the same error firing three times (e.g., from retries) should not stack three identical toasts.
3. Set appropriate auto-dismiss timing per severity: success/info can auto-dismiss quickly, errors that need user action should persist until dismissed.
4. Make notifications accessible: use `aria-live` regions so screen reader users are informed of the same events sighted users see (`frontend.accessibility`).
5. Avoid notification fatigue: don't notify for every minor background sync — reserve notifications for events the user needs to know about or act on.
6. Provide an action in the notification when relevant (undo, retry, view details) instead of a dead-end message.
7. Test the notification stack under multiple simultaneous events (e.g., several requests failing at once) to confirm it stays readable.

## Validation
- Identical repeated events produce one notification, not a stack of duplicates.
- Error notifications requiring action do not auto-dismiss before the user can read/act on them.
- Notifications are announced via `aria-live` for screen reader users, not only shown visually.
- The notification stack remains usable (not overflowing/overlapping) under multiple simultaneous events.

## Common failure modes
- Every retry attempt of a failing background request firing its own toast, burying the UI in duplicate error messages within seconds.
- Auto-dismissing error toasts on the same short timer as success toasts, so users miss actionable errors that appeared while they were looking elsewhere.

## Outputs
Notification/toast system wired to key async events, with dedup, accessibility, and severity-based timing.

## Related
`frontend.accessibility`, `frontend.error_handling`, `frontend.loading_states`, `ui_ux.design_component`, `frontend.design_system`

## skills/frontend/performance.md

# Frontend Performance

- **ID:** `frontend.performance`
- **Purpose:** keep a frontend application fast to load and responsive to interaction by fixing concrete, measured bottlenecks (bundle size, re-renders, unoptimized assets) rather than guessing at optimizations.
- **When:** a page's load time, interaction responsiveness, or Core Web Vitals are measurably degraded, or before shipping a feature that adds significant bundle weight or render cost.

## Procedure
1. Measure first: profile with browser devtools or real-user metrics (Core Web Vitals: LCP, INP, CLS) to find the actual bottleneck before changing code (`performance.profiling`).
2. Reduce bundle size via code-splitting at route/feature boundaries (`frontend.routing`) and checking for accidental large dependencies pulled into the main bundle.
3. Eliminate unnecessary re-renders: memoize expensive computations/components only where profiling shows a real cost, not preemptively everywhere.
4. Optimize asset delivery: compressed/responsive images, lazy-loaded below-the-fold media, and preloading critical above-the-fold resources.
5. Virtualize long lists/tables instead of rendering thousands of DOM nodes at once.
6. Avoid layout thrashing: batch DOM reads/writes, and reserve space for async content to avoid cumulative layout shift.
7. Re-measure after each change against the same metric to confirm the fix actually moved the number, not just "feels faster."

## Validation
- Core Web Vitals (LCP, INP, CLS) meet the project's target thresholds on representative pages/devices.
- Initial bundle size for a route does not include code only needed by other, unvisited routes.
- Profiling shows no unbounded/needless re-render loop on primary user interactions.
- Long lists (100+ items) render without noticeable input lag when scrolling.

## Common failure modes
- Blanket memoization applied everywhere "for performance" without profiling data, adding complexity without measurable benefit and sometimes making things slower.
- Rendering full-size, uncompressed images and letting the browser scale them down visually, wasting bandwidth and hurting LCP.

## Outputs
Measured before/after performance metrics and the specific optimization(s) applied.

## Related
`performance.profiling`, `frontend.routing`, `frontend.state_management`, `performance.frontend_optimization`, `frontend.responsive_design`

## skills/frontend/responsive_design.md

# Frontend Responsive Design

- **ID:** `frontend.responsive_design`
- **Purpose:** make a layout or component work correctly across viewport sizes (mobile, tablet, desktop) using a consistent breakpoint strategy, instead of one-off media queries per component.
- **When:** building any user-facing layout or component, or when a design needs to support both mobile and desktop usage.

## Procedure
1. Design mobile-first: build the narrow-viewport layout first, then add complexity/columns for wider viewports via `min-width` media queries.
2. Use the project's shared breakpoint tokens, not ad hoc pixel values per component, so breakpoints stay consistent across the app.
3. Prefer fluid/flexible layout primitives (flexbox/grid with relative units) over fixed pixel widths that break at arbitrary viewport sizes.
4. Handle touch vs pointer input differences explicitly (tap target size of at least ~44px, no hover-only interactions on primary flows).
5. Test real content, not lorem ipsum: long strings, wrapped text, and dynamic image aspect ratios often break "responsive" layouts that look fine with short placeholder text.
6. Verify the component works at in-between sizes too, not only at exact breakpoint values — resize continuously rather than toggling two presets.
7. Confirm no horizontal scroll is introduced at any supported width, especially from fixed-width children or unaccounted-for padding/margins.

## Validation
- The layout has no horizontal scroll at any width from the minimum supported viewport upward.
- Interactive elements meet minimum touch target size on mobile.
- No hover-only functionality is the sole way to access a primary action on touch devices.
- Breakpoint values match the project's shared tokens, not one-off numbers.

## Common failure modes
- Designing/testing only at two fixed widths (e.g., 375px and 1440px) and missing breakage at common in-between sizes like tablets or narrow desktop windows.
- Fixed pixel widths on containers that overflow on smaller viewports, causing horizontal scroll that's easy to miss when testing only at desktop width.

## Outputs
Responsive component/layout implementation verified across the project's supported breakpoints.

## Related
`frontend.component_design`, `frontend.accessibility`, `ui_ux.design_component`, `frontend.design_system`, `frontend.performance`

## skills/frontend/routing.md

# Frontend Routing

- **ID:** `frontend.routing`
- **Purpose:** define the application's route structure, navigation guards, and code-splitting boundaries so URLs are shareable, bookmarkable, and access-controlled.
- **When:** adding a new page/view, changing navigation flow, or introducing a section that requires authentication or role-based access.

## Procedure
1. Map each route to a URL that reflects the resource/view, not internal implementation (e.g., `/orders/:id`, not `/view?type=order&id=`).
2. Decide which state belongs in the URL (filters, pagination, selected tab) vs component state — URL state survives refresh and is shareable (`frontend.state_management`).
3. Implement route guards for authenticated/authorized routes at the routing layer, not inside individual page components (`authentication.implementation`, `security.authorization`).
4. Split code by route/feature (lazy-loaded chunks) so the initial bundle doesn't include every page (`frontend.performance`).
5. Define 404/not-found and unauthorized redirect behavior explicitly, not as an afterthought.
6. Handle route transitions' loading state (`frontend.loading_states`) so navigation doesn't show a blank screen while the next route's data loads.
7. Verify deep links work: reloading the app directly on a nested route must restore the correct view and data, not just work when navigated to from within the app.

## Validation
- Every authenticated/protected route is guarded at the router level; unguarded direct navigation to it is impossible.
- Reloading the browser on any route (not just the home route) renders the correct page.
- Shareable state (filters, selected item) round-trips through the URL correctly.
- Route-level code splitting keeps the initial JS bundle from including unrelated feature code.

## Common failure modes
- Auth checks implemented inside page components (via effect-based redirects) instead of at the router level, causing a flash of protected content before the redirect fires.
- Filter/tab state kept only in component state, so refreshing or sharing the URL loses the user's context.

## Outputs
Route configuration, guard implementation, and code-split route bundles.

## Related
`frontend.state_management`, `security.authorization`, `frontend.loading_states`, `frontend.performance`, `authentication.implementation`

## skills/frontend/security.md

# Frontend Security

- **ID:** `frontend.security`
- **Purpose:** prevent client-side vulnerabilities (XSS, insecure data handling, token exposure, unsafe third-party content) that are specific to the frontend layer, on top of — not instead of — backend security controls.
- **When:** rendering user-generated or third-party content, handling auth tokens client-side, integrating third-party scripts/iframes, or building any input path that reaches the DOM.

## Procedure
1. Never render user-controlled content via raw HTML injection (`innerHTML`, `dangerouslySetInnerHTML`, `v-html`) without sanitizing it through a vetted library first (`security.xss_prevention`).
2. Rely on the framework's default output escaping for text content; treat any bypass of that escaping as a flagged, reviewed exception, not a routine choice.
3. Handle auth tokens per `frontend.browser_storage` guidance — prefer httpOnly cookies over JS-readable storage, and never log tokens to the console or an error tracker.
4. Set a Content-Security-Policy and validate any third-party script/iframe/widget against it before embedding (`security.security_headers`).
5. Validate and sanitize any data pulled into the DOM from URL parameters, especially when used to build links, redirects, or embedded content (open-redirect and reflected-XSS vectors).
6. Ensure CSRF protections (`security.csrf_protection`) and CORS configuration (`security.cors`) are respected by how the frontend issues state-changing requests.
7. Keep frontend dependencies patched and audited (`security.dependency_security`) — client-side supply-chain compromises execute directly in the user's browser.

## Validation
- No user-controlled string reaches `innerHTML`/`dangerouslySetInnerHTML` without passing through a sanitizer.
- No auth token or secret appears in localStorage, URL query strings, or client-side logs.
- Content-Security-Policy blocks unexpected inline scripts and unapproved third-party origins.
- State-changing requests include CSRF protection and respect the API's CORS policy rather than assuming permissive access.

## Common failure modes
- Sanitizing on the way in (at form submit) but not on the way out (at render), missing that data written by one flow gets rendered unsafely by a different, later flow.
- Third-party embedded widgets/scripts granted full page access without CSP restrictions, turning a compromised third party into a full XSS vector.

## Outputs
Sanitization at every user-content render path, secure token handling, and a verified CSP/CORS/CSRF configuration.

## Related
`security.xss_prevention`, `security.csrf_protection`, `security.cors`, `frontend.browser_storage`, `security.web_security_baseline`

## skills/frontend/state_management.md

# Frontend State Management

- **ID:** `frontend.state_management`
- **Purpose:** choose and implement the right state ownership (local, shared/global, server-cache, URL) for a piece of frontend state, avoiding both prop-drilling and over-centralized global stores.
- **When:** a component needs state that outlives a single render, is shared across components, or mirrors server data.

## Procedure
1. Classify the state before picking a tool: ephemeral UI state (local), cross-component shared state (context/store), server data (cache layer), or state that should live in the URL (`frontend.routing`).
2. Default to local component state; lift state only as far up the tree as the components that actually need it.
3. For server data, use a dedicated cache layer instead of manually storing fetched data in a global store — this gets loading/error states and invalidation for free (`frontend.api_integration`, `frontend.loading_states`).
4. For genuinely global UI state (auth session, theme, feature flags), use one designated store, not several competing mechanisms in the same app.
5. Keep derived state computed, not duplicated — never store a value that can be calculated from other state/props.
6. Define update boundaries: which component/action is allowed to mutate a given piece of shared state, to keep mutations traceable.
7. Verify re-render impact: state changes shouldn't cascade re-renders through unrelated parts of the tree.

## Validation
- No fetched server data lives duplicated in both a global store and a query cache.
- No component prop-drills more than 2-3 levels to pass state down.
- Derived values are computed at render/selector time, not stored redundantly.
- State updates are traceable to a single owning action/reducer, not scattered mutation sites.

## Common failure modes
- Putting all state (including server responses) into one global store "for consistency," losing cache invalidation and request deduplication a dedicated data layer provides for free.
- Storing derived/computed values in state, causing them to go stale when source values change and nothing re-derives them.

## Outputs
State ownership decision per feature, store/context/cache implementation, and documented update boundaries.

## Related
`frontend.api_integration`, `frontend.routing`, `frontend.loading_states`, `frontend.ui_architecture`, `frontend.design_patterns`

## skills/ui_ux/design_system.md

# UX Design System Management

- **ID:** `ux.design_system`
- **Purpose:** build and maintain a shared, documented set of design rules, patterns, and components so a product's experience stays coherent across teams and screens instead of drifting into one-off, inconsistent designs.
- **When:** more than one designer or team is building UI for the same product, or inconsistency (duplicate patterns, conflicting styles) is already visible across the product.

## Procedure
1. Start from what already exists: audit current screens for repeated patterns and inconsistencies before inventing new components wholesale.
2. Define the foundational layer first — design tokens (`ui.design_tokens`) for color, spacing, typography — so every component built on top inherits consistency automatically.
3. Document each component's purpose, states, variants, and usage rules (when to use it vs. a similar alternative), not just its visual appearance (`ui_ux.component_catalog`).
4. Keep the design system and the corresponding code implementation in sync deliberately — a design system that only exists in a design tool and drifts from the shipped code is not trustworthy.
5. Establish a governance process for proposing new patterns/components and deprecating old ones, so the system evolves deliberately instead of by accretion.
6. Make the system easy to adopt: accessible documentation, ready-to-use assets/code, and examples, or teams will keep building one-offs out of convenience.
7. Version the design system and communicate breaking changes to consuming teams the same way an API would (`api.versioning`).

## Validation
- Every commonly repeated UI pattern in the product has one documented, canonical version in the system.
- The design system's documented components match what actually ships in code, not an idealized or outdated version.
- A new designer/developer can find and correctly apply the right component without asking, using the documentation alone.
- Deprecated patterns are marked and have a migration path, not silently left to coexist indefinitely with their replacement.

## Common failure modes
- Building a beautiful design-tool library that the engineering team never adopts because there's no corresponding code implementation.
- Letting the system grow by accretion (every team adds "just one more variant") without governance, until it has ten inconsistent ways to do the same thing.
- Documenting visual appearance but not usage rules, so teams pick the wrong component for the context even while "using the system."
- Treating the system as a one-time deliverable instead of an ongoing, versioned, maintained product.

## Outputs
A documented, governed design system (tokens, components, usage rules) kept in sync with its code implementation.

## Related
`ui.design_tokens`, `ui.theming`, `ui.component_design`, `ui_ux.design_component`, `frontend.design_system`

## skills/ui_ux/accessibility.md

# UX Accessibility

- **ID:** `ux.accessibility`
- **Purpose:** design a product experience that people using assistive technology, or with visual/motor/cognitive limitations, can perceive, operate, and understand — as a baseline requirement, not an add-on pass.
- **When:** designing any user-facing flow, and mandatory before shipping any new interactive feature or public-facing product.

## Procedure
1. Design against a concrete standard (WCAG 2.1/2.2 AA at minimum) rather than a vague notion of "accessible enough."
2. Ensure every piece of information conveyed by color alone also has a non-color indicator (icon, text, pattern) for users who can't perceive color differences.
3. Verify text and meaningful UI contrast ratios meet the standard (4.5:1 for normal text, 3:1 for large text/UI components) at design time, not after implementation.
4. Design a logical, complete keyboard navigation path (tab order, visible focus state, no keyboard traps) for every interactive flow.
5. Write meaningful labels, alt text, and heading structure for screen readers — a label that only makes sense visually (e.g., an icon-only button with no accessible name) is not sufficient.
6. Design forms with explicit, programmatically-associated labels and clear, specific error messages tied to the offending field, not just a generic banner.
7. Validate with actual assistive technology (screen reader, keyboard-only pass) before shipping, in addition to automated contrast/markup checks.

## Validation
- The design meets a named standard (e.g., WCAG 2.1 AA), checked explicitly, not assumed.
- No information is conveyed by color alone anywhere in the design.
- Every interactive element is reachable and operable via keyboard alone, with a visible focus indicator.
- A screen reader pass through the primary flow produces coherent, complete announcements (labels, state, errors).

## Common failure modes
- Relying on color alone to indicate state (red text for errors) with no icon or text label, invisible to colorblind users.
- Shipping icon-only buttons or images with no accessible name, so screen reader users hear "button" with no purpose.
- A visually logical layout that has a scrambled or trapped keyboard tab order because DOM order wasn't considered.
- Treating an automated contrast/lint scan as sufficient validation, skipping an actual keyboard-only or screen-reader pass that catches what automation can't.

## Outputs
An accessibility-reviewed design meeting a named standard, validated with keyboard and assistive-technology passes.

## Related
`ux.usability`, `ux.usability_testing`, `ui.component_design`, `ui_ux.design_component`

## skills/ui_ux/component_catalog.md

# UI/UX Reusable Component Catalog

Reusable UI components available to project preparation and UI/UX roles.

## Common components
- Skeleton loading states
- Context menus
- Modern selectors and multi-selects
- Modern filters
- Search boxes with debounce and clear state
- Dialogs and confirmation flows
- Toasts and inline feedback
- Empty states
- Error states and retry actions
- Tables, cards and responsive grids
- Pagination
- Tabs and accordions
- Accessible forms and validation

## Rule
Component selection must follow the project's architecture, accessibility, responsive requirements and design language rather than adding components without a use case.

## skills/ui_ux/component_design.md

# UI Component Design (System-Level)

- **ID:** `ui.component_design`
- **Purpose:** establish the reusable methodology, naming, variant, and composition rules that every component in the product follows — so components form a coherent, predictable system rather than a pile of unrelated one-offs.
- **When:** defining or evolving a product's component-level design conventions (how variants/props/states are structured across all components), as opposed to designing one specific component instance.

## Procedure
1. Define a consistent variant/prop model across components (e.g., every component that has emphasis levels uses the same `primary/secondary/tertiary` naming), not a bespoke naming scheme per component.
2. Define composition rules: which components are meant to nest inside others, and which combinations are unsupported, so usage stays predictable.
3. Define the canonical state set every interactive component must support (default, hover/focus, active, disabled, loading, error) as a system-wide baseline, not decided freshly per component.
4. Base every component's visual properties on design tokens (`ui.design_tokens`) rather than hardcoded values, so theming and consistency are structural, not per-component discipline.
5. Decide and document the boundary between "use an existing component" and "this genuinely needs a new one" to prevent both needless proliferation and forced misuse of the wrong component.
6. Version component APIs (props/variants) deliberately when changing them, since components are consumed across many screens simultaneously (`api.backward_compatibility` mindset applied to UI).
7. Feed every concrete component built under this methodology into the catalog (`ui_ux.design_component`, `skills/ui_ux/component_catalog.md`) so the system-level rules and the instance-level catalog stay linked.

## Validation
- Variant, prop, and state naming is consistent across components — the same concept is never named differently in different components.
- Every component's styling traces to design tokens, not one-off hardcoded values.
- Composition rules (what nests in what) are documented, not discovered by trial and error.
- A clear, applied rule exists for when to reuse/extend vs. create a new component.

## Common failure modes
- Letting each component invent its own variant naming (`type`, `kind`, `style`, `variant` all used interchangeably across the library), confusing consumers.
- Hardcoding colors/spacing per component instead of referencing tokens, so a rebrand or theme change requires touching every component individually.
- No documented composition rules, so components get nested in unsupported, visually broken ways.
- Conflating this system-level methodology with designing a single component instance, producing system rules that are really just one component's quirks generalized badly.

## Outputs
A documented component methodology (variant model, state baseline, composition rules, reuse-vs-new criteria) governing every component in the system.

## Related
`ui_ux.design_component`, `ui.design_tokens`, `ux.design_system`, `api.backward_compatibility`

## skills/ui_ux/design_tokens.md

# UI Design Tokens

- **ID:** `ui.design_tokens`
- **Purpose:** define atomic, named design values (color, spacing, typography, radius, shadow) as the single source of truth consumed by both design tools and code, so visual consistency is structural rather than a matter of discipline.
- **When:** establishing a new design system's foundation, or when the same visual value (a specific blue, an 8px gap) is being independently redefined in multiple places across design files or code.

## Procedure
1. Define tokens in tiers: primitive tokens (raw values like `blue-500`, `space-4`) and semantic tokens that reference them by role (`color.action.primary` → `blue-500`) — components should consume semantic tokens, not primitives directly.
2. Cover every dimension that repeats across the UI: color, spacing scale, typography scale, border radius, shadow/elevation, and motion duration/easing if applicable.
3. Store tokens in a format that can be transformed into every consuming platform (CSS variables, iOS/Android values, design-tool variables) from one source, rather than hand-syncing values across platforms.
4. Name tokens by role/intent (`color.text.danger`), not by literal appearance (`color.red`) — literal names break the moment a semantic color's actual hue changes.
5. Keep the primitive scale intentionally constrained (a fixed spacing/type scale) rather than allowing arbitrary new values to be added per use case.
6. Version token changes and treat a changed or removed token the same as a breaking API change (`api.backward_compatibility`) — many components depend on it simultaneously.
7. Sync token values between the design tool and the codebase automatically (token pipeline/export) rather than manually copying values, which drifts within a few releases.

## Validation
- Every recurring visual value in the product traces to a named token, not a locally hardcoded value.
- Token names describe role/intent, not literal appearance.
- The design tool and the shipped code consume the same token values, verifiably in sync (via an automated pipeline, not manual copying).
- A change to a widely-used token's value is treated with the same care as a breaking contract change, not pushed silently.

## Common failure modes
- Naming a token after its literal color (`color.blue`) and then having to rename every usage when the brand's blue changes.
- Letting designers and engineers maintain separate copies of "the same" values by hand, which drift apart within a few sprints.
- Allowing arbitrary one-off values to bypass the token scale ("just this once, 13px"), eroding the constrained scale's value over time.
- Changing a widely-referenced token's value without checking downstream impact, visually breaking many components at once.

## Outputs
A versioned token set (primitive and semantic layers) exported to every consuming platform from a single source.

## Related
`ui.theming`, `ui.component_design`, `ux.design_system`, `api.backward_compatibility`

## skills/ui_ux/responsive_design.md

# UX Responsive Design

- **ID:** `ux.responsive_design`
- **Purpose:** design a layout and interaction model that adapts correctly across device sizes and input types, instead of a fixed desktop design that degrades on other viewports.
- **When:** designing any screen or flow that will be viewed on more than one device class (mobile, tablet, desktop), which in practice means nearly every product surface.

## Procedure
1. Design mobile-first: start from the narrowest realistic viewport and add layout complexity as space allows, rather than designing desktop-first and cramming it down.
2. Define breakpoints based on where the content itself breaks (where text wraps awkwardly, where a grid gets too cramped), not arbitrary device widths.
3. Decide per-component whether it reflows (stacks), truncates (with a way to see the rest), or is replaced by an alternate pattern (e.g., a table becomes cards) at narrow widths — don't just shrink everything proportionally.
4. Design touch targets at a minimum comfortable size (~44x44px) and adequate spacing on touch viewports, distinct from the tighter targets acceptable with a mouse.
5. Account for both portrait and landscape orientation, and for viewport height (not just width) when content-heavy screens are involved.
6. Verify the design against real content extremes (very long strings, many items, empty state) at every breakpoint, not just the sample content used in mockups.
7. Validate on real devices or accurate emulation, not just by resizing a desktop browser window, since touch behavior and rendering differ.

## Validation
- The design has a defined behavior (stack/truncate/replace) for every component at each breakpoint, not just proportional shrinking.
- No horizontal scroll or clipped content appears at any supported viewport width.
- Touch targets meet the minimum size/spacing on touch viewports.
- The design was checked against realistic content extremes at each breakpoint, not only sample placeholder content.

## Common failure modes
- Designing desktop-first and treating mobile as an afterthought resize pass, producing cramped or broken layouts on small screens.
- Shrinking touch targets to match tight mouse-oriented desktop spacing, making controls hard to tap accurately.
- Testing only with short placeholder text/data, missing overflow bugs that appear with real long names or large lists.
- Picking breakpoints from device marketing widths instead of where the actual content and layout break.

## Outputs
A responsive layout specification (breakpoints and per-component behavior) validated across viewport sizes and real content.

## Related
`ux.usability`, `ui.component_design`, `frontend.responsive_design`, `ux.prototyping`

## skills/ui_ux/theming.md

# UI Theming

- **ID:** `ui.theming`
- **Purpose:** support multiple visual presentations of the same UI (light/dark mode, brand variants, white-labeling) through systematic overrides, without duplicating components or hardcoding a single visual outcome.
- **When:** a product needs to support more than one visual mode (light/dark, high-contrast, multi-brand/white-label) or is being retrofitted to support one after shipping with hardcoded styles.

## Procedure
1. Build theming on top of design tokens (`ui.design_tokens`) — components must reference token names, never hardcoded values, or theming has nothing to hook into.
2. Define each theme as a complete mapping of semantic token names to concrete values (e.g., `color.background.primary` → different hex per theme), not a partial override list that leaves gaps.
3. Verify accessibility contrast requirements independently for every theme, not just the default — a dark theme's contrast can fail even when the light theme passes.
4. Decide theme switching behavior explicitly: respect system preference by default, allow manual override, and persist the user's choice.
5. Test every component in every supported theme, specifically looking for hardcoded colors that don't respond to the theme switch (a common regression source).
6. For multi-brand/white-label theming, keep brand-specific values entirely in the token layer so the same component code serves every brand without conditional logic.
7. Document how to add a new theme (which tokens must be defined) so it's a config change, not a code change scattered across components.

## Validation
- Every themeable value traces to a token; no component has a hardcoded color/style that ignores the active theme.
- Each supported theme independently meets accessibility contrast requirements.
- Switching themes at runtime updates the entire UI consistently, with no leftover elements stuck in the previous theme.
- Adding a new theme requires only defining a new token mapping, not touching component code.

## Common failure modes
- A component with one hardcoded color that "looks fine" in light mode but becomes invisible or illegible in dark mode.
- Defining a dark theme by simply inverting lightness values without re-checking contrast, producing a theme that technically exists but fails accessibility.
- Partial token overrides per theme, leaving some UI elements silently falling back to default/light values in dark mode.
- Hardcoding brand-specific logic (`if (brand === 'x') color = ...`) into components instead of pushing brand differences into the token layer.

## Outputs
A complete token mapping per supported theme, verified for contrast, with theme-switching behavior implemented and documented.

## Related
`ui.design_tokens`, `ui.visual_design`, `ux.accessibility`, `ux.design_system`

## skills/ui_ux/visual_hierarchy.md

# UX Visual Hierarchy

- **ID:** `ux.visual_hierarchy`
- **Purpose:** arrange a screen's visual elements (size, weight, color, spacing, position) so a user's attention lands on the most important thing first, in the intended order, without conscious effort.
- **When:** designing or reviewing any screen with more than one competing element, especially ones with a primary action or a clear reading priority.

## Procedure
1. Identify the single most important element/action on the screen before laying anything out — hierarchy design requires knowing what should win.
2. Use size and weight to signal importance (larger/bolder = more important) consistently, so the pattern stays learnable across the product.
3. Use spacing and grouping (proximity, whitespace) to show which elements relate to each other, rather than relying on borders/dividers for every grouping.
4. Establish a deliberate reading order (typically top-to-bottom, left-to-right for LTR languages) and place primary actions where that order naturally lands.
5. Limit the number of elements competing for primary visual weight — if everything is emphasized, nothing is; use one primary action, not several equally bold ones.
6. Use color deliberately for emphasis (reserve the primary/accent color for the primary action) rather than applying it decoratively across many elements.
7. Test the hierarchy with a squint test or five-second test: what does a user notice first, and does it match the intended priority.

## Validation
- There is exactly one clear primary action per screen/section, visually distinguishable from secondary and tertiary actions.
- Grouping and spacing make related elements visually obvious without relying solely on borders.
- A five-second glance test on the screen identifies the intended primary element first.
- The accent/primary color is reserved for primary actions, not spread across decorative or secondary elements.

## Common failure modes
- Making multiple elements equally bold/large ("everything is important"), leaving the user with no clear starting point.
- Using the same visual weight for primary and secondary actions, causing users to click the wrong one by default.
- Relying only on borders/dividers to separate sections instead of spacing, producing a visually noisy, boxed-in layout.
- Applying the brand accent color decoratively everywhere, diluting its usefulness as a signal for "this is the action to take."

## Outputs
A screen layout with a deliberate, testable visual priority order for its elements.

## Related
`ui.visual_design`, `ux.usability`, `ui.design_tokens`, `ux.wireframing`

## skills/apis/authentication.md

# API Authentication

- **ID:** `api.authentication`
- **Purpose:** verify the identity of every caller at the API boundary, reliably and consistently, before any request reaches business logic.
- **When:** exposing any endpoint that is not intentionally public, or reviewing an existing API for endpoints that skip identity verification.

## Procedure
1. Choose one authentication mechanism appropriate to the consumer (short-lived bearer tokens/JWT for services and SPAs, session cookies with `HttpOnly`/`Secure`/`SameSite` for browser apps, signed API keys for server-to-server) and apply it consistently per client type.
2. Enforce authentication centrally (middleware/gateway), not inside individual handlers, so no new endpoint can accidentally ship unauthenticated.
3. Validate tokens fully on every request: signature, expiry, issuer, and audience — never trust a client-supplied identity claim without verification.
4. Use short-lived access tokens with a separate refresh mechanism rather than long-lived tokens that can't be revoked quickly.
5. Return `401 Unauthorized` (not `403` or `404`) for missing/invalid credentials, and never reveal whether a resource exists to an unauthenticated caller.
6. Log authentication failures (without logging the credential itself) for anomaly detection.
7. Explicitly mark and document any intentionally public endpoint so its lack of auth is a decision, not an oversight.

## Validation
- Every non-public endpoint rejects requests with missing, expired, or invalid credentials before reaching handler logic.
- Authentication is enforced in one central place, verifiable by inspecting the routing/middleware layer, not endpoint-by-endpoint.
- No raw credential (password, token, API key) appears in logs or error responses.
- Public endpoints are an explicit, documented allowlist rather than "everything not yet protected."

## Common failure modes
- Adding a new endpoint that forgets to attach the auth middleware, silently shipping it unauthenticated.
- Trusting a client-supplied user ID or role header without verifying it against the authenticated token's claims.
- Using long-lived tokens with no revocation path, so a leaked token stays valid indefinitely.
- Returning `404` vs `403` inconsistently, which lets an attacker enumerate protected resources by response code.

## Outputs
A centrally enforced authentication layer, token/session issuance and validation logic, and a documented list of public vs. protected endpoints.

## Related
`api.authorization`, `security.authentication`, `security.jwt_security`, `api.contract_design`

## skills/apis/pagination.md

# API Pagination

- **ID:** `api.pagination`
- **Purpose:** let a collection endpoint return results in bounded, navigable pages instead of risking an unbounded response that degrades performance or fails outright.
- **When:** designing or reviewing any endpoint that returns a list/collection whose size is not guaranteed to stay small.

## Procedure
1. Choose cursor-based pagination for large, frequently-mutated, or real-time-ish collections; offset/limit is acceptable only for small, mostly-static collections where "jump to page N" matters more than consistency.
2. Define a default and a hard maximum page size; never allow an unbounded `limit` value from the client.
3. Return pagination metadata in a consistent envelope (`nextCursor`/`hasMore`, or `total`/`page`/`pageSize`) reused across every paginated endpoint (`api.response_model`).
4. Guarantee stable ordering (an explicit `ORDER BY` on a unique or tie-broken key) so pages don't skip or repeat items as data changes between requests.
5. For cursor pagination, encode the cursor opaquely (don't expose raw offsets or internal IDs the client could tamper with) and treat it as short-lived.
6. Document the pagination contract explicitly: default size, max size, whether `total` is exact or approximate, and cursor expiry if any.
7. Test the boundary cases: empty collection, single page, exact page-size boundary, and concurrent inserts/deletes between page fetches.

## Validation
- No collection endpoint can return more than the documented maximum page size regardless of client input.
- Ordering is deterministic across requests for the same query, even under concurrent writes.
- The pagination envelope shape is identical across all paginated endpoints in the API.
- Boundary cases (empty result, last page, exact page-size multiple) are covered by tests.

## Common failure modes
- Sorting only by a non-unique field (e.g., `createdAt`), causing items with identical timestamps to be skipped or duplicated across pages.
- Allowing an unbounded or very large client-supplied `limit`, letting one request return the entire table.
- Computing an exact `total` count on every page request against a huge table, tanking performance for a rarely-needed number.
- Exposing raw database offsets as the cursor, letting clients skip/replay pages in ways that break under concurrent writes.

## Outputs
A documented, consistently applied pagination contract (request params and response envelope) for every collection endpoint.

## Related
`api.response_model`, `api.contract_design`, `api.rate_limiting`, `database.query_optimization`

## skills/apis/contract_design.md

# API Contract Design

## Objective
Create stable, explicit and versioned HTTP/JSON contracts that can be consumed by any agent or client.

## When to use
- creating or changing an API endpoint;
- changing request/response fields;
- introducing pagination, filtering or idempotency.

## Procedure
1. Identify the resource and SSOT.
2. Define request and response schemas.
3. Define authentication and authorization requirements.
4. Define validation, error semantics and status codes.
5. Define compatibility and versioning impact.
6. Define idempotency requirements for mutating operations.
7. Add deterministic tests for success and failure cases.
8. Update API contract documentation.

## Validation
- schemas validate;
- malformed input is rejected;
- unauthorized access is rejected;
- response shape is stable;
- breaking changes are explicitly versioned.

## Security
Apply least privilege, input validation, output constraints, rate limiting and secret-free logs.

## skills/apis/documentation.md

# API Documentation

- **ID:** `api.documentation`
- **Purpose:** produce API documentation that a new consumer can use to make a correct first call without reading the implementation source.
- **When:** publishing a new API/endpoint, changing behavior that consumers depend on, or discovering that support questions keep repeating what should be documented.

## Procedure
1. Document each operation's purpose, auth requirement, request shape, response shape, and every realistic status code it can return — success and error alike.
2. Generate the reference documentation from the OpenAPI spec (`api.openapi`) rather than hand-writing a parallel description that can drift.
3. Add at least one worked example per operation: a realistic request and its exact response, including error examples.
4. Document non-obvious behavior explicitly: rate limits, idempotency guarantees, pagination semantics, eventual consistency, side effects.
5. Maintain a changelog that records every consumer-visible change, dated and linked to the version it shipped in.
6. Keep an explicit error catalog (error codes, meanings, remediation) separate from the happy-path docs.
7. Review docs for accuracy whenever the underlying contract changes — treat a stale doc as a bug, not a low-priority cleanup.

## Validation
- A developer unfamiliar with the codebase can make a correct authenticated call using only the docs.
- Every documented operation includes at least one error example, not only the success case.
- The changelog has an entry for every breaking or consumer-visible change, in order.
- No documented example returns a response that the current implementation cannot actually produce.

## Common failure modes
- Documenting only the happy path, leaving consumers to discover error shapes by trial and error in production.
- Letting docs and implementation diverge silently because docs are hand-maintained separately from the spec.
- Omitting operational details (rate limits, retry policy, pagination cursor lifetime) that consumers need but aren't obvious from the schema alone.
- Writing a changelog entry that says "various fixes" instead of naming the specific consumer-visible change.

## Outputs
Published, versioned API reference documentation with worked examples, an error catalog, and a changelog.

## Related
`api.openapi`, `api.contract_design`, `api.versioning`, `documentation.technical_writing`

## skills/testing/accessibility_testing.md

# Accessibility Testing

- **ID:** `testing.accessibility_testing`
- **Purpose:** Verify that a user interface is usable by people relying on assistive technology (screen readers, keyboard-only navigation, magnification) and meets the project's accessibility standard.
- **When:** Apply to any new or changed user-facing UI, especially forms, navigation, modals and custom interactive components, before release.

## Procedure
1. Identify the applicable standard (e.g., WCAG 2.1 AA) and the specific success criteria relevant to the changed UI.
2. Run automated checks (axe, Lighthouse or equivalent) to catch mechanical violations: missing alt text, contrast ratio, missing form labels, invalid ARIA.
3. Navigate the full flow using only the keyboard: confirm every interactive element is reachable, has a visible focus indicator, and follows a logical tab order.
4. Test with a screen reader (NVDA, VoiceOver or equivalent) to confirm announced labels, roles and state changes actually make sense, not just that ARIA attributes are present.
5. Check color contrast and that no information is conveyed by color alone (error states, required fields, status indicators).
6. Verify dynamic content (modals, toasts, live updates) announces changes to assistive technology and manages focus correctly on open/close.
7. Record findings against the specific success criterion violated, with severity, since automated tools alone typically catch only a fraction of real issues.

## Validation
- Automated scan passes with zero critical violations.
- Every interactive element is operable by keyboard alone, with visible focus.
- Screen reader announces meaningful labels and state changes, verified manually, not just ARIA presence.
- No information is conveyed by color alone.

## Common failure modes
- Treating a clean automated scan as sufficient — automated tools catch only a fraction of real accessibility issues, missing logical/semantic problems.
- Adding ARIA attributes without verifying with an actual screen reader that they produce a sensible announcement.
- Custom components (dropdowns, modals, date pickers) reimplementing native behavior without keyboard support or focus management.

## Outputs
An accessibility findings report mapped to specific success criteria, plus a passing automated scan.

## Related
`testing.test_strategy`, `testing.quality_gates`, `review.test_review`, `review.documentation_review`

## skills/testing/integration_testing.md

# Integration Testing

- **ID:** `testing.integration_testing`
- **Purpose:** Verify that a component behaves correctly against a real (or realistically simulated) boundary — database, filesystem, queue, cache, or another internal service.
- **When:** Apply whenever code crosses a process, persistence, or network boundary and unit tests with mocks would hide real integration bugs (wrong SQL, serialization mismatches, transaction behavior).

## Procedure
1. Identify the real boundary under test (DB schema, message broker, filesystem, internal API) and decide whether to use a real instance, container, or a high-fidelity emulator — not a hand-written mock.
2. Provision an isolated environment per test run (ephemeral DB/container, dedicated schema, ephemeral queue) so tests don't share state with other runs.
3. Seed only the test data required for the scenario, using fixtures or factories rather than production data copies.
4. Exercise the real code path end-to-end through the boundary (actual SQL, actual serialization, actual transaction commit/rollback).
5. Assert on the boundary's observable state after the operation (row exists, message published, file written) in addition to the return value.
6. Tear down or roll back state after each test so runs are repeatable and order-independent.
7. Keep the suite separate from unit tests so it can run less frequently (e.g., pre-merge) without slowing the fast feedback loop.

## Validation
- Tests run against a real or high-fidelity instance of the boundary, not a hand-rolled mock of it.
- Each test run starts from a known, isolated state and cleans up after itself.
- Assertions check actual boundary state, not just that a mock was called.
- The suite is reliably green on repeated runs — no order dependence or leftover state.

## Common failure modes
- Mocking the boundary so completely that the test verifies the mock's behavior, not the real integration.
- Sharing one persistent test database across parallel test runs, causing intermittent collisions.
- Forgetting teardown, so state from a failed run poisons the next run.

## Outputs
An integration test suite exercising real boundaries with isolated, reproducible setup/teardown.

## Related
`testing.test-pyramid`, `testing.fixtures`, `testing.api_testing`, `review.database_review`

## skills/testing/mocking.md

# Mocking and Test Doubles

- **ID:** `testing.mocking`
- **Purpose:** Replace a real dependency with a controlled substitute so a unit can be tested in isolation, without over-specifying implementation details that make tests brittle.
- **When:** Apply when a unit under test depends on something slow, non-deterministic, external, or hard to trigger into a specific state (network calls, clocks, random values, third-party services).

## Procedure
1. Identify the dependency to replace and choose the right double: a stub (returns canned data), a fake (simplified real implementation), a spy (records calls), or a mock (asserts expected interactions).
2. Prefer the least restrictive double that proves the behavior — use a stub for data-only needs and reserve interaction-asserting mocks for cases where the interaction itself is the behavior under test.
3. Define the double against the dependency's real interface/contract, not a convenient subset, so it can't drift silently from the real thing.
4. Configure only the specific responses the test scenario needs (success, specific error, timeout) rather than a blanket "always succeeds" double.
5. Assert on the unit's observable behavior first; assert on mock interactions only when the interaction itself (e.g., "must call payment.capture exactly once") is the actual requirement.
6. Avoid mocking types you don't own (framework internals, language built-ins) — wrap them behind your own interface and mock that instead.
7. Periodically verify the double still matches the real dependency's contract, especially after the real dependency's API changes.

## Validation
- The double implements the same interface/contract as the real dependency, not an ad hoc convenient shape.
- Tests assert on behavior/output first; interaction assertions are reserved for cases where the call itself is the requirement.
- No test mocks a type it doesn't own directly.
- Mocked contracts are checked periodically against the real dependency to catch drift.

## Common failure modes
- Over-using mock interaction assertions (verifying call counts/order) so refactors that preserve behavior still break tests.
- Mocking so much of the system that the test only proves the mocks were wired correctly, not that the real code works.
- Letting a mock's shape drift from the real dependency's actual API, so tests pass while the real integration is broken — the exact gap contract testing exists to catch.

## Outputs
Test doubles scoped to the minimum needed to isolate the unit, matching the real dependency's contract.

## Related
`testing.unit_testing`, `testing.fixtures`, `testing.contract_testing`, `testing.test_data`

## skills/testing/test_automation.md

# Test Automation

- **ID:** `testing.test_automation`
- **Purpose:** Wire the test suite into CI/CD so it runs automatically on every relevant change and reliably blocks merges or deploys on failure.
- **When:** Apply once a test suite exists and needs to run consistently without manual triggering — typically as soon as the first tests are written for a project or pipeline.

## Procedure
1. Identify the trigger points that need automated runs: pull request, pre-merge, pre-deploy, scheduled (nightly) — not all suites belong at every trigger.
2. Split the suite by speed/cost so fast suites (unit) run on every push and slower suites (integration, e2e, load) run at coarser triggers.
3. Configure the CI pipeline to fail the build/block the merge on any test failure — a red pipeline that still allows merge is not a real gate.
4. Make test runs reproducible in CI: pinned dependency versions, containerized environment, seeded/ephemeral test data, no reliance on a developer's local state.
5. Surface failures with enough detail (logs, stack trace, failing assertion) directly in the CI output so a developer doesn't need to reproduce locally to diagnose.
6. Track flaky tests (pass/fail inconsistently on unchanged code) and fix or quarantine them promptly — an ignored flaky test erodes trust in the whole gate.
7. Monitor pipeline duration and split/parallelize suites as they grow, to keep feedback fast enough that developers don't bypass the gate.

## Validation
- CI actually blocks merge/deploy on failure — verified, not just configured optimistically.
- Test runs are reproducible: same code produces the same result regardless of which machine runs it.
- Flaky tests are tracked and addressed, not silently ignored or re-run until green.
- Feedback time stays fast enough that the gate doesn't get bypassed under deadline pressure.

## Common failure modes
- A CI job that reports failure but a merge/deploy path that doesn't actually check its status, silently making the gate advisory.
- Flaky tests accumulating until the team habitually re-runs failed pipelines without investigating, hiding real intermittent bugs.
- Environment drift between CI and local/production, so tests pass in CI but fail (or vice versa) elsewhere.

## Outputs
A CI-wired test suite with an enforced pass/fail gate on the intended triggers.

## Related
`testing.quality_gates`, `testing.smoke_testing`, `testing.test-pyramid`, `review.regression_review`

## skills/testing/unit_testing.md

# Unit Testing

- **ID:** `testing.unit_testing`
- **Purpose:** Verify a single unit of deterministic logic in isolation, fast and without external dependencies, so failures point directly at the broken code.
- **When:** Apply to any function, method or class with a decidable input/output contract, especially business rules, calculations and branching logic.

## Procedure
1. Identify the unit's public contract (inputs, outputs, side effects, error conditions) separate from its implementation details.
2. Isolate external dependencies (I/O, network, clock, randomness) with test doubles or dependency injection so the unit runs in-process.
3. Write one test per observable behavior: happy path, each boundary condition, each error/exception path.
4. Assert on outputs and observable side effects only, not internal implementation state.
5. Keep each test independent — no shared mutable state or execution-order dependency between tests.
6. Run the suite and confirm it executes fast enough to run on every save/commit (seconds, not minutes).
7. Add a unit test for every reported defect at the lowest level that reproduces it.

## Validation
- Each test fails for exactly one reason and its name states that reason.
- No test depends on network, filesystem, real clock or another test's execution order.
- Boundary and error conditions are covered, not just the happy path.
- The suite runs in seconds and can be executed repeatedly without side effects.

## Common failure modes
- Testing implementation details (private methods, internal call order) so refactors break tests without a real regression.
- Leaking a shared mutable fixture between tests, causing order-dependent flakiness.
- Skipping error-path tests, so exception handling is unverified until it fails in production.

## Outputs
A fast, isolated unit test suite covering happy paths, boundaries and error paths for the unit's contract.

## Related
`testing.mocking`, `testing.fixtures`, `testing.test-pyramid`, `testing.test_data`, `testing.coverage_analysis`

## skills/security/jwt_security.md

# JWT Security

- **ID:** `security.jwt_security`
- **Purpose:** Issue and verify JSON Web Tokens so algorithm confusion, signature stripping, or stale-key replay cannot let an attacker forge a valid token for an arbitrary identity.
- **When:** Any system issues or consumes JWTs for authentication, authorization, or inter-service trust — stateless session tokens, API access tokens, service-to-service tokens.
- **Security level:** `critical`

## Procedure
1. Pin the expected signing algorithm explicitly in the verifier (e.g. `RS256` only) rather than trusting the `alg` header in the token — libraries that read `alg` from the token are vulnerable to algorithm confusion (attacker sends `alg: HS256` and signs with the server's public RSA key as an HMAC secret) or `alg: none` (CWE-347).
2. Verify signature before reading any claim for business logic; never decode-and-trust without calling the library's verify function.
3. Always validate `exp` (and `nbf`/`iat` where relevant); keep access-token lifetimes short (minutes) and use a separate, revocable refresh token for long-lived sessions.
4. Treat JWTs as bearer tokens with no built-in revocation — a valid signature is accepted until `exp` — so pair short-lived tokens with a revocation mechanism (deny-list, key rotation, or token versioning tied to server-side user state) for logout and compromise response.
5. Rotate signing keys on a schedule and support multiple valid keys via a `kid` header lookup against a JWKS, so rotation doesn't invalidate all outstanding tokens instantly.
6. Never place sensitive secrets in the payload — JWT payloads are base64url-encoded, not encrypted, and are trivially readable by anyone holding the token.
7. Validate `aud` (audience) so a token issued for service A cannot be replayed against service B.

## Validation
- Verifier code hardcodes/pins accepted algorithm(s) and rejects `alg: none` and unexpected algorithms outright.
- Expired and not-yet-valid tokens are rejected in a direct test.
- A revocation path exists and is exercised on logout/password change.

## Common failure modes
- Library auto-trusting the `alg` header, enabling algorithm confusion attacks that forge a valid signature using a known public key.
- Long-lived access tokens with no revocation mechanism, so a leaked token stays valid for its full lifetime regardless of logout or credential rotation.
- Sensitive PII or authorization secrets embedded in the payload, readable by anyone who intercepts the token via browser extensions, logs, or referrer headers.

## Outputs
JWT issuance/verification with pinned algorithm, short-lived access tokens, JWKS-based key rotation, and a revocation strategy.

## Related
`security.oidc`, `security.authentication`, `security.session_security`, `security.authorization`

## skills/security/secrets_management.md

# Secrets Management

- **ID:** `security.secrets_management`
- **Purpose:** Eliminate hardcoded and long-lived credentials by centralizing secrets in a vault with dynamic issuance, rotation, and audited access.
- **When:** Whenever code, configuration, CI pipelines, or infrastructure need API keys, database credentials, service tokens, or signing keys.
- **Security level:** `critical`

## Procedure
1. Classify every credential the system uses (DB passwords, API keys, OAuth client secrets, webhook signing secrets, encryption keys) and its blast radius if leaked.
2. Move secrets out of source control, committed `.env` files, and container images into a dedicated secrets manager (HashiCorp Vault, AWS/GCP/Azure secret managers) — env vars are only the last-mile injection mechanism, never the source of truth.
3. Prefer dynamic, short-lived credentials over static ones: Vault's database secrets engine or cloud IAM role assumption issues per-session credentials with automatic expiry, so a leaked credential self-invalidates.
4. Configure automated rotation for any secret that must remain static, with dual-secret overlap so rotation never causes an outage.
5. Enforce least-privilege access policies scoped to the specific consuming service identity, not a shared blanket policy, and log every read with requester identity.
6. Add pre-commit and CI secret-scanning (gitleaks, trufflehog) as a blocking gate, tied to a documented leak-response runbook (revoke, rotate, audit access) in `security.incident_response`.
7. For local development, use vault dev-mode or scoped low-privilege sandbox credentials — never copy production secrets to developer machines.

## Validation
- Secret-scanning of the repo and CI history returns zero live credentials.
- Every secret has an owner, a rotation cadence or dynamic-issuance mechanism, and a scoped access policy.
- Secret access is logged and attributable to a specific identity/service, not a shared key.
- A rotate-on-demand drill completes without service downtime.

## Common failure modes
- Treating `.env` as "not committed" while it still ships inside a Docker image layer or CI artifact.
- Rotating the vault secret but not invalidating cached copies in running services, leaving the old secret usable.
- Granting a CI pipeline org-wide vault access instead of scoping to the one secret it actually needs.

## Outputs
Secrets inventory with rotation cadence, vault integration, CI secret-scanning gate, leak-response runbook.

## Related
`security.key_management`, `security.encryption`, `security.supply_chain`, `security.incident_response`

## skills/git/merge.md

# Merging Branches

- **ID:** `git.merge`
- **Purpose:** integrate a branch into another (typically into trunk) preserving an honest, traceable history of when and how the work was combined.
- **When:** a feature/fix branch is ready to be integrated into the shared branch, or reconciling two diverged long-lived branches.

## Procedure
1. Confirm the source branch passes the team's quality gate (tests, lint, review) before merging, not after (`testing.quality_gates`).
2. Choose merge strategy deliberately: a merge commit preserves the branch's full history and context; a squash merge produces one clean commit for a noisy branch history — pick based on whether the branch's internal history has value.
3. Update the branch against the latest target (merge or rebase target in) before the final merge, so the merge itself doesn't surprise reviewers with unrelated upstream changes.
4. Resolve any conflicts with attention to semantic correctness (`git.conflict_resolution`), not just making the diff markers disappear.
5. Re-run the full test suite after conflict resolution, since a textually clean merge can still be behaviorally wrong.
6. Delete the source branch after a successful merge to keep the branch list meaningful and avoid accidental re-merges.

## Validation
- The merged result passes the full test suite, not just the tests each side passed independently.
- The merge commit (or squash commit) message clearly attributes what was integrated and why.
- No conflict marker or leftover merge artifact remains in the merged code.
- The source branch is deleted or explicitly retained for a stated reason, not left to accumulate indefinitely.

## Common failure modes
- A conflict resolved by mechanically picking "ours" or "theirs" on every hunk without reading either side, silently reverting one side's real fix.
- Squash-merging a branch whose individual commits actually documented an important incremental investigation, losing that context permanently.
- Merging without re-running tests, assuming a clean textual merge implies a working merge.

## Outputs
Merged integration branch, resolved conflicts verified by tests, deleted source branch.

## Related
`git.rebase`, `git.conflict_resolution`, `git.branching`, `testing.quality_gates`

## skills/git/commit.md

# Atomic Commits and Message Conventions

- **ID:** `git.commit`
- **Purpose:** produce atomic, well-described commits that each represent one logical change, making history readable, bisectable, and safely revertible.
- **When:** committing any change, and especially before opening a PR that others will review or that future bisection may depend on.

## Procedure
1. Stage only the changes belonging to one logical unit of work; split unrelated changes (a refactor plus a bug fix) into separate commits.
2. Write the subject line as a concise imperative summary (e.g., `fix: ...`, `feat: ...`), consistent with the project's existing convention (check `git log`).
3. Explain the "why" in the commit body when the change isn't self-evident from the diff — the diff already shows the "what."
4. Avoid committing generated artifacts, secrets, or unrelated formatting-only churn alongside a functional change; a pure formatting pass belongs in its own commit.
5. Verify the commit builds and passes tests in isolation where practical, so a future `git bisect` lands on a working state, not a broken intermediate one.
6. Squash exploratory/fixup commits ("wip", "fix typo") before they reach shared history, keeping the merged history intentional rather than a raw work log.

## Validation
- Each commit's diff maps to exactly one described change; reverting it doesn't require picking apart unrelated lines.
- `git log --oneline` reads as a coherent narrative of the change, not a series of "wip"/"fix" commits.
- `git bisect` across the commit range never lands on a commit that fails to build.
- No commit contains a secret, credential, or accidentally-included unrelated file.

## Common failure modes
- One giant commit mixing a dependency bump, a refactor, and a bug fix, making `git revert` or `git bisect` useless for isolating the actual cause of a regression.
- A commit message like "fixes" with no context, leaving future readers (including `git.history_analysis`) unable to understand why the change was made.
- Leaving "wip"/fixup commits in shared history instead of squashing before merge, cluttering blame/bisect output.

## Outputs
Atomic commits with descriptive messages, clean bisectable history.

## Related
`git.branching`, `git.history_analysis`, `git.change_isolation`, `code_review.review_changes`

## skills/git/conflict_resolution.md

# Merge Conflict Resolution

- **ID:** `git.conflict_resolution`
- **Purpose:** resolve merge/rebase conflicts by verifying the resulting code is semantically correct for both sides' intent, not merely free of conflict markers.
- **When:** a merge or rebase reports conflicting hunks, especially when both sides touched overlapping logic rather than just adjacent lines.

## Procedure
1. Read both sides' full change (not just the conflicting hunk) to understand each side's actual intent before resolving.
2. Ask why each side changed what it changed — check the originating commit messages/PR context, don't guess from the diff alone.
3. When both sides modified the same logic differently (not just formatting), resolve by reconciling intent (often requiring a change that matches neither side's diff verbatim), not by picking one side wholesale.
4. Re-run the relevant tests (and add a new one if the conflict reveals an untested interaction) after resolving — a textually valid resolution can still be behaviorally wrong.
5. Flag conflicts that involve business-logic disagreement (not just code overlap) for a human decision rather than resolving them unilaterally.
6. Document non-obvious resolutions in the merge/rebase commit so a future reader understands why the resolution isn't a literal combination of both sides.

## Validation
- The resolved code satisfies the intent of both original changes, verified by running both sides' relevant tests.
- No conflict was resolved by blindly accepting one side without reading the other.
- A new test exists for any interaction the conflict revealed that wasn't previously covered.
- Non-obvious resolutions are explained in the commit, not left for a future reader to reverse-engineer.

## Common failure modes
- Accepting "ours" or "theirs" wholesale on a hunk touching overlapping business logic, silently discarding a real bug fix from the other side.
- A textually clean resolution that compiles and has no conflict markers but reintroduces a bug one side had specifically fixed.
- Resolving a conflict without re-running tests, only discovering the semantic break in production.

## Outputs
Conflict-resolved code verified by tests, documented rationale for non-trivial resolutions.

## Related
`git.merge`, `git.rebase`, `testing.quality_gates`, `code_review.review_changes`

## skills/git/branching.md

# Git Branching Strategy

- **ID:** `git.branching`
- **Purpose:** choose and enforce a branching model (trunk-based, feature-branch, or release-branch) that matches the team's release cadence, and keep branches short-lived to avoid drift.
- **When:** starting a new feature/fix, or the team is struggling with merge conflicts and long-lived divergent branches.

## Procedure
1. Pick one branching model deliberately based on release cadence (continuous deployment favors trunk-based; scheduled releases can justify release branches) — don't let it emerge accidentally.
2. Name branches by convention (e.g., `type/scope-short-description`) so intent and ownership are legible from the branch list alone.
3. Branch from the latest integration branch (main/trunk), not from another in-progress feature branch, to avoid inheriting unmerged, unreviewed work.
4. Keep branches short-lived: cut a branch, ship it, delete it — long-lived branches accumulate drift that turns every merge into a conflict-resolution exercise (`git.merge`, `git.conflict_resolution`).
5. Rebase or sync short-lived branches against trunk regularly (`git.rebase`) rather than merging trunk in sporadically, so drift stays small.
6. Protect the integration branch (required review, required status checks) so no branch merges without passing the team's quality gate (`testing.quality_gates`).

## Validation
- No branch survives more than a few days without merging or being explicitly abandoned.
- Branch names make ownership and intent identifiable without opening the branch.
- The integration branch has protection rules preventing direct unreviewed pushes.
- A new contributor can tell which branching model is in use from the repo's actual branch history, not just documentation.

## Common failure modes
- A "long-running feature branch" that diverges from trunk for weeks, turning its eventual merge into a multi-day conflict-resolution project.
- Branching off another feature branch instead of trunk, silently coupling two unrelated pieces of unreviewed work.
- No branch protection, letting a direct push to main bypass review and CI entirely.

## Outputs
Documented branching model, branch naming convention, protected integration branch.

## Related
`git.merge`, `git.rebase`, `git.commit`, `testing.quality_gates`

## skills/performance/frontend_optimization.md

# Frontend Performance Optimization

- **ID:** `performance.frontend_optimization`
- **Purpose:** reduce perceived and measured load/interaction time in a web/mobile client, improving Core Web Vitals or equivalent user-facing performance metrics.
- **When:** a page/screen has poor load time, layout stability, or interaction responsiveness, measured by real-user monitoring or lab tools (Lighthouse, WebPageTest).

## Procedure
1. Measure baseline with both lab (Lighthouse/WebPageTest) and field (real-user monitoring) data — lab-only numbers can miss real network/device variance.
2. Identify the specific metric that's failing (LCP, FID/INP, CLS, TTFB) since the fix differs entirely by which one is the problem.
3. For LCP/TTFB issues, check server response time and critical-resource loading order (render-blocking CSS/JS, unoptimized largest image).
4. For CLS issues, check for layout shifts from late-loading images/ads/fonts without reserved space, or dynamically injected content above existing content.
5. Reduce JavaScript bundle size shipped on initial load: code-split by route, defer non-critical scripts, remove unused dependencies.
6. Optimize asset delivery: compress/resize images appropriately, use modern formats, serve via CDN, set correct caching headers.
7. Re-measure with the same lab and field tools after the change and confirm the specific target metric improved, not just an aggregate score.

## Validation
- The specific failing metric (LCP/INP/CLS/TTFB) is identified before optimization starts, not treated generically as "slow."
- Both lab and field measurements confirm improvement after the change.
- Bundle size/critical-path resource count decreased where JS-blocking was the identified cause.
- No new layout shift or interaction regression was introduced by the fix.

## Common failure modes
- Optimizing based on lab scores alone while real users on slow networks/devices see no improvement.
- Chasing an aggregate performance score instead of the specific Core Web Vital that's actually failing for real users.
- Lazy-loading or code-splitting introduced carelessly, causing a new layout shift or interaction delay that offsets the gain.

## Outputs
Measured improvement in the specific target Core Web Vital, confirmed in both lab and field data.

## Related
`frontend.performance`, `performance.network_optimization`, `performance.caching`, `ux.usability`

## skills/documentation/adr.md

# Writing a Decision Record (ADR)

- **ID:** `documentation.adr`
- **Purpose:** write a decision record that captures a choice, its context, the alternatives considered, and the consequences accepted — durable enough that someone reading it a year later understands why, not just what.
- **When:** writing up any significant decision (technical or otherwise) as a documentation artifact — this skill is the general writing discipline; `architecture.adr` covers the architecture-specific process for when and how such decisions get made.

## Procedure
1. State the decision itself in one clear sentence up front — a reader skimming should get the outcome without reading the whole document.
2. Capture the context/forces that made this a decision at all: what constraint, requirement, or problem forced a choice to be made.
3. List the real alternatives considered, with their genuine trade-offs — a record with only one option listed isn't a decision record, it's a justification after the fact.
4. State the consequences honestly, including the downsides accepted, not only the benefits — future readers need to know what was traded away.
5. Record the decision's status (proposed, accepted, superseded) and date, and link forward/backward when a later decision supersedes this one.
6. Keep the record immutable once accepted — don't edit history to match a later change; write a new record that supersedes it instead (`documentation.decision_record`).
7. Store it where it will actually be found later (a consistent decisions directory), not buried in a chat thread or PR description only.

## Validation
- The decision, its context, and its consequences are each identifiable in under a minute of reading.
- At least one real alternative is documented with why it was rejected, not just the chosen option.
- The record's status is current, and superseded records point to what replaced them.
- The record is stored in the project's designated location for decisions, not scattered.

## Common failure modes
- Writing the record after the fact as a rationalization for a decision already implemented, omitting the alternatives that were actually considered and making it useless for future re-evaluation.
- Editing an old record in place to reflect a later change, destroying the historical record of what was actually decided and when.

## Outputs
A dated, status-tracked decision record documenting the choice, alternatives, and consequences.

## Related
`architecture.adr`, `documentation.decision_record`, `documentation.architecture_documentation`, `mnemosine.memory_capture`

## skills/documentation/changelog.md

# Changelog Maintenance

- **ID:** `documentation.changelog`
- **Purpose:** maintain a human-readable log of notable changes per release so consumers can tell what changed and whether it affects them without reading commit history.
- **When:** cutting a release/version, or as part of every change that affects consumers of the project (breaking change, new feature, fix) if the project maintains a running changelog.

## Procedure
1. Group entries by change type (Added, Changed, Deprecated, Removed, Fixed, Security) so a reader can scan for the category relevant to them.
2. Write each entry from the consumer's perspective (what changed for them), not as a raw commit message or internal implementation detail.
3. Flag breaking changes unmistakably (a dedicated section or explicit marker), since these are the entries that block or require action from consumers.
4. Tie each entry to a version number and date, following the project's versioning scheme (semver or equivalent) consistently.
5. Add the changelog entry as part of the PR/change that introduces it, not reconstructed later from git log at release time — reconstruction loses context and misses entries.
6. Link entries to the relevant issue/PR/decision record for readers who want more detail than the one-line summary.
7. Keep an "Unreleased" section at the top for merged-but-unreleased changes, moved to a dated version section at release time.

## Validation
- Every breaking change is unmistakably flagged, not buried among routine entries.
- Entries are grouped by type and readable without needing to cross-reference commit history.
- Each release's entries are dated and tied to a version number matching the project's versioning scheme.
- Entries were added alongside the change that caused them, not reconstructed after the fact.

## Common failure modes
- Changelog entries written as copy-pasted commit messages, meaningless to a consumer who doesn't know the internal file structure.
- Breaking changes listed with the same visual weight as a typo fix, causing consumers to upgrade blind and hit an unannounced break.

## Outputs
A versioned, dated changelog file updated as part of each consumer-facing change.

## Related
`documentation.readme`, `api.versioning`, `documentation.decision_record`, `git.release_tagging`

## skills/code_review/review_changes.md

# Review Changes

## Objective
Evaluate changes for correctness, security, maintainability, compatibility and test coverage.

## Procedure
1. Compare requested behavior with the actual diff.
2. Verify invariants and SSOT boundaries.
3. Check error handling and edge cases.
4. Check authorization and data exposure.
5. Check filesystem and concurrency safety.
6. Check tests and regression coverage.
7. Record findings with severity and remediation.
