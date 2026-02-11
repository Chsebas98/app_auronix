import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor que aplica retry dinámicamente según extras
class RetryControlInterceptor extends Interceptor {
  final Dio dio;
  final int defaultRetries;
  final List<Duration> defaultDelays;

  RetryControlInterceptor({
    required this.dio,
    this.defaultRetries = 2,
    this.defaultDelays = const [Duration(seconds: 1), Duration(seconds: 2)],
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useRetry = options.extra[RequestExtras.useRetry] == true;

    if (useRetry) {
      // Configurar timeouts más cortos para retry
      options.connectTimeout = const Duration(seconds: 30);
      options.receiveTimeout = const Duration(seconds: 30);

      final retries =
          options.extra[RequestExtras.retryCount] as int? ?? defaultRetries;

      debugPrint('🔄 Retry habilitado para: ${options.uri}');
      debugPrint('   🔢 Max retries: $retries');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final useRetry = err.requestOptions.extra[RequestExtras.useRetry] == true;

    if (!useRetry) {
      return handler.next(err);
    }

    final retries =
        err.requestOptions.extra[RequestExtras.retryCount] as int? ??
        defaultRetries;
    final delays =
        err.requestOptions.extra[RequestExtras.retryDelays]
            as List<Duration>? ??
        defaultDelays;

    // Obtener attempt actual
    final attempt = err.requestOptions.extra['retry_attempt'] as int? ?? 0;

    // Evaluar si debe reintentar
    if (!_shouldRetry(err, attempt, retries)) {
      debugPrint('❌ No se reintentará: ${err.requestOptions.uri}');
      debugPrint('   Attempt: $attempt/$retries');
      return handler.next(err);
    }

    // Calcular delay
    final delayIndex = attempt.clamp(0, delays.length - 1);
    final delay = delays[delayIndex];

    debugPrint(
      '🔄 Reintentando request (${attempt + 1}/$retries): ${err.requestOptions.uri}',
    );
    debugPrint('   ⏱️  Delay: ${delay.inSeconds}s');

    await Future.delayed(delay);

    try {
      // Incrementar attempt
      final newOptions = err.requestOptions.copyWith();
      newOptions.extra['retry_attempt'] = attempt + 1;

      // Reintentar request
      final response = await dio.fetch(newOptions);

      debugPrint(
        '✅ Retry exitoso (${attempt + 1}/$retries): ${err.requestOptions.uri}',
      );

      return handler.resolve(response);
    } on DioException catch (e) {
      debugPrint(
        '⚠️ Retry falló (${attempt + 1}/$retries): ${err.requestOptions.uri}',
      );

      // Seguir con el error (será capturado de nuevo por este interceptor)
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int attempt, int maxRetries) {
    // No reintentar si ya se alcanzó el máximo
    if (attempt >= maxRetries) return false;

    // No reintentar si fue cancelado o certificado inválido
    if (err.type == DioExceptionType.cancel ||
        err.type == DioExceptionType.badCertificate) {
      return false;
    }

    // Reintentar solo en errores de red o server 5xx
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null) {
        return statusCode >= 500 || statusCode == 408 || statusCode == 429;
      }
      return false;
    }

    // Reintentar en timeouts y errores de conexión
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
