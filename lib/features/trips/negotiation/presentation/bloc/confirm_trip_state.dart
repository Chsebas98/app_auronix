part of 'confirm_trip_cubit.dart';

enum ConfirmTripStatus {
  loadingOrigin,
  estimating,
  ready,
  publishing,
  published,
  error,
}

class ConfirmTripState extends Equatable {
  const ConfirmTripState({
    this.destination,
    this.status = ConfirmTripStatus.loadingOrigin,
    this.origin,
    this.estimate,
    this.minPrice,
    this.published,
    this.errorMessage,
  });

  final ConfirmTripStatus status;

  /// Nulo solo hasta que [ConfirmTripCubit.init] recibe el destino elegido
  /// en "Seleccionar destino" — la UI solo se construye después de eso.
  final AddressSuggestion? destination;
  final AddressSuggestion? origin;
  final TripEstimate? estimate;

  /// `PublicConfig.precioMinimoTrayecto` — null si la configuración pública
  /// no se pudo obtener ni siquiera de la caché (docs/testing.md caso #19).
  final double? minPrice;
  final PublishedTripRequest? published;
  final String? errorMessage;

  bool get isBusy =>
      status == ConfirmTripStatus.loadingOrigin ||
      status == ConfirmTripStatus.estimating ||
      status == ConfirmTripStatus.publishing;

  ConfirmTripState copyWith({
    ConfirmTripStatus? status,
    AddressSuggestion? destination,
    AddressSuggestion? origin,
    TripEstimate? estimate,
    double? minPrice,
    bool clearMinPrice = false,
    PublishedTripRequest? published,
    String? errorMessage,
  }) {
    return ConfirmTripState(
      destination: destination ?? this.destination,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      estimate: estimate ?? this.estimate,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      published: published ?? this.published,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    destination,
    origin,
    estimate,
    minPrice,
    published,
    errorMessage,
  ];
}
