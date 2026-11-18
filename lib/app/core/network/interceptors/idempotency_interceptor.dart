import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Agrega un header 'Idempotency-Key' (UUID v4) a los POST de creacion/oferta
/// de viajes, para que reintentos de red no dupliquen el viaje en el backend
/// (el backend de Ando ya valida este header — ver tarea T54 del backend).
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  static const _idempotentPaths = ['/api/v1/trips'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST' &&
        _idempotentPaths.any(options.path.contains)) {
      options.headers['Idempotency-Key'] = _uuid.v4();
    }
    handler.next(options);
  }
}
