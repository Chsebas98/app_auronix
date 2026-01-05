part of 'dialog_cubit.dart';

sealed class DialogState {
  const DialogState();
}

class DialogHidden extends DialogState {
  const DialogHidden();
}

class DialogLoading extends DialogState {
  final bool dismissible;
  const DialogLoading({this.dismissible = false});
}

class DialogMessage extends DialogState {
  final String title;
  final String? message;
  const DialogMessage({required this.title, this.message});
}
