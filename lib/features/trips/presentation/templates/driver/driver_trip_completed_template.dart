import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DriverTripCompletedTemplate extends StatelessWidget {
  const DriverTripCompletedTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final result = state.completedTrip;

        return Scaffold(
          backgroundColor: context.appColors.background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ── Icono de éxito ────────────────────────────────────
                  Container(
                    width: 96.r,
                    height: 96.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.eleventh.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.eleventh,
                      size: 56.r,
                    ),
                  ),
                  24.verticalSpace,

                  AppText(
                    '¡Viaje completado!',
                    variant: AppTextVariant.headlineSmall,
                    color: context.appColors.text,
                    fontWeight: FontWeight.w800,
                    align: TextAlign.center,
                  ),
                  8.verticalSpace,
                  AppText(
                    'Gracias por tu servicio. Aquí está el resumen del viaje.',
                    variant: AppTextVariant.bodyMedium,
                    color: context.appColors.textSecondary,
                    align: TextAlign.center,
                  ),
                  40.verticalSpace,

                  // ── Resumen card ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Tarifa total',
                          value:
                              '\$${result?.precioTotal.toStringAsFixed(2) ?? '--'}',
                          valueColor: context.appColors.text,
                          bold: true,
                        ),
                        Divider(
                          height: 24.h,
                          color: context.appColors.divider,
                        ),
                        _SummaryRow(
                          label: 'Comisión plataforma',
                          value:
                              '\$${result?.comisionMonto.toStringAsFixed(2) ?? '--'}',
                          valueColor: context.appColors.textSecondary,
                        ),
                        16.verticalSpace,
                        _SummaryRow(
                          label: 'Tu ganancia',
                          value:
                              '\$${result?.montoConductor.toStringAsFixed(2) ?? '--'}',
                          valueColor: AppColors.eleventh,
                          bold: true,
                          large: true,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Botón finalizar ───────────────────────────────────
                  AppButton(
                    label: 'VOLVER AL INICIO',
                    variant: AppButtonVariant.filled,
                    expand: true,
                    onPressed: () =>
                        context.go(ConductorRoutesPath.startTrips),
                  ),
                  16.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
    this.large = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: context.appColors.textSecondary,
        ),
        AppText(
          value,
          variant: large ? AppTextVariant.titleMedium : AppTextVariant.bodyMedium,
          color: valueColor,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ],
    );
  }
}
