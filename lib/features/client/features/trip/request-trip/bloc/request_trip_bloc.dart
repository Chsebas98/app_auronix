// request-trip/presentation/bloc/request_trip_bloc.dart

import 'dart:async';
import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_entity.dart';
import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_model.dart';
import 'package:auronix_app/features/client/features/trip/domain/repository/trip_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'request_trip_event.dart';
part 'request_trip_state.dart';

class RequestTripBloc extends Bloc<RequestTripEvent, RequestTripState> {
  final TripRepository _tripRepository;

  RequestTripBloc({required TripRepository tripRepository})
    : _tripRepository = tripRepository,
      super(const RequestTripState()) {
    on<SearchDestinationEvent>(_onSearchDestination);
    on<SelectDestinationEvent>(_onSelectDestination);
    on<ClearSearchEvent>(_onClearSearch);
  }

  FutureOr<void> _onSearchDestination(
    SearchDestinationEvent event,
    Emitter<RequestTripState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    try {
      emit(state.copyWith(isSearching: true));

      debugPrint('🔍 [Bloc] Buscando: $query');

      // ✅ Llamar al Repository
      final response = await _tripRepository.searchPlaces(query);

      if (!response.response) {
        debugPrint('❌ [Bloc] Error: ${response.message}');
        emit(
          state.copyWith(
            searchResults: [],
            isSearching: false,
            errorMessage: response.message,
          ),
        );
        return;
      }

      // Parsear resultados
      final placesJson = response.result as List;
      final places = placesJson
          .map((json) => PlaceModel.fromJson(json))
          .toList();

      debugPrint('✅ [Bloc] ${places.length} resultados encontrados');

      emit(
        state.copyWith(
          searchResults: places,
          isSearching: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('❌ [Bloc] Error en búsqueda: $e');
      emit(
        state.copyWith(
          searchResults: [],
          isSearching: false,
          errorMessage: 'Error al buscar lugares',
        ),
      );
    }
  }

  FutureOr<void> _onSelectDestination(
    SelectDestinationEvent event,
    Emitter<RequestTripState> emit,
  ) async {
    debugPrint('📍 [Bloc] Destino seleccionado: ${event.destination.name}');

    emit(
      state.copyWith(
        selectedDestination: event.destination,
        searchResults: [], // Limpiar resultados
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<RequestTripState> emit,
  ) async {
    debugPrint('🧹 [Bloc] Limpiando búsqueda');

    emit(
      state.copyWith(
        searchResults: [],
        isSearching: false,
        clearDestination: true,
        errorMessage: null,
      ),
    );
  }
}
