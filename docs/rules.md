# Reglas del Proyecto Ando-UI

## Reglas de Calidad y Gobernanza de Mnemosine
- **Trazabilidad de Tests**: Cada criterio de aceptación automático se prueba con un test cuyo nombre lleva el código del criterio (por ejemplo `T12-C3`).
- **Cero Código Muerto**: Nada de código muerto ni duplicado. Lo que se reemplaza dentro de la misma versión se elimina con sus referencias, imports, tests y dependencias.
- **Mecanismos Deterministas**: Utilizar patrones deterministas y contratos estrictos para comunicación con el backend Spring Boot.
- **No Secretos en Código**: Claves, tokens y credenciales deben obtenerse exclusivamente de variables de entorno o almacenamiento seguro (Keychain/Keystore via Flutter Secure Storage).
- **Respeto a Contratos SSOT**: Los contratos de API REST y WebSockets del backend `micro-auronix` son la fuente única de verdad y no deben alterarse en el cliente.
