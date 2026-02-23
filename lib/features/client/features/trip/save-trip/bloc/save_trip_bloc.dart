import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'save_trip_event.dart';
part 'save_trip_state.dart';

class SaveTripBloc extends Bloc<SaveTripEvent, SaveTripState> {
  SaveTripBloc() : super(SaveTripInitial()) {
    on<SaveTripEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
