import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'request_trip_event.dart';
part 'request_trip_state.dart';

class RequestTripBloc extends Bloc<RequestTripEvent, RequestTripState> {
  RequestTripBloc() : super(RequestTripInitial()) {
    on<RequestTripEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
