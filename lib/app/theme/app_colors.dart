import 'package:flutter/material.dart' show Color, Colors;

class AppColors {
  // ==================== NEUTRALES ====================
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Colors.transparent;

  // ==================== LIGHT MODE ====================
  static const lightBackground = Color(0xFFFBF9F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightInput = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF191919);
  static const lightTextSecondary = Color(0xFFB3B3B4);
  static const lightDivider = Color(0xFFE0E0E0);
  static const lightBorder = Color(0xFFE5E5E5);

  // ==================== DARK MODE ====================
  static const darkBackground = Color(0xFF191919);
  static const darkSurface = Color(0xFF222226);
  static const darkCard = Color(0xFF363940);
  static const darkInput = Color(0xFF363940);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFAAA5A6);
  static const darkDivider = Color(0xFF444444);
  static const darkBorder = Color(0xFF3A3A3A);

  // ==================== BRAND COLORS ====================
  static const primary = Color(0xFFFBF9F8);
  static const secondary = Color(0xFF191919);
  static const third = Color(0xFFFFC900); // Yellow/Gold
  static const fourth = Color(0xFFB3B3B4); // Gray
  static const fifth = Color(0xFF00B292); // Teal
  static const sixth = Color(0xFF00B393); // Teal variant
  static const sevent = Color(0xFFFF3B00); // Red/Orange
  static const eight = Color(0xFFB5B5B6); // Gray variant
  static const nineth = Color(0xFFF9D659); // Light yellow
  static const tenth = Color(0xFFF99C59); // Orange
  static const eleventh = Color(0xFF00D16C); // Green
  static const twelveth = Color(0xFFFFC107); // Amber

  // ==================== GRAYS (para ambos modos) ====================
  static const gray50 = Color(0xFFF2F2F2);
  static const gray100 = Color(0xFFE5E5E5);
  static const gray200 = Color(0xFFD1D1D1);
  static const gray300 = Color(0xFFB3B3B4);
  static const gray400 = Color(0xFFAAA5A6);
  static const gray500 = Color(0xFF8E8E8E);
  static const gray600 = Color(0xFF6B6B6B);
  static const gray700 = Color(0xFF4A4A4A);
  static const gray800 = Color(0xFF363940);
  static const gray900 = Color(0xFF222226);

  // ==================== TOAST COLORS ====================
  // ERROR
  static const toastErrorBg = Color(0xFFFEF0F2);
  static const toastErrorButton = Color(0xFFC70036);
  static const toastErrorText = Color(0xFF8B0836);
  static const toastErrorBorder = Color(0xFFFFCCD3);
  static const toastErrorShadow = Color(0x1D293D0D);

  // SUCCESS
  static const toastSuccessBg = Color(0xFFE8F9EF);
  static const toastSuccessButton = Color(0xFF28A745);
  static const toastSuccessText = Color(0xFF1B462D);
  static const toastSuccessBorder = Color(0xFFC6F0D2);
  static const toastSuccessShadow = Color(0x1D293D0D);

  // WARNING
  static const toastWarningBg = Color(0xFFFFF9E8);
  static const toastWarningButton = Color(0xFFFFC107);
  static const toastWarningText = Color(0xFF5C4500);
  static const toastWarningBorder = Color(0xFFFFE6B5);
  static const toastWarningShadow = Color(0x1D293D0D);

  // INFO
  static const toastInfoBg = Color(0xFFEEF5FB);
  static const toastInfoButton = Color(0xFF338ACC);
  static const toastInfoText = Color(0xFF70ADDB);
  static const toastInfoBorder = Color(0xFFDBEAF6);
  static const toastInfoShadow = Color(0x1D293D0D);

  // ==================== DIALOG COLORS ====================
  static const dialogBtnOkBg = Color(0xFFFFC107);
  static const dialogBtnOkText = Color(0xFF1D2939);
  static const dialogBtnCancelBg = Color(0xFFF2F4F7);
  static const dialogBtnCancelText = Color(0xFF344054);
}

class AppShadowColors {
  // Neutrales
  static const whiteSoft = Color(0x14FFFFFF);
  static const whiteHard = Color(0x24FFFFFF);

  static const blackSoft = Color(0x14000000);
  static const blackHard = Color(0x24000000);

  // Generales
  static const primarySoft = Color(0x14FBF9F8);
  static const primaryHard = Color(0x24FBF9F8);

  static const secondarySoft = Color(0x14191919);
  static const secondaryHard = Color(0x24191919);

  static const thirdSoft = Color(0x14FFC900);
  static const thirdHard = Color(0x24FFC900);

  static const fourthSoft = Color(0x14B3B3B4);
  static const fourthHard = Color(0x24B3B3B4);

  static const fifthSoft = Color(0x1400B292);
  static const fifthHard = Color(0x2400B292);

  static const sixthSoft = Color(0x1400B393);
  static const sixthHard = Color(0x2400B393);

  static const seventSoft = Color(0x14FF3B00);
  static const seventHard = Color(0x24FF3B00);

  static const eightSoft = Color(0x14B5B5B6);
  static const eightHard = Color(0x24B5B5B6);

  static const ninethSoft = Color(0x14F9D659);
  static const ninethHard = Color(0x24F9D659);

  static const tenthSoft = Color(0x14F99C59);
  static const tenthHard = Color(0x24F99C59);

  static const eleventhSoft = Color(0x1400D16C);
  static const eleventhHard = Color(0x2400D16C);

  static const twelvethSoft = Color(0x14FFC107);
  static const twelvethHard = Color(0x24FFC107);

  // ==================== SHADOWS DARK MODE ====================
  static const darkSoft = Color(0x14222226);
  static const darkHard = Color(0x24222226);
}
