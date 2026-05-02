part of 'driver_trip_bloc.dart';

sealed class DriverTripEvent extends Equatable {
  const DriverTripEvent();

  @override
  List<Object?> get props => [];
}

final class DriverTripLoadNearbyEvent extends DriverTripEvent {
  const DriverTripLoadNearbyEvent();
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
  const DriverTripAcceptEvent({required this.requestId});
  final String requestId;

  @override
  List<Object?> get props => [requestId];
}

final class DriverTripRejectEvent extends DriverTripEvent {
  const DriverTripRejectEvent({required this.requestId});
  final String requestId;

  @override
  List<Object?> get props => [requestId];
}
