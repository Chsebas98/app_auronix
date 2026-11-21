part of 'location_search_bloc.dart';

sealed class LocationSearchEvent extends Equatable {
  const LocationSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Texto digitado en el buscador de origen o destino (debounce de 350ms,
/// T19-C1).
class SearchQueryChanged extends LocationSearchEvent {
  const SearchQueryChanged(this.query, this.isOrigin);

  final String query;
  final bool isOrigin;

  @override
  List<Object?> get props => [query, isOrigin];
}

/// El usuario elige una sugerencia de la lista de predicciones.
class SelectPlace extends LocationSearchEvent {
  const SelectPlace(this.place, this.isOrigin);

  final PlacePrediction place;
  final bool isOrigin;

  @override
  List<Object?> get props => [place, isOrigin];
}

/// Fija el origen a partir de la ubicacion actual del dispositivo (ya
/// resuelta fuera del Bloc — geolocalizacion no es su responsabilidad).
class SetCurrentLocationAsOrigin extends LocationSearchEvent {
  const SetCurrentLocationAsOrigin(this.coords, this.address);

  final LatLng coords;
  final String address;

  @override
  List<Object?> get props => [coords, address];
}

/// Intercambia origen y destino (T19-C2); recalcula la ruta si ambos ya
/// estaban cargados.
class SwapLocations extends LocationSearchEvent {
  const SwapLocations();
}

class ClearLocation extends LocationSearchEvent {
  const ClearLocation(this.isOrigin);

  final bool isOrigin;

  @override
  List<Object?> get props => [isOrigin];
}

/// Vuelve al estado inicial (p. ej. al cerrar el buscador).
class ResetSearch extends LocationSearchEvent {
  const ResetSearch();
}

/// Reintenta el calculo de ruta/tarifa con el origen y destino actuales
/// (T21-C11: boton "Reintentar" cuando el calculo previo fallo).
class RetryRouteCalculation extends LocationSearchEvent {
  const RetryRouteCalculation();
}
