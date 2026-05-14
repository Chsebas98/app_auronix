import 'package:auronix_app/shared/atoms/buttons/app_notification_button.dart';
import 'package:auronix_app/shared/atoms/buttons/app_theme_toogle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverHomeAppbarActions extends StatelessWidget {
  const DriverHomeAppbarActions({
    required this.onNotificationTap,
    this.hasUnread = true,
    super.key,
  });

  final VoidCallback onNotificationTap;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppNotificationButton(onTap: onNotificationTap, hasUnread: hasUnread),
        const AppThemeToggle(),
        8.horizontalSpace,
      ],
    );
  }
}
