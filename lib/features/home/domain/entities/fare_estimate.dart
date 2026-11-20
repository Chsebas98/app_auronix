/// Estimacion preliminar de tarifa (T18), calculada en el cliente antes de
/// solicitar el viaje. El precio final real lo define el backend al crear
/// el viaje — esto es solo una previsualizacion para el pasajero.
class FareEstimate {
  const FareEstimate({
    required this.estimatedPrice,
    required this.currency,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
  });

  final double estimatedPrice;
  final String currency;
  final double baseFare;
  final double distanceFare;
  final double timeFare;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FareEstimate &&
          other.estimatedPrice == estimatedPrice &&
          other.currency == currency &&
          other.baseFare == baseFare &&
          other.distanceFare == distanceFare &&
          other.timeFare == timeFare);

  @override
  int get hashCode =>
      Object.hash(estimatedPrice, currency, baseFare, distanceFare, timeFare);
}
