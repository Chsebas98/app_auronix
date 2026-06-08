# Consumir Endpoints MVP — Auronix Backend

> **Base URL:** `http://TU_SERVER:8081`
> **Todos los endpoints son POST**
> **Content-Type:** `application/json`

---

## Estructura de respuesta estándar

Toda respuesta sigue este contrato sin excepción:

```json
{
  "response": true,
  "codeStatus": 200,
  "message": "Operación exitosa",
  "result": { ... },
  "extraDetail": null
}
```

| Campo | Tipo | Descripción |
|---|---|---|
| `response` | `bool` | `true` = éxito, `false` = error |
| `codeStatus` | `int` | Código HTTP del resultado |
| `message` | `string` | Mensaje legible para el usuario (en español) |
| `result` | `object \| null` | Payload de la respuesta |
| `extraDetail` | `string \| null` | Detalle técnico del error (solo cuando `response = false`) |

**En caso de error:**
```json
{
  "response": false,
  "codeStatus": 401,
  "message": "Credenciales inválidas",
  "result": null,
  "extraDetail": "Email o contraseña incorrectos"
}
```

---

## Modelo AuthenticationCredentials

Todos los endpoints de auth devuelven este modelo **plano** dentro de `result`:

```json
{
  "token_access": "eyJhbGci...",
  "token_refresh": "eyJhbGci...",
  "role": "rolUser",
  "username": "maria1234",
  "first_name": "María",
  "second_name": null,
  "last_name": "Torres",
  "second_last_name": null,
  "email": "maria@ejemplo.com",
  "photo_url": "",
  "is_google_user": false
}
```

| `role` | Actor |
|---|---|
| `rolUser` | Pasajero / Cliente |
| `rolDriver` | Conductor |
| `rolMember` | Miembro |
| `rolGerente` | Gerente de cooperativa |
| `rolAdmin` | Administrador |

---

## Autenticación en endpoints protegidos

Mientras el sistema JWT está en fase de integración, los endpoints protegidos requieren el `userId` en el header:

```
X-User-Id: 42
```

En producción este header será reemplazado por el token en el header estándar:
```
Authorization: Bearer <token_access>
```

---

## AUTH — Clientes

### Verificar disponibilidad de email

```
POST /api/v1/auth/clients/verify-register
```

**Request:**
```json
{ "email": "usuario@ejemplo.com" }
```

**Response `result`:** `null`

| `codeStatus` | Significado |
|---|---|
| `200` | Email disponible |
| `400` | Email ya registrado |

---

### Registrar cliente

```
POST /api/v1/auth/clients/register
```

**Request:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "MiClave123",
  "nombre1": "María",
  "nombre2": "Fernanda",
  "ape1": "Torres",
  "ape2": "Vega"
}
```

**Response `result`:** `AuthenticationCredentials`

---

### Login cliente

```
POST /api/v1/auth/clients/login
```

**Request:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "MiClave123"
}
```

**Response `result`:** `AuthenticationCredentials`

---

### Login con Google

```
POST /api/v1/auth/clients/google-login
```

**Request:**
```json
{
  "email": "usuario@gmail.com",
  "google_id": "1089273648...",
  "google_token": "ya29.a0A...",
  "nombre1": "María",
  "ape1": "Torres",
  "photo_url": "https://lh3.googleusercontent.com/..."
}
```

**Response `result`:** `AuthenticationCredentials`

---

### Refresh token

```
POST /api/v1/auth/clients/refresh-token
```

**Request:**
```json
{ "refreshToken": "eyJhbGci..." }
```

**Response `result`:** `AuthenticationCredentials`

---

### Logout

```
POST /api/v1/auth/clients/logout
```

**Request:**
```json
{ "email": "usuario@ejemplo.com" }
```

**Response `result`:** `null` — codeStatus `200`

---

## AUTH — Conductores

### Login conductor

```
POST /api/v1/auth/drivers/login
```

**Request:**
```json
{
  "identificacion": "1712345678",
  "password": "MiClave123"
}
```

