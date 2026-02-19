import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/home/home-client-bloc/home_client_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroSectionWidget extends StatelessWidget {
  const HeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeClientBloc, HomeClientState>(
      builder: (context, state) {
        final user = state.dataProfile;
        final firstName = user.firstName.isNotEmpty
            ? FormsHelpers.getTextTransform(user.firstName, capitalize: true)
            : 'Usuario';

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
              // Saludo
              Text(
                '👋 ¡Hola, $firstName!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8.h),

              // Ubicación actual
              Row(
                children: [
                  Icon(Icons.location_on, size: 18.r, color: AppColors.third),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Av. Principal 123, Quito', // todo: GPS real
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.fourth,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint('📍 Cambiar ubicación');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Cambiar',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.third,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Buscador de destino
              // Buscador de destino
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12.r),
                shadowColor: theme.brightness == Brightness.light
                    ? AppShadowColors.thirdSoft
                    : AppShadowColors.darkSoft,
                child: InkWell(
                  onTap: () {
                    debugPrint('🔍 Buscar destino');
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      // ✅ Colores específicos
                      color: theme.brightness == Brightness.light
                          ? AppColors.lightInput
                          : AppColors.darkInput,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 24.r,
                          color: theme.brightness == Brightness.light
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            '¿A dónde vas?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.r,
                          color: theme.brightness == Brightness.light
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
