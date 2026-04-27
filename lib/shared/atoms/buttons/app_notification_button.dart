import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppNotificationButton extends StatelessWidget {
  const AppNotificationButton({
    required this.onTap,
    this.hasUnread = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        children: [
          Icon(Icons.notifications_outlined, size: 26.r),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.sevent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
