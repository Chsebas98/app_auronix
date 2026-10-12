import 'package:auronix_app/app/core/services/location_service.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/negotiation/presentation/bloc/select_destination_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

/// "Seleccionar destino" (docs/design_patterns.md 3.2): buscador de texto +
/// mapa con pin fijo al centro que el usuario mueve arrastrando el mapa —
/// ambos métodos confirmados como formas válidas de elegir el punto. Al
/// confirmar, hace `pop` con el [AddressSuggestion] elegido; el llamador
/// (flujo de publicar solicitud, Fase 6, todavía no construido) decide qué
/// hacer con el resultado.
class SelectDestinationPage extends StatefulWidget {
  const SelectDestinationPage({super.key});

  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

class _SelectDestinationPageState extends State<SelectDestinationPage> {
  final _mapController = MapController();
  late final SelectDestinationCubit _cubit;

  static const _lightTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  @override
  void initState() {
    super.initState();
    _cubit = sl<SelectDestinationCubit>();
    _initCenter();
  }

  Future<void> _initCenter() async {
    final result = await sl<LocationService>().getCurrentPosition();
    result.fold((_) => null, (position) {
      _cubit.setInitialCenter(LatLng(position.latitude, position.longitude));
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final tileUrl = isLight ? _lightTileUrl : _darkTileUrl;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: BlocBuilder<SelectDestinationCubit, SelectDestinationState>(
          builder: (context, state) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.center,
                    initialZoom: 15.0,
                    onMapEvent: (event) {
                      if (event.source == MapEventSource.dragEnd) {
                        _cubit.onMapMoved(event.camera.center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains: isLight ? const [] : const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.auronix.app',
                    ),
                  ],
                ),

                // Pin fijo al centro de la pantalla (el mapa se mueve debajo).
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(
                        Icons.location_pin,
                        size: 44,
                        color: AppColors.third,
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        8.verticalSpace,
                        _SearchBar(
                          onBack: () => Navigator.pop(context),
                          onChanged: (q) => _cubit.search(q),
                        ),
                        if (state.suggestions.isNotEmpty)
                          _SuggestionsList(
                            suggestions: state.suggestions,
                            onSelected: (s) {
                              _cubit.selectSuggestion(s);
                              _mapController.move(LatLng(s.lat, s.lng), 16.0);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: context.appColors.background,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            state.isResolvingLabel
                                ? 'Buscando dirección...'
                                : (state.label.isEmpty
                                      ? 'Mueve el mapa para elegir el punto'
                                      : state.label),
                            variant: AppTextVariant.bodyMedium,
                            align: TextAlign.center,
                          ),
                          12.verticalSpace,
                          AppButton(
                            label: 'Confirmar ubicación',
                            expand: true,
                            isDisabled:
                                state.isResolvingLabel || state.label.isEmpty,
                            onPressed: () => Navigator.pop(
                              context,
                              AddressSuggestion(
                                label: state.label,
                                lat: state.center.latitude,
                                lng: state.center.longitude,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onBack, required this.onChanged});

  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: context.appColors.background,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar dirección',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({required this.suggestions, required this.onSelected});

  final List<AddressSuggestion> suggestions;
  final ValueChanged<AddressSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: context.appColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = suggestions[index];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(s.label),
              onTap: () => onSelected(s),
            );
          },
        ),
      ),
    );
  }
}
