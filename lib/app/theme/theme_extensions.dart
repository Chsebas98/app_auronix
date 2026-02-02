import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension ThemeContextExtension on BuildContext {
  bool get isLight => Theme.of(this).brightness == Brightness.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

extension AppColorsExtension on AppColors {
  static Color cardColor(BuildContext context) {
    return context.isLight ? AppColors.lightCard : AppColors.darkCard;
  }

  static Color inputColor(BuildContext context) {
    return context.isLight ? AppColors.lightInput : AppColors.darkInput;
  }

  static Color textColor(BuildContext context) {
    return context.isLight ? AppColors.lightText : AppColors.darkText;
  }

  static Color textSecondaryColor(BuildContext context) {
    return context.isLight
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;
  }

  static Color borderColor(BuildContext context) {
    return context.isLight ? AppColors.lightBorder : AppColors.darkBorder;
  }

  static Color surfaceColor(BuildContext context) {
    return context.isLight ? AppColors.lightSurface : AppColors.darkSurface;
  }
}
