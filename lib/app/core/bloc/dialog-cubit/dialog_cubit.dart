import 'dart:async' show Completer;
import 'package:flutter/material.dart' show Color;
import 'package:flutter/widgets.dart' show WidgetBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';
part 'dialog_state.dart';

class DialogCubit extends Cubit<DialogState> {
  DialogCubit() : super(const DialogIdle());

  // ---------- Básicos ----------
  void showLoading({
    bool dismissible = false,
    DialogPresentation presentation = DialogPresentation.replaceTop,
  }) {
    emit(DialogLoading(dismissible: dismissible, presentation: presentation));
  }

  void showMessage({
    required String title,
    String? message,
    bool dismissible = false,
    DialogPresentation presentation = DialogPresentation.stack,
  }) {
    emit(
      DialogMessage(
        title: title,
        message: message,
        dismissible: dismissible,
        presentation: presentation,
      ),
    );
  }

  /// Confirm dialog que devuelve Future bool
  Future<bool> showConfirm({
    required String title,
    required String message,
    String okText = 'Aceptar',
    String cancelText = 'Cancelar',
    DialogPresentation presentation = DialogPresentation.stack,
  }) {
    final completer = Completer<bool>();
    emit(
      DialogConfirm(
        title: title,
        message: message,
        okText: okText,
        cancelText: cancelText,
        completer: completer,
        presentation: presentation,
      ),
    );
    return completer.future;
  }

  // ---------- Custom / Fullscreen ----------
  void showCustomDialog({
    required WidgetBuilder builder,
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    DialogPresentation presentation = DialogPresentation.stack,
    Color? barrierColor,
  }) {
    emit(
      DialogCustom(
        builder: builder,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
        barrierColor: barrierColor,
        presentation: presentation,
      ),
    );
  }

  void showFullscreenDialog({
    required WidgetBuilder pageBuilder,
    bool barrierDismissible = false,
    bool useRootNavigator = false, // en tu caso lo usabas false
    DialogPresentation presentation = DialogPresentation.stack,
    Color? barrierColor,
  }) {
    emit(
      DialogFullscreen(
        pageBuilder: pageBuilder,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
        barrierColor: barrierColor,
        presentation: presentation,
      ),
    );
  }

  // ---------- Close helpers ----------
  void hideTop() => emit(const DialogHideTop());
  void hideAll() => emit(const DialogHideAll());

  // Opcional: reset a idle para no re-ejecutar
  void idle() => emit(const DialogIdle());
}
