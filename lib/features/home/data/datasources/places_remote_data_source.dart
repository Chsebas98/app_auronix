import 'package:auronix_app/features/home/data/models/place_details_dto.dart';
import 'package:auronix_app/features/home/data/models/place_prediction_dto.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';

/// Adapta el PlacesService existente (T17: no crear un datasource paralelo)
/// a traves de sus metodos *Raw, que a diferencia de autocomplete()/
/// getDetails() no capturan errores — dejan propagar DioException para que
/// PlacesRepositoryImpl pueda mapearla a un Failure tipado.
class PlacesRemoteDataSource {
  PlacesRemoteDataSource(this._service);

  final PlacesService _service;

  Future<List<PlacePredictionDto>> searchPredictions(String query) async {
    final raw = await _service.fetchAutocompleteRaw(query);
    return raw
        .map(
          (json) => PlacePredictionDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<PlaceDetailsDto> getPlaceDetails(String placeId) async {
    final raw = await _service.fetchDetailsRaw(placeId);
    if (raw == null) {
      throw const FormatException(
        'Places no devolvio resultado para el placeId',
      );
    }
    return PlaceDetailsDto.fromJson(raw);
  }
}
