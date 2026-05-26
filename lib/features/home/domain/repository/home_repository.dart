import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/driver_home_data.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<Failure, DriverHomeData>> getDriverHome(int userId);
}
