import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:dartz/dartz.dart';

abstract class GeoRepository {
  Future<Either<Failure, List<AddressSuggestion>>> autocomplete({
    required String query,
    double? lat,
    double? lng,
  });

  Future<Either<Failure, String>> reverseGeocode({
    required double lat,
    required double lng,
  });
}
