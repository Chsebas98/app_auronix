import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ClientSaveTripsTemplate extends StatelessWidget {
  const ClientSaveTripsTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.appColors.icon, size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          'Viajes guardados',
          variant: AppTextVariant.titleMedium,
          color: context.appColors.text,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.third.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_outline_rounded,
                  color: AppColors.third,
                  size: 40.r,
                ),
              ),
              24.verticalSpace,
              AppText(
                'Sin destinos guardados',
                variant: AppTextVariant.titleSmall,
                color: context.appColors.text,
                fontWeight: FontWeight.w700,
                align: TextAlign.center,
              ),
              12.verticalSpace,
              AppText(
                'Guarda tus destinos frecuentes para solicitar viajes más rápido.',
                variant: AppTextVariant.bodyMedium,
                color: context.appColors.textSecondary,
                align: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'SOLICITAR UN VIAJE',
                variant: AppButtonVariant.filled,
                expand: true,
                onPressed: () => context.go(ClientRoutesPath.trips),
              ),
              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
