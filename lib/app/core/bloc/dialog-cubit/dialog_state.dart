part of 'dialog_cubit.dart';

enum DialogPresentation {
  /// Apila encima del que esté abierto (dialog sobre dialog).
  stack,

  /// Cierra el top actual y luego muestra el nuevo.
  replaceTop,
}

sealed class DialogState {
  const DialogState();
}

class DialogIdle extends DialogState {
  const DialogIdle();
}

class DialogHideTop extends DialogState {
  const DialogHideTop();
}

class DialogHideAll extends DialogState {
  const DialogHideAll();
}

class DialogLoading extends DialogState {
  final bool dismissible;
  final DialogPresentation presentation;
  const DialogLoading({required this.dismissible, required this.presentation});
}

class DialogMessage extends DialogState {
  final String title;
  final String? message;
  final bool dismissible;
  final DialogPresentation presentation;
  const DialogMessage({
    required this.title,
    this.message,
    required this.dismissible,
    required this.presentation,
  });
}

class DialogConfirm extends DialogState {
  final String title;
  final String message;
  final String okText;
  final String cancelText;
  final Completer<bool> completer;
  final DialogPresentation presentation;

  const DialogConfirm({
    required this.title,
    required this.message,
    required this.okText,
    required this.cancelText,
    required this.completer,
    required this.presentation,
  });
}

class DialogCustom extends DialogState {
  final WidgetBuilder builder;
  final bool barrierDismissible;
  final bool useRootNavigator;
  final Color? barrierColor;
  final DialogPresentation presentation;

  const DialogCustom({
    required this.builder,
    required this.barrierDismissible,
    required this.useRootNavigator,
    required this.presentation,
    this.barrierColor,
  });
}

class DialogFullscreen extends DialogState {
  final WidgetBuilder pageBuilder;
  final bool barrierDismissible;
  final bool useRootNavigator;
  final Color? barrierColor;
  final DialogPresentation presentation;

  const DialogFullscreen({
    required this.pageBuilder,
    required this.barrierDismissible,
    required this.useRootNavigator,
    required this.presentation,
    this.barrierColor,
  });
}
