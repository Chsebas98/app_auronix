import 'dart:async';

import 'package:auronix_app/app/core/config/public_config_service.dart';
import 'package:auronix_app/app/core/services/location_service.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/published_trip_request.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/trip_estimate.dart';
import 'package:auronix_app/features/trips/negotiation/domain/repositories/geo_repository.dart';
import 'package:auronix_app/features/trips/negotiation/domain/repositories/trip_negotiation_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'confirm_trip_state.dart';

/// Pantalla "Confirmar viaje y precio" (docs/design_patterns.md 3.2,
/// docs/flow.md sección 3): resuelve el origen (ubicación actual), pide el
/// precio sugerido al backend y publica la solicitud con el precio final
/// que edite el pasajero (mínimo `PublicConfigService.precioMinimoTrayecto`,
/// nunca hardcodeado).
class ConfirmTripCubit extends Cubit<ConfirmTripState> {
  final TripNegotiationRepository _tripRepository;
  final GeoRepository _geoRepository;
  final LocationService _locationService;
  final PublicConfigService _publicConfigService;

  ConfirmTripCubit({
    required TripNegotiationRepository tripRepository,
    required GeoRepository geoRepository,
    required LocationService locationService,
    required PublicConfigService publicConfigService,
  }) : _tripRepository = tripRepository,
       _geoRepository = geoRepository,
       _locationService = locationService,
       _publicConfigService = publicConfigService,
       super(const ConfirmTripState());

  Future<void> init(AddressSuggestion destination) async {
    emit(
      ConfirmTripState(
        destination: destination,
        status: ConfirmTripStatus.loadingOrigin,
      ),
    );

    final positionResult = await _locationService.getCurrentPosition();
    final origin = await positionResult.fold<Future<AddressSuggestion?>>(
      (_) async => null,
      (position) async {
        final labelResult = await _geoRepository.reverseGeocode(
          lat: position.latitude,
          lng: position.longitude,
        );
        final label = labelResult.fold((_) => 'Tu ubicación actual', (l) => l);
        return AddressSuggestion(
          label: label.isEmpty ? 'Tu ubicación actual' : label,
          lat: position.latitude,
          lng: position.longitude,
        );
      },
    );

    if (origin == null) {
      emit(
        state.copyWith(
          status: ConfirmTripStatus.error,
          errorMessage: 'No se pudo obtener tu ubicación actual',
        ),
      );
      return;
    }

    emit(state.copyWith(origin: origin));
    await _estimate();
  }

  Future<void> _estimate() async {
    final origin = state.origin;
    final destination = state.destination;
    if (origin == null || destination == null) return;

    emit(state.copyWith(status: ConfirmTripStatus.estimating));

    final configResult = await _publicConfigService.getConfig();
    final estimateResult = await _tripRepository.estimateTrip(
      originLat: origin.lat,
      originLng: origin.lng,
      originAddress: origin.label,
      destinationLat: destination.lat,
      destinationLng: destination.lng,
      destinationAddress: destination.label,
    );

    estimateResult.fold(
      (failure) => emit(
        state.copyWith(
          status: ConfirmTripStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (estimate) {
        // docs/testing.md caso #19: sin config pública no se inventa un
        // mínimo — se bloquea la publicación con mensaje explícito.
        final minPrice = configResult.fold(
          (_) => null,
          (config) => config.precioMinimoTrayecto,
        );
        emit(
          state.copyWith(
            status: ConfirmTripStatus.ready,
            estimate: estimate,
            minPrice: minPrice,
            clearMinPrice: minPrice == null,
          ),
        );
      },
    );
  }

  Future<void> publish({required double precioPublicado}) async {
    final origin = state.origin;
    final destination = state.destination;
    if (origin == null || destination == null || state.estimate == null) {
      return;
    }

    if (state.minPrice != null && precioPublicado < state.minPrice!) {
      emit(
        state.copyWith(
          errorMessage:
              'El precio no puede ser menor a '
              '${state.minPrice!.toStringAsFixed(2)} ${state.estimate!.moneda}',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ConfirmTripStatus.publishing));

    final result = await _tripRepository.publishTripRequest(
      originLat: origin.lat,
      originLng: origin.lng,
      originAddress: origin.label,
      destinationLat: destination.lat,
      destinationLng: destination.lng,
      destinationAddress: destination.label,
      precioPublicado: precioPublicado,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ConfirmTripStatus.ready,
          errorMessage: failure.message,
        ),
      ),
      (published) => emit(
        state.copyWith(
          status: ConfirmTripStatus.published,
          published: published,
        ),
      ),
    );
  }
}
