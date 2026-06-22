import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
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

class ClientConfirmTripTemplate extends StatefulWidget {
  const ClientConfirmTripTemplate({super.key});

  @override
  State<ClientConfirmTripTemplate> createState() =>
      _ClientConfirmTripTemplateState();
}

class _ClientConfirmTripTemplateState
    extends State<ClientConfirmTripTemplate> {
  static const _precioKm = 1.8;
  static const _maxPickupDistanceM = 200.0;

  final Completer<GoogleMapController> _mapCompleter = Completer();
  final _places = sl<PlacesService>();

  // GPS real del usuario (para validar radio)
  double _gpsLat = 0;
  double _gpsLng = 0;

  // Posición del pin (centro del mapa)
  double _pickupLat = 0;
  double _pickupLng = 0;
  String _pickupAddress = 'Mueve el mapa para ajustar';
  bool _isGeocodingPickup = false;

  // Destino
  double _destLat = 0;
  double _destLng = 0;
  String _destAddress = '';

  double _distanceKm = 0;
  double _pickupDistanceM = 0;
  Timer? _geocodeTimer;

  bool get _isOutOfRange => _pickupDistanceM > _maxPickupDistanceM;
  bool get _hasRoute => _destLat != 0 || _destLng != 0;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initFromState();
    }
  }

  @override
  void dispose() {
    _geocodeTimer?.cancel();
    super.dispose();
  }

  Future<void> _initFromState() async {
    final state = context.read<ClientTripBloc>().state;

    if (state.destinoLatitud != null && state.destinoLongitud != null) {
      _destLat = state.destinoLatitud!;
      _destLng = state.destinoLongitud!;
      _destAddress = state.destinoDireccion ?? '';
    }

    if (state.origenLatitud != null &&
        state.origenLongitud != null &&
        (state.origenLatitud != 0 || state.origenLongitud != 0)) {
      _gpsLat = state.origenLatitud!;
      _gpsLng = state.origenLongitud!;
      _pickupLat = _gpsLat;
      _pickupLng = _gpsLng;
      _pickupAddress = state.origenDireccion ?? 'Mi ubicación actual';
    } else {
      await _fetchGps();
    }

    _recalculate();
    if (mounted) setState(() {});

    if (_pickupLat != 0 && _mapCompleter.isCompleted) {
      final controller = await _mapCompleter.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_pickupLat, _pickupLng),
          16,
        ),
      );
    }
  }

  Future<void> _fetchGps() async {
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
      if (pos == null) return;
      _gpsLat = pos.latitude;
      _gpsLng = pos.longitude;
      _pickupLat = _gpsLat;
      _pickupLng = _gpsLng;
    } catch (_) {}
  }

  void _onCameraMove(CameraPosition position) {
    _pickupLat = position.target.latitude;
    _pickupLng = position.target.longitude;
  }

  void _onCameraIdle() {
    _recalculate();
    setState(() {
      _pickupAddress = 'Obteniendo dirección...';
      _isGeocodingPickup = true;
    });
    _geocodeTimer?.cancel();
    _geocodeTimer = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode();
    });
  }

  void _recalculate() {
    if (_gpsLat != 0 && _pickupLat != 0) {
      _pickupDistanceM = Geolocator.distanceBetween(
        _gpsLat, _gpsLng, _pickupLat, _pickupLng,
      );
    }
    if (_hasRoute && _pickupLat != 0) {
      _distanceKm = Geolocator.distanceBetween(
            _pickupLat, _pickupLng, _destLat, _destLng,
          ) /
          1000;
    }
  }

  Future<void> _reverseGeocode() async {
    final address = await _places.reverseGeocode(_pickupLat, _pickupLng);
    if (!mounted) return;
    setState(() {
      _pickupAddress = address ??
          '${_pickupLat.toStringAsFixed(4)}, ${_pickupLng.toStringAsFixed(4)}';
      _isGeocodingPickup = false;
    });
  }

  void _onRequestTrip(BuildContext context) {
    if (!_hasRoute || _isOutOfRange) return;

    final session = context.read<SessionBloc>().state;
    final userId = session is SessionAuthenticated
        ? JwtHelpers.getUserId(session.dataUser.tokenAccess) ?? 0
        : 0;

    context.read<ClientTripBloc>().add(
          ClientTripSetRouteEvent(
            origenLatitud: _pickupLat,
            origenLongitud: _pickupLng,
            origenDireccion: _pickupAddress,
            destinoLatitud: _destLat,
            destinoLongitud: _destLng,
            destinoDireccion: _destAddress,
            distanciaEstimadaKm: _distanceKm,
          ),
        );

    context.read<ClientTripBloc>().add(
          ClientTripRequestEvent(
            userId: userId,
            origenLatitud: _pickupLat,
            origenLongitud: _pickupLng,
            origenDireccion: _pickupAddress,
            destinoLatitud: _destLat,
            destinoLongitud: _destLng,
            destinoDireccion: _destAddress,
            distanciaEstimadaKm: _distanceKm,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final precio = _distanceKm * _precioKm;
    final initialTarget = _pickupLat != 0
        ? LatLng(_pickupLat, _pickupLng)
        : const LatLng(-0.1807, -78.4678);

    return BlocListener<ClientTripBloc, ClientTripState>(
      listenWhen: (prev, curr) =>
          curr.status == ClientTripStatus.searching &&
          prev.status != ClientTripStatus.searching,
      listener: (_, __) =>
          context.pushReplacement('/client/searching-driver'),
      child: BlocBuilder<ClientTripBloc, ClientTripState>(
        builder: (context, state) {
          final isRequesting = state.status == ClientTripStatus.requesting;

          return Scaffold(
            backgroundColor: context.appColors.background,
            body: Stack(
              children: [
                // ── Google Map ───────────────────────────────────
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 16,
                  ),
                  style: context.isDark ? _darkMapStyle : null,
                  onMapCreated: (controller) {
                    if (!_mapCompleter.isCompleted) {
                      _mapCompleter.complete(controller);
                    }
                    if (_pickupLat != 0) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(_pickupLat, _pickupLng),
                            16,
                          ),
                        );
                      });
                    }
                  },
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  markers: {
                    if (_destLat != 0)
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: LatLng(_destLat, _destLng),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),

                // ── Pin fijo al centro ──────────────────────────
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 48.r,
                          color: _isOutOfRange
                              ? AppColors.sevent
                              : AppColors.fifth,
                        ),
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── AppBar transparente ─────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            margin: EdgeInsets.all(12.r),
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: context.appColors.mapCardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: context.appColors.icon,
                              size: 18.r,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                right: 16.w, top: 12.h, bottom: 12.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: context.appColors.mapCardBg,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AppText(
                              'Selecciona punto de recogida',
                              variant: AppTextVariant.bodySmall,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Warning fuera de rango ──────────────────────
                if (_isOutOfRange)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 70.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.sevent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.white, size: 18.r),
                          8.horizontalSpace,
                          Expanded(
                            child: AppText(
                              'Estás muy lejos de tu ubicación actual (máx ${_maxPickupDistanceM.round()}m)',
                              variant: AppTextVariant.bodySmall,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Card inferior ───────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.appColors.mapCardBg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: context.appColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            12.verticalSpace,
                            _AddressRow(
                              icon: Icons.my_location_rounded,
                              color: _isOutOfRange
                                  ? AppColors.sevent
                                  : AppColors.fifth,
                              label: 'Recogida',
                              address: _pickupAddress,
                              isLoading: _isGeocodingPickup,
                            ),
                            8.verticalSpace,
                            Padding(
                              padding: EdgeInsets.only(left: 9.w),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    width: 2,
                                    height: 16.h,
                                    color: context.appColors.border),
                              ),
                            ),
                            8.verticalSpace,
                            _AddressRow(
                              icon: Icons.location_on_rounded,
                              color: AppColors.sevent,
                              label: 'Destino',
                              address:
                                  _destAddress.isEmpty ? '--' : _destAddress,
                            ),
                            16.verticalSpace,
                            Divider(color: context.appColors.border),
                            12.verticalSpace,
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _MetricChip(
                                  icon: Icons.straighten_rounded,
                                  value:
                                      '${_distanceKm.toStringAsFixed(1)} km',
                                  label: 'Distancia',
                                ),
                                _MetricChip(
                                  icon: Icons.access_time_rounded,
                                  value:
                                      '~${(_distanceKm * 3).round()} min',
                                  label: 'Tiempo est.',
                                ),
                                _MetricChip(
                                  icon: Icons.attach_money_rounded,
                                  value:
                                      '\$${precio.toStringAsFixed(2)}',
                                  label: 'Precio est.',
                                  highlight: true,
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            AppButton(
                              label: 'SOLICITAR VIAJE',
                              variant: AppButtonVariant.filled,
                              expand: true,
                              isLoading: isRequesting,
                              isDisabled: !_hasRoute || _isOutOfRange,
                              onPressed: _hasRoute && !_isOutOfRange
                                  ? () => _onRequestTrip(context)
                                  : null,
                            ),
                            8.verticalSpace,
                          ],
                        ),
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

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
    this.isLoading = false,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String address;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.r),
        10.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label,
                  variant: AppTextVariant.labelSmall,
                  color: context.appColors.textSecondary),
              2.verticalSpace,
              isLoading
                  ? SizedBox(
                      height: 14.h,
                      width: 120.w,
                      child: LinearProgressIndicator(
                        color: AppColors.third,
                        backgroundColor: context.appColors.border,
                      ),
                    )
                  : AppText(address,
                      variant: AppTextVariant.bodySmall,
                      color: context.appColors.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
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
    final textColor = highlight ? AppColors.third : context.appColors.text;
    final bgColor = highlight
        ? AppColors.third.withValues(alpha: 0.1)
        : context.appColors.card;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
            color: highlight ? AppColors.third : context.appColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 16.r),
          4.verticalSpace,
          AppText(value,
              variant: AppTextVariant.labelMedium,
              color: textColor,
              fontWeight: FontWeight.w700),
          2.verticalSpace,
          AppText(label,
              variant: AppTextVariant.labelSmall,
              color: context.appColors.textSecondary),
        ],
      ),
    );
  }
}
