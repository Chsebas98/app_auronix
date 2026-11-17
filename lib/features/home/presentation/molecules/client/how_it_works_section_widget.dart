import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HowItWorksSectionWidget extends StatelessWidget {
  const HowItWorksSectionWidget({super.key});

  static const _steps = [
    (
      icon: Icons.location_on_rounded,
      color: AppColors.fifth,
      title: 'Elige tu destino',
      desc: 'Ingresa a dónde quieres ir y confirma tu punto de origen.',
    ),
    (
      icon: Icons.directions_car_rounded,
      color: AppColors.third,
      title: 'Conectamos con un conductor',
      desc: 'Encontramos el conductor más cercano disponible para ti.',
    ),
    (
      icon: Icons.check_circle_rounded,
      color: AppColors.eleventh,
      title: 'Viaja seguro',
      desc: 'Sigue tu viaje en tiempo real y paga al completarlo.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '¿Cómo funciona?',
            variant: AppTextVariant.titleSmall,
            color: context.appColors.text,
            fontWeight: FontWeight.w700,
          ),
          16.verticalSpace,
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? 12.h : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon, color: step.color, size: 22.r),
                      ),
                      if (i < _steps.length - 1)
                        Container(
                          width: 2,
                          height: 24.h,
                          color: context.appColors.border,
                        ),
                    ],
                  ),
                  14.horizontalSpace,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            step.title,
                            variant: AppTextVariant.bodyMedium,
                            color: context.appColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                          4.verticalSpace,
                          AppText(
                            step.desc,
                            variant: AppTextVariant.bodySmall,
                            color: context.appColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