**Response `result`:** `AuthenticationCredentials` con `role: "rolDriver"`

> El conductor debe tener estado `ACTIVO` para poder hacer login.

---

### Registrar conductor

```
POST /api/v1/auth/drivers/register
```

**Request:**
```json
{
  "email": "conductor@ejemplo.com",
  "password": "MiClave123",
  "first_name": "Carlos",
  "second_name": null,
  "last_name": "Pérez",
  "second_last_name": "Vega",
  "cedula": "1712345678",
  "licencia_conducir": "LIC-001234",
  "tipo_licencia": "C",
  "fecha_vencimiento_licencia": "2027-12-31",
  "cooperativa_id": 1
}
```

**Response `result`:** `AuthenticationCredentials` con `role: "rolDriver"`

---

## PERFIL

### Obtener perfil del cliente

```
POST /api/v1/profile
Headers: X-User-Id: {userId}
Body: {}
```

**Response `result`:** `AuthenticationCredentials` (sin tokens)

---

### Actualizar perfil del cliente

```
POST /api/v1/profile/update
Headers: X-User-Id: {userId}
```

**Request** (todos los campos son opcionales):
```json
{
  "first_name": "María",
  "second_name": "Fernanda",
  "last_name": "Torres",
  "second_last_name": "Vega",
  "phone": "0991234567",
  "photo_url": "https://storage.ejemplo.com/foto.jpg"
}
```

**Response `result`:** `AuthenticationCredentials` actualizado

---

### Home del conductor

```
POST /api/v1/profile/driver/home
Headers: X-User-Id: {userId}
Body: {}
```

**Response `result`:**
```json
{
  "username": "carlos5678",
  "first_name": "Carlos",
  "last_name": "Pérez",
  "photo_url": "",
  "is_available": false,
  "current_address": null,
  "rating": 4.80,
  "daily_earnings": 37.50,
  "completed_trips": 12,
  "earnings_history": [
    { "label": "8am",  "amount": 5.00,  "index": 8  },
    { "label": "10am", "amount": 12.50, "index": 10 },
    { "label": "2pm",  "amount": 20.00, "index": 14 }
  ]
}
```

> `earnings_history` contiene solo las horas en que el conductor completó viajes hoy (zona horaria Quito, UTC-5). Horas sin viajes no aparecen.

---

## VIAJES — Cliente

### Solicitar viaje

```
POST /api/v1/trips/request
Headers: X-User-Id: {userId}
```

**Request:**
```json
{
  "origen_latitud": -0.2295,
  "origen_longitud": -78.5243,
  "origen_direccion": "Av. Amazonas N21-147",
  "destino_latitud": -0.1800,
  "destino_longitud": -78.4800,
  "destino_direccion": "Cumbayá, Quito",
  "distancia_estimada_km": 8.5,
  "metodo_pago_id": null
}
```

**Response `result`:**
```json
{
  "id": 7,
  "codigoViaje": "VJ-KR4T2",
  "passengerId": 3,
  "driverId": null,
  "cooperativaId": 1,
  "origenLatitud": -0.2295,
  "origenLongitud": -78.5243,
  "origenDireccion": "Av. Amazonas N21-147",
  "destinoLatitud": -0.1800,
  "destinoLongitud": -78.4800,
  "destinoDireccion": "Cumbayá, Quito",
  "distanciaKm": 8.50,
  "precioTotal": 5.75,
  "estado": "SOLICITADO",
  "fechaSolicitud": "2026-05-25T14:30:00"
}
```

---

### Consultar estado del viaje

```
POST /api/v1/trips/get-status
Headers: X-User-Id: {userId}
```

**Request:**
```json
{ "codigoViaje": "VJ-KR4T2" }
```

**Response `result`:** mismo modelo de viaje arriba con estado actualizado.

---

### Cancelar viaje

```
POST /api/v1/trips/cancel
Headers: X-User-Id: {userId}
```

**Request:**
```json
{
  "tripId": 7,
  "motivo": "Cambié de opinión"
}
```

