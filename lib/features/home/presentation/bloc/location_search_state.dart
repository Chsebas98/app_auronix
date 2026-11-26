part of 'location_search_bloc.dart';

/// Punto (origen o destino) ya resuelto a coordenadas, ya sea por seleccion
/// de una sugerencia (via getPlaceDetails) o por geolocalizacion.
class SelectedLocation extends Equatable {
  const SelectedLocation({required this.coords, required this.address});

  final LatLng coords;
  final String address;

  @override
  List<Object?> get props => [coords, address];
}

/// Sentinel para distinguir "no tocar este campo" de "ponerlo en null"
/// dentro de copyWith, sin necesitar un parametro booleano `clearX` por
/// cada campo nullable.
const _unset = Object();

class LocationSearchState extends Equatable {
  const LocationSearchState({
    this.origin,
    this.destination,
    this.predictions = const [],
    this.routeInfo,
    this.fareEstimate,
    this.isSearchingOrigin = false,
    this.isSearchingDestination = false,
    this.isCalculatingRoute = false,
    this.hasNoResults = false,
    this.errorMessage,
  });

  final SelectedLocation? origin;
  final SelectedLocation? destination;
  final List<PlacePrediction> predictions;
  final RouteInfo? routeInfo;
  final FareEstimate? fareEstimate;
  final bool isSearchingOrigin;
  final bool isSearchingDestination;
  final bool isCalculatingRoute;
  final bool hasNoResults;
  final String? errorMessage;

  /// Verdadero cuando origin y destination estan listos y la ruta terminó
  /// de calcularse con exito (equivalente al estado "routeReady" de T19-C4).
  bool get isRouteReady =>
      !isCalculatingRoute && routeInfo != null && fareEstimate != null;

  LocationSearchState copyWith({
    Object? origin = _unset,
    Object? destination = _unset,
    List<PlacePrediction>? predictions,
    Object? routeInfo = _unset,
    Object? fareEstimate = _unset,
    bool? isSearchingOrigin,
    bool? isSearchingDestination,
    bool? isCalculatingRoute,
    bool? hasNoResults,
    Object? errorMessage = _unset,
  }) {
    return LocationSearchState(
      origin: identical(origin, _unset)
          ? this.origin
          : origin as SelectedLocation?,
      destination: identical(destination, _unset)
          ? this.destination
          : destination as SelectedLocation?,
      predictions: predictions ?? this.predictions,
      routeInfo: identical(routeInfo, _unset)
          ? this.routeInfo
          : routeInfo as RouteInfo?,
      fareEstimate: identical(fareEstimate, _unset)
          ? this.fareEstimate
          : fareEstimate as FareEstimate?,
      isSearchingOrigin: isSearchingOrigin ?? this.isSearchingOrigin,
      isSearchingDestination:
          isSearchingDestination ?? this.isSearchingDestination,
      isCalculatingRoute: isCalculatingRoute ?? this.isCalculatingRoute,
      hasNoResults: hasNoResults ?? this.hasNoResults,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    origin,
    destination,
    predictions,
    routeInfo,
    fareEstimate,
    isSearchingOrigin,
    isSearchingDestination,
    isCalculatingRoute,
    hasNoResults,
    errorMessage,
  ];
}
