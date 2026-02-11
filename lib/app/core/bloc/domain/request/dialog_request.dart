import 'dart:convert';

import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/dialogs/custom_dialog.dart';

class DialogRequest {
  final TypeDialog typeDialog;
  final DialogType dialogType;
  final int statusCode;
  final String title;
  final String description;

  const DialogRequest({
    this.typeDialog = TypeDialog.resDialog,
    this.dialogType = DialogType.error,
    this.statusCode = 0,
    required this.title,
    required this.description,
  });

  const DialogRequest.empty()
    : typeDialog = TypeDialog.resDialog,
      dialogType = DialogType.error,
      title = '',
      description = '',
      statusCode = 0;

  static DialogType _getDialogTypeFromStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return DialogType.success;
    } else if (statusCode >= 400 && statusCode < 500) {
      return DialogType.warning;
    } else {
      return DialogType.error;
    }
  }

  factory DialogRequest.fromResponse({
    ServiceResponse? dataResponse,
    TypeDialog typeDialog = TypeDialog.resDialog,
    DialogType? dialogType,
    String? errorDetail,
    int? statusCode,
    String? message,
  }) {
    return DialogRequest(
      typeDialog: typeDialog,
      dialogType:
          dialogType ??
          _getDialogTypeFromStatus(statusCode ?? dataResponse?.statusCode ?? 0),
      title: dataResponse?.message ?? message ?? 'Ocurrió un problema',
      description:
          dataResponse?.errorDetail ??
          errorDetail ??
          'La acción no se pudo completar, por favor intente nuevamente.',
    );
  }

  Map<String, dynamic> toJson() => {
    'typeDialog': typeDialog.toString(),
    'title': title,
    'description': description,
  };

  @override
  String toString() => jsonEncode(toJson());
}
