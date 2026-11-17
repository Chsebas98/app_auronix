import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/data/datasources/remote/home_driver_remote_datasource.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/driver_home_data.dart';
import 'package:auronix_app/features/home/domain/repository/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDriverRemoteDatasource _remote;

  HomeRepositoryImpl({required HomeDriverRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<Either<Failure, DriverHomeData>> getDriverHome(int userId) async {
    try {
      final model = await _remote.getDriverHome(userId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final body = e.response!.data as Map<String, dynamic>;
        return Left(ServerFailure(
          message: body['message'] as String? ?? 'Error al cargar datos',
          statusCode: e.response?.statusCode,
        ));
      }
      return Left(NetworkFailure(message: e.message ?? 'Error de red'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
