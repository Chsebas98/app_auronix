import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(const BottomNavState());

  void setIndex(int index) => emit(state.copyWith(currentIndex: index));

  void clampToLength(int length) {
    if (length <= 0) {
      emit(const BottomNavState(currentIndex: 0));
      return;
    }
    final safe = state.currentIndex.clamp(0, length - 1);
    if (safe != state.currentIndex) emit(state.copyWith(currentIndex: safe));
  }
}
