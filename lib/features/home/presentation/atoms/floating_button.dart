import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Los gradientes de marca (brand) no cambian entre modos
    // pero el texto/icono encima si debe respetar contraste
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16.r),
      shadowColor: theme.shadowColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.third,
                AppColors.nineth,
              ], // brand — OK hardcoded
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.appColors.borderPrimary,
              width: 2.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_taxi_rounded,
                size: 32.r,
                color:
                    // theme.brightness == Brightness.light
                    // ?
                    AppColors.secondary,
                // : AppColors.primary,
              ),
              SizedBox(width: 12.w),
              AppText(
                label,
                variant: AppTextVariant.titleMedium,
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
