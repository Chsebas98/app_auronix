import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:auronix_app/features/trips/presentation/atoms/driver_car_marker.dart';
import 'package:auronix_app/features/trips/presentation/atoms/trip_request_marker.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/molecules/driver/trip_request_bottom_card.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

class DriverNearbyMap extends StatefulWidget {
  const DriverNearbyMap({super.key});

  @override
  State<DriverNearbyMap> createState() => _DriverNearbyMapState();
}

class _DriverNearbyMapState extends State<DriverNearbyMap> {
  final _mapController = MapController();

  // Light → OpenStreetMap default (beige/colores naturales como la imagen)
  static const _lightTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Dark → CartoDB dark matter
  static const _darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMarkerTap(BuildContext context, TripRequest request) {
    context.read<DriverTripBloc>().add(
      DriverTripSelectRequestEvent(request: request),
    );
    _mapController.move(request.position, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight ? _lightTileUrl : _darkTileUrl;
    final headerBg = isLight
        ? AppColors.white.withValues(alpha: 0.92)
        : AppColors.darkBackground.withValues(alpha: 0.85);
    final headerText = context.appColors.text;

    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final driverPos =
            state.driverPosition ?? const LatLng(4.7110, -74.0721);

        return Stack(
          children: [
            // ── Mapa ──────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: driverPos,
                initialZoom: 14.5,
                onTap: (_, __) {
                  if (state.hasSelectedRequest) {
                    context.read<DriverTripBloc>().add(
                      const DriverTripDismissRequestEvent(),
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  // subdomains solo para CartoDB
                  subdomains: isLight ? const [] : const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.auronix.app',
                ),
                MarkerLayer(
                  markers: [
                    // Marcador del conductor
                    Marker(
                      point: driverPos,
                      width: 56.r,
                      height: 56.r,
                      child: const DriverCarMarker(),
                    ),
                    // Solicitudes cercanas
                    ...state.nearbyRequests.map((request) {
                      final isSelected =
                          state.selectedRequest?.id == request.id;
                      return Marker(
                        point: request.position,
                        width: 48.r,
                        height: 48.r,
                        child: TripRequestMarker(
                          isSelected: isSelected,
                          onTap: () => _onMarkerTap(context, request),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // ── Header ────────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: headerBg,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AppText(
                      'SOLICITUDES CERCANAS',
                      variant: AppTextVariant.titleSmall,
                      color: headerText,
                      fontWeight: FontWeight.w800,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom card animada ────────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: state.hasSelectedRequest ? 0 : -300.h,
              left: 0,
              right: 0,
              child: state.selectedRequest != null
                  ? TripRequestBottomCard(
                      request: state.selectedRequest!,
                      isLoading: state.status == DriverTripStatus.accepting,
                      onAccept: () => context.read<DriverTripBloc>().add(
                        DriverTripAcceptEvent(
                          requestId: state.selectedRequest!.id,
                        ),
                      ),
                      onReject: () => context.read<DriverTripBloc>().add(
                        DriverTripRejectEvent(
                          requestId: state.selectedRequest!.id,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
