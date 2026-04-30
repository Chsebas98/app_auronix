import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyEarningsHeader extends StatelessWidget {
  const DailyEarningsHeader({
    required this.totalEarnings,
    required this.completedTrips,
    this.onCard = false, // ya no cambia nada, se puede eliminar despues
    super.key,
  });

  final double totalEarnings;
  final int completedTrips;
  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.text;
    final mutedColor = context.appColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'INGRESOS DEL DÍA',
          variant: AppTextVariant.labelMedium,
          fontWeight: FontWeight.w800,
          color: mutedColor,
        ),
        4.verticalSpace,
        AppText(
          '\$${totalEarnings.toStringAsFixed(2)}',
          variant: AppTextVariant.headlineLarge,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        AppText(
          '$completedTrips Viajes Completados',
          variant: AppTextVariant.bodySmall,
          color: mutedColor,
        ),
      ],
    );
  }
}
