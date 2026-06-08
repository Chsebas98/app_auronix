part of 'home_client_bloc.dart';

sealed class HomeClientEvent extends Equatable {
  const HomeClientEvent();

  @override
  List<Object?> get props => [];
}

final class HomeClientInitEvent extends HomeClientEvent {
  final AuthenticationCredentials credentials;
  const HomeClientInitEvent({required this.credentials});

  @override
  List<Object?> get props => [credentials];
}

final class GetCurrentLocationEvent extends HomeClientEvent {
  const GetCurrentLocationEvent();
}

final class HomeClientProfileLoadedEvent extends HomeClientEvent {
  final AuthenticationCredentials profile;
  const HomeClientProfileLoadedEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class HomeClientTripUpdatedEvent extends HomeClientEvent {
  final dynamic trip;
  const HomeClientTripUpdatedEvent({required this.trip});

  @override
  List<Object?> get props => [trip];
}
