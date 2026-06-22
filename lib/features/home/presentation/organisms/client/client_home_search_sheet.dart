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

class ClientHomeSearchSheet extends StatefulWidget {
  const ClientHomeSearchSheet({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.originAddress,
    required this.parentContext,
  });

  final double originLat;
  final double originLng;
  final String originAddress;
  final BuildContext parentContext;

  @override
  State<ClientHomeSearchSheet> createState() => _ClientHomeSearchSheetState();
}

class _ClientHomeSearchSheetState extends State<ClientHomeSearchSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _places = sl<PlacesService>();

  List<PlacePrediction> _suggestions = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query.length < 2) {
      _debounce?.cancel();
      setState(() => _suggestions = []);
      return;
    }
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 300), () => _doSearch(query));
  }

  Future<void> _doSearch(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    final hasOrigin = widget.originLat != 0 && widget.originLng != 0;
    final results = await _places.autocomplete(
      query,
      lat: hasOrigin ? widget.originLat : null,
      lng: hasOrigin ? widget.originLng : null,
    );
    if (mounted) {
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    }
  }

  void _onSelectPrediction(PlacePrediction prediction) {
    Navigator.of(context).pop();

    widget.parentContext.read<ClientTripBloc>().add(
          ClientTripSetRouteEvent(
            origenLatitud: widget.originLat,
            origenLongitud: widget.originLng,
            origenDireccion: widget.originAddress,
            destinoLatitud: prediction.latitude,
            destinoLongitud: prediction.longitude,
            destinoDireccion: prediction.description,
            distanciaEstimadaKm: prediction.distanceKm > 0
                ? prediction.distanceKm
                : 2.5,
          ),
        );

    widget.parentContext.push(ClientRoutesPath.confirmTrip);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Handle ────────────────────────────────────────
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // ── Título ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: AppText(
                '¿A dónde vas?',
                variant: AppTextVariant.titleMedium,
                color: context.appColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),

            // ── Buscador ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                      child: Icon(Icons.search_rounded,
                          color: context.appColors.textSecondary, size: 20.r),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
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
                    if (_isSearching)
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
                            color: context.appColors.textSecondary,
                            size: 18.r),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _suggestions = []);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // ── Resultados ────────────────────────────────────
            Expanded(
              child: _suggestions.isEmpty && _searchCtrl.text.length < 2
                  ? _QuickOptions()
                  : _suggestions.isEmpty && !_isSearching
                      ? _NoResults(query: _searchCtrl.text)
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Divider(
                                color: context.appColors.border, height: 1),
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
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

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
              child: Icon(Icons.location_on_outlined,
                  color: AppColors.sevent, size: 18.r),
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
            if (prediction.distanceKm > 0) ...[
              8.horizontalSpace,
              AppText(
                prediction.distanceKm < 1
                    ? '${(prediction.distanceKm * 1000).round()} m'
                    : '${prediction.distanceKm.toStringAsFixed(1)} km',
                variant: AppTextVariant.labelSmall,
                color: context.appColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Sugerencias',
            variant: AppTextVariant.labelMedium,
            color: context.appColors.textSecondary,
          ),
          16.verticalSpace,
          _QuickOptionRow(icon: Icons.work_outline_rounded, label: 'Trabajo'),
          8.verticalSpace,
          _QuickOptionRow(icon: Icons.home_outlined, label: 'Casa'),
          8.verticalSpace,
          _QuickOptionRow(
              icon: Icons.star_outline_rounded, label: 'Favoritos'),
        ],
      ),
    );
  }
}

class _QuickOptionRow extends StatelessWidget {
  const _QuickOptionRow({required this.icon, required this.label});
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
          child:
              Icon(icon, color: context.appColors.textSecondary, size: 18.r),
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

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
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
