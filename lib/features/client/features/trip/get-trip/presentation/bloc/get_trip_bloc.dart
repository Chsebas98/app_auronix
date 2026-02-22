import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_trip_event.dart';
part 'get_trip_state.dart';

class GetTripBloc extends Bloc<GetTripEvent, GetTripState> {
  GetTripBloc() : super(GetTripInitial()) {
    on<GetTripEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
