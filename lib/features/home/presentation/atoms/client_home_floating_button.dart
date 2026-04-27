import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientHomeFloatingButton extends StatelessWidget {
  const ClientHomeFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16.r),
      shadowColor: theme.shadowColor,
      child: InkWell(
        onTap: () => AppRouter.push(ClientRoutesPath.selectDestination),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.third, AppColors.nineth],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.third, width: 2.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_taxi_rounded,
                size: 32.r,
                color: AppColors.secondary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Pedir Taxi Ahora',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
