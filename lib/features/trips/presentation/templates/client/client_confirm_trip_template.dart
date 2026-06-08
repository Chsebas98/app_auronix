import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClientConfirmTripTemplate extends StatefulWidget {
  const ClientConfirmTripTemplate({super.key});

  @override
  State<ClientConfirmTripTemplate> createState() =>
      _ClientConfirmTripTemplateState();
}

class _ClientConfirmTripTemplateState
    extends State<ClientConfirmTripTemplate> {
  static const _precioKm = 1.8; // USD por km

  final _mapController = MapController();

  // Estado local del pickup
  LatLng? _pickupPos;
  String _pickupAddress = 'Obteniendo dirección...';
  bool _isGeocodingPickup = false;

  // Destino (viene del estado del bloc)
  LatLng? _destPos;
  String _destAddress = '';

  double _distanceKm = 0;
  Timer? _geocodeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromState());
  }

  @override
  void dispose() {
    _geocodeTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initFromState() async {
    final state = context.read<ClientTripBloc>().state;

    // Destino desde el estado del bloc
    if (state.destinoLatitud != null && state.destinoLongitud != null) {
      _destPos = LatLng(state.destinoLatitud!, state.destinoLongitud!);
      _destAddress = state.destinoDireccion ?? '';
    }

    // Origen: usar el del bloc si existe, si no GPS
    if (state.origenLatitud != null &&
        state.origenLongitud != null &&
        (state.origenLatitud != 0 || state.origenLongitud != 0)) {
      _setPickup(
        LatLng(state.origenLatitud!, state.origenLongitud!),
        state.origenDireccion ?? 'Mi ubicación actual',
        geocode: false,
      );
    } else {
      await _getGpsPickup();
    }

    if (mounted) setState(() {});
  }

  Future<void> _getGpsPickup() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;
      final pickup = LatLng(pos.latitude, pos.longitude);
      _setPickup(pickup, 'Mi ubicación actual', geocode: true);

      // Centrar el mapa en el pickup
      _mapController.move(pickup, 15.0);
    } catch (_) {}
  }

  void _setPickup(LatLng pos, String address, {bool geocode = false}) {
    _pickupPos = pos;
    _pickupAddress = address;
    _recalculateDistance();
    if (geocode) _reverseGeocodePickup(pos);
    if (mounted) setState(() {});
  }

  void _recalculateDistance() {
    if (_pickupPos == null || _destPos == null) return;
    final d = const Distance();
    _distanceKm = d.as(LengthUnit.Kilometer, _pickupPos!, _destPos!);
  }

  /// El usuario tapa el mapa → mueve el indicador de recogida al punto tapeado.
  void _onMapTap(TapPosition tapPos, LatLng point) {
    if (!mounted) return;
    _setPickup(point, 'Actualizando dirección...', geocode: false);
    _scheduleReverseGeocode(point);
  }

  void _scheduleReverseGeocode(LatLng point) {
    _geocodeTimer?.cancel();
    _geocodeTimer = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocodePickup(point);
    });
  }

  Future<void> _reverseGeocodePickup(LatLng pos) async {
    if (!mounted) return;
    setState(() => _isGeocodingPickup = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if (p.street?.isNotEmpty == true) p.street,
          if (p.locality?.isNotEmpty == true) p.locality,
        ];
        _pickupAddress =
            parts.isNotEmpty ? parts.join(', ') : 'Punto de recogida';
      }
    } catch (_) {
      _pickupAddress =
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    } finally {
      if (mounted) setState(() => _isGeocodingPickup = false);
    }
  }

  void _onRequestTrip(BuildContext context, ClientTripState state) {
    if (_pickupPos == null || _destPos == null) return;

    final session = context.read<SessionBloc>().state;
    final userId = session is SessionAuthenticated
        ? JwtHelpers.getUserId(session.dataUser.tokenAccess) ?? 0
        : 0;

    // Actualizar ruta en el estado con las coordenadas finales
    context.read<ClientTripBloc>().add(
          ClientTripSetRouteEvent(
            origenLatitud: _pickupPos!.latitude,
            origenLongitud: _pickupPos!.longitude,
            origenDireccion: _pickupAddress,
            destinoLatitud: _destPos!.latitude,
            destinoLongitud: _destPos!.longitude,
            destinoDireccion: _destAddress,
            distanciaEstimadaKm: _distanceKm,
          ),
        );

    context.read<ClientTripBloc>().add(
          ClientTripRequestEvent(
            userId: userId,
            origenLatitud: _pickupPos!.latitude,
            origenLongitud: _pickupPos!.longitude,
            origenDireccion: _pickupAddress,
            destinoLatitud: _destPos!.latitude,
            destinoLongitud: _destPos!.longitude,
            destinoDireccion: _destAddress,
            distanciaEstimadaKm: _distanceKm,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight
        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

    return BlocListener<ClientTripBloc, ClientTripState>(
      listenWhen: (prev, curr) =>
          curr.status == ClientTripStatus.searching &&
          prev.status != ClientTripStatus.searching,
      listener: (_, __) => context.pushReplacement('/client/searching-driver'),
      child: BlocBuilder<ClientTripBloc, ClientTripState>(
        builder: (context, state) {
          final isRequesting = state.status == ClientTripStatus.requesting;
          final hasRoute = _pickupPos != null && _destPos != null;
          final precio = _distanceKm * _precioKm;

          return Scaffold(
            backgroundColor: context.appColors.background,
            body: Stack(
              children: [
                // ── Mapa interactivo ──────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pickupPos ??
                        (_destPos ?? const LatLng(4.7110, -74.0721)),
                    initialZoom: 15.0,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains:
                          isLight ? const [] : const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.auronix.app',
                    ),
                    // Línea de ruta
                    if (hasRoute)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_pickupPos!, _destPos!],
                            strokeWidth: 4.5,
                            color: AppColors.fifth,
                          ),
                        ],
                      ),
                    // Marcadores
                    MarkerLayer(
                      markers: [
                        // Pickup (origen) — tapeando el mapa se mueve
                        if (_pickupPos != null)
                          Marker(
                            point: _pickupPos!,
                            width: 52.r,
                            height: 64.r,
                            alignment: Alignment.bottomCenter,
                            child: _PickupMarker(
                                isLoading: _isGeocodingPickup),
                          ),
                        // Destino — fijo
                        if (_destPos != null)
                          Marker(
                            point: _destPos!,
                            width: 36.r,
                            height: 44.r,
                            alignment: Alignment.bottomCenter,
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

                // ── AppBar transparente ───────────────────────────────
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
                                  color: AppColors.black.withValues(alpha: 0.15),
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
                            margin: EdgeInsets.only(right: 16.w, top: 12.h, bottom: 12.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: context.appColors.mapCardBg,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AppText(
                              'Toca el mapa para ajustar recogida',
                              variant: AppTextVariant.bodySmall,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Card inferior con detalles + botón ────────────────
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
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Handle ─────────────────────────────────
                            Container(
                              width: 40.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: context.appColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            12.verticalSpace,

                            // ── Pickup row ─────────────────────────────
                            _AddressRow(
                              icon: Icons.my_location_rounded,
                              color: AppColors.fifth,
                              label: 'Recogida',
                              address: _isGeocodingPickup
                                  ? 'Obteniendo dirección...'
                                  : _pickupAddress,
                              isLoading: _isGeocodingPickup,
                            ),
                            8.verticalSpace,
                            Padding(
                              padding: EdgeInsets.only(left: 9.w),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    width: 2, height: 16.h,
                                    color: context.appColors.border),
                              ),
                            ),
                            8.verticalSpace,

                            // ── Destino row ────────────────────────────
                            _AddressRow(
                              icon: Icons.location_on_rounded,
                              color: AppColors.sevent,
                              label: 'Destino',
                              address: _destAddress.isEmpty
                                  ? '--'
                                  : _destAddress,
                            ),
                            16.verticalSpace,
                            Divider(color: context.appColors.divider),
                            12.verticalSpace,

                            // ── Métricas ───────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _MetricChip(
                                  icon: Icons.straighten_rounded,
                                  value: '${_distanceKm.toStringAsFixed(1)} km',
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

                            // ── Botón solicitar ────────────────────────
                            AppButton(
                              label: 'SOLICITAR VIAJE',
                              variant: AppButtonVariant.filled,
                              expand: true,
                              isLoading: isRequesting,
                              isDisabled: !hasRoute,
                              onPressed: hasRoute
                                  ? () => _onRequestTrip(context, state)
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

// ── Marcador animado de recogida ─────────────────────────────────────────────

class _PickupMarker extends StatelessWidget {
  const _PickupMarker({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on_rounded,
          color: AppColors.fifth,
          size: 52.r,
          shadows: [
            Shadow(
              color: AppColors.fifth.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        Positioned(
          top: 6.r,
          child: Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              color: AppColors.fifth,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Padding(
                    padding: EdgeInsets.all(5.r),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Icon(Icons.my_location_rounded,
                    color: AppColors.white, size: 14.r),
          ),
        ),
      ],
    );
  }
}

// ── Rows y chips ─────────────────────────────────────────────────────────────

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
                        backgroundColor:
                            context.appColors.border,
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
