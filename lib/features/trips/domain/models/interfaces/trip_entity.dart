class TripEntity {
  final int id;
  final String codigoViaje;
  final int passengerId;
  final int? driverId;
  final int cooperativaId;
  final double origenLatitud;
  final double origenLongitud;
  final String origenDireccion;
  final double destinoLatitud;
  final double destinoLongitud;
  final String destinoDireccion;
  final double distanciaKm;
  final double precioTotal;
  final String estado;
  final String fechaSolicitud;

  const TripEntity({
    required this.id,
    required this.codigoViaje,
    required this.passengerId,
    this.driverId,
    required this.cooperativaId,
    required this.origenLatitud,
    required this.origenLongitud,
    required this.origenDireccion,
    required this.destinoLatitud,
    required this.destinoLongitud,
    required this.destinoDireccion,
    required this.distanciaKm,
    required this.precioTotal,
    required this.estado,
    required this.fechaSolicitud,
  });
}
