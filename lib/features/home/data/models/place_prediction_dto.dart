import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';

/// Mapea la respuesta cruda de autocompletado de Google Places (T17). Los
/// campos secundarios (structured_formatting, secondary_text) no siempre
/// vienen en la respuesta — se usa una cadena vacia como fallback seguro en
/// vez de fallar el parseo.
class PlacePredictionDto {
  const PlacePredictionDto({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  factory PlacePredictionDto.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    final description = json['description'] as String? ?? '';
    final mainText = structured?['main_text'] as String? ?? description;
    final secondaryText = structured?['secondary_text'] as String? ?? '';

    return PlacePredictionDto(
      placeId: json['place_id'] as String? ?? '',
      description: description,
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'description': description,
    'structured_formatting': {
      'main_text': mainText,
      'secondary_text': secondaryText,
    },
  };

  /// Sin coordenadas: la respuesta de autocompletado de Google no las
  /// incluye, solo el `place_id` para resolverlas despues via
  /// [PlacesRemoteDataSource.getPlaceDetails].
  PlacePrediction toEntity() => PlacePrediction(
    id: placeId,
    mainText: mainText,
    secondaryText: secondaryText,
    latitude: 0,
    longitude: 0,
  );
}
