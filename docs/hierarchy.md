# Jerarquía de Directorios del Proyecto Ando-UI

Organización Clean Architecture (Feature-First) + Atomic Design:

```
lib/
├── app/
│   ├── config/             # Configuración por ambientes (local, dev, prod)
│   ├── di/                 # Inyección de dependencias (GetIt/Injectable)
│   ├── network/            # Cliente HTTP, WebSocket Manager, Interceptores JWT
│   ├── router/             # Configuración de rutas (client_routes, conductor_routes)
│   └── theme/              # Tokens de diseño, colores y tipografía
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── trips/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── client_profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── onboarding/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── atoms/
    ├── molecules/
    ├── organisms/
    └── templates/
```
