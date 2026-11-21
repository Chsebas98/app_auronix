import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';

/// Entidad de dominio de un viaje (T22). Campos segun el esquema real de
/// tb_trips (micro-auronix V6__create_trips.sql/V9__add_contraoferta_to_trips.sql)
/// y TripResponseDto. driverId/vehicleId son nulos hasta que el viaje tiene
/// conductor asignado.
class TripEntity {
  final int id;
  final String codigoViaje;
  final int passengerId;
  final int? driverId;
  final int? vehicleId;
  final int cooperativaId;
  final double origenLatitud;
  final double origenLongitud;
  final String origenDireccion;
  final double destinoLatitud;
  final double destinoLongitud;
  final String destinoDireccion;
  final double distanciaKm;
  final double precioTotal;
  final TripStatus estado;
  final String fechaSolicitud;

  /// Posicion de seguimiento en vivo del conductor durante el viaje
  /// (actualizada por socket, no persistida en tb_trips) — null hasta la
  /// primera actualizacion de posicion recibida.
  final double? trackingLatitud;
  final double? trackingLongitud;

  const TripEntity({
    required this.id,
    required this.codigoViaje,
    required this.passengerId,
    this.driverId,
    this.vehicleId,
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
    this.trackingLatitud,
    this.trackingLongitud,
  });
}
