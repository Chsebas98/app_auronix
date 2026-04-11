import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsSectionWidget extends StatelessWidget {
  const StatsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.third.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.third.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Text('Por qué elegirnos', style: theme.textTheme.titleLarge),
          SizedBox(height: 20.h),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.people,
                value: '15K+',
                label: 'Usuarios',
                color: AppColors.fifth,
              ),
              _StatItem(
                icon: Icons.business,
                value: '50+',
                label: 'Cooperativas',
                color: AppColors.third,
              ),
              _StatItem(
                icon: Icons.star,
                value: '4.8',
                label: 'Rating',
                color: AppColors.twelveth,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Beneficios
          _BenefitItem(icon: Icons.check_circle, text: 'Precios transparentes'),
          SizedBox(height: 8.h),
          _BenefitItem(
            icon: Icons.check_circle,
            text: 'Múltiples opciones de pago',
          ),
          SizedBox(height: 8.h),
          _BenefitItem(icon: Icons.check_circle, text: 'Soporte 24/7'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32.r),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.fourth),
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: AppColors.eleventh, size: 20.r),
        SizedBox(width: 12.w),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
