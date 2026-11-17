import 'dart:async';

import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_search_sheet.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
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

class ClientSelectDestinationTemplate extends StatefulWidget {
  const ClientSelectDestinationTemplate({super.key});

  @override
  State<ClientSelectDestinationTemplate> createState() =>
      _ClientSelectDestinationTemplateState();
}

class _ClientSelectDestinationTemplateState
    extends State<ClientSelectDestinationTemplate> {
  final Completer<GoogleMapController> _mapCompleter = Completer();

  double _originLat = 0;
  double _originLng = 0;
  String _originAddress = 'Obteniendo ubicación...';
  bool _originReady = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initOrigin();
    }
  }

  bool _looksLikeCoords(String text) =>
      RegExp(r'^-?\d+\.\d+,\s*-?\d+\.\d+$').hasMatch(text.trim());

  Future<void> _initOrigin() async {
    final extra =
        GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (extra != null) {
      final lat = extra['lat'] as double? ?? 0;
      final lng = extra['lng'] as double? ?? 0;
      final address = extra['address'] as String? ?? '';
      if (lat != 0 && lng != 0) {
        _originLat = lat;
        _originLng = lng;
        _originReady = true;

        if (address.isNotEmpty && !_looksLikeCoords(address)) {
          _originAddress = address;
          if (mounted) setState(() {});
        } else {
          _originAddress = 'Obteniendo dirección...';
          if (mounted) setState(() {});
          final geocoded =
              await sl<PlacesService>().reverseGeocode(lat, lng);
          _originAddress = geocoded ?? 'Mi ubicación actual';
          if (mounted) setState(() {});
        }
        return;
      }
    }

    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        if (mounted) {
          setState(() => _originAddress = 'Ubicación no disponible');
        }
        return;
      }

      _originLat = position.latitude;
      _originLng = position.longitude;
      _originReady = true;
      _originAddress = 'Obteniendo dirección...';
      if (mounted) setState(() {});

      final geocoded = await sl<PlacesService>()
          .reverseGeocode(position.latitude, position.longitude);
      _originAddress = geocoded ?? 'Mi ubicación actual';
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _originAddress = 'Ubicación no disponible');
      }
    }
  }

  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ClientHomeSearchSheet(
        originLat: _originLat,
        originLng: _originLng,
        originAddress: _originAddress,
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (!_originReady) return;
    final controller = await _mapCompleter.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_originLat, _originLng),
        15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = _originReady
        ? LatLng(_originLat, _originLng)
        : const LatLng(-0.1807, -78.4678);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ───────────────────────────────────
          // RepaintBoundary: aísla el AndroidView del mapa para que
          // las animaciones de diálogos encima (DialogCubit) no
          // disparen su frame callback de offset a mitad de layout.
          RepaintBoundary(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: target,
                zoom: 15,
              ),
              style: context.isDark ? _darkMapStyle : null,
              onMapCreated: (controller) {
                if (!_mapCompleter.isCompleted) {
                  _mapCompleter.complete(controller);
                }
              },
              myLocationEnabled: _originReady,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),

          // ── Botón volver ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 16.w,
            child: _CircleButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => context.pop(),
            ),
          ),

          // ── Barra de búsqueda ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 64.w,
            right: 16.w,
            child: GestureDetector(
              onTap: _openSearchSheet,
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: context.appColors.textSecondary, size: 20.r),
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

          // ── Card de ubicación actual ───────────────────────
          if (_originAddress.isNotEmpty)
            Positioned(
              bottom: 24.h,
              left: 16.w,
              right: 72.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location_rounded,
                        color: AppColors.fifth, size: 18.r),
                    10.horizontalSpace,
                    Expanded(
                      child: AppText(
                        _originAddress,
                        variant: AppTextVariant.bodySmall,
                        color: context.appColors.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── FAB re-centrar ─────────────────────────────────
          if (_originReady)
            Positioned(
              bottom: 24.h,
              right: 16.w,
              child: _CircleButton(
                icon: Icons.my_location_rounded,
                onTap: _goToCurrentLocation,
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: context.appColors.icon, size: 22.r),
      ),
    );
  }
}
