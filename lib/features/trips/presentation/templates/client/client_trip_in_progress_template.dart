import 'dart:async';

import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
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

class ClientTripInProgressTemplate extends StatefulWidget {
  const ClientTripInProgressTemplate({super.key});

  @override
  State<ClientTripInProgressTemplate> createState() =>
      _ClientTripInProgressTemplateState();
}

class _ClientTripInProgressTemplateState
    extends State<ClientTripInProgressTemplate> {
  final Completer<GoogleMapController> _mapCompleter = Completer();
  bool _positionListening = false;
  List<LatLng> _routePoints = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_positionListening) {
      _positionListening = true;
      final bloc = context.read<ClientTripBloc>();
      if (bloc.isClosed) return;
      final state = bloc.state;
      final tripId = state.activeTrip?.id;
      if (tripId != null) {
        bloc.add(ClientTripListenPositionEvent(tripId: tripId));
      }
      _loadRoute(state);
    }
  }

  Future<void> _loadRoute(ClientTripState state) async {
    final trip = state.activeTrip;
    final oLat = trip?.origenLatitud ?? state.origenLatitud;
    final oLng = trip?.origenLongitud ?? state.origenLongitud;
    final dLat = trip?.destinoLatitud ?? state.destinoLatitud;
    final dLng = trip?.destinoLongitud ?? state.destinoLongitud;

    if (oLat == null || oLng == null || dLat == null || dLng == null) return;

    final points = await sl<PlacesService>().getRoutePoints(
      originLat: oLat,
      originLng: oLng,
      destLat: dLat,
      destLng: dLng,
    );

    if (mounted && points.isNotEmpty) {
      setState(() {
        _routePoints =
            points.map((p) => LatLng(p[0], p[1])).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            trip?.origenLatitud ?? state.origenLatitud ?? -0.1807,
            trip?.origenLongitud ?? state.origenLongitud ?? -78.4678,
          );
          final destination = LatLng(
            trip?.destinoLatitud ?? state.destinoLatitud ?? -0.1750,
            trip?.destinoLongitud ?? state.destinoLongitud ?? -78.4600,
          );

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
                // ── Google Map ──────────────────────────────────────
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
                    if (state.hasDriverPosition)
                      Marker(
                        markerId: const MarkerId('driver'),
                        position: LatLng(
                            state.driverLat!, state.driverLng!),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueYellow),
                        infoWindow:
                            const InfoWindow(title: 'Conductor'),
                      ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: _routePoints.isNotEmpty
                          ? _routePoints
                          : [origin, destination],
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

                // ── Status card ──────────────────────────────────────
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
                              color: Colors.black.withValues(alpha: 0.12),
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
                                color:
                                    AppColors.third.withValues(alpha: 0.15),
                              ),
                              child: Icon(Icons.directions_car_rounded,
                                  color: AppColors.third, size: 22.r),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                    color:
                                        context.appColors.textSecondary,
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

                // ── Código de viaje ──────────────────────────────────
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
                            color: Colors.black.withValues(alpha: 0.15),
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