**Response `result`:** `null` — codeStatus `200`

---

### Calificar conductor

```
POST /api/v1/trips/rate-driver
Headers: X-User-Id: {userId}
```

**Request:**
```json
{
  "tripId": 7,
  "calificacion": 5,
  "comentario": "Excelente servicio"
}
```

**Response `result`:** `null` — codeStatus `200`

---

## VIAJES — Conductor

### Viajes disponibles (sin WebSocket)

```
POST /api/v1/trips/get-available
Headers: X-User-Id: {userId}
Body: {}
```

**Response `result`:** `Array<TripResponse>` — lista de viajes en estado `SOLICITADO` de la cooperativa del conductor.

---

### Aceptar viaje

```
POST /api/v1/trips/accept
Headers: X-User-Id: {userId}
```

**Request:**
```json
{ "tripId": 7 }
```

**Response `result`:** `TripResponse` con estado `ACEPTADO`

> El conductor debe tener `disponible = true`. Al aceptar se marca como no disponible.

---

### Iniciar viaje

```
POST /api/v1/trips/start
Headers: X-User-Id: {userId}
```

**Request:**
```json
{ "tripId": 7 }
```

**Response `result`:** `TripResponse` con estado `EN_CURSO`

---

### Completar viaje

```
POST /api/v1/trips/complete
Headers: X-User-Id: {userId}
```

**Request:**
```json
{
  "tripId": 7,
  "distanciaFinalKm": 8.7,
  "duracionMinutos": 22
}
```

**Response `result`:**
```json
{
  "id": 7,
  "estado": "COMPLETADO",
  "precioTotal": 5.85,
  "comisionMonto": 0.88,
  "montoConductor": 4.97,
  "fechaFin": "2026-05-25T15:02:00"
}
```

---

### Calificar pasajero

```
POST /api/v1/trips/rate-passenger
Headers: X-User-Id: {userId}
```

**Request:**
```json
{
  "tripId": 7,
  "calificacion": 4,
  "comentario": "Puntual"
}
```

**Response `result`:** `null` — codeStatus `200`

---

## Estados del viaje

```
SOLICITADO → ACEPTADO → EN_CURSO → COMPLETADO
                                 ↘ CANCELADO
```

---

## WebSockets

> **No requieren autenticación en el MVP.**
> El servidor solo empuja datos (push). No procesa mensajes enviados desde el cliente.

### Conexión

```
ws://TU_SERVER:8081/ws/{canal}
```

### Canales disponibles

| Canal | Quién conecta | Cuándo recibe |
|---|---|---|
| `/ws/driver/{driverId}/requests` | Conductor | Cada vez que un cliente solicita un viaje |
| `/ws/trip/{tripId}/status` | Cliente y conductor | Cuando el estado del viaje cambia |

### Formato del evento

```json
{
  "event": "nombre.del.evento",
  "data": { ... }
}
```

### Eventos por canal

#### `driver/{driverId}/requests`

```json
{
  "event": "trip.request.new",
  "data": {
    "id": 7,
    "codigoViaje": "VJ-KR4T2",
    "origenDireccion": "Av. Amazonas N21-147",
    "destinoDireccion": "Cumbayá, Quito",
    "origenLatitud": -0.2295,
    "origenLongitud": -78.5243,
    "distanciaKm": 8.50,
    "precioTotal": 5.75,
    "estado": "SOLICITADO"
  }
}
```

#### `trip/{tripId}/status`

```json
{
  "event": "trip.status.updated",
  "data": {
    "trip_id": 7,
    "status": "ACEPTADO",
    "data": { ...TripResponse completo... }
  }
}
```

Los valores posibles de `status` son: `ACEPTADO`, `EN_CURSO`, `COMPLETADO`.

---

### Ejemplo Flutter — Conductor

