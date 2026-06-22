import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const _darkMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#242f3e"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]}
]''';

class DriverTripInProgressTemplate extends StatefulWidget {
  const DriverTripInProgressTemplate({super.key});

  @override
  State<DriverTripInProgressTemplate> createState() =>
      _DriverTripInProgressTemplateState();
}

class _DriverTripInProgressTemplateState
    extends State<DriverTripInProgressTemplate> {
  final Completer<GoogleMapController> _mapCompleter = Completer();

  int _getUserId() {
    final session = context.read<SessionBloc>().state;
    if (session is SessionAuthenticated) {
      return JwtHelpers.getUserId(session.dataUser.tokenAccess) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
              : const LatLng(-0.1807, -78.4678);
          final destination = trip != null
              ? LatLng(trip.destinoLatitud, trip.destinoLongitud)
              : const LatLng(-0.1750, -78.4600);

          final isStarting = state.status == DriverTripStatus.starting;
          final isCompleting = state.status == DriverTripStatus.completing;
          final isInProgress = state.status == DriverTripStatus.inProgress;
          final cardBg = context.appColors.mapCardBg;

          final bounds = LatLngBounds(
            southwest: LatLng(
              origin.latitude < destination.latitude
                  ? origin.latitude
                  : destination.latitude,
              origin.longitude < destination.longitude
                  ? origin.longitude
                  : destination.longitude,
            ),
            northeast: LatLng(
              origin.latitude > destination.latitude
                  ? origin.latitude
                  : destination.latitude,
              origin.longitude > destination.longitude
                  ? origin.longitude
                  : destination.longitude,
            ),
          );

          return Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: origin,
                    zoom: 13.5,
                  ),
                  style: context.isDark ? _darkMapStyle : null,
                  onMapCreated: (controller) {
                    if (!_mapCompleter.isCompleted) {
                      _mapCompleter.complete(controller);
                    }
                    Future.delayed(const Duration(milliseconds: 300), () {
                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 80),
                      );
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('origin'),
                      position: origin,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: [origin, destination],
                      width: 4,
                      color: AppColors.fifth,
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),

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
                              color: Colors.black.withValues(alpha: 0.15),
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
                          onPressed: () {
                            final userId = _getUserId();
                            context.read<DriverTripBloc>().add(
                                  DriverTripCompleteEvent(
                                    userId: userId,
                                    tripId: trip?.id ?? 0,
                                    distanciaFinalKm:
                                        trip?.distanciaKm ?? 0,
                                    duracionMinutos: 10,
                                  ),
                                );
                          },
                        )
                      : AppButton(
                          label: 'INICIAR VIAJE',
                          variant: AppButtonVariant.filled,
                          isLoading: isStarting,
                          expand: true,
                          onPressed: () {
                            final userId = _getUserId();
                            context.read<DriverTripBloc>().add(
                                  DriverTripStartEvent(
                                    userId: userId,
                                    tripId: trip?.id ?? 0,
                                  ),
                                );
                          },
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
