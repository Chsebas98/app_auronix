import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/home/domain/repositories/directions_repository.dart';
import 'package:auronix_app/features/home/domain/repositories/places_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

part 'location_search_event.dart';
part 'location_search_state.dart';

/// Espera [duration] de silencio entre eventos y, si llega uno nuevo antes
/// de que termine el anterior, cancela el handler en curso (switchMap) en
/// vez de encolarlo — evita llamadas al repositorio por cada tecla (T19-C1).
EventTransformer<T> _debounceRestartable<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

/// Orquesta la busqueda y seleccion de origen/destino (T19): autocompletado
/// con debounce, intercambio de puntos y calculo automatico de ruta + tarifa
/// estimada en cuanto ambos puntos quedan definidos.
class LocationSearchBloc
    extends Bloc<LocationSearchEvent, LocationSearchState> {
  LocationSearchBloc({
    required PlacesRepository placesRepository,
    required DirectionsRepository directionsRepository,
    Duration debounceDuration = const Duration(milliseconds: 350),
  }) : _places = placesRepository,
       _directions = directionsRepository,
       super(const LocationSearchState()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounceRestartable(debounceDuration),
    );
    on<SelectPlace>(_onSelectPlace);
    on<SetCurrentLocationAsOrigin>(_onSetCurrentLocationAsOrigin);
    on<SwapLocations>(_onSwapLocations);
    on<ClearLocation>(_onClearLocation);
    on<ResetSearch>(_onResetSearch);
    on<RetryRouteCalculation>(_onRetryRouteCalculation);
  }

  final PlacesRepository _places;
  final DirectionsRepository _directions;

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<LocationSearchState> emit,
  ) async {
    emit(
      state.copyWith(
        isSearchingOrigin: event.isOrigin ? true : null,
        isSearchingDestination: !event.isOrigin ? true : null,
        hasNoResults: false,
        errorMessage: null,
      ),
    );

    final result = await _places.searchPredictions(event.query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSearchingOrigin: false,
          isSearchingDestination: false,
          errorMessage: failure.message,
        ),
      ),
      (predictions) => emit(
        state.copyWith(
          predictions: predictions,
          hasNoResults: predictions.isEmpty,
          isSearchingOrigin: false,
          isSearchingDestination: false,
        ),
      ),
    );
  }

  Future<void> _onSelectPlace(
    SelectPlace event,
    Emitter<LocationSearchState> emit,
  ) async {
    final result = await _places.getPlaceDetails(event.place.id);
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (details) async {
        final location = SelectedLocation(
          coords: LatLng(details.latitude, details.longitude),
          address: event.place.mainText.isNotEmpty
              ? event.place.mainText
              : details.formattedAddress,
        );
        emit(
          event.isOrigin
              ? state.copyWith(origin: location, predictions: const [])
              : state.copyWith(destination: location, predictions: const []),
        );
        await _maybeCalculateRoute(emit);
      },
    );
  }

  Future<void> _onSetCurrentLocationAsOrigin(
    SetCurrentLocationAsOrigin event,
    Emitter<LocationSearchState> emit,
  ) async {
    emit(
      state.copyWith(
        origin: SelectedLocation(coords: event.coords, address: event.address),
      ),
    );
    await _maybeCalculateRoute(emit);
  }

  Future<void> _onSwapLocations(
    SwapLocations event,
    Emitter<LocationSearchState> emit,
  ) async {
    emit(state.copyWith(origin: state.destination, destination: state.origin));
    await _maybeCalculateRoute(emit);
  }

  void _onClearLocation(
    ClearLocation event,
    Emitter<LocationSearchState> emit,
  ) {
    emit(
      event.isOrigin
          ? state.copyWith(origin: null, routeInfo: null, fareEstimate: null)
          : state.copyWith(
              destination: null,
              routeInfo: null,
              fareEstimate: null,
            ),
    );
  }

  void _onResetSearch(ResetSearch event, Emitter<LocationSearchState> emit) {
    emit(const LocationSearchState());
  }

  Future<void> _onRetryRouteCalculation(
    RetryRouteCalculation event,
    Emitter<LocationSearchState> emit,
  ) async {
    await _maybeCalculateRoute(emit);
  }

  /// Si origin y destination ya estan definidos, recalcula ruta y tarifa
  /// (T19-C4): isCalculatingRoute=true mientras tanto, luego routeInfo +
  /// fareEstimate (o errorMessage si falla).
  Future<void> _maybeCalculateRoute(Emitter<LocationSearchState> emit) async {
    final origin = state.origin;
    final destination = state.destination;
    if (origin == null || destination == null) return;

    emit(
      state.copyWith(
        isCalculatingRoute: true,
        routeInfo: null,
        fareEstimate: null,
        errorMessage: null,
      ),
    );

    final routeResult = await _directions.getRoute(
      origin: origin.coords,
      destination: destination.coords,
    );
    await routeResult.fold(
      (failure) async => emit(
        state.copyWith(
          isCalculatingRoute: false,
          errorMessage: failure.message,
        ),
      ),
      (route) async {
        final fareResult = await _directions.estimateFare(
          distanceMeters: route.distanceMeters,
          durationSeconds: route.durationSeconds,
        );
        emit(
          fareResult.fold(
            (failure) => state.copyWith(
              isCalculatingRoute: false,
              routeInfo: route,
              errorMessage: failure.message,
            ),
            (fare) => state.copyWith(
              isCalculatingRoute: false,
              routeInfo: route,
              fareEstimate: fare,
            ),
          ),
        );
      },
    );
  }
}
