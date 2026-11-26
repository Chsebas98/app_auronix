# QA Checklist

# Reused Qa from Central Memory

## qa/accessibility_checklist.md

# Accessibility checklist

- Keyboard navigation works for all interactive elements.
- Color contrast meets WCAG AA.
- Screen-reader labels present for inputs and icons-only buttons.

## qa/functional_testing_checklist.md

# Functional testing checklist

- Golden path covered end to end.
- Known edge cases covered (empty, boundary, invalid input).
- Error states show a usable message and do not crash the flow.

## qa/regression_checklist.md

# Regression checklist

- Previously fixed bugs remain fixed.
- Existing automated tests pass before merging.
- Manual smoke test of critical flows after dependency or infra changes.

## qa/performance_checklist.md

# Performance checklist

- Presupuesto de rendimiento definido (tiempo de respuesta, tamaño de bundle, uso de memoria) antes de liberar.
- Pruebas de carga sobre los endpoints críticos, no solo pruebas funcionales.
- Cuellos de botella identificados con perfilado, no adivinados.
- Consultas N+1 y payloads no paginados revisados antes de producción.

## qa/release_readiness_checklist.md

# Release readiness checklist

- All required questions answered and no blocking pending items.
- Migrations applied and reversible.
- Rollback plan documented.

## qa/security_review_checklist.md

# Security review checklist

- Input validation and output encoding at trust boundaries.
- AuthN/AuthZ enforced server-side, not only in the UI.
- No secrets in logs, commits or client-visible responses.
