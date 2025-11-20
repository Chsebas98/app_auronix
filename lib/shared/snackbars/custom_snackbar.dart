import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: non_constant_identifier_names
SnackBar CustomSnackbar({
  TypeToast isDefaultSnackbar = TypeToast.defaultToast,
  TypeColor typeColor = TypeColor.success,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
  required String title,
  required String description,
  required ThemeData theme,
  int seconds = 20,
  RichText? descriptionRich,
  String textButton = 'Entendido',
  VoidCallback? onVisible,
  VoidCallback? actionClosed,
}) {
  return SnackBar(
    behavior: behavior,
    onVisible: onVisible,
    dismissDirection: DismissDirection.vertical,
    showCloseIcon: isDefaultSnackbar == TypeToast.defaultToast ? true : false,
    elevation: 0,
    duration: Duration(seconds: seconds),
    backgroundColor: isDefaultSnackbar == TypeToast.defaultToast
        ? SnackUtil.getColor(typeColor, TypeElementToast.toastBg)
        : AppColors.transparent,
    content: isDefaultSnackbar == TypeToast.defaultToast
        ? _contentDefaultSnackbar(
            typeColor: typeColor,
            title: title,
            description: description,
            theme: theme,
            descriptionRich: descriptionRich,
          )
        : _contentCustomSnackbar(
            typeColor: typeColor,
            title: title,
            description: description,
            theme: theme,
            descriptionRich: descriptionRich,
            textButton: textButton,
            onVisible: onVisible,
            actionClosed: actionClosed,
          ),
  );
}

Widget _contentDefaultSnackbar({
  TypeColor typeColor = TypeColor.success,
  required String title,
  required String description,
  required ThemeData theme,
  RichText? descriptionRich,
}) {
  return Column(
    children: [
      if (title.isNotEmpty)
        AutoSizeText(
          title,
          maxLines: 1,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: SnackUtil.getColor(typeColor, TypeElementToast.toastText),
          ),
        ),
      if (description.isNotEmpty || descriptionRich != null) 2.verticalSpace,
      if (description.isNotEmpty)
        AutoSizeText(
          description,
          maxLines: 2,
          style: theme.textTheme.bodySmall!.copyWith(
            color: SnackUtil.getColor(typeColor, TypeElementToast.toastText),
          ),
        ),
      if (descriptionRich != null) descriptionRich,
    ],
  );
}

Widget _contentCustomSnackbar({
  TypeColor typeColor = TypeColor.success,
  required String title,
  required String description,
  required ThemeData theme,
  RichText? descriptionRich,
  String textButton = 'Entendido',
  VoidCallback? onVisible,
  VoidCallback? actionClosed,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    decoration: BoxDecoration(
      color: SnackUtil.getColor(typeColor, TypeElementToast.toastBg),
      border: Border.all(
        color: SnackUtil.getColor(typeColor, TypeElementToast.toastBorder),
      ),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 24.w,
          color: SnackUtil.getColor(typeColor, TypeElementToast.toastText),
        ),
        12.horizontalSpace,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty)
                AutoSizeText(
                  title,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SnackUtil.getColor(
                      typeColor,
                      TypeElementToast.toastText,
                    ),
                  ),
                ),
              if (title.isNotEmpty &&
                  (description.isNotEmpty || descriptionRich != null))
                10.verticalSpace,
              if (description.isNotEmpty)
                AutoSizeText(
                  description,
                  maxLines: 2,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: SnackUtil.getColor(
                      typeColor,
                      TypeElementToast.toastText,
                    ),
                  ),
                ),
              if (descriptionRich != null) descriptionRich,
              12.verticalSpace,
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SnackUtil.getColor(
                    typeColor,
                    TypeElementToast.toastButton,
                  ),
                  foregroundColor: SnackUtil.getColor(
                    typeColor,
                    TypeElementToast.toastText,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12.r),
                  ),
                ),
                onPressed: actionClosed,
                child: Text(textButton),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
