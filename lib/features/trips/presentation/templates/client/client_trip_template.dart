import 'dart:async';

import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
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

class ClientTripTemplate extends StatefulWidget {
  const ClientTripTemplate({super.key});

  @override
  State<ClientTripTemplate> createState() => _ClientTripTemplateState();
}

class _ClientTripTemplateState extends State<ClientTripTemplate> {
  final Completer<GoogleMapController> _mapCompleter = Completer();
  LatLng _currentPos = const LatLng(-0.1807, -78.4678);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos != null && mounted) {
        setState(() => _currentPos = LatLng(pos!.latitude, pos.longitude));
        if (_mapCompleter.isCompleted) {
          final controller = await _mapCompleter.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPos, 14.5),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ClientTripBloc, ClientTripState>(
          listenWhen: (prev, curr) =>
              curr.status == ClientTripStatus.searching &&
              prev.status != ClientTripStatus.searching,
          listener: (_, __) =>
              context.push(ClientRoutesPath.searchingDriver),
        ),
        BlocListener<ClientTripBloc, ClientTripState>(
          listenWhen: (prev, curr) =>
              curr.status == ClientTripStatus.accepted &&
              prev.status != ClientTripStatus.accepted,
          listener: (_, __) =>
              context.pushReplacement(ClientRoutesPath.tripInProgress),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // RepaintBoundary: aísla el AndroidView del mapa para que
            // las animaciones de diálogos encima (DialogCubit) no
            // disparen su frame callback de offset a mitad de layout.
            RepaintBoundary(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPos,
                  zoom: 14.5,
                ),
                style: context.isDark ? _darkMapStyle : null,
                onMapCreated: (controller) {
                  if (!_mapCompleter.isCompleted) {
                    _mapCompleter.complete(controller);
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 8.h),
                  child: GestureDetector(
                    onTap: () =>
                        context.push(ClientRoutesPath.selectDestination),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
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
                          Icon(
                            Icons.search_rounded,
                            color: context.appColors.textSecondary,
                            size: 20.r,
                          ),
                          12.horizontalSpace,
                          AppText(
                            '¿A dónde vas?',
                            variant: AppTextVariant.bodyMedium,
                            color: context.appColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 32.h,
              left: 24.w,
              right: 24.w,
              child: AppButton(
                label: 'SOLICITAR VIAJE',
                variant: AppButtonVariant.filled,
                expand: true,
                onPressed: () =>
                    context.push(ClientRoutesPath.selectDestination),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
