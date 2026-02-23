import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
    required super.placeId,
    required super.name,
    required super.address,
    required super.lat,
    required super.lng,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['placeId'] ?? json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? json['formatted_address'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }
}
