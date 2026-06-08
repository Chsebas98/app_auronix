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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClientSelectDestinationTemplate extends StatefulWidget {
  const ClientSelectDestinationTemplate({super.key});

  @override
  State<ClientSelectDestinationTemplate> createState() =>
      _ClientSelectDestinationTemplateState();
}

class _ClientSelectDestinationTemplateState
    extends State<ClientSelectDestinationTemplate> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _places = sl<PlacesService>();

  List<PlacePrediction> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  Timer? _debounce;

  // Origen GPS
  double _originLat = 0;
  double _originLng = 0;
  String _originAddress = 'Obteniendo ubicación...';
  bool _originReady = false;

  @override
  void initState() {
    super.initState();
    _initOrigin();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _initOrigin() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _originAddress = 'Permiso de ubicación requerido');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      _originLat = pos.latitude;
      _originLng = pos.longitude;

      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if (p.street?.isNotEmpty == true) p.street,
            if (p.locality?.isNotEmpty == true) p.locality,
          ];
          _originAddress =
              parts.isNotEmpty ? parts.join(', ') : 'Mi ubicación actual';
        }
      } catch (_) {
        _originAddress =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      }

      if (mounted) setState(() => _originReady = true);
    } catch (_) {
      if (mounted) setState(() => _originAddress = 'Ubicación no disponible');
    }
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query.length < 2) {
      _debounce?.cancel();
      setState(() => _suggestions = []);
      return;
    }
    // Debounce 600 ms — Nominatim rate limit: 1 req/s
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _doSearch(query));
  }

  Future<void> _doSearch(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    final results = await _places.autocomplete(
      query,
      lat: _originReady ? _originLat : null,
      lng: _originReady ? _originLng : null,
    );
    if (mounted) {
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    }
  }

  void _onSelectPrediction(PlacePrediction prediction) {
    // Nominatim ya incluye lat/lng — no necesitamos getDetails
    final distKm = _originReady
        ? const Distance().as(
            LengthUnit.Kilometer,
            LatLng(_originLat, _originLng),
            LatLng(prediction.latitude, prediction.longitude),
          )
        : 2.5;

    context.read<ClientTripBloc>().add(
          ClientTripSetRouteEvent(
            origenLatitud: _originLat,
            origenLongitud: _originLng,
            origenDireccion: _originAddress,
            destinoLatitud: prediction.latitude,
            destinoLongitud: prediction.longitude,
            destinoDireccion: prediction.description,
            distanciaEstimadaKm: distKm,
          ),
        );

    context.push(ClientRoutesPath.confirmTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.appColors.icon, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          '¿A dónde vas?',
          variant: AppTextVariant.titleMedium,
          color: context.appColors.text,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Origen (GPS) ────────────────────────────────────────────
          _LocationRow(
            icon: Icons.my_location_rounded,
            iconColor: AppColors.fifth,
            title: 'Tu ubicación',
            subtitle: _originAddress,
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(color: context.appColors.divider, height: 1),
          ),

          // ── Buscador destino ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.input,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.appColors.border),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(
                      Icons.search_rounded,
                      color: context.appColors.textSecondary,
                      size: 20.r,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        color: context.appColors.text,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar destino...',
                        hintStyle: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  if (_isSearching || _isLoadingDetails)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.third,
                        ),
                      ),
                    )
                  else if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear_rounded,
                          color: context.appColors.textSecondary, size: 18.r),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _suggestions = []);
                      },
                    ),
                ],
              ),
            ),
          ),

          // ── Lista de sugerencias ────────────────────────────────────
          Expanded(
            child: _suggestions.isEmpty && _searchCtrl.text.length < 2
                ? _EmptySearchState()
                : _suggestions.isEmpty && !_isSearching
                    ? _NoResultsState(query: _searchCtrl.text)
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Divider(
                              color: context.appColors.divider, height: 1),
                        ),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          return _SuggestionTile(
                            prediction: s,
                            onTap: () => _onSelectPrediction(s),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.r),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title,
                    variant: AppTextVariant.labelSmall,
                    color: context.appColors.textSecondary),
                2.verticalSpace,
                AppText(subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: context.appColors.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.prediction, required this.onTap});
  final PlacePrediction prediction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: context.appColors.card,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.sevent,
                size: 18.r,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    prediction.mainText,
                    variant: AppTextVariant.bodyMedium,
                    color: context.appColors.text,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prediction.secondaryText.isNotEmpty) ...[
                    2.verticalSpace,
                    AppText(
                      prediction.secondaryText,
                      variant: AppTextVariant.bodySmall,
                      color: context.appColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Sugerencias',
            variant: AppTextVariant.labelMedium,
            color: context.appColors.textSecondary,
          ),
          16.verticalSpace,
          _QuickOption(
            icon: Icons.work_outline_rounded,
            label: 'Trabajo',
          ),
          8.verticalSpace,
          _QuickOption(
            icon: Icons.home_outlined,
            label: 'Casa',
          ),
          8.verticalSpace,
          _QuickOption(
            icon: Icons.star_outline_rounded,
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: context.appColors.textSecondary, size: 48.r),
            16.verticalSpace,
            AppText(
              'Sin resultados para "$query"',
              variant: AppTextVariant.bodyMedium,
              color: context.appColors.textSecondary,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickOption extends StatelessWidget {
  const _QuickOption({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: context.appColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: context.appColors.textSecondary, size: 18.r),
        ),
        12.horizontalSpace,
        AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: context.appColors.text,
        ),
      ],
    );
  }
}
