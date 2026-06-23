import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/home/data/models/driver_home_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HomeDriverRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  HomeDriverRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<DriverHomeModel> getDriverHome(int userId) async {
    final response = await _dio.post(
      '$_baseUrl/profile/driver/home',
      options: Options(
        contentType: 'application/json',
        headers: {'X-User-Id': userId},
      ),
      data: {},
    );
    final body = response.data as Map<String, dynamic>;
    return DriverHomeModel.fromJson(body['result'] as Map<String, dynamic>);
  }

  Future<bool> setAvailability(bool disponible) async {
    debugPrint('[DriverHome] setAvailability: $disponible');
    final response = await _dio.post(
      '$_baseUrl/profile/driver/availability',
      options: Options(contentType: 'application/json'),
      data: {'disponible': disponible},
    );
    final body = response.data as Map<String, dynamic>;
    return body['response'] as bool? ?? false;
  }
}
