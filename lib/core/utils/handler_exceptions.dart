import 'package:auronix_app/core/core.dart';

class ErrorServiceException implements Exception {
  final String message;
  final String? errorDetail;
  final int? statusCode;

  const ErrorServiceException({
    required this.message,
    this.errorDetail,
    this.statusCode,
  });

  @override
  String toString() => 'ErrorServiceException: $message $errorDetail}';

  /// Crea excepción desde ServiceResponse
  factory ErrorServiceException.fromResponse(ServiceResponse response) {
    return ErrorServiceException(
      message: response.message,
      errorDetail: response.errorDetail,
      statusCode: response.statusCode,
    );
  }
}
