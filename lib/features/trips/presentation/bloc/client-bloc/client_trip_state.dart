part of 'client_trip_bloc.dart';

enum ClientTripStatus {
  initial,
  requesting,
  searching,
  accepted,
  inProgress,
  completed,
  cancelled,
  rating,
  rated,
  error,
}

final class ClientTripState extends Equatable {
  const ClientTripState({
    this.status = ClientTripStatus.initial,
    this.activeTrip,
    this.errorMessage,
    this.origenLatitud,
    this.origenLongitud,
    this.origenDireccion,
    this.destinoLatitud,
    this.destinoLongitud,
    this.destinoDireccion,
    this.distanciaEstimadaKm,
  });

  final ClientTripStatus status;
  final TripEntity? activeTrip;
  final String? errorMessage;

  // Ruta seleccionada (antes de confirmar el viaje)
  final double? origenLatitud;
  final double? origenLongitud;
  final String? origenDireccion;
  final double? destinoLatitud;
  final double? destinoLongitud;
  final String? destinoDireccion;
  final double? distanciaEstimadaKm;

  bool get isSearching => status == ClientTripStatus.searching;
  bool get hasActiveTrip => activeTrip != null;
  bool get hasRoute =>
      origenDireccion != null && destinoDireccion != null;

  ClientTripState copyWith({
    ClientTripStatus? status,
    TripEntity? activeTrip,
    bool clearTrip = false,
    String? errorMessage,
    double? origenLatitud,
    double? origenLongitud,
    String? origenDireccion,
    double? destinoLatitud,
    double? destinoLongitud,
    String? destinoDireccion,
    double? distanciaEstimadaKm,
  }) {
    return ClientTripState(
      status: status ?? this.status,
      activeTrip: clearTrip ? null : activeTrip ?? this.activeTrip,
      errorMessage: errorMessage ?? this.errorMessage,
      origenLatitud: origenLatitud ?? this.origenLatitud,
      origenLongitud: origenLongitud ?? this.origenLongitud,
      origenDireccion: origenDireccion ?? this.origenDireccion,
      destinoLatitud: destinoLatitud ?? this.destinoLatitud,
      destinoLongitud: destinoLongitud ?? this.destinoLongitud,
      destinoDireccion: destinoDireccion ?? this.destinoDireccion,
      distanciaEstimadaKm: distanciaEstimadaKm ?? this.distanciaEstimadaKm,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTrip,
        errorMessage,
        origenLatitud,
        origenLongitud,
        origenDireccion,
        destinoLatitud,
        destinoLongitud,
        destinoDireccion,
        distanciaEstimadaKm,
      ];
}
