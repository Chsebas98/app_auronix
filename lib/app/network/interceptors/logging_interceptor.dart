import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor de logs que enmascara headers de autorización y campos
/// sensibles (contraseñas, tokens) antes de imprimir cualquier request,
/// response o error — el [LogInterceptor] de dio por defecto los vuelca
/// sin filtrar, y con `requestBody: true`/`responseBody: true` eso incluye
/// la contraseña de un login o los tokens de una respuesta de refresh.
class LoggingInterceptor extends Interceptor {
  static const _maskedHeaderKeys = {'authorization', 'cookie', 'set-cookie'};

  static const _maskedBodyKeys = {
    'password',
    'contrasena',
    'contraseña',
    'token',
    'token_access',
    'token_refresh',
    'access_token',
    'refresh_token',
    'idempotency-key',
  };

  static const _mask = '***';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      'Dio: --> ${options.method} ${options.uri}\n'
      'Headers: ${_sanitizeHeaders(options.headers)}\n'
      'Body: ${_sanitizeBody(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'Dio: <-- ${response.statusCode} ${response.requestOptions.uri}\n'
      'Body: ${_sanitizeBody(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'Dio: <-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}\n'
      'Body: ${_sanitizeBody(err.response?.data)}',
    );
    handler.next(err);
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map(
      (key, value) => MapEntry(
        key,
        _maskedHeaderKeys.contains(key.toLowerCase()) ? _mask : value,
      ),
    );
  }

  static dynamic _sanitizeBody(dynamic data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key,
          _maskedBodyKeys.contains(key.toString().toLowerCase())
              ? _mask
              : _sanitizeBody(value),
        ),
      );
    }
    if (data is List) {
      return data.map(_sanitizeBody).toList();
    }
    return data;
  }
}
