part of 'client_trip_bloc.dart';

sealed class ClientTripEvent extends Equatable {
  const ClientTripEvent();

  @override
  List<Object?> get props => [];
}

final class ClientTripRequestEvent extends ClientTripEvent {
  final int userId;
  final double origenLatitud;
  final double origenLongitud;
  final String origenDireccion;
  final double destinoLatitud;
  final double destinoLongitud;
  final String destinoDireccion;
  final double distanciaEstimadaKm;

  const ClientTripRequestEvent({
    required this.userId,
    required this.origenLatitud,
    required this.origenLongitud,
    required this.origenDireccion,
    required this.destinoLatitud,
    required this.destinoLongitud,
    required this.destinoDireccion,
    required this.distanciaEstimadaKm,
  });

  @override
  List<Object?> get props => [userId, origenDireccion, destinoDireccion];
}

final class ClientTripConnectSocketEvent extends ClientTripEvent {
  final int tripId;
  const ClientTripConnectSocketEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

final class ClientTripStatusUpdatedEvent extends ClientTripEvent {
  final TripStatusEvent socketEvent;
  const ClientTripStatusUpdatedEvent({required this.socketEvent});

  @override
  List<Object?> get props => [socketEvent];
}

final class ClientTripCancelEvent extends ClientTripEvent {
  final int userId;
  final int tripId;
  final String motivo;
  const ClientTripCancelEvent({
    required this.userId,
    required this.tripId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [tripId];
}

final class ClientTripRateDriverEvent extends ClientTripEvent {
  final int userId;
  final int tripId;
  final int calificacion;
  final String? comentario;
  const ClientTripRateDriverEvent({
    required this.userId,
    required this.tripId,
    required this.calificacion,
    this.comentario,
  });

  @override
  List<Object?> get props => [tripId, calificacion];
}

final class ClientTripSetRouteEvent extends ClientTripEvent {
  final double origenLatitud;
  final double origenLongitud;
  final String origenDireccion;
  final double destinoLatitud;
  final double destinoLongitud;
  final String destinoDireccion;
  final double distanciaEstimadaKm;

  const ClientTripSetRouteEvent({
    required this.origenLatitud,
    required this.origenLongitud,
    required this.origenDireccion,
    required this.destinoLatitud,
    required this.destinoLongitud,
    required this.destinoDireccion,
    required this.distanciaEstimadaKm,
  });

  @override
  List<Object?> get props => [origenDireccion, destinoDireccion];
}

final class ClientTripResetEvent extends ClientTripEvent {
  const ClientTripResetEvent();
}
