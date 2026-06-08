import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentTripsSectionWidget extends StatelessWidget {
  const RecentTripsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Viajes recientes',
            variant: AppTextVariant.titleSmall,
            color: context.appColors.text,
            fontWeight: FontWeight.w700,
          ),
          16.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppColors.third.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: AppColors.third,
                    size: 28.r,
                  ),
                ),
                16.verticalSpace,
                AppText(
                  'Sin viajes aún',
                  variant: AppTextVariant.titleSmall,
                  color: context.appColors.text,
                  fontWeight: FontWeight.w600,
                  align: TextAlign.center,
                ),
                8.verticalSpace,
                AppText(
                  'Tus viajes aparecerán aquí una vez que hagas tu primera solicitud.',
                  variant: AppTextVariant.bodySmall,
                  color: context.appColors.textSecondary,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
