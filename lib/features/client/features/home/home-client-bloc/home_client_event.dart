part of 'home_client_bloc.dart';

sealed class HomeClientEvent extends Equatable {
  const HomeClientEvent();

  @override
  List<Object> get props => [];
}

class GetDataProfileEvent extends HomeClientEvent {}

class CompleteProfileEvent extends HomeClientEvent {
  final String imgUrl;
  final String name;
  final String gender;
  final String phone;

  const CompleteProfileEvent({
    required this.imgUrl,
    required this.name,
    required this.phone,
    required this.gender,
  });

  @override
  List<Object> get props => [name, phone];
}

class CheckCurrentTripEvent extends HomeClientEvent {}

class CancelTripEvent extends HomeClientEvent {
  final String tripId;

  const CancelTripEvent(this.tripId);

  @override
  List<Object> get props => [tripId];
}

class UpdateCurrentTripEvent extends HomeClientEvent {
  final TripModel trip;

  const UpdateCurrentTripEvent(this.trip);

  @override
  List<Object> get props => [trip];
}

class ClearCurrentTripEvent extends HomeClientEvent {}

class GetCurrentLocationEvent extends HomeClientEvent {}
