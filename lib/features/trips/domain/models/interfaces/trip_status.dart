/// Estado de un viaje tal como lo envia/espera el backend real
/// (micro-auronix `TripStatus.java`/`TripResponseDto`): las cadenas
/// literales son SOLICITADO/OFERTADO/ACEPTADO/EN_CURSO/COMPLETADO/
/// CANCELADO, mismo orden y nombres que el enum Java.
enum TripStatus {
  solicitado,
  ofertado,
  aceptado,
  enCurso,
  completado,
  cancelado;

  /// Lanza [InvalidTripStatusException] si [value] no es un estado valido —
  /// nunca cae en un estado por defecto silencioso (mismo criterio que
  /// UserRole.fromBackendValue).
  static TripStatus fromBackendValue(String value) {
    switch (value.toUpperCase()) {
      case 'SOLICITADO':
        return TripStatus.solicitado;
      case 'OFERTADO':
        return TripStatus.ofertado;
      case 'ACEPTADO':
        return TripStatus.aceptado;
      case 'EN_CURSO':
        return TripStatus.enCurso;
      case 'COMPLETADO':
        return TripStatus.completado;
      case 'CANCELADO':
        return TripStatus.cancelado;
      default:
        throw InvalidTripStatusException(value);
    }
  }

  String toBackendValue() {
    switch (this) {
      case TripStatus.solicitado:
        return 'SOLICITADO';
      case TripStatus.ofertado:
        return 'OFERTADO';
      case TripStatus.aceptado:
        return 'ACEPTADO';
      case TripStatus.enCurso:
        return 'EN_CURSO';
      case TripStatus.completado:
        return 'COMPLETADO';
      case TripStatus.cancelado:
        return 'CANCELADO';
    }
  }
}

class InvalidTripStatusException implements Exception {
  final String rawValue;

  const InvalidTripStatusException(this.rawValue);

  @override
  String toString() =>
      'InvalidTripStatusException: estado de viaje desconocido "$rawValue"';
}
