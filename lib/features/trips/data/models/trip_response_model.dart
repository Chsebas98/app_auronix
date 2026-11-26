import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';

class TripResponseModel {
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

  const TripResponseModel({
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
  });

  factory TripResponseModel.fromJson(Map<String, dynamic> json) =>
      TripResponseModel(
        id: json['id'] as int,
        codigoViaje: json['codigoViaje'] as String? ?? '',
        passengerId: json['passengerId'] as int? ?? 0,
        driverId: json['driverId'] as int?,
        vehicleId: json['vehicleId'] as int?,
        cooperativaId: json['cooperativaId'] as int? ?? 0,
        origenLatitud: (json['origenLatitud'] as num?)?.toDouble() ?? 0,
        origenLongitud: (json['origenLongitud'] as num?)?.toDouble() ?? 0,
        origenDireccion: json['origenDireccion'] as String? ?? '',
        // El backend permite destino nulo (viaje recien SOLICITADO, sin
        // destino aun confirmado) — se usa 0 como placeholder en vez de
        // fallar el parseo completo del viaje por ese campo.
        destinoLatitud: (json['destinoLatitud'] as num?)?.toDouble() ?? 0,
        destinoLongitud: (json['destinoLongitud'] as num?)?.toDouble() ?? 0,
        destinoDireccion: json['destinoDireccion'] as String? ?? '',
        distanciaKm: (json['distanciaKm'] as num?)?.toDouble() ?? 0,
        precioTotal: (json['precioTotal'] as num?)?.toDouble() ?? 0,
        estado: TripStatus.fromBackendValue(
          json['estado'] as String? ?? 'SOLICITADO',
        ),
        fechaSolicitud: json['fechaSolicitud'] as String? ?? '',
      );

  TripEntity toEntity() => TripEntity(
    id: id,
    codigoViaje: codigoViaje,
    passengerId: passengerId,
    driverId: driverId,
    vehicleId: vehicleId,
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
