import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'modal_temp_state.dart';

class ModalTempCubit extends Cubit<ModalTempState> {
  ModalTempCubit() : super(ModalTempState());

  FutureOr<void> stringTemp1ChangedEvent(String value) {
    emit(state.copyWith(stringTemp1: value));
  }

  FutureOr<void> stringTemp2ChangedEvent(String value) {
    emit(state.copyWith(stringTemp2: value));
  }

  FutureOr<void> stringTemp3ChangedEvent(String value) {
    emit(state.copyWith(stringTemp3: value));
  }

  FutureOr<void> boolTemp1ChangedEvent(bool value) {
    emit(state.copyWith(boolTemp1: value));
  }

  FutureOr<void> boolTemp2ChangedEvent(bool value) {
    emit(state.copyWith(boolTemp2: value));
  }

  FutureOr<void> boolTemp3ChangedEvent(bool value) {
    emit(state.copyWith(boolTemp3: value));
  }
}
