import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';

class TripResponseModel {
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

  const TripResponseModel({
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

  factory TripResponseModel.fromJson(Map<String, dynamic> json) =>
      TripResponseModel(
        id: json['id'] as int,
        codigoViaje: json['codigoViaje'] as String? ?? '',
        passengerId: json['passengerId'] as int? ?? 0,
        driverId: json['driverId'] as int?,
        cooperativaId: json['cooperativaId'] as int? ?? 0,
        origenLatitud: (json['origenLatitud'] as num).toDouble(),
        origenLongitud: (json['origenLongitud'] as num).toDouble(),
        origenDireccion: json['origenDireccion'] as String? ?? '',
        destinoLatitud: (json['destinoLatitud'] as num).toDouble(),
        destinoLongitud: (json['destinoLongitud'] as num).toDouble(),
        destinoDireccion: json['destinoDireccion'] as String? ?? '',
        distanciaKm: (json['distanciaKm'] as num).toDouble(),
        precioTotal: (json['precioTotal'] as num).toDouble(),
        estado: json['estado'] as String? ?? '',
        fechaSolicitud: json['fechaSolicitud'] as String? ?? '',
      );

  TripEntity toEntity() => TripEntity(
        id: id,
        codigoViaje: codigoViaje,
        passengerId: passengerId,
        driverId: driverId,
        cooperativaId: cooperativaId,
        origenLatitud: origenLatitud,
        origenLongitud: origenLongitud,
        origenDireccion: origenDireccion,
        destinoLatitud: destinoLatitud,
        destinoLongitud: destinoLongitud,
        destinoDireccion: destinoDireccion,
        distanciaKm: distanciaKm,
        precioTotal: precioTotal,
        estado: estado,
        fechaSolicitud: fechaSolicitud,
      );
}
