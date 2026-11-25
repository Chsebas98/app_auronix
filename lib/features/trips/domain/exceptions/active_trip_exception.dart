/// Lanzada por [TripRepositoryImpl] cuando el backend responde 409 a una
/// solicitud de viaje porque el pasajero ya tiene un viaje activo (estado
/// distinto de COMPLETADO/CANCELADO) — ver micro-auronix CreateTripUseCase.
class ActiveTripException implements Exception {
  final String message;

  const ActiveTripException([
    this.message = 'Ya tienes un viaje activo en curso.',
  ]);

  @override
  String toString() => 'ActiveTripException: $message';
}
