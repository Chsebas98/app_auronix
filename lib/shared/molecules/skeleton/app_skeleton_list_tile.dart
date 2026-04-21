import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/skeleton/app_skeleton_box.dart';
import 'package:flutter/material.dart';

class AppSkeletonListTile extends StatelessWidget {
  const AppSkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSkeletonBox(width: 48, height: 48, borderRadius: AppRadius.md),
        SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBox(height: 14),
              SizedBox(height: AppSpacing.x2),
              AppSkeletonBox(height: 12, borderRadius: AppRadius.xs),
              SizedBox(height: AppSpacing.x2),
              AppSkeletonBox(height: 12, borderRadius: AppRadius.xs),
            ],
          ),
        ),
      ],
    );
  }
}
