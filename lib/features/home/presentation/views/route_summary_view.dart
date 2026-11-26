import 'package:auronix_app/features/home/presentation/bloc/location_search_bloc.dart';
import 'package:auronix_app/features/home/presentation/widgets/fare_estimate_card.dart';
import 'package:auronix_app/features/home/presentation/widgets/route_map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Orquesta el mapa de previsualizacion y la tarjeta de tarifa (T21) sobre
/// el estado de LocationSearchBloc (T19): origen y destino ya deben estar
/// seleccionados cuando se muestra esta vista.
class RouteSummaryView extends StatelessWidget {
  const RouteSummaryView({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationSearchBloc, LocationSearchState>(
      builder: (context, state) {
        final origin = state.origin;
        final destination = state.destination;
        if (origin == null || destination == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            Positioned.fill(
              child: RouteMapPreview(
                origin: origin.coords,
                destination: destination.coords,
                routePoints: state.routeInfo?.points ?? const [],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: FareEstimateCard(
                  routeInfo: state.routeInfo,
                  fareEstimate: state.fareEstimate,
                  isLoading: state.isCalculatingRoute,
                  errorMessage: state.errorMessage,
                  onRetry: () => context.read<LocationSearchBloc>().add(
                    const RetryRouteCalculation(),
                  ),
                  onConfirm: onConfirm,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
