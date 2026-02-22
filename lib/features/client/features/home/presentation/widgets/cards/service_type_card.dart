import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String priceRange;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const ServiceTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.priceRange,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16.r),
        shadowColor: AppShadowColors.blackSoft,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: 110.w,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              // ✅ Colores específicos
              color: theme.brightness == Brightness.light
                  ? AppColors.lightCard
                  : AppColors.darkCard,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56.r,
                      height: 56.r,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, size: 32.r, color: color),
                    ),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        // ✅ Color específico
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      priceRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        // ✅ Color específico
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                // Badge (resto igual)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
