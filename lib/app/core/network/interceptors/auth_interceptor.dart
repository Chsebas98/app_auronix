import 'dart:async';

import 'package:auronix_app/app/core/services/secure_storage_service.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthInterceptor extends Interceptor {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final AuthRemoteDatasource _authRemote;
  final Dio _dio;

  bool _isRefreshing = false;

  final List<Completer<String>> _refreshQueue = [];

  AuthInterceptor({
    required AppDatabase db,
    required SecureStorageService secureStorage,
    required AuthRemoteDatasource authRemote,
    required Dio dio,
  }) : _db = db,
       _secureStorage = secureStorage,
       _authRemote = authRemote,
       _dio = dio;

  // ── onRequest ────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicRoute(options.path)) return handler.next(options);

    var accessToken = await _secureStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      final shouldRefresh = _shouldRefreshProactively(accessToken);

      if (shouldRefresh) {
        final refreshed = await _proactiveRefresh();
        if (refreshed != null) accessToken = refreshed;
      }

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

    if (_isRefreshing) {
      debugPrint('Refresh en progreso, encolando...');
      final completer = Completer<String>();
      _refreshQueue.add(completer);

      try {
        final newToken = await completer.future;
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(retryOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      final userType = await _secureStorage.getUserType();

      if (refreshToken == null || refreshToken.isEmpty || userType == null) {
        debugPrint('Sin refresh token — limpiando sesión');
        _resolveQueue(null);
        await _clearSession(userType);
        return handler.next(err);
      }

      final response = userType == DbConstants.userTypeClient
          ? await _authRemote.refreshClientToken(refreshToken)
          : await _authRemote.refreshDriverToken(refreshToken);

      if (!response['response']) {
        debugPrint('Refresh falló: ${response['message']}');
        _resolveQueue(null);
        await _clearSession(userType);
        return handler.next(err);
      }

      final result = response['result'] as Map<String, dynamic>;
      final newAccessToken = result['token_access'] as String;
      final newRefreshToken = result['token_refresh'] as String;

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        userType: userType,
      );

      debugPrint('Tokens refrescados');

      _resolveQueue(newAccessToken);

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('Error en refresh: $e');
      _resolveQueue(null);
      final userType = await _secureStorage.getUserType();
      await _clearSession(userType);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  bool _shouldRefreshProactively(String accessToken) {
    try {
      final payload = JwtDecoder.decode(accessToken);
      final exp = payload['exp'];
      if (exp == null) return false;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (exp as int) * 1000,
      );
      return expiresAt.difference(DateTime.now()).inSeconds < 60;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _proactiveRefresh() async {
    if (_isRefreshing) return null;
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      final userType = await _secureStorage.getUserType();

      if (refreshToken == null || refreshToken.isEmpty || userType == null) {
        return null;
      }

      final response = userType == DbConstants.userTypeClient
          ? await _authRemote.refreshClientToken(refreshToken)
          : await _authRemote.refreshDriverToken(refreshToken);

      if (!response['response']) return null;

      final result = response['result'] as Map<String, dynamic>;
      final newAccessToken = result['token_access'] as String;
      final newRefreshToken = result['token_refresh'] as String;

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        userType: userType,
      );

      debugPrint('Tokens refrescados proactivamente');
      return newAccessToken;
    } catch (e) {
      debugPrint('Error en refresh proactivo: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearSession(String? userType) async {
    await _secureStorage.clearTokens();
    if (userType != null) await _db.clearUser(userType);
  }

  void _resolveQueue(String? newToken) {
    for (final completer in _refreshQueue) {
      if (newToken != null) {
        completer.complete(newToken);
      } else {
        completer.completeError('Refresh failed');
      }
    }
    _refreshQueue.clear();
  }

  bool _isPublicRoute(String path) {
    const publicRoutes = [
      '/auth/clients/login',
      '/auth/clients/register',
      '/auth/clients/google-login',
      '/auth/clients/register/send-otp',
      '/auth/clients/register/verify-otp',
      '/auth/clients/refresh-token',
      '/auth/drivers/login',
      '/auth/drivers/register',
      '/auth/drivers/refresh-token',
      '/auth/logout',
    ];
    return publicRoutes.any(path.contains);
  }
}
