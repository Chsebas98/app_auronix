import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: AppColors.primary,
    primaryColorDark: AppColors.black,
    primaryColorLight: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primary,
    dividerTheme: DividerThemeData(color: AppColors.eight, thickness: 1.h),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStatePropertyAll(AppColors.secondary),
      side: BorderSide(color: AppColors.secondary),
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.eight;
        if (states.contains(WidgetState.selected)) return AppColors.third;
        return Colors.transparent;
      }),
    ),
    cardTheme: CardThemeData(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.third),
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.secondary, size: 24.r),
    snackBarTheme: SnackBarThemeData(
      dismissDirection: DismissDirection.vertical,
      contentTextStyle: ThemeData.light().textTheme.labelSmall?.copyWith(
        color: AppColors.twelveth,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.secondary,
        disabledForegroundColor: AppColors.fourth,
      ),
    ),
    textTheme: TextTheme(
      // Display (muy grande, para titulares impactantes)
      displayLarge: TextStyle(
        fontSize: 96.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
      ),
      displayMedium: TextStyle(
        fontSize: 60.sp,
        fontWeight: FontWeight.w300,
        color: AppColors.secondary,
      ),
      displaySmall: TextStyle(
        fontSize: 48.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 34.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      ),

      // Body (texto normal)
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),

      // Labels (texto de botones u otros elementos pequeños)
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      floatingLabelStyle: ThemeData.light().textTheme.labelMedium?.copyWith(
        color: AppColors.secondary,
      ),
      alignLabelWithHint: false,
      fillColor: AppColors.primary,
      errorStyle: ThemeData.light().textTheme.labelSmall?.copyWith(
        color: AppColors.sevent,
      ),
      errorMaxLines: 2,
      labelStyle: ThemeData.light().textTheme.labelMedium?.copyWith(
        color: AppColors.eight,
      ),
      hintStyle: ThemeData.light().textTheme.bodyMedium?.copyWith(
        color: AppColors.eight,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third, width: 2.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.fourth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.sevent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.sevent),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20.r),
          side: BorderSide(color: AppColors.third),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        disabledBackgroundColor: AppColors.fourth,
        disabledForegroundColor: AppColors.secondary,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20.r),
          side: BorderSide(color: AppColors.third),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        disabledBackgroundColor: AppColors.fourth,
        disabledForegroundColor: AppColors.secondary,
        backgroundColor: AppColors.third,
        foregroundColor: AppColors.secondary,
      ),
    ),
  );
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.secondary,
    primaryColorDark: AppColors.primary,
    primaryColorLight: AppColors.black,
    scaffoldBackgroundColor: AppColors.secondary,
    dividerTheme: DividerThemeData(color: AppColors.eight, thickness: 1.h),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStatePropertyAll(AppColors.primary),
      side: BorderSide(color: AppColors.primary),
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.eight;
        if (states.contains(WidgetState.selected)) return AppColors.third;
        return Colors.transparent;
      }),
    ),
    cardTheme: CardThemeData(
      color: AppColors.fourth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.third),
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.primary, size: 24.r),
    snackBarTheme: SnackBarThemeData(
      dismissDirection: DismissDirection.vertical,
      contentTextStyle: ThemeData.light().textTheme.labelSmall?.copyWith(
        color: AppColors.twelveth,
      ),
      closeIconColor: AppColors.third,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.third,
        disabledForegroundColor: AppColors.eight,
      ),
    ),
    textTheme: TextTheme(
      // Display (muy grande, para titulares impactantes)
      displayLarge: TextStyle(
        fontSize: 96.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 60.sp,
        fontWeight: FontWeight.w300,
        color: AppColors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 48.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 34.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),

      // Body (texto normal)
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),

      // Labels (texto de botones u otros elementos pequeños)
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      errorStyle: ThemeData.light().textTheme.labelSmall?.copyWith(
        color: AppColors.sevent,
      ),
      errorMaxLines: 2,
      labelStyle: ThemeData.light().textTheme.labelMedium?.copyWith(
        color: AppColors.third,
      ),
      hintStyle: ThemeData.light().textTheme.bodyMedium?.copyWith(
        color: AppColors.eight,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third, width: 2.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.third),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.fourth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.sevent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.sevent),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20.r),
          side: BorderSide(color: AppColors.third),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        disabledBackgroundColor: AppColors.fourth,
        disabledForegroundColor: AppColors.secondary,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20.r),
          side: BorderSide(color: AppColors.third),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        disabledBackgroundColor: AppColors.fourth,
        disabledForegroundColor: AppColors.secondary,

        backgroundColor: AppColors.third,
        foregroundColor: AppColors.secondary,
      ),
    ),
  );
}
