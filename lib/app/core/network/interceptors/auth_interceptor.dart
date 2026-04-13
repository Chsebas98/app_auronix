import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/features/client/auth/data/remote/authentication_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor para manejo automático de autenticación y refresh de tokens
class AuthInterceptor extends Interceptor {
  final AppDatabase _db;
  final AuthenticationService _authenticationService;
  bool _isRefreshing = false;
  final List<RequestOptions> _requestsQueue = [];

  AuthInterceptor({
    required AppDatabase db,
    required AuthenticationService authenticationService,
  }) : _db = db,
       _authenticationService = authenticationService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Excluir rutas que no necesitan autenticación
    if (_isPublicRoute(options.path)) {
      debugPrint('🌍 Ruta pública: ${options.path}');
      return handler.next(options);
    }

    // Obtener access token
    final accessToken = await _db.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('⚠️ No hay access token, request sin auth');
      return handler.next(options);
    }

    // Agregar Authorization header
    options.headers['Authorization'] = 'Bearer $accessToken';
    debugPrint('🔑 Authorization header agregado');

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Solo manejar 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    debugPrint('🔴 401 Unauthorized detectado en: ${err.requestOptions.path}');

    // Si ya estamos refrescando, encolar request
    if (_isRefreshing) {
      debugPrint('⏳ Refresh en progreso, encolando request...');
      _requestsQueue.add(err.requestOptions);
      return;
    }

    try {
      _isRefreshing = true;
      debugPrint('🔄 Iniciando refresh de tokens...');

      // Obtener refresh token
      final refreshToken = await _db.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No hay refresh token, cerrando sesión');
        await _db.clearUser();
        return handler.next(err);
      }

      // Llamar a refresh endpoint
      final response = await _authenticationService.refreshToken(refreshToken);

      if (!response['response']) {
        debugPrint('❌ Refresh falló: ${response['message']}');
        await _db.clearUser();
        return handler.next(err);
      }

      // Extraer nuevos tokens
      final result = response['result'] as Map<String, dynamic>;
      final newAccessToken = result['token_access'] as String;
      final newRefreshToken = result['token_refresh'] as String;

      debugPrint('✅ Tokens refrescados exitosamente');

      // Guardar nuevos tokens
      await _db.updateTokens(
        tokenAccess: newAccessToken,
        tokenRefresh: newRefreshToken,
      );

      // Reintentar request original con nuevo token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      debugPrint('🔄 Reintentando request original...');
      final retryResponse = await Dio().fetch(retryOptions);

      debugPrint('✅ Request original exitoso después de refresh');

      // Procesar cola de requests
      if (_requestsQueue.isNotEmpty) {
        debugPrint(
          '📦 Procesando ${_requestsQueue.length} requests encolados...',
        );

        for (final queuedRequest in _requestsQueue) {
          queuedRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            await Dio().fetch(queuedRequest);
          } catch (e) {
            debugPrint('⚠️ Error en request encolado: $e');
          }
        }

        _requestsQueue.clear();
      }

      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('❌ Error durante refresh: $e');
      await _db.clearUser();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Rutas que NO requieren autenticación
  bool _isPublicRoute(String path) {
    final publicRoutes = [
      // Client auth
      '/auth/clients/login',
      '/auth/clients/register',
      '/auth/clients/google-login',
      '/auth/clients/verify-register',
      '/auth/clients/refresh-token',
      // Driver auth
      '/auth/drivers/login',
      '/auth/drivers/register',
      '/auth/drivers/refresh-token',
      // Shared logout
      '/auth/logout',
    ];

    return publicRoutes.any((route) => path.contains(route));
  }
}
