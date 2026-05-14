import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:flutter/cupertino.dart' show Color;

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

  // ==================== TRIP WIDGET COLORS ====================
  // Para el gradiente del card de viaje
  static const tripCardGradientStart = AppColors.third; // Yellow principal
  static const tripCardGradientEnd =
      AppColors.twelveth; // Amber (variación más oscura)

  // Para overlays dentro del card
  static const tripOverlayLight = AppColors.lightCard; // Blanco
  static const tripOverlayDark = AppColors.darkCard; // Gris oscuro

  // Para botones dentro del trip
  static const tripCancelButton = AppColors.sevent; // Rojo
  static const tripActionButtonLight = AppColors.lightDivider; // Gris claro
  static const tripActionButtonDark = AppColors.gray800; // Gris oscuro
}
