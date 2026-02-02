import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HowItWorksSectionWidget extends StatelessWidget {
  const HowItWorksSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Column(
      children: [
        const SectionHeader(
          title: 'Es fácil y rápido',
          subtitle: 'Solo 3 pasos para tu viaje',
          icon: Icons.info_outline,
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _StepItem(
                number: '1',
                title: 'Ingresa tu destino',
                description: 'Dinos a dónde quieres ir',
                icon: Icons.location_on,
                color: AppColors.eleventh,
              ),
              SizedBox(height: 16.h),
              _StepItem(
                number: '2',
                title: 'Elige cooperativa',
                description: 'Compara precios y tiempos',
                icon: Icons.business,
                color: AppColors.third,
              ),
              SizedBox(height: 16.h),
              _StepItem(
                number: '3',
                title: 'Confirma y paga',
                description: 'Tu taxi llegará en minutos',
                icon: Icons.check_circle,
                color: AppColors.sixth,
              ),
              SizedBox(height: 20.h),
              OutlinedButton.icon(
                onPressed: () {
                  debugPrint('📺 Ver tutorial completo');
                },
                icon: Icon(Icons.play_circle_outline, size: 20.r),
                label: const Text('Ver Tutorial Completo'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Número
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.w),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),

        SizedBox(width: 16.w),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20.r, color: color),
                  SizedBox(width: 6.w),
                  Text(title, style: theme.textTheme.titleSmall),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.fourth,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
