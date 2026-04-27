import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_client_event.dart';
part 'home_client_state.dart';

class HomeClientBloc extends Bloc<HomeClientEvent, HomeClientState> {
  HomeClientBloc() : super(HomeClientInitial()) {
    on<HomeClientEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
