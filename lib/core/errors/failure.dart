sealed class Failure {
  final String message;
  final String? detail;
  final int? statusCode;

  const Failure({required this.message, this.detail, this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.detail,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.detail});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.detail});
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.detail,
    super.statusCode,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.detail});
}
