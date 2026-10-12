import 'dart:async';

import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/negotiation/domain/repositories/geo_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'select_destination_state.dart';

/// Estado de la pantalla "Seleccionar destino" (docs/design_patterns.md
/// 3.2, docs/flow.md sección 3): buscador de texto + pin fijo al centro del
/// mapa que el usuario mueve arrastrando el mapa por debajo — ambos métodos
/// terminan resolviendo el mismo `{label, lat, lng}`.
class SelectDestinationCubit extends Cubit<SelectDestinationState> {
  final GeoRepository _repository;
  Timer? _debounce;

  SelectDestinationCubit(this._repository)
    : super(const SelectDestinationState());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void setInitialCenter(LatLng center) {
    emit(state.copyWith(center: center));
    resolveLabelForCenter();
  }

  /// Se llama cuando el usuario termina de arrastrar el mapa (el pin queda
  /// fijo al centro de la pantalla).
  void onMapMoved(LatLng newCenter) {
    emit(state.copyWith(center: newCenter, suggestions: const []));
    resolveLabelForCenter();
  }

  Future<void> resolveLabelForCenter() async {
    emit(state.copyWith(isResolvingLabel: true));
    final result = await _repository.reverseGeocode(
      lat: state.center.latitude,
      lng: state.center.longitude,
    );
    emit(
      result.fold(
        (_) => state.copyWith(isResolvingLabel: false),
        (label) => state.copyWith(label: label, isResolvingLabel: false),
      ),
    );
  }

  /// Busca con debounce de 400ms mientras el usuario escribe.
  void search(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      emit(state.copyWith(suggestions: const []));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      emit(state.copyWith(isSearching: true));
      final result = await _repository.autocomplete(
        query: query,
        lat: state.center.latitude,
        lng: state.center.longitude,
      );
      emit(
        result.fold(
          (_) => state.copyWith(isSearching: false, suggestions: const []),
          (suggestions) =>
              state.copyWith(isSearching: false, suggestions: suggestions),
        ),
      );
    });
  }

  void selectSuggestion(AddressSuggestion suggestion) {
    emit(
      state.copyWith(
        center: LatLng(suggestion.lat, suggestion.lng),
        label: suggestion.label,
        suggestions: const [],
      ),
    );
  }
}
