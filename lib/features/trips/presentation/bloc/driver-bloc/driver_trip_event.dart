part of 'driver_trip_bloc.dart';

sealed class DriverTripEvent extends Equatable {
  const DriverTripEvent();

  @override
  List<Object?> get props => [];
}

final class DriverTripLoadNearbyEvent extends DriverTripEvent {
  final int userId;
  const DriverTripLoadNearbyEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class DriverTripConnectSocketEvent extends DriverTripEvent {
  final int driverId;
  const DriverTripConnectSocketEvent({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

final class DriverTripSocketReceivedEvent extends DriverTripEvent {
  final TripRequestEvent event;
  const DriverTripSocketReceivedEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

final class DriverTripSelectRequestEvent extends DriverTripEvent {
  const DriverTripSelectRequestEvent({required this.request});
  final TripRequest request;

  @override
  List<Object?> get props => [request];
}

final class DriverTripDismissRequestEvent extends DriverTripEvent {
  const DriverTripDismissRequestEvent();
}

final class DriverTripAcceptEvent extends DriverTripEvent {
  final int userId;
  final int tripId;
  final String requestId;
  const DriverTripAcceptEvent({
    required this.userId,
    required this.tripId,
    required this.requestId,
  });

  @override
  List<Object?> get props => [userId, tripId, requestId];
}

final class DriverTripRejectEvent extends DriverTripEvent {
  final int userId;
  final int tripId;
  final String requestId;
  final String? motivo;
  const DriverTripRejectEvent({
    required this.userId,
    required this.tripId,
    required this.requestId,
    this.motivo,
  });

  @override
  List<Object?> get props => [userId, tripId, requestId];
}

final class DriverTripStartEvent extends DriverTripEvent {
  final int userId;
  final int tripId;
  const DriverTripStartEvent({required this.userId, required this.tripId});

  @override
  List<Object?> get props => [userId, tripId];
}

final class DriverTripCompleteEvent extends DriverTripEvent {
  final int userId;
  final int tripId;
  final double distanciaFinalKm;
  final int duracionMinutos;
  const DriverTripCompleteEvent({
    required this.userId,
    required this.tripId,
    required this.distanciaFinalKm,
    required this.duracionMinutos,
  });

  @override
  List<Object?> get props => [userId, tripId, distanciaFinalKm, duracionMinutos];
}

final class DriverTripRatePassengerEvent extends DriverTripEvent {
  final int userId;
  final int tripId;
  final int calificacion;
  final String? comentario;
  const DriverTripRatePassengerEvent({
    required this.userId,
    required this.tripId,
    required this.calificacion,
    this.comentario,
  });

  @override
  List<Object?> get props => [userId, tripId, calificacion, comentario];
}
