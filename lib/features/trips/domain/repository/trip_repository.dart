import 'package:dartz/dartz.dart';

abstract class TripRepository {
  Future<Either> getTrips();
}
