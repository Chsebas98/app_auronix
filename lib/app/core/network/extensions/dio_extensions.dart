import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:dio/dio.dart';

/// Extensions para facilitar uso de cache y retry
extension DioRequestExtensions on Dio {
  /// GET con control de cache y retry
  Future<Response<T>> getWithExtras<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool useCache = false,
    bool useRetry = false,
    Duration? cacheMaxAge,
    int? retryCount,
  }) {
    final extras = <String, dynamic>{};

    if (useCache) {
      extras[RequestExtras.useCache] = true;
      if (cacheMaxAge != null) extras[RequestExtras.cacheMaxAge] = cacheMaxAge;
    }

    if (useRetry) {
      extras[RequestExtras.useRetry] = true;
      if (retryCount != null) extras[RequestExtras.retryCount] = retryCount;
    }

    return get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {...extras, ...?options?.extra},
      ),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST con control de cache y retry
  Future<Response<T>> postWithExtras<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useCache = false,
    bool useRetry = false,
    Duration? cacheMaxAge,
    int? retryCount,
  }) {
    final extras = <String, dynamic>{};

    if (useCache) {
      extras[RequestExtras.useCache] = true;
      if (cacheMaxAge != null) extras[RequestExtras.cacheMaxAge] = cacheMaxAge;
    }

    if (useRetry) {
      extras[RequestExtras.useRetry] = true;
      if (retryCount != null) extras[RequestExtras.retryCount] = retryCount;
    }

    return post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {...extras, ...?options?.extra},
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT con control de cache y retry
  Future<Response<T>> putWithExtras<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useCache = false,
    bool useRetry = false,
    int? retryCount,
  }) {
    final extras = <String, dynamic>{};

    if (useCache) extras[RequestExtras.useCache] = true;
    if (useRetry) {
      extras[RequestExtras.useRetry] = true;
      if (retryCount != null) extras[RequestExtras.retryCount] = retryCount;
    }

    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {...extras, ...?options?.extra},
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE con retry (normalmente sin cache)
  Future<Response<T>> deleteWithExtras<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useRetry = false,
    int? retryCount,
  }) {
    final extras = <String, dynamic>{};

    if (useRetry) {
      extras[RequestExtras.useRetry] = true;
      if (retryCount != null) extras[RequestExtras.retryCount] = retryCount;
    }

    return delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {...extras, ...?options?.extra},
      ),
      cancelToken: cancelToken,
    );
  }
}
