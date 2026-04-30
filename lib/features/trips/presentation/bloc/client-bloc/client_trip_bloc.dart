import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'client_trip_event.dart';
part 'client_trip_state.dart';

class ClientTripBloc extends Bloc<ClientTripEvent, ClientTripState> {
  ClientTripBloc() : super(ClientTripInitial()) {
    on<ClientTripEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
