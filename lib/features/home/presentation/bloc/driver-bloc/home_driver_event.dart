part of 'home_driver_bloc.dart';

sealed class HomeDriverEvent extends Equatable {
  const HomeDriverEvent();

  @override
  List<Object?> get props => [];
}

final class GetCurrentLocationEvent extends HomeDriverEvent {}

final class HomeDriverInitEvent extends HomeDriverEvent {
  const HomeDriverInitEvent();
}

final class HomeDriverToggleAvailabilityEvent extends HomeDriverEvent {
  const HomeDriverToggleAvailabilityEvent();
}

final class HomeDriverLocationUpdatedEvent extends HomeDriverEvent {
  final String address;
  const HomeDriverLocationUpdatedEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

final class HomeDriverTripRequestedEvent extends HomeDriverEvent {
  final dynamic trip; // reemplaza con tu modelo TripRequest
  const HomeDriverTripRequestedEvent({required this.trip});

  @override
  List<Object?> get props => [trip];
}

final class HomeDriverTripAcceptedEvent extends HomeDriverEvent {
  const HomeDriverTripAcceptedEvent();
}

final class HomeDriverTripRejectedEvent extends HomeDriverEvent {
  const HomeDriverTripRejectedEvent();
}

final class HomeDriverProfileLoadedEvent extends HomeDriverEvent {
  final dynamic profile;
  const HomeDriverProfileLoadedEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}
