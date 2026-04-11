// domain/models/place_entity.dart

import 'dart:convert';

import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;

  const PlaceEntity({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  const PlaceEntity.empty()
    : placeId = '',
      name = '',
      address = '',
      lat = 0.0,
      lng = 0.0;

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'name': name,
    'address': address,
    'lat': lat,
    'lng': lng,
  };

  @override
  String toString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [placeId, name, address, lat, lng];
}
