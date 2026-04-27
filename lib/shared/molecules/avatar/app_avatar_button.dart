import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAvatarButton extends StatelessWidget {
  const HomeAvatarButton({this.photoUrl, required this.onTap, super.key});

  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.third, width: 2.w),
          image: photoUrl != null && photoUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: AppColors.third.withValues(alpha: 0.3),
        ),
        child: photoUrl == null || photoUrl!.isEmpty
            ? Icon(Icons.person, size: 20.r, color: context.appColors.icon)
            : null,
      ),
    );
  }
}
