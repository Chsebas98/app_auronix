import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Configuración type-safe para extras de Dio
class RequestExtras {
  // Keys para extras
  static const String useCache = 'useCache';
  static const String useRetry = 'useRetry';
  static const String cacheMaxAge = 'cacheMaxAge';
  static const String cacheKey = 'cacheKey';
  static const String retryCount = 'retryCount';
  static const String retryDelays = 'retryDelays';

  /// Crear extras para request sin cache ni retry (default)
  static Map<String, dynamic> none() => {};

  /// Request con cache
  static Map<String, dynamic> withCache({
    Duration maxAge = const Duration(minutes: 5),
    String? customKey,
  }) {
    return {
      useCache: true,
      cacheMaxAge: maxAge,
      if (customKey != null) cacheKey: customKey,
    };
  }

  /// Request con retry
  static Map<String, dynamic> withRetry({
    int retries = 2,
    List<Duration>? delays,
  }) {
    return {
      useRetry: true,
      retryCount: retries,
      if (delays != null) retryDelays: delays,
    };
  }

  /// Request con cache Y retry
  static Map<String, dynamic> withCacheAndRetry({
    Duration maxAge = const Duration(minutes: 5),
    String? customKey,
    int retries = 2,
    List<Duration>? delays,
  }) {
    return {
      useCache: true,
      cacheMaxAge: maxAge,
      if (customKey != null) cacheKey: customKey,
      useRetry: true,
      retryCount: retries,
      if (delays != null) retryDelays: delays,
    };
  }

  /// Cache de larga duración (para catálogos, configuraciones, etc.)
  static Map<String, dynamic> longCache({
    Duration maxAge = const Duration(hours: 24),
  }) {
    return {useCache: true, cacheMaxAge: maxAge};
  }

  /// Retry agresivo (para operaciones críticas)
  static Map<String, dynamic> aggressiveRetry() {
    return {
      useRetry: true,
      retryCount: 3,
      retryDelays: [
        const Duration(seconds: 1),
        const Duration(seconds: 3),
        const Duration(seconds: 5),
      ],
    };
  }
}

/// Policy para cache dinámico
enum CacheStrategy {
  noCache, // Sin cache
  refresh, // Fuerza refresh desde network
  forceCache, // Usa cache aunque esté expirado
  cacheFirst, // Cache primero, si falla network
  networkFirst, // Network primero, si falla cache
}

extension CacheStrategyExtension on CacheStrategy {
  CachePolicy toCachePolicy() {
    switch (this) {
      case CacheStrategy.noCache:
        return CachePolicy.noCache;
      case CacheStrategy.refresh:
        return CachePolicy.refresh;
      case CacheStrategy.forceCache:
        return CachePolicy.forceCache;
      case CacheStrategy.cacheFirst:
        return CachePolicy.refreshForceCache;
      case CacheStrategy.networkFirst:
        return CachePolicy.request;
    }
  }
}
