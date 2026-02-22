import 'package:auronix_app/features/client/features/home/domain/models/interfaces/current_trip_status.dart';
import 'package:equatable/equatable.dart';

class TripModel extends Equatable {
  final String id;
  final TripStatus status;
  final String origin;
  final String destination;
  final String? originAddress;
  final String? destinationAddress;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Driver info (null si aún no hay conductor)
  final String? driverId;
  final String? driverName;
  final String? driverPhotoUrl;
  final String? driverPlate;
  final double? driverRating;
  final String? driverPhone;

  // Tracking
  final double? driverLat;
  final double? driverLng;
  final int? estimatedArrivalMinutes;

  const TripModel({
    required this.id,
    required this.status,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
    this.estimatedPrice,
    this.finalPrice,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.driverId,
    this.driverName,
    this.driverPhotoUrl,
    this.driverPlate,
    this.driverRating,
    this.driverPhone,
    this.driverLat,
    this.driverLng,
    this.estimatedArrivalMinutes,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    origin,
    destination,
    estimatedPrice,
    driverId,
    driverLat,
    driverLng,
  ];
}
