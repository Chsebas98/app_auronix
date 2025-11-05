import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/snackbars/custom_snackbar.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        WidgetsBinding,
        ThemeData,
        Color,
        SnackBarBehavior,
        RichText,
        VoidCallback;

class SnackUtil {
  static void showToastValidation({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String description,
    TypeToast? isDefaultSnackbar,
    TypeColor? typeColor,
    SnackBarBehavior? behavior,
    RichText? descriptionRich,
    String? textButton,
    VoidCallback? onVisible,
    VoidCallback? actionClosed,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootMessengerKey.currentState?.showSnackBar(
        CustomSnackbar(
          theme: theme,
          title: title,
          description: description,
          isDefaultSnackbar: isDefaultSnackbar ?? TypeToast.defaultToast,
          typeColor: typeColor ?? TypeColor.success,
          behavior: behavior ?? SnackBarBehavior.floating,
          descriptionRich: descriptionRich,
          textButton: textButton ?? 'Entendido',
          onVisible: onVisible,
          actionClosed: actionClosed,
        ),
      );
    });
  }

  static const Map<TypeColor, Map<TypeElementToast, Color>> _colorMap = {
    TypeColor.success: {
      TypeElementToast.toastBg: AppColors.toastSuccessBg,
      TypeElementToast.toastButton: AppColors.toastSuccessButton,
      TypeElementToast.toastText: AppColors.toastSuccessText,
      TypeElementToast.toastBorder: AppColors.toastSuccessBorder,
      TypeElementToast.toastShadow: AppColors.toastSuccessShadow,
    },
    TypeColor.warning: {
      TypeElementToast.toastBg: AppColors.toastWarningBg,
      TypeElementToast.toastButton: AppColors.toastWarningButton,
      TypeElementToast.toastText: AppColors.toastWarningText,
      TypeElementToast.toastBorder: AppColors.toastWarningBorder,
      TypeElementToast.toastShadow: AppColors.toastWarningShadow,
    },
    TypeColor.error: {
      TypeElementToast.toastBg: AppColors.toastErrorBg,
      TypeElementToast.toastButton: AppColors.toastErrorButton,
      TypeElementToast.toastText: AppColors.toastErrorText,
      TypeElementToast.toastBorder: AppColors.toastErrorBorder,
      TypeElementToast.toastShadow: AppColors.toastErrorShadow,
    },
  };

  static Color getColor(TypeColor typeColor, TypeElementToast typeElement) {
    return _colorMap[typeColor]![typeElement]!;
  }
}
