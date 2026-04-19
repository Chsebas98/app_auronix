import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Extensión de tema semántica. Contiene todos los tokens de color
/// que cambian entre light y dark mode.
/// Acceso: context.appColors.card
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme({
    required this.background,
    required this.surface,
    required this.card,
    required this.input,
    required this.text,
    required this.textSecondary,
    required this.divider,
    required this.border,
    required this.button,
    required this.borderPrimary,
    required this.icon,
    required this.tripOverlay,
    required this.tripActionButton,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  final Color background;
  final Color surface;
  final Color card;
  final Color input;
  final Color text;
  final Color textSecondary;
  final Color divider;
  final Color border;
  final Color button;
  final Color borderPrimary;
  final Color icon;
  final Color tripOverlay;
  final Color tripActionButton;
  final Color skeletonBase;
  final Color skeletonHighlight;

  // ── Instancias estáticas listas para usar en AppTheme ──────────────────────

  static const light = AppColorsTheme(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    card: AppColors.lightCard,
    input: AppColors.lightInput,
    text: AppColors.lightText,
    textSecondary: AppColors.lightTextSecondary,
    divider: AppColors.lightDivider,
    border: AppColors.lightBorder,
    button: AppColors.third,
    borderPrimary: AppColors.twelveth,
    icon: AppColors.secondary,
    tripOverlay: AppColors.lightCard,
    tripActionButton: AppColors.lightCard,
    skeletonBase: AppColors.skeletonBaseLight,
    skeletonHighlight: AppColors.skeletonHighlightLight,
  );

  static const dark = AppColorsTheme(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    card: AppColors.darkCard,
    input: AppColors.darkInput,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    divider: AppColors.darkDivider,
    border: AppColors.darkBorder,
    button: AppColors.twelveth,
    borderPrimary: AppColors.third,
    icon: AppColors.white,
    tripOverlay: AppColors.darkCard,
    tripActionButton: AppColors.twelveth,
    skeletonBase: AppColors.skeletonBaseDark,
    skeletonHighlight: AppColors.skeletonHighlightDark,
  );

  // ── ThemeExtension overrides ───────────────────────────────────────────────

  @override
  AppColorsTheme copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? input,
    Color? text,
    Color? textSecondary,
    Color? divider,
    Color? border,
    Color? button,
    Color? borderPrimary,
    Color? icon,
    Color? tripOverlay,
    Color? tripActionButton,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return AppColorsTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      input: input ?? this.input,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      button: button ?? this.button,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      icon: icon ?? this.icon,
      tripOverlay: tripOverlay ?? this.tripOverlay,
      tripActionButton: tripActionButton ?? this.tripActionButton,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  AppColorsTheme lerp(AppColorsTheme? other, double t) {
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      input: Color.lerp(input, other.input, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      button: Color.lerp(button, other.button, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      tripOverlay: Color.lerp(tripOverlay, other.tripOverlay, t)!,
      tripActionButton: Color.lerp(
        tripActionButton,
        other.tripActionButton,
        t,
      )!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
    );
  }
}

// ── Extensiones de acceso conveniente ─────────────────────────────────────────

extension AppThemeContext on BuildContext {
  /// Tokens de color semánticos del tema actual.
  /// Uso: context.appColors.card
  AppColorsTheme get appColors => Theme.of(this).extension<AppColorsTheme>()!;

  bool get isLight => Theme.of(this).brightness == Brightness.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
