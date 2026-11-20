import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/features/home/presentation/bloc/location_search_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_icon_button.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:auronix_app/shared/molecules/location_search_input.dart';
import 'package:auronix_app/shared/molecules/prediction_tile.dart';
import 'package:auronix_app/shared/molecules/skeleton_prediction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Vista de busqueda e intercambio de origen/destino (T20), construida
/// sobre LocationSearchBloc (T19). Se abre como contenido reemplazando el
/// sheet anterior (ClientHomeSearchSheet) desde
/// client_select_destination_template.dart — Tarea 0: no crea una pantalla
/// paralela, adapta el punto de entrada existente.
class LocationSearchView extends StatelessWidget {
  const LocationSearchView({
    this.initialOriginCoords,
    this.initialOriginAddress,
    this.onRouteReady,
    super.key,
  });

  final LatLng? initialOriginCoords;
  final String? initialOriginAddress;

  /// Se invoca con el estado final cuando el Bloc ya resolvio origen,
  /// destino, ruta y tarifa (state.isRouteReady).
  final ValueChanged<LocationSearchState>? onRouteReady;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationSearchBloc>(
      create: (_) {
        final bloc = sl<LocationSearchBloc>();
        if (initialOriginCoords != null && initialOriginAddress != null) {
          bloc.add(
            SetCurrentLocationAsOrigin(
              initialOriginCoords!,
              initialOriginAddress!,
            ),
          );
        }
        return bloc;
      },
      child: _LocationSearchBody(onRouteReady: onRouteReady),
    );
  }
}

class _LocationSearchBody extends StatefulWidget {
  const _LocationSearchBody({this.onRouteReady});

  final ValueChanged<LocationSearchState>? onRouteReady;

  @override
  State<_LocationSearchBody> createState() => _LocationSearchBodyState();
}

class _LocationSearchBodyState extends State<_LocationSearchBody> {
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  bool _activeIsOrigin = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<LocationSearchBloc>().state;
    _originCtrl.text = state.origin?.address ?? '';
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String text, {required bool isOrigin}) {
    _activeIsOrigin = isOrigin;
    context.read<LocationSearchBloc>().add(SearchQueryChanged(text, isOrigin));
  }

  void _onSelect(PlacePrediction prediction) {
    final isOrigin = _activeIsOrigin;
    (isOrigin ? _originCtrl : _destinationCtrl).text = prediction.mainText;
    context.read<LocationSearchBloc>().add(SelectPlace(prediction, isOrigin));
  }

  void _onSwap() {
    final originText = _originCtrl.text;
    _originCtrl.text = _destinationCtrl.text;
    _destinationCtrl.text = originText;
    context.read<LocationSearchBloc>().add(const SwapLocations());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<LocationSearchBloc, LocationSearchState>(
      listenWhen: (previous, current) =>
          !previous.isRouteReady && current.isRouteReady,
      listener: (context, state) {
        if (state.isRouteReady) {
          widget.onRouteReady?.call(state);
        }
      },
      builder: (context, state) {
        final isSearching =
            state.isSearchingOrigin || state.isSearchingDestination;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        LocationSearchInput(
                          key: const Key('location_search_origin_input'),
                          isOrigin: true,
                          controller: _originCtrl,
                          hintText: '¿Desde dónde sales?',
                          onChanged: (text) => _onChanged(text, isOrigin: true),
                          onClear: () {
                            _originCtrl.clear();
                            context.read<LocationSearchBloc>().add(
                              const ClearLocation(true),
                            );
                          },
                          isLoading: state.isSearchingOrigin,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        LocationSearchInput(
                          key: const Key('location_search_destination_input'),
                          isOrigin: false,
                          controller: _destinationCtrl,
                          hintText: '¿A dónde vas?',
                          onChanged: (text) =>
                              _onChanged(text, isOrigin: false),
                          onClear: () {
                            _destinationCtrl.clear();
                            context.read<LocationSearchBloc>().add(
                              const ClearLocation(false),
                            );
                          },
                          isLoading: state.isSearchingDestination,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppIconButton(
                    key: const Key('location_search_swap_button'),
                    iconAndroid: Icons.swap_vert_rounded,
                    iconIOS: Icons.swap_vert_rounded,
                    tooltip: 'Intercambiar origen y destino',
                    onPressed: _onSwap,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isSearching
                  ? const SkeletonPredictionList()
                  : state.hasNoResults
                  ? const _NoResults()
                  : state.predictions.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: state.predictions.length,
                      itemBuilder: (_, i) => PredictionTile(
                        prediction: state.predictions[i],
                        onTap: () => _onSelect(state.predictions[i]),
                      ),
                    ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppText(
                  state.errorMessage!,
                  variant: AppTextVariant.bodySmall,
                  color: colors.text,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sin resultados',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: context.appColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'No encontramos lugares con ese nombre',
                variant: AppTextVariant.bodyMedium,
                color: context.appColors.textSecondary,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