```dart
// pubspec.yaml → web_socket_channel: ^3.0.0

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverTripSocket {
  WebSocketChannel? _channel;

  void connect(int driverId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://TU_SERVER:8081/ws/driver/$driverId/requests'),
    );
    _channel!.stream.listen(
      _onMessage,
      onError: (_) => Future.delayed(const Duration(seconds: 3), () => connect(driverId)),
      onDone:  () => Future.delayed(const Duration(seconds: 3), () => connect(driverId)),
    );
  }

  void _onMessage(dynamic raw) {
    final event = jsonDecode(raw as String) as Map<String, dynamic>;
    if (event['event'] == 'trip.request.new') {
      final trip = event['data'] as Map<String, dynamic>;
      // → mostrar solicitud al conductor
    }
  }

  void disconnect() => _channel?.sink.close();
}
```

### Ejemplo Flutter — Cliente (estado del viaje)

```dart
class TripStatusSocket {
  WebSocketChannel? _channel;

  void connect(int tripId, void Function(String status, Map data) onUpdate) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://TU_SERVER:8081/ws/trip/$tripId/status'),
    );
    _channel!.stream.listen((raw) {
      final event = jsonDecode(raw as String) as Map<String, dynamic>;
      if (event['event'] == 'trip.status.updated') {
        final payload = event['data'] as Map<String, dynamic>;
        onUpdate(payload['status'] as String, payload);
      }
    });
  }

  void disconnect() => _channel?.sink.close();
}

// Uso:
TripStatusSocket().connect(tripId, (status, data) {
  switch (status) {
    case 'ACEPTADO':   // conductor aceptó, mostrar info del conductor
    case 'EN_CURSO':   // viaje en marcha
    case 'COMPLETADO': // mostrar resumen y calificación
  }
});
```

---

## Tabla resumen de endpoints

| Endpoint | Rol | Auth |
|---|---|---|
| `POST /api/v1/auth/clients/verify-register` | Público | No |
| `POST /api/v1/auth/clients/register` | Público | No |
| `POST /api/v1/auth/clients/login` | Público | No |
| `POST /api/v1/auth/clients/google-login` | Público | No |
| `POST /api/v1/auth/clients/refresh-token` | Público | No |
| `POST /api/v1/auth/clients/logout` | Público | No |
| `POST /api/v1/auth/drivers/login` | Público | No |
| `POST /api/v1/auth/drivers/register` | Público | No |
| `POST /api/v1/profile` | Cliente | X-User-Id |
| `POST /api/v1/profile/update` | Cliente | X-User-Id |
| `POST /api/v1/profile/driver/home` | Conductor | X-User-Id |
| `POST /api/v1/trips/request` | Cliente | X-User-Id |
| `POST /api/v1/trips/get-status` | Cliente | X-User-Id |
| `POST /api/v1/trips/cancel` | Cliente | X-User-Id |
| `POST /api/v1/trips/rate-driver` | Cliente | X-User-Id |
| `POST /api/v1/trips/get-available` | Conductor | X-User-Id |
| `POST /api/v1/trips/accept` | Conductor | X-User-Id |
| `POST /api/v1/trips/start` | Conductor | X-User-Id |
| `POST /api/v1/trips/complete` | Conductor | X-User-Id |
| `POST /api/v1/trips/rate-passenger` | Conductor | X-User-Id |
| `WS /ws/driver/{driverId}/requests` | Conductor | No |
| `WS /ws/trip/{tripId}/status` | Cliente / Conductor | No |

---

## Notas importantes

- **`X-User-Id`** es temporal. Cuando se active la validación JWT, se reemplaza por `Authorization: Bearer <token_access>` y el backend extrae el userId del token automáticamente. El frontend solo necesita cambiar el interceptor, los endpoints no cambian.
- **`photo_url`** siempre es `string`. Si el usuario no tiene foto devuelve `""`, nunca `null`.
- **Errores** siempre están en español en el campo `message`. Mostrar ese campo directamente al usuario es seguro.
- **Paginación** de historiales (`/trips/history`) está pendiente de implementar. Usará `page` y `per_page` en el body.
- **WebSocket reconexión** es responsabilidad del cliente. Implementar reconexión con backoff (el ejemplo usa 3 segundos fijo).
