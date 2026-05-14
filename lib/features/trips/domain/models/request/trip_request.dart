import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class TripRequest extends Equatable {
  const TripRequest({
    required this.id,
    required this.clientName,
    required this.clientRating,
    required this.distanceKm,
    required this.originAddress,
    required this.originEta,
    required this.destinationAddress,
    required this.destinationEta,
    required this.estimatedFare,
    required this.position,
  });

  final String id;
  final String clientName;
  final double clientRating;
  final double distanceKm;
  final String originAddress;
  final String originEta;
  final String destinationAddress;
  final String destinationEta;
  final double estimatedFare;
  final LatLng position;

  @override
  List<Object?> get props => [id];
}
