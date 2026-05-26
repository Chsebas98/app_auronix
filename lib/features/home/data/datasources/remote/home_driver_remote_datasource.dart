import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/home/data/models/driver_home_model.dart';
import 'package:dio/dio.dart';

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
}
