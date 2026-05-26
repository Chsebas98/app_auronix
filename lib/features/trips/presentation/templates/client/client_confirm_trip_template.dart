import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClientConfirmTripTemplate extends StatelessWidget {
  const ClientConfirmTripTemplate({super.key});

  // Precio estimado por km (MVP — hasta que el backend calcule precio real)
  static const _precioKm = 1800.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientTripBloc, ClientTripState>(
      builder: (context, state) {
        final isLight = context.isLight;
        final tileUrl = isLight
            ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
            : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

        final origin = LatLng(
          state.origenLatitud ?? 4.7110,
          state.origenLongitud ?? -74.0721,
        );
        final destination = LatLng(
          state.destinoLatitud ?? 4.7200,
          state.destinoLongitud ?? -74.0650,
        );
        final distancia = state.distanciaEstimadaKm ?? 2.5;
        final precioEstimado = distancia * _precioKm;
        final isRequesting = state.status == ClientTripStatus.requesting;

        return Scaffold(
          backgroundColor: context.appColors.background,
          appBar: AppBar(
            backgroundColor: context.appColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: context.appColors.icon, size: 20.r),
              onPressed: () => context.pop(),
            ),
            title: AppText(
              'Confirmar viaje',
              variant: AppTextVariant.titleMedium,
              color: context.appColors.text,
              fontWeight: FontWeight.w700,
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // ── Mini mapa ─────────────────────────────────────────────
              SizedBox(
                height: 200.h,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      (origin.latitude + destination.latitude) / 2,
                      (origin.longitude + destination.longitude) / 2,
                    ),
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains:
                          isLight ? const [] : const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.auronix.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [origin, destination],
                          strokeWidth: 4,
                          color: AppColors.fifth,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: origin,
                          width: 32.r,
                          height: 32.r,
                          child: Icon(Icons.trip_origin_rounded,
                              color: AppColors.fifth, size: 24.r),
                        ),
                        Marker(
                          point: destination,
                          width: 32.r,
                          height: 32.r,
                          child: Icon(Icons.location_on_rounded,
                              color: AppColors.sevent, size: 28.r),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Detalles ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteRow(
                        icon: Icons.trip_origin_rounded,
                        color: AppColors.fifth,
                        label: 'Origen',
                        address: state.origenDireccion ?? '--',
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 9.w),
                        child: Container(
                            height: 24.h,
                            width: 2,
                            color: context.appColors.border),
                      ),
                      _RouteRow(
                        icon: Icons.location_on_rounded,
                        color: AppColors.sevent,
                        label: 'Destino',
                        address: state.destinoDireccion ?? '--',
                      ),
                      24.verticalSpace,
                      Divider(color: context.appColors.divider),
                      24.verticalSpace,

                      // ── Resumen ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoChip(
                            icon: Icons.straighten_rounded,
                            value: '${distancia.toStringAsFixed(1)} km',
                            label: 'Distancia',
                          ),
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            value: '~${(distancia * 3).round()} min',
                            label: 'Tiempo est.',
                          ),
                          _InfoChip(
                            icon: Icons.attach_money_rounded,
                            value:
                                '\$${(precioEstimado / 1000).toStringAsFixed(1)}k',
                            label: 'Precio est.',
                            highlight: true,
                          ),
                        ],
                      ),
                      32.verticalSpace,

                      // ── Confirmar ─────────────────────────────────────
                      AppButton(
                        label: 'SOLICITAR VIAJE',
                        variant: AppButtonVariant.filled,
                        expand: true,
                        isLoading: isRequesting,
                        onPressed: () =>
                            context.read<ClientTripBloc>().add(
                                  ClientTripRequestEvent(
                                    userId: 0,
                                    origenLatitud: state.origenLatitud ?? 4.7110,
                                    origenLongitud:
                                        state.origenLongitud ?? -74.0721,
                                    origenDireccion:
                                        state.origenDireccion ?? '',
                                    destinoLatitud:
                                        state.destinoLatitud ?? 4.7200,
                                    destinoLongitud:
                                        state.destinoLongitud ?? -74.0650,
                                    destinoDireccion:
                                        state.destinoDireccion ?? '',
                                    distanciaEstimadaKm: distancia,
                                  ),
                                ),
                      ),
                      16.verticalSpace,
                    ],
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

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.r),
        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label,
                  variant: AppTextVariant.labelSmall,
                  color: context.appColors.textSecondary),
              4.verticalSpace,
              AppText(address,
                  variant: AppTextVariant.bodyMedium,
                  color: context.appColors.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.third.withValues(alpha: 0.12)
            : context.appColors.card,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: highlight ? AppColors.third : context.appColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: highlight ? AppColors.third : context.appColors.icon,
              size: 18.r),
          6.verticalSpace,
          AppText(
            value,
            variant: AppTextVariant.titleSmall,
            color: highlight ? AppColors.third : context.appColors.text,
            fontWeight: FontWeight.w700,
          ),
          2.verticalSpace,
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: context.appColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
