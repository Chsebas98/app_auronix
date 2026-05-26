import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/driver_home_data.dart';
import 'package:auronix_app/features/home/domain/repository/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetDriverHomeUseCase {
  final HomeRepository _repo;

  GetDriverHomeUseCase(this._repo);

  Future<Either<Failure, DriverHomeData>> call(int userId) =>
      _repo.getDriverHome(userId);
}
