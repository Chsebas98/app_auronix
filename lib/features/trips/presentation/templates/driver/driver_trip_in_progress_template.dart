import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class DriverTripInProgressTemplate extends StatefulWidget {
  const DriverTripInProgressTemplate({super.key});

  @override
  State<DriverTripInProgressTemplate> createState() =>
      _DriverTripInProgressTemplateState();
}

class _DriverTripInProgressTemplateState
    extends State<DriverTripInProgressTemplate> {
  final _mapController = MapController();

  static const _lightTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight ? _lightTileUrl : _darkTileUrl;

    return BlocListener<DriverTripBloc, DriverTripState>(
      listenWhen: (prev, curr) =>
          curr.status == DriverTripStatus.completed &&
          prev.status != DriverTripStatus.completed,
      listener: (context, state) =>
          context.pushReplacement(ConductorRoutesPath.rateTrip),
      child: BlocBuilder<DriverTripBloc, DriverTripState>(
        builder: (context, state) {
          final trip = state.activeTrip;
          final origin = trip != null
              ? LatLng(trip.origenLatitud, trip.origenLongitud)
              : const LatLng(4.7110, -74.0721);
          final destination = trip != null
              ? LatLng(trip.destinoLatitud, trip.destinoLongitud)
              : const LatLng(4.7200, -74.0650);

          final isStarting = state.status == DriverTripStatus.starting;
          final isCompleting = state.status == DriverTripStatus.completing;
          final isInProgress = state.status == DriverTripStatus.inProgress;
          final cardBg = context.appColors.mapCardBg;

          return Scaffold(
            body: Stack(
              children: [
                // ── Mapa ───────────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: origin,
                    initialZoom: 13.5,
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
                          width: 40.r,
                          height: 40.r,
                          child: Icon(
                            Icons.trip_origin_rounded,
                            color: AppColors.fifth,
                            size: 32.r,
                          ),
                        ),
                        Marker(
                          point: destination,
                          width: 40.r,
                          height: 40.r,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.sevent,
                            size: 36.r,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Info card ──────────────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      child: Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.directions_car_rounded,
                                    color: context.appColors.button,
                                    size: 20.r),
                                8.horizontalSpace,
                                AppText(
                                  isInProgress
                                      ? 'VIAJE EN CURSO'
                                      : 'VIAJE ACEPTADO',
                                  variant: AppTextVariant.titleSmall,
                                  color: context.appColors.text,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                            if (trip != null) ...[
                              8.verticalSpace,
                              _InfoRow(
                                icon: Icons.trip_origin_rounded,
                                color: AppColors.fifth,
                                label: trip.origenDireccion,
                              ),
                              4.verticalSpace,
                              _InfoRow(
                                icon: Icons.location_on_rounded,
                                color: AppColors.sevent,
                                label: trip.destinoDireccion,
                              ),
                              8.verticalSpace,
                              Row(
                                children: [
                                  AppText(
                                    '${trip.distanciaKm.toStringAsFixed(1)} km  •  ',
                                    variant: AppTextVariant.bodySmall,
                                    color: context.appColors.textSecondary,
                                  ),
                                  AppText(
                                    '\$${trip.precioTotal.toStringAsFixed(2)}',
                                    variant: AppTextVariant.bodyMedium,
                                    color: AppColors.third,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Action button ──────────────────────────────────────────
                Positioned(
                  bottom: 32.h,
                  left: 24.w,
                  right: 24.w,
                  child: isInProgress
                      ? AppButton(
                          label: 'COMPLETAR VIAJE',
                          variant: AppButtonVariant.filled,
                          isLoading: isCompleting,
                          expand: true,
                          onPressed: () => context.read<DriverTripBloc>().add(
                                DriverTripCompleteEvent(
                                  userId: 0,
                                  tripId: trip?.id ?? 0,
                                  distanciaFinalKm: trip?.distanciaKm ?? 0,
                                  duracionMinutos: 10,
                                ),
                              ),
                        )
                      : AppButton(
                          label: 'INICIAR VIAJE',
                          variant: AppButtonVariant.filled,
                          isLoading: isStarting,
                          expand: true,
                          onPressed: () => context.read<DriverTripBloc>().add(
                                DriverTripStartEvent(
                                  userId: 0,
                                  tripId: trip?.id ?? 0,
                                ),
                              ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14.r),
        6.horizontalSpace,
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: context.appColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
