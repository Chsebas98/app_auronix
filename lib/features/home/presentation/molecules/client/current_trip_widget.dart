import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CurrentTripWidget extends StatelessWidget {
  const CurrentTripWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientTripBloc, ClientTripState>(
      builder: (context, state) {
        if (state.status == ClientTripStatus.initial ||
            state.status == ClientTripStatus.cancelled ||
            state.status == ClientTripStatus.rated ||
            state.status == ClientTripStatus.error) {
          return const SizedBox.shrink();
        }

        final (label, color, route, icon) = switch (state.status) {
          ClientTripStatus.searching => (
              'Buscando conductor...',
              AppColors.third,
              ClientRoutesPath.searchingDriver,
              Icons.search_rounded,
            ),
          ClientTripStatus.requesting => (
              'Solicitando viaje...',
              AppColors.sixth,
              ClientRoutesPath.searchingDriver,
              Icons.hourglass_top_rounded,
            ),
          ClientTripStatus.accepted => (
              'Conductor en camino',
              AppColors.eleventh,
              ClientRoutesPath.tripInProgress,
              Icons.directions_car_rounded,
            ),
          ClientTripStatus.inProgress => (
              'Viaje en curso',
              AppColors.fifth,
              ClientRoutesPath.tripInProgress,
              Icons.navigation_rounded,
            ),
          ClientTripStatus.completed => (
              'Viaje completado',
              AppColors.eleventh,
              ClientRoutesPath.rateTrip,
              Icons.check_circle_rounded,
            ),
          _ => (
              'Viaje activo',
              AppColors.third,
              ClientRoutesPath.tripInProgress,
              Icons.directions_car_rounded,
            ),
        };

        return GestureDetector(
          onTap: () => context.push(route),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22.r),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        label,
                        variant: AppTextVariant.titleSmall,
                        color: context.appColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                      if (state.activeTrip?.destinoDireccion != null) ...[
                        4.verticalSpace,
                        AppText(
                          state.activeTrip!.destinoDireccion,
                          variant: AppTextVariant.bodySmall,
                          color: context.appColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.textSecondary,
                  size: 20.r,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
