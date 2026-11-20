import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/domain/entities/place_details.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:dartz/dartz.dart';

abstract class PlacesRepository {
  Future<Either<Failure, List<PlacePrediction>>> searchPredictions(
    String query,
  );

  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId);
}
