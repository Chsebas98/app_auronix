import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

enum AppSnackbarVariant { defaultToast, custom }

SnackBar appSnackbar({
  AppSnackbarVariant variant = AppSnackbarVariant.defaultToast,
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
    showCloseIcon: variant == AppSnackbarVariant.defaultToast,
    elevation: 0,
    duration: Duration(seconds: seconds),
    backgroundColor: variant == AppSnackbarVariant.defaultToast
        ? SnackUtil.getColor(typeColor, TypeElementToast.toastBg)
        : AppColors.transparent,
    content: variant == AppSnackbarVariant.defaultToast
        ? _DefaultSnackbarContent(
            typeColor: typeColor,
            title: title,
            description: description,
            theme: theme,
            descriptionRich: descriptionRich,
          )
        : _CustomSnackbarContent(
            typeColor: typeColor,
            title: title,
            description: description,
            theme: theme,
            descriptionRich: descriptionRich,
            textButton: textButton,
            actionClosed: actionClosed,
          ),
  );
}

// ── Default content ────────────────────────────────────────────────────────────

class _DefaultSnackbarContent extends StatelessWidget {
  const _DefaultSnackbarContent({
    required this.typeColor,
    required this.title,
    required this.description,
    required this.theme,
    this.descriptionRich,
  });

  final TypeColor typeColor;
  final String title;
  final String description;
  final ThemeData theme;
  final RichText? descriptionRich;

  @override
  Widget build(BuildContext context) {
    final textColor = SnackUtil.getColor(typeColor, TypeElementToast.toastText);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          AutoSizeText(
            title,
            maxLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        if (title.isNotEmpty &&
            (description.isNotEmpty || descriptionRich != null))
          SizedBox(height: AppSpacing.x1),
        if (description.isNotEmpty)
          AutoSizeText(
            description,
            maxLines: 2,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        if (descriptionRich != null) descriptionRich!,
      ],
    );
  }
}

// ── Custom content ─────────────────────────────────────────────────────────────

class _CustomSnackbarContent extends StatelessWidget {
  const _CustomSnackbarContent({
    required this.typeColor,
    required this.title,
    required this.description,
    required this.theme,
    required this.textButton,
    this.descriptionRich,
    this.actionClosed,
  });

  final TypeColor typeColor;
  final String title;
  final String description;
  final ThemeData theme;
  final RichText? descriptionRich;
  final String textButton;
  final VoidCallback? actionClosed;

  @override
  Widget build(BuildContext context) {
    final textColor = SnackUtil.getColor(typeColor, TypeElementToast.toastText);
    final bgColor = SnackUtil.getColor(typeColor, TypeElementToast.toastBg);
    final borderColor = SnackUtil.getColor(
      typeColor,
      TypeElementToast.toastBorder,
    );
    final buttonColor = SnackUtil.getColor(
      typeColor,
      TypeElementToast.toastButton,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 24, color: textColor),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                if (title.isNotEmpty &&
                    (description.isNotEmpty || descriptionRich != null))
                  const SizedBox(height: AppSpacing.x2),
                if (description.isNotEmpty)
                  AutoSizeText(
                    description,
                    maxLines: 2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                    ),
                  ),
                if (descriptionRich != null) descriptionRich!,
                const SizedBox(height: AppSpacing.x3),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x3,
                      vertical: AppSpacing.x1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
}
