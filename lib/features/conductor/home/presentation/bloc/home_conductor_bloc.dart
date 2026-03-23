import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/core/core.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_conductor_event.dart';
part 'home_conductor_state.dart';

class HomeConductorBloc extends Bloc<HomeConductorEvent, HomeConductorState> {
  HomeConductorBloc() : super(HomeConductorState()) {
    on<HomeConductorEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
