# Preguntas — pantalla por pantalla

## Estado: sin preguntas abiertas (2026-08-22)
Las 40 preguntas de la segunda ronda y las 6 preguntas nuevas derivadas de ellas fueron todas respondidas y ya están incorporadas en [`flow.md`](flow.md), [`database.md`](database.md), [`architecture.md`](architecture.md), [`design_patterns.md`](design_patterns.md), [`functionality.md`](functionality.md), [`security.md`](security.md), [`requirements.md`](requirements.md) y [`requerimientos_backend.md`](requerimientos_backend.md).

Este archivo se mantiene vacío de preguntas activas a propósito — es el lugar donde se agregan preguntas nuevas de aquí en adelante (ver regla al final). Historial completo de decisiones en [`questions.md`](questions.md).

## Resumen de las decisiones finales más relevantes (cuarta ronda)
- **Edad mínima: 18 años para todo usuario** (pasajero y conductor por igual) — reemplaza la regla anterior de 15 años para pasajero. Al fijarla en 18, no aplica ningún flujo de consentimiento parental.
- **Términos y condiciones**: v1 usa un texto estándar/genérico como placeholder, versionado (`terminos_version`), reemplazable por el del departamento legal sin romper el historial de aceptaciones.
- **Viajes transfronterizos: no permitidos.** Backend valida que origen y destino estén en el mismo país y rechaza la solicitud si no es así.
- **Desviación de ruta / check-in de seguridad**: umbral de 500m sostenidos por 90s o parada no planificada de 3 min (estándar tipo Uber RideCheck). La alerta al administrador se dispara automáticamente y de inmediato, sin depender de que el pasajero responda — prioriza el escenario de robo/secuestro sobre la conveniencia de evitar falsos positivos. El check-in en la app es un canal adicional, discreto y no alarmante.
- **Formato de placa por país (regex oficial confirmado)**:
  - Ecuador: `^[A-Z]{3}-\d{3,4}$`
  - Perú: `^([A-Z]{3}-\d{3}|[A-Z]\d[A-Z]-\d{3})$`
  - Colombia: `^([A-Z]{3}\d{3}|[A-Z]{2}\d{4})$`
- **Rango de contraoferta confirmado**: 90%-130% del precio sugerido (interpretación correcta).

## Regla
Si surge una nueva pregunta de negocio durante el desarrollo, agrégala aquí con el mismo formato usado en rondas anteriores (pregunta + por qué importa) antes de asumir una respuesta — ver [`rules.md`](rules.md) reglas 4-5.
