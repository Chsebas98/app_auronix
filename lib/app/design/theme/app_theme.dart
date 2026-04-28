import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
    base: ThemeData.light(useMaterial3: true),
    colors: AppColorsTheme.light,
    brightness: Brightness.light,
  );

  static ThemeData get dark => _buildTheme(
    base: ThemeData.dark(useMaterial3: true),
    colors: AppColorsTheme.dark,
    brightness: Brightness.dark,
  );

  // ── Builder central ────────────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ThemeData base,
    required AppColorsTheme colors,
    required Brightness brightness,
  }) {
    final isLight = brightness == Brightness.light;

    return base
        .copyWith(
          // ── Colores base ──────────────────────────────────────────────────────
          primaryColor: isLight ? AppColors.primary : AppColors.secondary,
          primaryColorDark: isLight ? AppColors.black : AppColors.primary,
          primaryColorLight: isLight ? AppColors.primary : AppColors.black,
          scaffoldBackgroundColor: colors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.third,
            brightness: brightness,
            primary: AppColors.third,
            onPrimary: AppColors.secondary,
            secondary: isLight ? AppColors.secondary : AppColors.white,
            surface: colors.surface,
            error: AppColors.sevent,
          ),

          // ── ThemeExtensions ───────────────────────────────────────────────────
          extensions: const [
            // Se reemplaza la instancia según el modo, ver arriba en light/dark
          ],

          // ── ProgressIndicator ─────────────────────────────────────────────────
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.third,
          ),

          // ── Divider ───────────────────────────────────────────────────────────
          dividerTheme: DividerThemeData(
            color: AppColors.eight,
            thickness: 1.h,
          ),

          // ── Checkbox ─────────────────────────────────────────────────────────
          checkboxTheme: CheckboxThemeData(
            checkColor: WidgetStatePropertyAll(
              isLight ? AppColors.secondary : AppColors.primary,
            ),
            side: BorderSide(
              color: isLight ? AppColors.secondary : AppColors.white,
            ),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) return AppColors.eight;
              if (states.contains(WidgetState.selected)) return AppColors.third;
              return Colors.transparent;
            }),
          ),

          // ── Card ──────────────────────────────────────────────────────────────
          cardTheme: CardThemeData(
            color: colors.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: const BorderSide(color: AppColors.third),
            ),
          ),

          // ── Icons ─────────────────────────────────────────────────────────────
          iconTheme: IconThemeData(color: colors.icon, size: 24.r),

          // ── SnackBar ──────────────────────────────────────────────────────────
          snackBarTheme: SnackBarThemeData(
            dismissDirection: DismissDirection.vertical,
            closeIconColor: AppColors.third,
            contentTextStyle: base.textTheme.labelSmall?.copyWith(
              color: AppColors.twelveth,
            ),
          ),

          // ── IconButton ─────────────────────────────────────────────────��──────
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: isLight ? AppColors.secondary : AppColors.third,
              disabledForegroundColor: AppColors.eight,
            ),
          ),

          // ── TextTheme ─────────────────────────────────────────────────────────
          textTheme: _buildTextTheme(colors.text),

          // ── InputDecoration ───────────────────────────────────────────────────
          inputDecorationTheme: _buildInputDecorationTheme(
            colors: colors,
            isLight: isLight,
          ),

          // ── OutlinedButton ────────────────────────────────────────────────────
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(20.r),
                side: const BorderSide(color: AppColors.third),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              disabledBackgroundColor: AppColors.fourth,
              disabledForegroundColor: AppColors.secondary,
              backgroundColor: colors.background,
              foregroundColor: isLight
                  ? AppColors.secondary
                  : AppColors.primary,
            ),
          ),

          // ── FilledButton ──────────────────────────────────────────────────────
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(20.r),
                side: const BorderSide(color: AppColors.third),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              disabledBackgroundColor: AppColors.fourth,
              disabledForegroundColor: AppColors.secondary,
              backgroundColor: AppColors.third,
              foregroundColor: AppColors.secondary,
            ),
          ),
        )
        .copyWith(
          // Inyectamos la extensión DESPUÉS del copyWith principal para que
          // la instancia correcta (light/dark) quede registrada.
          extensions: [colors],
        );
  }

  // ── TextTheme ──────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }

  // ── InputDecorationTheme ───────────────────────────────────────────────────

  static InputDecorationTheme _buildInputDecorationTheme({
    required AppColorsTheme colors,
    required bool isLight,
  }) {
    final radius = BorderRadius.circular(8.r);
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.input,
      alignLabelWithHint: false,
      floatingLabelStyle: TextStyle(color: colors.text, fontSize: 12),
      labelStyle: TextStyle(color: AppColors.eight, fontSize: 12),
      hintStyle: TextStyle(color: AppColors.eight, fontSize: 14),
      errorStyle: TextStyle(color: AppColors.sevent, fontSize: 10),
      errorMaxLines: 2,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.third),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.third, width: 2.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.third),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.fourth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.sevent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.sevent),
      ),
    );
  }
}
