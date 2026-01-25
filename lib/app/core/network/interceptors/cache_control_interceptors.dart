import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Interceptor que controla cache dinámicamente según extras
class CacheControlInterceptor extends Interceptor {
  final CacheOptions defaultCacheOptions;

  CacheControlInterceptor({required this.defaultCacheOptions});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useCache = options.extra[RequestExtras.useCache] == true;

    if (!useCache) {
      // Sin cache: forzar noCache
      final noCacheOptions = defaultCacheOptions.copyWith(
        policy: CachePolicy.noCache,
      );

      options.extra.addAll(noCacheOptions.toExtra());

      debugPrint('🚫 Cache deshabilitado para: ${options.uri}');
      return handler.next(options);
    }

    // CON CACHE: aplicar configuración
    final maxAge =
        options.extra[RequestExtras.cacheMaxAge] as Duration? ??
        const Duration(minutes: 5);

    final customKey = options.extra[RequestExtras.cacheKey] as String?;

    // Configurar cache options personalizados
    final cacheOptions = defaultCacheOptions.copyWith(
      policy: CachePolicy.request, // Request first, then cache
      maxStale: maxAge,
      keyBuilder: customKey != null
          ? ({body, headers, required url}) => customKey
          : defaultCacheOptions.keyBuilder,
    );

    // Inyectar cache options en el request
    options.extra.addAll(cacheOptions.toExtra());

    debugPrint('✅ Cache habilitado para: ${options.uri}');
    debugPrint('   ⏱️  MaxAge: ${maxAge.inMinutes}min');
    if (customKey != null) {
      debugPrint('   🔑 CustomKey: $customKey');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final useCache =
        response.requestOptions.extra[RequestExtras.useCache] == true;

    if (useCache && kDebugMode) {
      // ✅ Acceso directo a extras con keys de dio_cache_interceptor
      // Keys comunes: 'dio_cache_from_network', 'dio_cache_key', etc.

      // Intentar obtener info del cache si existe
      final extras = response.extra;
      final fromNetwork = extras['dio_cache_from_network'];
      final cacheKey = extras['dio_cache_key'];

      debugPrint('📦 Cache response para: ${response.requestOptions.uri}');

      if (fromNetwork != null) {
        debugPrint('   🌐 From network: $fromNetwork');
        debugPrint('   💾 From cache: ${!fromNetwork}');
      }

      if (cacheKey != null) {
        debugPrint('   🔑 Cache key: $cacheKey');
      }

      // Si no hay info de cache, simplemente continuar
      if (fromNetwork == null && cacheKey == null) {
        debugPrint('   ℹ️  Response sin metadata de cache');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final useCache = err.requestOptions.extra[RequestExtras.useCache] == true;

    if (useCache && kDebugMode) {
      debugPrint('❌ Error en request con cache: ${err.requestOptions.uri}');
      debugPrint('   Error: ${err.message}');
    }

    handler.next(err);
  }
}
