import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Agrega un header 'X-Idempotency-Key' (UUID v4) a los POST de creacion/oferta
/// de viajes, para que reintentos de red no dupliquen el viaje en el backend
/// real (micro-auronix IdempotencyFilter espera el prefijo 'X-'; T23-C3 — no
/// 'Idempotency-Key' sin prefijo, que el filtro real ignora por completo).
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  static const _idempotentPaths = ['/api/v1/trips'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST' &&
        _idempotentPaths.any(options.path.contains)) {
      options.headers['X-Idempotency-Key'] = _uuid.v4();
    }
    handler.next(options);
  }
}
