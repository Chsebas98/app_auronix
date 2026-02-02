import 'dart:io';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/core/network/interceptors/cache_control_interceptors.dart';
import 'package:auronix_app/app/core/network/interceptors/retry_control_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/features/client/auth/infraestructure/data/remote/strapi_services.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

class DioClient {
  static Dio? _dio;
  static CacheOptions? _cacheOptions;
  static bool _initialized = false;

  /// Obtener instancia configurada de Dio
  static Future<Dio> getInstance({
    bool enableSSLPinning = false,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    AppDatabase? database,
    StrapiServices? strapiServices,
  }) async {
    if (_dio != null && _initialized) return _dio!;

    await _initializeCache();

    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // SSL Pinning (opcional)
    if (enableSSLPinning) {
      await _setupSSLPinning(dio);
    }

    // 1. Cache Interceptor (DEBE IR PRIMERO)
    if (_cacheOptions != null) {
      dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions!));
    }

    // 2. Cache Control Interceptor (controla cache dinámicamente)
    if (_cacheOptions != null) {
      dio.interceptors.add(
        CacheControlInterceptor(defaultCacheOptions: _cacheOptions!),
      );
    }

    if (database != null && strapiServices != null) {
      dio.interceptors.add(
        AuthInterceptor(db: database, strapiServices: strapiServices),
      );
      debugPrint('✅ Auth Interceptor agregado');
    }

    // 3. Retry Control Interceptor (controla retry dinámicamente)
    dio.interceptors.add(
      RetryControlInterceptor(
        dio: dio,
        defaultRetries: 2,
        defaultDelays: [const Duration(seconds: 1), const Duration(seconds: 3)],
      ),
    );

    // 4. Log Interceptor (último para ver todo)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => debugPrint('🌐 Dio: $obj'),
      ),
    );

    _dio = dio;
    _initialized = true;

    debugPrint('✅ DioClient inicializado');
    debugPrint(
      '   📦 Cache: ${_cacheOptions != null ? 'Enabled' : 'Disabled'}',
    );
    debugPrint('   🔄 Retry: Enabled (dinámico)');
    debugPrint(
      '   🔒 SSL Pinning: ${enableSSLPinning ? 'Enabled' : 'Disabled'}',
    );

    return _dio!;
  }

  static Future<void> _initializeCache() async {
    if (_cacheOptions != null) return;

    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheStore = HiveCacheStore(
        cacheDir.path,
        hiveBoxName: 'auronix_app_cache',
      );

      _cacheOptions = CacheOptions(
        store: cacheStore,
        policy: CachePolicy.noCache, // Default: sin cache
        priority: CachePriority.high,
        maxStale: const Duration(days: 7),
        allowPostMethod: true,
        keyBuilder: _smartCacheKeyBuilder,
      );

      debugPrint('✅ Cache inicializado: ${cacheDir.path}');
    } catch (e) {
      debugPrint('❌ Error al inicializar cache: $e');
      _cacheOptions = null;
    }
  }

  static String _smartCacheKeyBuilder({
    Object? body,
    Map<String, String>? headers,
    required Uri url,
  }) {
    final method = 'REQUEST'; // Genérico
    final auth = headers?['Authorization']?.hashCode ?? 0;
    final bodyHash = body?.toString().hashCode ?? 0;

    return '$method|$url|auth=$auth|body=$bodyHash';
  }

  static Future<void> _setupSSLPinning(Dio dio) async {
    try {
      final SecurityContext context = SecurityContext.defaultContext;
      final certData = await rootBundle.load('assets/certificates/cert.pem');
      context.setTrustedCertificatesBytes(certData.buffer.asUint8List());

      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => HttpClient(context: context),
      );

      debugPrint('✅ SSL Pinning configurado');
    } catch (e) {
      debugPrint('⚠️ SSL Pinning no disponible: $e');
    }
  }

  /// Limpiar todo el cache
  static Future<void> clearCache() async {
    try {
      await _cacheOptions?.store?.clean();
      debugPrint('🗑️ Cache limpiado completamente');
    } catch (e) {
      debugPrint('❌ Error al limpiar cache: $e');
    }
  }

  /// Eliminar cache por key específica
  static Future<void> deleteCacheByKey(String key) async {
    try {
      await _cacheOptions?.store?.delete(key);
      debugPrint('🗑️ Cache eliminado para key: $key');
    } catch (e) {
      debugPrint('❌ Error al eliminar cache: $e');
    }
  }

  /// Verificar si existe cache para una key
  static Future<bool> existsInCache(String key) async {
    try {
      final cached = await _cacheOptions?.store?.get(key);
      return cached != null;
    } catch (_) {
      return false;
    }
  }

  /// Exponer CacheOptions para uso externo si es necesario
  static CacheOptions? get cacheOptions => _cacheOptions;
}
