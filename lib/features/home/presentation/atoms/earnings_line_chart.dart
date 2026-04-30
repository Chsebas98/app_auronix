import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EarningsLineChart extends StatelessWidget {
  const EarningsLineChart({
    required this.points,
    this.lineColor = AppColors.sixth, // teal por defecto
    this.gradientColor = AppColors.sixth, // teal por defecto
    this.labelColor, // null = sigue el tema
    super.key,
  });

  final List<EarningsPoint> points;
  final Color lineColor;
  final Color gradientColor;
  final Color?
  labelColor; // opcional — si no se pasa usa context.appColors.text

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    // Si no se pasa labelColor, usa el color de texto del tema
    final resolvedLabelColor = labelColor ?? context.appColors.text;

    final maxY = points.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return AppText(
                  points[index].label,
                  variant: AppTextVariant.labelSmall,
                  color: resolvedLabelColor, // ← siempre explícito
                );
              },
            ),
          ),
        ),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: points
                .map((p) => FlSpot(p.index.toDouble(), p.amount))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  gradientColor.withValues(alpha: 0.35),
                  gradientColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
