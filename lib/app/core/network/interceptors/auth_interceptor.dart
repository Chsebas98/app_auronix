import 'dart:async';

import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  final AppDatabase _db;
  final AuthRemoteDatasource _authRemote;
  final Dio _dio;

  bool _isRefreshing = false;

  // Completer por request — cada uno espera su resolución
  final List<Completer<String>> _refreshQueue = [];

  AuthInterceptor({
    required AppDatabase db,
    required AuthRemoteDatasource authRemote,
    required Dio dio,
  }) : _db = db,
       _authRemote = authRemote,
       _dio = dio;

  // ── onRequest ────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicRoute(options.path)) return handler.next(options);

    final activeUser = await _db.getActiveUserMap();
    final accessToken = activeUser?[DbConstants.colTokenAccess] as String?;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  // ── onError ──────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    debugPrint('401 en: ${err.requestOptions.path}');

    //Si ya hay un refresh en curso — encolar con Completer y esperar
    if (_isRefreshing) {
      debugPrint('⏳ Refresh en progreso, encolando...');
      final completer = Completer<String>();
      _refreshQueue.add(completer);

      try {
        // Esperar a que el refresh termine y recibir el nuevo token
        final newToken = await completer.future;
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(retryOptions); // usa _dio configurado
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // ── Ejecutar refresh ─────────────────────────────────────────

    _isRefreshing = true;

    try {
      final activeUser = await _db.getActiveUserMap();
      final userType = activeUser?[DbConstants.colUserType] as String?;
      final refreshToken = activeUser?[DbConstants.colTokenRefresh] as String?;

      if (refreshToken == null || refreshToken.isEmpty || userType == null) {
        debugPrint('Sin refresh token — limpiando sesión');
        _resolveQueue(null); // notificar a encolados que falló
        if (userType != null) await _db.clearUser(userType);
        return handler.next(err);
      }

      // Llamar al endpoint de refresh según userType
      final response = userType == DbConstants.userTypeClient
          ? await _authRemote.refreshClientToken(refreshToken)
          : await _authRemote.refreshDriverToken(refreshToken);

      if (!response['response']) {
        debugPrint('Refresh falló: ${response['message']}');
        _resolveQueue(null);
        await _db.clearUser(userType);
        return handler.next(err);
      }

      final result = response['result'] as Map<String, dynamic>;
      final newAccessToken = result['token_access'] as String;
      final newRefreshToken = result['token_refresh'] as String;

      await _db.updateTokens(
        tokenAccess: newAccessToken,
        tokenRefresh: newRefreshToken,
        userType: userType,
      );

      debugPrint('Tokens refrescados');

      // Notificar a todos los encolados con el nuevo token
      _resolveQueue(newAccessToken);

      // Reintentar el request original
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(
        retryOptions,
      ); // usa _dio configurado
      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('Error en refresh: $e');
      _resolveQueue(null);
      final activeUser = await _db.getActiveUserMap();
      final userType = activeUser?[DbConstants.colUserType] as String?;
      if (userType != null) await _db.clearUser(userType);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Resuelve o rechaza todos los Completers encolados
  void _resolveQueue(String? newToken) {
    for (final completer in _refreshQueue) {
      if (newToken != null) {
        completer.complete(newToken); // éxito → reciben el token
      } else {
        completer.completeError('Refresh failed'); // fallo → se manejan
      }
    }
    _refreshQueue.clear();
  }

  bool _isPublicRoute(String path) {
    const publicRoutes = [
      '/auth/clients/login',
      '/auth/clients/register',
      '/auth/clients/google-login',
      '/auth/clients/verify-register',
      '/auth/clients/refresh-token',
      '/auth/drivers/login',
      '/auth/drivers/register',
      '/auth/drivers/refresh-token',
      '/auth/logout',
    ];
    return publicRoutes.any(path.contains);
  }
}
