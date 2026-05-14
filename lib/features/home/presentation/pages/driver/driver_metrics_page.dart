import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/features/home/presentation/atoms/earnings_line_chart.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:auronix_app/shared/molecules/navigation/app_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverMetricsPage extends StatelessWidget {
  const DriverMetricsPage({super.key});

  // TODO: reemplazar con datos reales del TripsBloc
  static final _mockPoints = [
    const EarningsPoint(label: '8am', amount: 0, index: 0),
    const EarningsPoint(label: '10am', amount: 45, index: 1),
    const EarningsPoint(label: '11am', amount: 80, index: 2),
    const EarningsPoint(label: '12pm', amount: 95, index: 3),
    const EarningsPoint(label: '1pm', amount: 180, index: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(
        hasBackButton: true,
        content: AppText(
          'Mis Métricas',
          variant: AppTextVariant.titleMedium,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Ingresos del día',
              variant: AppTextVariant.titleLarge,
              fontWeight: FontWeight.w700,
            ),
            16.verticalSpace,
            SizedBox(
              height: 250.h,
              child: EarningsLineChart(points: _mockPoints),
            ),
          ],
        ),
      ),
    );
  }
}
