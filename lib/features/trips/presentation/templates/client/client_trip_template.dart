import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClientTripTemplate extends StatefulWidget {
  const ClientTripTemplate({super.key});

  @override
  State<ClientTripTemplate> createState() => _ClientTripTemplateState();
}

class _ClientTripTemplateState extends State<ClientTripTemplate> {
  final _mapController = MapController();

  static const _lightTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  static const _bogota = LatLng(4.7110, -74.0721);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight ? _lightTileUrl : _darkTileUrl;

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
            // ── Mapa de fondo ─────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _bogota,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  subdomains: isLight ? const [] : const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.auronix.app',
                ),
              ],
            ),

            // ── Barra de búsqueda ─────────────────────────────────────────
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
                            color: AppColors.black.withValues(alpha: 0.12),
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

            // ── Botón inferior ────────────────────────────────────────────
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
