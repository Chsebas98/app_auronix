import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/features/home/presentation/atoms/home_greeting_text.dart';
import 'package:auronix_app/features/home/presentation/atoms/home_location_row.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverHomeHeroContent extends StatelessWidget {
  const DriverHomeHeroContent({
    required this.firstName,
    required this.address,
    required this.isLoadingAddress,
    required this.isAvailable,
    required this.onRefreshLocation,
    required this.onToggleAvailability,
    super.key,
  });

  final String firstName;
  final String address;
  final bool isLoadingAddress;
  final bool isAvailable;
  final VoidCallback onRefreshLocation;
  final VoidCallback onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.brightness == Brightness.light
              ? [
                  AppColors.third.withValues(alpha: 0.15),
                  theme.primaryColor.withValues(alpha: 0.0),
                ]
              : [
                  AppColors.third.withValues(alpha: 0.08),
                  theme.primaryColor.withValues(alpha: 0.0),
                ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeGreetingText(firstName: firstName),
          8.verticalSpace,
          HomeLocationRow(
            address: address,
            isLoading: isLoadingAddress,
            onRefresh: onRefreshLocation,
          ),
          16.verticalSpace,
          _AvailabilityToggle(
            isAvailable: isAvailable,
            onToggle: onToggleAvailability,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({
    required this.isAvailable,
    required this.onToggle,
  });

  final bool isAvailable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          isAvailable ? 'Disponible' : 'No disponible',
          variant: AppTextVariant.titleSmall,
          fontWeight: FontWeight.w600,
          color: isAvailable ? AppColors.eleventh : AppColors.gray500,
        ),
        const Spacer(),
        Switch.adaptive(
          value: isAvailable,
          onChanged: (_) => onToggle(),
          activeColor: AppColors.eleventh,
        ),
      ],
    );
  }
}
