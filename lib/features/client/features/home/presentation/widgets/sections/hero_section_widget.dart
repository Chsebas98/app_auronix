import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/features/home/home-client-bloc/home_client_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroSectionWidget extends StatefulWidget {
  const HeroSectionWidget({super.key});

  @override
  State<HeroSectionWidget> createState() => _HeroSectionWidgetState();
}

class _HeroSectionWidgetState extends State<HeroSectionWidget> {
  @override
  void initState() {
    super.initState();
    // Obtener ubicación al iniciar
    context.read<HomeClientBloc>().add(GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeClientBloc, HomeClientState>(
      builder: (context, state) {
        final user = state.dataProfile;
        final firstName = user.firstName.isNotEmpty
            ? FormsHelpers.getTextTransform(user.firstName, capitalize: true)
            : 'Usuario';

        // ✅ Obtener dirección del state
        final address = state.currentAddress.isEmpty
            ? 'Obteniendo ubicación...'
            : state.currentAddress;

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
              Row(
                children: [
                  Icon(
                    Icons.waving_hand_rounded,
                    size: 24.r,
                    color: AppColors.third,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      '¡Hola, $firstName!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              8.verticalSpace,

              // Ubicación actual
              Row(
                children: [
                  // ✅ Mostrar loading si está cargando
                  state.isLoadingAddress
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.location_on,
                          size: 18.r,
                          color: AppColors.third,
                        ),
                  6.horizontalSpace,
                  Expanded(
                    child: Text(
                      address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.fourth,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: state.isLoadingAddress
                        ? null
                        : () {
                            debugPrint('📍 Actualizando ubicación');
                            context.read<HomeClientBloc>().add(
                              GetCurrentLocationEvent(),
                            );
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
                        color: state.isLoadingAddress
                            ? AppColors.fourth.withValues(alpha: 0.5)
                            : AppColors.third,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              16.verticalSpace,

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
                    // TODO: Navegar a seleccionar destino
                    // AppRouter.push(ClientRoutesPath.selectDestination);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
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
                        12.horizontalSpace,
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
