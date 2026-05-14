import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'client_trip_event.dart';
part 'client_trip_state.dart';

class ClientTripBloc extends Bloc<ClientTripEvent, ClientTripState> {
  ClientTripBloc() : super(ClientTripInitial()) {
    on<ClientTripEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<ClientTripInitEvent>(_onClientTripInitEvent);
  }

  FutureOr<void> _onClientTripInitEvent(
    ClientTripInitEvent event,
    Emitter<ClientTripState> emit,
  ) async {}
}
