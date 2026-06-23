import 'package:equatable/equatable.dart';

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
    required this.latitude,
    required this.longitude,
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
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [id];
}
