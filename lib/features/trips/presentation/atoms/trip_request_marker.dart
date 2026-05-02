import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripRequestMarker extends StatelessWidget {
  const TripRequestMarker({
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.location_on_rounded,
          color: isSelected
              ? AppColors.third
              : AppColors.third.withValues(alpha: 0.85),
          size: isSelected ? 42.r : 36.r,
          shadows: [
            Shadow(
              color: AppColors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
