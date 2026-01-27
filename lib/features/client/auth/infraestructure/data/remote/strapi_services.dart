import 'package:auronix_app/app/core/network/extensions/dio_extensions.dart';
import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class StrapiServices {
  static String _baseUrl = Environment().config!.apiBaseUrl;

  final Dio _dio;

  StrapiServices({required Dio dio}) : _dio = dio;

  /// Buscar usuario por email (CON CACHE + RETRY)
  Future<StrapiUserResponse?> findUserByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);

      debugPrint('🔍 Buscando usuario: $email');

      debugPrint(
        'Peticion que mando : ${'$_baseUrl/tb-clients?filters[email][\$eq]=$encodedEmail&populate=role'}',
      );
      final response = await _dio.get(
        '$_baseUrl/tb-clients',
        queryParameters: {
          'filters[email][\$eq]': encodedEmail,
          'populate': 'role',
        },
        options: Options(
          extra: RequestExtras.withCacheAndRetry(
            maxAge: const Duration(minutes: 5), // Cache 5min
            retries: 2,
          ),
        ),
      );
      final users = response.data['data'] as List;

      if (users.isNotEmpty) {
        debugPrint('✅ Usuario encontrado');
        return StrapiUserResponse.fromJson(users.first);
      }

      debugPrint('ℹ️ Usuario no existe');
      return null;
    } catch (e) {
      debugPrint('❌ Error en findUserByEmail: $e');
      rethrow;
    }
  }

  /// Listar catálogos (CACHE DE LARGA DURACIÓN, sin retry necesario)
  Future<List<StrapiRole>> getCatalogos() async {
    try {
      debugPrint('📚 Obteniendo catálogos');

      final response = await _dio.get(
        '$_baseUrl/tb-catalogos',
        options: Options(
          extra: RequestExtras.longCache(
            maxAge: const Duration(hours: 24), // Cache 24h
          ),
        ),
      );

      final catalogos = (response.data['data'] as List)
          .map((e) => StrapiRole.fromJson(e))
          .toList();

      debugPrint('✅ ${catalogos.length} catálogos obtenidos');

      return catalogos;
    } catch (e) {
      debugPrint('❌ Error en getCatalogos: $e');
      rethrow;
    }
  }

  /// Crear usuario (CON RETRY AGRESIVO, sin cache)
  Future<StrapiUserResponse> createUser({
    required String email,
    required String username,
    required String nombre1,
    String? nombre2,
    String? ape1,
    String? ape2,
    String? photoUrl,
    String? tokenAccess,
    int roleId = 2,
  }) async {
    try {
      debugPrint('🆕 Creando usuario: $email');

      final response = await _dio.post(
        '$_baseUrl/tb-clients',
        data: {
          'data': {
            'email': email,
            'username': username,
            'nombre1': nombre1,
            'nombre2': nombre2,
            'ape1': ape1,
            'ape2': ape2,
            'photo_url': photoUrl,
            'token_access': tokenAccess,
            'role': roleId,
            'inicio_google': true,
            'estado_user': true,
            'bloqueado': false,
          },
        },
        options: Options(
          extra: RequestExtras.aggressiveRetry(), // Retry 3 veces
        ),
      );

      debugPrint('✅ Usuario creado exitosamente');

      return StrapiUserResponse.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('❌ Error en createUser: $e');
      rethrow;
    }
  }

  /// Actualizar usuario (CON RETRY, sin cache)
  Future<StrapiUserResponse> updateUser({
    required String documentId,
    bool? inicioGoogle,
    String? tokenAccess,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('🔄 Actualizando usuario: $documentId');

      final dataToUpdate = <String, dynamic>{};
      if (inicioGoogle != null) dataToUpdate['inicio_google'] = inicioGoogle;
      if (tokenAccess != null) dataToUpdate['token_access'] = tokenAccess;
      if (photoUrl != null) dataToUpdate['photo_url'] = photoUrl;
      if (additionalData != null) dataToUpdate.addAll(additionalData);

      final response = await _dio.put(
        '$_baseUrl/tb-clients/$documentId',
        data: {'data': dataToUpdate},
        options: Options(extra: RequestExtras.withRetry(retries: 2)),
      );

      debugPrint('✅ Usuario actualizado');

      return StrapiUserResponse.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('❌ Error en updateUser: $e');
      rethrow;
    }
  }

  /// Ejemplo: Request sin cache ni retry (default)
  Future<Map<String, dynamic>> someOtherEndpoint() async {
    final response = await _dio.get(
      '$_baseUrl/some-endpoint',
      options: Options(
        extra: RequestExtras.none(), // Sin cache ni retry
      ),
    );

    return response.data;
  }

  /// Ejemplo usando extensions
  Future<StrapiUserResponse?> findUserByEmailWithExtension(String email) async {
    final response = await _dio.getWithExtras(
      '$_baseUrl/tb-clients',
      queryParameters: {
        'filters[email][\$eq]': Uri.encodeComponent(email),
        'populate': 'role',
      },
      useCache: true,
      useRetry: true,
      cacheMaxAge: const Duration(minutes: 5),
      retryCount: 2,
    );

    final users = response.data['data'] as List;
    return users.isNotEmpty ? StrapiUserResponse.fromJson(users.first) : null;
  }
}
