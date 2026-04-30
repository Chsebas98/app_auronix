import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/features/home/presentation/atoms/earnings_line_chart.dart';
import 'package:auronix_app/features/home/presentation/molecules/driver/daily_earnings_header.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverDailyEarningsCard extends StatelessWidget {
  const DriverDailyEarningsCard({
    required this.totalEarnings,
    required this.completedTrips,
    required this.earningsHistory,
    super.key,
  });

  final double totalEarnings;
  final int completedTrips;
  final List<EarningsPoint> earningsHistory;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.appColors.earningsCard; // ← sigue el tema
    final textColor = context.appColors.text; // ← sigue el tema
    final mutedColor = context.appColors.textSecondary;

    return GestureDetector(
      onTap: () => AppRouter.push(ConductorRoutesPath.metrics),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.appColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DailyEarningsHeader(
              totalEarnings: totalEarnings,
              completedTrips: completedTrips,
              onCard: false, // ← false porque ya no es amarilla, sigue el tema
            ),
            12.verticalSpace,
            SizedBox(
              height: 120,
              child: EarningsLineChart(
                points: earningsHistory,
                lineColor: AppColors.sixth, // teal siempre
                gradientColor: AppColors.sixth,
                labelColor: textColor,
              ),
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  'Ver métricas completas',
                  variant: AppTextVariant.labelSmall,
                  color: mutedColor,
                ),
                4.horizontalSpace,
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10.r,
                  color: mutedColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
