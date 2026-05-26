import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ClientTripCompletedTemplate extends StatelessWidget {
  const ClientTripCompletedTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientTripBloc, ClientTripState>(
      builder: (context, state) {
        final trip = state.activeTrip;
        final distancia = state.distanciaEstimadaKm ?? trip?.distanciaKm ?? 0;
        final precio = trip?.precioTotal ?? (distancia * 1800);

        return Scaffold(
          backgroundColor: context.appColors.background,
          body: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ── Icono éxito ─────────────────────────────────────
                  Container(
                    width: 96.r,
                    height: 96.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.eleventh.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.check_circle_rounded,
                        color: AppColors.eleventh, size: 56.r),
                  ),
                  24.verticalSpace,

                  AppText(
                    '¡Llegaste a tu destino!',
                    variant: AppTextVariant.headlineSmall,
                    color: context.appColors.text,
                    fontWeight: FontWeight.w800,
                    align: TextAlign.center,
                  ),
                  8.verticalSpace,
                  AppText(
                    'Gracias por viajar con Auronix.',
                    variant: AppTextVariant.bodyMedium,
                    color: context.appColors.textSecondary,
                    align: TextAlign.center,
                  ),
                  40.verticalSpace,

                  // ── Resumen viaje ───────────────────────────────────
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
                        if (trip?.codigoViaje != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                'Código: ',
                                variant: AppTextVariant.bodySmall,
                                color: context.appColors.textSecondary,
                              ),
                              AppText(
                                trip!.codigoViaje,
                                variant: AppTextVariant.bodyMedium,
                                color: context.appColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Divider(color: context.appColors.divider),
                          12.verticalSpace,
                        ],
                        _SummaryRow(
                          label: 'Distancia',
                          value: '${distancia.toStringAsFixed(1)} km',
                        ),
                        12.verticalSpace,
                        _SummaryRow(
                          label: 'Origen',
                          value: state.origenDireccion ??
                              trip?.origenDireccion ??
                              '--',
                          compact: true,
                        ),
                        12.verticalSpace,
                        _SummaryRow(
                          label: 'Destino',
                          value: state.destinoDireccion ??
                              trip?.destinoDireccion ??
                              '--',
                          compact: true,
                        ),
                        Divider(height: 28.h, color: context.appColors.divider),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'Total pagado',
                              variant: AppTextVariant.titleSmall,
                              color: context.appColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              '\$${(precio / 1000).toStringAsFixed(1)}k',
                              variant: AppTextVariant.titleMedium,
                              color: AppColors.third,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Volver al inicio ────────────────────────────────
                  AppButton(
                    label: 'VOLVER AL INICIO',
                    variant: AppButtonVariant.filled,
                    expand: true,
                    onPressed: () {
                      context
                          .read<ClientTripBloc>()
                          .add(const ClientTripResetEvent());
                      context.go(ClientRoutesPath.home);
                    },
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
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: context.appColors.textSecondary,
        ),
        Flexible(
          child: AppText(
            value,
            variant: AppTextVariant.bodySmall,
            color: context.appColors.text,
            fontWeight: FontWeight.w500,
            align: TextAlign.end,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
