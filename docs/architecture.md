# Architecture overview

Describe the system boundaries, components, dependencies and integration points.

# Reused Architecture from Central Memory

## architectures/clean_feature_first.md

# Clean Architecture (Feature-First) + Atomic Design

## Intent
Organize a client application (mobile/web UI) by business feature first, with Clean Architecture's dependency rule inside each feature, and Atomic Design structuring every feature's UI layer.

## Applicability
Use on a UI application with multiple independent business features (e.g. auth, home, trips) that each need their own data/domain/presentation separation, and where the UI itself is complex enough to benefit from a composable component hierarchy (atoms/molecules/organisms/templates/pages).

## Non-applicability
Avoid on a small single-screen app or a prototype — the per-feature layering and atomic component split add structural overhead that only pays off once there are several independent features and a non-trivial component library.

## Structure
Top level is organized by feature (`features/<feature>/`), not by technical layer. Each feature contains:
- `data/` — datasources (remote/local) and repository implementations, plus data-transfer models.
- `domain/` — repository interfaces, domain models and use cases; owns no framework or persistence dependency.
- `presentation/` — state management (e.g. Bloc/Cubit) plus UI organized by Atomic Design: `atoms` (smallest reusable widgets: buttons, inputs, text styles), `molecules` (small combinations of atoms: a labeled input, a card), `organisms` (self-contained UI sections composed of molecules/atoms: a bottom nav, a search sheet), `templates` (page-level layout skeletons wiring organisms together), `pages` (the actual routed screen, binding a template to live state).
A `shared/` module mirrors the same atomic structure (`shared/atoms`, `shared/molecules`, `shared/organisms`, `shared/templates`) for widgets reused across features, and an app-level module (`app/`) holds cross-cutting concerns (DI, routing, theming, network client) that every feature depends on but no feature owns.

## Implementation guidance
Keep the Clean Architecture dependency rule inside each feature: `presentation` depends on `domain`, `domain` defines the repository interfaces `data` implements — never the reverse. Don't let two features import each other's internals directly; shared UI/logic belongs in `shared/` or the app-level module, not in a feature-to-feature dependency. Within `presentation`, a `page` should compose `templates`/`organisms`, never reach directly into another feature's atoms — promote a widget to `shared/` once a second feature needs it.

## Validation
Each feature's `domain` layer has zero imports from `data` implementations or any UI/framework package. Widgets in `atoms`/`molecules` take data via constructor parameters only (no direct Bloc/repository access) — only `organisms`/`pages` wire state management in. No feature directory imports another feature's internal (non-`shared`) files.

## Security
Treat `data/datasources` as the only place allowed to hold API clients, tokens or local storage handles; `domain`/`presentation` must not read secrets or make raw network calls directly — route everything through the feature's repository/use case.

## Trade-offs
High navigability (a feature is self-contained, easy to find/remove/replace) and a consistent, composable UI vocabulary across the app, at the cost of more files/boilerplate per feature and the discipline required to keep promotion to `shared/` deliberate rather than ad hoc duplication.

## Related
Skill: `architecture.clean_architecture`, `architecture.mobile`, `ui_ux.component_design`, `frontend.component_design`. Consider `architecture.layered` as the simpler non-feature-first alternative when the app has only one real feature area.

## architectures/adr.md

# Architecture Decision Record

## Intent
Preserve the context, decision and consequences behind an important architectural choice.

## Applicability
Use when alternatives exist, the decision has durable consequences, or future agents need the rationale.

## Non-applicability
Do not create an ADR for routine implementation details with no meaningful architectural consequence.

## Structure
Record context, constraints, alternatives considered, decision, consequences, risks and status.

## Implementation guidance
Reference affected contracts, components and constraints. Keep the ADR immutable in intent; supersede it with a new decision when the architecture changes.

## Validation
A reviewer should be able to understand why the decision was made without reconstructing the original discussion.

## Security
Record relevant security implications and rejected alternatives when security is a material decision factor.

## Trade-offs
Preserves rationale and reduces repeated debate, but requires maintenance and disciplined updates.

## Related
Skill: `architecture.system_design`. Project SSOT for architectural decisions is `architecture/decisions/`.
