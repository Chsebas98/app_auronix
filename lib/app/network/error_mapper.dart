import 'package:auronix_app/core/errors/failure.dart';
import 'package:dio/dio.dart';

/// Traduce un [DioException] a un [Failure] tipado con un mensaje amigable,
/// sin exponer trazas internas (headers, body de la peticion, stack trace)
/// que [DioException.toString] no incluye pero el [Response.data] crudo si
/// podria traer si se reenviara sin filtrar.
class ErrorMapper {
  const ErrorMapper._();

  static Failure fromDioException(DioException exception) {
    final response = exception.response;
    if (response == null) {
      return _fromConnectionError(exception);
    }

    final statusCode = response.statusCode ?? 0;
    final serverMessage = _extractServerMessage(response.data);

    if (statusCode == 401) {
      return AuthFailure(
        message: serverMessage ?? 'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 409) {
      return IdempotencyConflictFailure(
        message:
            serverMessage ??
            'Esa solicitud ya se está procesando, espera un momento antes de reintentar.',
      );
    }

    if (statusCode >= 500) {
      return ServerFailure(
        message:
            serverMessage ??
            'Ocurrió un error en el servidor. Intenta de nuevo.',
        detail: 'HTTP $statusCode',
        statusCode: statusCode,
      );
    }

    return ServerFailure(
      message: serverMessage ?? 'No se pudo completar la solicitud.',
      detail: 'HTTP $statusCode',
      statusCode: statusCode,
    );
  }

  static Failure _fromConnectionError(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message:
              'No hay conexión a internet. Revisa tu red e intenta de nuevo.',
        );
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'La solicitud fue cancelada.');
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'No se pudo verificar la conexión segura con el servidor.',
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return UnexpectedFailure(
          message: 'Ocurrió un error inesperado. Intenta de nuevo.',
          detail: exception.type.name,
        );
    }
  }

  /// El backend responde errores como `{"message": "..."}` (ver
  /// auth_repository_impl.dart); si el body no trae ese formato, no hay
  /// mensaje confiable que mostrar y se usa el generico de cada caso.
  static String? _extractServerMessage(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
