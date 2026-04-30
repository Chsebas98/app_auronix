import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'driver_trip_event.dart';
part 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  DriverTripBloc() : super(DriverTripInitial()) {
    on<DriverTripEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
