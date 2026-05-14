import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/features/home/presentation/atoms/home_greeting_text.dart';
import 'package:auronix_app/features/home/presentation/atoms/home_location_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientHomeHeroContent extends StatelessWidget {
  const ClientHomeHeroContent({
    required this.firstName,
    required this.address,
    required this.isLoadingAddress,
    required this.onRefreshLocation,
    super.key,
  });

  final String firstName;
  final String address;
  final bool isLoadingAddress;
  final VoidCallback onRefreshLocation;

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
        ],
      ),
    );
  }
}
