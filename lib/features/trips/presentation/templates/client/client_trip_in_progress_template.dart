import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClientTripInProgressTemplate extends StatefulWidget {
  const ClientTripInProgressTemplate({super.key});

  @override
  State<ClientTripInProgressTemplate> createState() =>
      _ClientTripInProgressTemplateState();
}

class _ClientTripInProgressTemplateState
    extends State<ClientTripInProgressTemplate> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight
        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

    return BlocListener<ClientTripBloc, ClientTripState>(
      listenWhen: (prev, curr) =>
          curr.status == ClientTripStatus.completed &&
          prev.status != ClientTripStatus.completed,
      listener: (_, __) =>
          context.pushReplacement(ClientRoutesPath.rateTrip),
      child: BlocBuilder<ClientTripBloc, ClientTripState>(
        builder: (context, state) {
          final trip = state.activeTrip;
          final origin = LatLng(
            trip?.origenLatitud ?? state.origenLatitud ?? 4.7110,
            trip?.origenLongitud ?? state.origenLongitud ?? -74.0721,
          );
          final destination = LatLng(
            trip?.destinoLatitud ?? state.destinoLatitud ?? 4.7200,
            trip?.destinoLongitud ?? state.destinoLongitud ?? -74.0650,
          );

          return Scaffold(
            body: Stack(
              children: [
                // ── Mapa ────────────────────────────────────────────────
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
                          width: 36.r,
                          height: 36.r,
                          child: Icon(Icons.trip_origin_rounded,
                              color: AppColors.fifth, size: 28.r),
                        ),
                        Marker(
                          point: destination,
                          width: 36.r,
                          height: 36.r,
                          child: Icon(Icons.location_on_rounded,
                              color: AppColors.sevent, size: 32.r),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Status card ──────────────────────────────────────────
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
                          color: context.appColors.mapCardBg,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.third
                                    .withValues(alpha: 0.15),
                              ),
                              child: Icon(Icons.directions_car_rounded,
                                  color: AppColors.third, size: 22.r),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'VIAJE EN CURSO',
                                    variant: AppTextVariant.labelMedium,
                                    color: AppColors.third,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  4.verticalSpace,
                                  AppText(
                                    trip?.destinoDireccion ??
                                        state.destinoDireccion ??
                                        '--',
                                    variant: AppTextVariant.bodySmall,
                                    color: context.appColors.textSecondary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Código de viaje ──────────────────────────────────────
                if (trip?.codigoViaje != null)
                  Positioned(
                    bottom: 32.h,
                    left: 24.w,
                    right: 24.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: context.appColors.mapCardBg,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            'Código: ',
                            variant: AppTextVariant.bodyMedium,
                            color: context.appColors.textSecondary,
                          ),
                          AppText(
                            trip!.codigoViaje,
                            variant: AppTextVariant.titleSmall,
                            color: context.appColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
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
