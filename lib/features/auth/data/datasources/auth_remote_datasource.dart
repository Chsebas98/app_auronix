import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Unified remote datasource for all authentication operations
/// (client and driver).
class AuthRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  Map<String, dynamic> _handleDioException(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      return {
        'response': false,
        'statusCode': e.response?.statusCode ?? 0,
        'message': data['message'] ?? 'Error de conexión',
        'errorDetail': data['errorDetail'] ?? e.message ?? 'Error desconocido',
      };
    }
    return {
      'response': false,
      'statusCode': e.response?.statusCode ?? 0,
      'message': 'Error de conexión',
      'errorDetail': e.message ?? 'No se pudo conectar al servidor',
    };
  }

  // ──────────────────── CLIENT ────────────────────

  Future<Map<String, dynamic>> loginClient({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'password': password},
      );
      debugPrint('loginClient exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> googleLogin(
    AuthenticationCredentials creds,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/google-login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'email': creds.email,
          'googleToken': creds.tokenAccess,
          'nombre1': creds.firstName,
          'ape1': creds.lastName,
        },
      );
      debugPrint('googleLogin exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// `POST /auth/clients/register/send-otp` (docs/requerimientos_backend.md
  /// sección 2.1): envía un código de 6 dígitos al email, expira en 10 min,
  /// reenviable con cooldown de 60s.
  Future<Map<String, dynamic>> sendRegisterOtp({required String email}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/register/send-otp',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email},
      );
      debugPrint('sendRegisterOtp exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// `POST /auth/clients/register/verify-otp`. **Nombre de clave del código
  /// sin confirmar por backend** — se usa `codigo`, ver
  /// docs/requerimientos_backend.md sección 9.
  Future<Map<String, dynamic>> verifyRegisterOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/register/verify-otp',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'codigo': code},
      );
      debugPrint('verifyRegisterOtp exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> registerClient(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: data,
      );
      debugPrint('registerClient exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> refreshClientToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/refresh-token',
        options: Options(contentType: 'application/json'),
        data: {'token_refresh': refreshToken},
      );
      debugPrint('refreshClientToken exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> closeSessionLogout(
    String email,
    String mnemonic,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/logout',
        options: Options(contentType: 'application/json'),
        data: {'email': email, 'role': mnemonic},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  // ──────────────────── DRIVER ────────────────────

  Future<Map<String, dynamic>> loginDriver({
    required String ciPassport,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'ci_passport': ciPassport, 'password': password},
      );
      debugPrint('loginDriver exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// Campos de licencia/vehículo/T&C/fecha de nacimiento enviados como
  /// `snake_case` para seguir el estilo ya establecido de este endpoint
  /// (`ci_passport`) — nombres exactos sin confirmar por backend, ver
  /// docs/requerimientos_backend.md sección 9.
  Future<Map<String, dynamic>> registerDriver({
    required String ciPassport,
    required String password,
    required String email,
    String? licenseNumber,
    String? licenseType,
    String? plateNumber,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
    DateTime? birthDate,
    String? terminosVersion,
    DateTime? terminosAceptadosEn,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'ci_passport': ciPassport,
          'password': password,
          'email': email,
          if (licenseNumber != null) 'numero_licencia': licenseNumber,
          if (licenseType != null) 'tipo_licencia': licenseType,
          if (plateNumber != null) 'placa': plateNumber,
          if (vehicleBrand != null) 'marca_vehiculo': vehicleBrand,
          if (vehicleModel != null) 'modelo_vehiculo': vehicleModel,
          if (vehicleYear != null) 'anio_vehiculo': vehicleYear,
          if (birthDate != null)
            'fecha_nacimiento': birthDate.toIso8601String(),
          if (terminosVersion != null) 'terminos_version': terminosVersion,
          if (terminosAceptadosEn != null)
            'terminos_aceptados_en': terminosAceptadosEn.toIso8601String(),
        },
      );
      debugPrint('registerDriver exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> refreshDriverToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/refresh-token',
        options: Options(contentType: 'application/json'),
        data: {'token_refresh': refreshToken},
      );
      debugPrint('refreshDriverToken exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  // ──────────────────── CUENTA (compartido) ────────────────────

  /// `DELETE /users/me` (docs/requerimientos_backend.md sección 2.3).
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/users/me',
        options: Options(contentType: 'application/json'),
      );
      debugPrint('deleteAccount exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// `PATCH /users/me/email` — requiere re-verificación por OTP del lado
  /// backend antes de aplicar el cambio (docs/requerimientos_backend.md
  /// sección 2.3); el mecanismo exacto no está detallado — ver sección 9.
  Future<Map<String, dynamic>> changeEmail({required String newEmail}) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/users/me/email',
        options: Options(contentType: 'application/json'),
        data: {'email': newEmail},
      );
      debugPrint('changeEmail exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// `PATCH /users/me/phone` — misma nota de re-verificación que [changeEmail].
  Future<Map<String, dynamic>> changePhone({required String newPhone}) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/users/me/phone',
        options: Options(contentType: 'application/json'),
        data: {'telefono': newPhone},
      );
      debugPrint('changePhone exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}
