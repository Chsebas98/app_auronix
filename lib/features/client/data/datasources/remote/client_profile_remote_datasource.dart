import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/data/models/profile_update_request_model.dart';
import 'package:dio/dio.dart';

class ClientProfileRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  ClientProfileRemoteDatasource({required Dio dio}) : _dio = dio;

  Options _headers(int userId) => Options(
        contentType: 'application/json',
        headers: {'X-User-Id': userId},
      );

  Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await _dio.post(
      '$_baseUrl/profile',
      options: _headers(userId),
      data: {},
    );
    final body = response.data as Map<String, dynamic>;
    return body['result'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required ProfileUpdateRequestModel data,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/profile/update',
      options: _headers(userId),
      data: data.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    return body['result'] as Map<String, dynamic>;
  }
}
