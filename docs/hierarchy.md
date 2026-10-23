# Jerarquía de archivos y convenciones de carpeta

## Por feature (`lib/features/<feature>/`)
```
<feature>/
  data/
    datasources/        # llamadas HTTP/locales
    repositories/        # implementación de domain/repositories
  domain/
    models/               # entidades e interfaces (a veces en models/interfaces/)
    repository/ | repositories/   # contrato abstracto (naming inconsistente entre features)
    usecases/              # una acción de negocio por archivo
  presentation/
    bloc/  (o driver-bloc/ + client-bloc/ si el feature separa por rol)
    atoms/ molecules/ organisms/ templates/ pages/   # a veces con subcarpetas driver/ client/
```
Nota: algunas features usan `domain/repository` (singular) y otras `domain/repositories` (plural). Al crear una feature nueva, sigue la convención de `auth` (`domain/repositories/`, plural, la más completa); no mezcles ambas dentro de la misma feature.

### Submódulos dentro de `trips/` (confirmado en [`architecture.md`](architecture.md))
`trips/` no se divide en features nuevas independientes para cada capacidad — se organiza en submódulos que comparten el dominio "viaje": `trips/negotiation/` (publicar solicitud y ofertas), `trips/chat/`, `trips/ratings/`, `trips/safety/` (SOS, contacto de emergencia, desviación de ruta). Cada submódulo sigue la misma estructura `data/domain/presentation` que una feature normal, anidada bajo `trips/`. No crear estas capacidades como features top-level en `lib/features/`.

## UI compartida (`lib/shared/`)
Mismo esquema Atomic Design que las features, pero sin capas `data`/`domain` (es solo UI): `atoms/`, `molecules/`, `organisms/`, `templates/`, `pages/`, más `blocs/` para estado de UI puro (ej. `modals/`). `lib/shared/shared.dart` es el barrel de importación, pero **no es exhaustivo** (no incluye `templates/`) — verificar si un componente está exportado antes de asumir que se puede importar desde el barrel.

## App shell (`lib/app/`)
```
app/
  core/         # network, bloc (globales), permission, packages
  database/      # sqflite
  design/        # theme, tokens
  di/            # get_it
  environments/  # flavors dev/prod
  handlers/      # traducen cubits globales en overlays de UI
  router/        # go_router, subcarpetas client/ y driver/
```

## Convenciones de nombres observadas
- Carpetas compuestas: **kebab-case** (`profile-drawer`, `bottom-appbar`, `driver-bloc`, `client-bloc`). Excepción inconsistente: `statusForms` (camelCase) — no replicar; usar kebab-case en carpetas nuevas.
- Prefijo `App` en widgets/clases compartidas nuevas (`AppButton`, `AppText`, `AppTextField`...), salvo patrones con nombre propio ya establecido (`CustomDialog`, `ProfileDrawer`).
- Archivos de bloc: `<nombre>_bloc.dart` + evento/estado (`<nombre>_bloc_event.dart`/`<nombre>_event.dart`, `<nombre>_bloc_state.dart`/`<nombre>_state.dart`) — el sufijo exacto no es 100% uniforme entre features; revisa el feature específico antes de asumir el nombre del archivo hermano.
- Separación por rol dentro de un mismo feature: subcarpetas literales `driver/` y `client/` dentro de `presentation/{molecules,organisms,templates,pages}` y `presentation/bloc/{driver-bloc,client-bloc}`.

## Dónde NO crear archivos nuevos
- No agregues lógica de negocio dentro de `lib/shared/` (es solo UI reutilizable, sin conocimiento de features).
- No agregues widgets de un feature específico dentro de `lib/app/` (la app shell es transversal, no debe conocer detalles de `trips`/`home`/etc.).
