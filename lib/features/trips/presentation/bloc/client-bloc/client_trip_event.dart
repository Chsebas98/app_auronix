part of 'client_trip_bloc.dart';

sealed class ClientTripEvent extends Equatable {
  const ClientTripEvent();

  @override
  List<Object> get props => [];
}

class ClientTripInitEvent extends ClientTripEvent {
  const ClientTripInitEvent();
}
