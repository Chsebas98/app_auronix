import 'package:auronix_app/features/home/domain/entities/place_details.dart';

/// Mapea el `result` crudo de la respuesta de detalle de Google Places (T17).
class PlaceDetailsDto {
  const PlaceDetailsDto({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;

  /// Lanza [FormatException] si falta la geometria — sin coordenadas el
  /// resultado no sirve para nada en este dominio (seleccionar un origen o
  /// destino), asi que no hay un fallback seguro posible aqui (a diferencia
  /// de los campos de texto de [PlacePredictionDto]).
  factory PlaceDetailsDto.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']?['location'] as Map<String, dynamic>?;
    if (location == null) {
      throw const FormatException('Respuesta de Places sin geometria/location');
    }
    return PlaceDetailsDto(
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      formattedAddress:
          json['formatted_address'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'geometry': {
      'location': {'lat': latitude, 'lng': longitude},
    },
    'formatted_address': formattedAddress,
  };

  PlaceDetails toEntity() => PlaceDetails(
    latitude: latitude,
    longitude: longitude,
    formattedAddress: formattedAddress,
  );
}
