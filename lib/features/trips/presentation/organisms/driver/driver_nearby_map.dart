import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/molecules/driver/trip_request_bottom_card.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class DriverNearbyMap extends StatefulWidget {
  const DriverNearbyMap({super.key});

  @override
  State<DriverNearbyMap> createState() => _DriverNearbyMapState();
}

class _DriverNearbyMapState extends State<DriverNearbyMap> {
  final Completer<GoogleMapController> _mapCompleter = Completer();

  int _getUserId() {
    final session = context.read<SessionBloc>().state;
    if (session is SessionAuthenticated) {
      return JwtHelpers.getUserId(session.dataUser.tokenAccess) ?? 0;
    }
    return 0;
  }

  Future<void> _onMarkerTap(
      BuildContext context, TripRequest request) async {
    context.read<DriverTripBloc>().add(
          DriverTripSelectRequestEvent(request: request),
        );
    if (_mapCompleter.isCompleted) {
      final controller = await _mapCompleter.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(request.position.latitude, request.position.longitude),
          15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerBg = context.isLight
        ? AppColors.white.withValues(alpha: 0.92)
        : AppColors.darkBackground.withValues(alpha: 0.85);

    return BlocListener<DriverTripBloc, DriverTripState>(
      listenWhen: (prev, curr) =>
          prev.driverPosition == null && curr.driverPosition != null,
      listener: (context, state) async {
        if (_mapCompleter.isCompleted && state.driverPosition != null) {
          final controller = await _mapCompleter.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(state.driverPosition!.latitude,
                  state.driverPosition!.longitude),
              14.5,
            ),
          );
        }
      },
      child: BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final driverPos = state.driverPosition != null
            ? LatLng(state.driverPosition!.latitude,
                state.driverPosition!.longitude)
            : const LatLng(-0.1807, -78.4678);

        final markers = <Marker>{};

        for (final request in state.nearbyRequests) {
          markers.add(
            Marker(
              markerId: MarkerId('request_${request.id}'),
              position: LatLng(
                  request.position.latitude, request.position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                state.selectedRequest?.id == request.id
                    ? BitmapDescriptor.hueYellow
                    : BitmapDescriptor.hueOrange,
              ),
              onTap: () => _onMarkerTap(context, request),
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: driverPos,
                zoom: 14.5,
              ),
              style: context.isDark ? _darkMapStyle : null,
              onMapCreated: (controller) {
                if (!_mapCompleter.isCompleted) {
                  _mapCompleter.complete(controller);
                }
              },
              onTap: (_) {
                if (state.hasSelectedRequest) {
                  context.read<DriverTripBloc>().add(
                        const DriverTripDismissRequestEvent(),
                      );
                }
              },
              markers: markers,
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: headerBg,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AppText(
                      'SOLICITUDES CERCANAS',
                      variant: AppTextVariant.titleSmall,
                      color: context.appColors.text,
                      fontWeight: FontWeight.w800,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: state.hasSelectedRequest ? 0 : -300.h,
              left: 0,
              right: 0,
              child: state.selectedRequest != null
                  ? TripRequestBottomCard(
                      request: state.selectedRequest!,
                      isLoading:
                          state.status == DriverTripStatus.accepting,
                      onAccept: () {
                        final userId = _getUserId();
                        context.read<DriverTripBloc>().add(
                              DriverTripAcceptEvent(
                                requestId: state.selectedRequest!.id,
                                tripId: int.tryParse(
                                        state.selectedRequest!.id) ??
                                    0,
                                userId: userId,
                              ),
                            );
                      },
                      onReject: () {
                        final userId = _getUserId();
                        context.read<DriverTripBloc>().add(
                              DriverTripRejectEvent(
                                userId: userId,
                                tripId: int.tryParse(
                                        state.selectedRequest!.id) ??
                                    0,
                                requestId: state.selectedRequest!.id,
                              ),
                            );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    ),
    );
  }
}
