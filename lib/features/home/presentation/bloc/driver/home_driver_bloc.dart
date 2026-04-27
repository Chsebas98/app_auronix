import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_driver_event.dart';
part 'home_driver_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  HomeDriverBloc() : super(HomeDriverInitial()) {
    on<HomeDriverEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
