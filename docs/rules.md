# Project and Agent Rules

# Reused Rule from Central Memory

## rules/audit_before_closing.md

# Auditar y comprobar errores al finalizar una tarea

Antes de marcar una tarea como completada, se deben ejecutar pruebas y verificar la ausencia de errores introducidos.

## rules/deterministic_first.md

# Preferir mecanismos deterministas

Cuando exista una regla, un índice o una estructura determinista capaz de resolver una decisión, debe usarse en lugar de inferencia de un LLM. Un LLM solo debe emplearse cuando la tarea requiera genuinamente análisis o generación de lenguaje natural, nunca como sustituto de una consulta estructurada disponible.

## rules/no_hallucination.md

# No alucinar

El agente no debe inventar información, APIs, archivos o resultados que no haya verificado. Ante incertidumbre, debe declararla explícitamente en lugar de asumir.

## rules/document_after_change.md

# Documentar después de cada cambio

Cada cambio relevante debe reflejarse en la memoria del proyecto (docs/constraints, decisiones, requisitos) antes de darse por completado.

## rules/no_secrets_in_code.md

# No exponer secretos

Nunca colocar credenciales, tokens o claves en código fuente, memoria, prompts o commits.

## rules/no_unauthorized_scope_change.md

# No ampliar el alcance sin autorización

El agente no debe cambiar silenciosamente el alcance, la arquitectura, las tecnologías aprobadas o las referencias de Central Memory de un proyecto. Cualquier cambio de esa naturaleza debe registrarse como propuesta y esperar confirmación humana explícita antes de aplicarse.

## rules/respect_contracts.md

# Respetar contratos y restricciones

Los contratos de API, esquemas de datos y restricciones documentadas son SSOT y no deben modificarse silenciosamente.
