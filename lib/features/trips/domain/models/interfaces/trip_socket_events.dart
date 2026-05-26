import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';

class TripRequestEvent {
  final int id;
  final String codigoViaje;
  final String origenDireccion;
  final String destinoDireccion;
  final double origenLatitud;
  final double origenLongitud;
  final double distanciaKm;
  final double precioTotal;

  const TripRequestEvent({
    required this.id,
    required this.codigoViaje,
    required this.origenDireccion,
    required this.destinoDireccion,
    required this.origenLatitud,
    required this.origenLongitud,
    required this.distanciaKm,
    required this.precioTotal,
  });

  factory TripRequestEvent.fromJson(Map<String, dynamic> json) =>
      TripRequestEvent(
        id: json['id'] as int,
        codigoViaje: json['codigoViaje'] as String? ?? '',
        origenDireccion: json['origenDireccion'] as String? ?? '',
        destinoDireccion: json['destinoDireccion'] as String? ?? '',
        origenLatitud: (json['origenLatitud'] as num).toDouble(),
        origenLongitud: (json['origenLongitud'] as num).toDouble(),
        distanciaKm: (json['distanciaKm'] as num).toDouble(),
        precioTotal: (json['precioTotal'] as num).toDouble(),
      );
}

class TripStatusEvent {
  final int tripId;
  final String status;
  final TripEntity? trip;

  const TripStatusEvent({
    required this.tripId,
    required this.status,
    this.trip,
  });
}
