sealed class Failure {
  final String message;
  final String? detail;
  final int? statusCode;

  const Failure({required this.message, this.detail, this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.detail, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.detail});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.detail});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.detail, super.statusCode});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.detail});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.detail});
}

/// Conflicto de idempotencia (HTTP 409): un reintento de red duplico una
/// peticion con el mismo Idempotency-Key (ver IdempotencyInterceptor, T6).
class IdempotencyConflictFailure extends Failure {
  const IdempotencyConflictFailure({required super.message, super.detail})
    : super(statusCode: 409);
}

/// No existe una ruta transitable entre origen y destino (T18): Google
/// Directions responde HTTP 200 con status ZERO_RESULTS/NOT_FOUND, no un
/// error HTTP — se distingue de un ServerFailure generico para que la UI
/// pueda mostrar "sin ruta disponible" en vez de un error tecnico.
class RouteNotFoundFailure extends Failure {
  const RouteNotFoundFailure({
    super.message = 'No se encontró una ruta entre los puntos indicados.',
    super.detail,
  });
}
