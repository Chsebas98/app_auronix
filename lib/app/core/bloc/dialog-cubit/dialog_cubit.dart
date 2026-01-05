import 'package:flutter_bloc/flutter_bloc.dart';
part 'dialog_state.dart';

class DialogCubit extends Cubit<DialogState> {
  DialogCubit() : super(const DialogHidden());

  void showLoading({bool dismissible = false}) =>
      emit(DialogLoading(dismissible: dismissible));

  void showMessage({required String title, String? message}) =>
      emit(DialogMessage(title: title, message: message));

  void hide() => emit(const DialogHidden());
}
