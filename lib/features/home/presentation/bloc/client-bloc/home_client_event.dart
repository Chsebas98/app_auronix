part of 'home_client_bloc.dart';

sealed class HomeClientEvent extends Equatable {
  const HomeClientEvent();

  @override
  List<Object?> get props => [];
}

final class HomeClientInitEvent extends HomeClientEvent {
  const HomeClientInitEvent();
}

final class GetCurrentLocationEvent extends HomeClientEvent {
  const GetCurrentLocationEvent();
}

final class HomeClientProfileLoadedEvent extends HomeClientEvent {
  final dynamic profile; // reemplaza con tu modelo UserProfile
  const HomeClientProfileLoadedEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class HomeClientTripUpdatedEvent extends HomeClientEvent {
  final dynamic trip; // reemplaza con tu modelo Trip
  const HomeClientTripUpdatedEvent({required this.trip});

  @override
  List<Object?> get props => [trip];
}
