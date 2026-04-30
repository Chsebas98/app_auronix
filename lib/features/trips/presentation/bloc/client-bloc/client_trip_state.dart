part of 'client_trip_bloc.dart';

sealed class ClientTripState extends Equatable {
  const ClientTripState();
  
  @override
  List<Object> get props => [];
}

final class ClientTripInitial extends ClientTripState {}
