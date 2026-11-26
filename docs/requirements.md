# Technical Requirements

Languages, versions and frameworks selected from Central Memory are listed below. The internal analysis may propose additions.

# Reused Version from Central Memory

## versions/flutter-3.44.md

# Flutter 3.44 / Dart 3.12

Applies to: `languages/dart.md`, `frameworks/flutter.md`

Current stable line pinning Dart SDK `>=3.12.0 <4.0.0`. Brings the latest stable Impeller rendering engine improvements and continued Material 3 refinements. No breaking widget-API changes expected from 3.38 baselines; verify plugin compatibility (Firebase, platform channels) before bumping the floor version in `pubspec.yaml`.

# Reused Mcp from Central Memory

## mcp/filesystem.md

# Sistema de archivos (MCP)

Leer y escribir archivos locales dentro de carpetas autorizadas.

## Cuándo usarlo

Agentes que trabajan sobre una copia local del proyecto y necesitan leer o generar archivos fuera del editor.

## Seguridad

Autoriza solo la carpeta del proyecto. No expongas carpetas personales, claves SSH ni archivos .env.

## Reglas para el agente

- Usa este servidor MCP solo si el proyecto lo seleccionó.
- La configuración y las credenciales del servidor las gestiona el usuario en su entorno; no se guardan en Mnemosine ni en el repositorio.

## mcp/github.md

# GitHub (MCP)

Leer y gestionar repositorios, issues y pull requests de GitHub desde el agente.

## Cuándo usarlo

Consultar issues, revisar pull requests, buscar código en otros repositorios de la organización.

## Seguridad

Usa un token con el mínimo alcance necesario (solo el repositorio del proyecto). Nunca pegues el token en el repositorio ni en la memoria.

## Reglas para el agente

- Usa este servidor MCP solo si el proyecto lo seleccionó.
- La configuración y las credenciales del servidor las gestiona el usuario en su entorno; no se guardan en Mnemosine ni en el repositorio.

# Reused Language from Central Memory

## languages/dart.md

# Dart

## Use when
Building a Flutter application (mobile, web or desktop) from a single codebase, or any Flutter-adjacent tooling/package.

## Key considerations
- Sound null safety is mandatory — model absence with nullable types deliberately, not with sentinel values.
- Dart is optimized for UI: everything (including control flow like loops inside widget builders) ends up rebuilt on every frame, so keep build methods cheap and push expensive work out of them.
- Async/await and `Future`/`Stream` are first-class; prefer them over manual callback chains, especially for sockets and API calls.
- Strong static typing with type inference (`var`) — don't fight it with excessive `dynamic`.

## Common pitfalls
- Using `dynamic` to silence the analyzer instead of modeling the real type, which pushes failures from compile time to runtime.
- Holding `StreamSubscription`/`AnimationController`/socket instances without disposing them in `dispose()`, leaking memory and callbacks on disposed widgets.
- Mutating state directly instead of going through the chosen state-management solution (Bloc/Riverpod/Provider), breaking rebuild propagation.

# Reused Framework from Central Memory

## frameworks/flutter.md

# Flutter

## Language
Dart

## Use when
One codebase targeting mobile (iOS/Android), web and desktop with a consistent native-feeling UI.

## Key considerations
- Widget composition is the core mental model — everything is a widget.
- State management (Riverpod, Bloc, Provider) should be chosen deliberately, not per-screen ad hoc.
- Platform channels are needed for native APIs Flutter doesn't expose directly.

## Common pitfalls
- Rebuilding large widget trees unnecessarily hurts performance; scope `setState`/providers narrowly.
- Ignoring platform-specific UX conventions makes the app feel foreign on iOS or Android.
