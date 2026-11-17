import 'dart:async';

import 'package:auronix_app/features/trips/data/datasources/socket/client_position_listener.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/cancel_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/rate_driver_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/request_trip_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'client_trip_event.dart';
part 'client_trip_state.dart';

class ClientTripBloc extends Bloc<ClientTripEvent, ClientTripState> {
  final RequestTripUseCase _requestTrip;
  final CancelTripUseCase _cancelTrip;
  final RateDriverUseCase _rateDriver;
  final TripStatusSocket _socket;
  final ClientPositionListener _positionListener;

  StreamSubscription<TripStatusEvent>? _socketSub;
  StreamSubscription<DriverPositionUpdate>? _positionSub;

  ClientTripBloc({
    required RequestTripUseCase requestTrip,
    required CancelTripUseCase cancelTrip,
    required RateDriverUseCase rateDriver,
    required TripStatusSocket socket,
    required ClientPositionListener positionListener,
  })  : _requestTrip = requestTrip,
        _cancelTrip = cancelTrip,
        _rateDriver = rateDriver,
        _socket = socket,
        _positionListener = positionListener,
        super(const ClientTripState()) {
    on<ClientTripSetRouteEvent>(_onSetRoute);
    on<ClientTripRequestEvent>(_onRequest);
    on<ClientTripConnectSocketEvent>(_onConnectSocket);
    on<ClientTripStatusUpdatedEvent>(_onStatusUpdated);
    on<ClientTripCancelEvent>(_onCancel);
    on<ClientTripRateDriverEvent>(_onRateDriver);
    on<ClientTripListenPositionEvent>(_onListenPosition);
    on<ClientTripDriverPositionEvent>(_onDriverPosition);
    on<ClientTripResetEvent>(_onReset);
  }

  FutureOr<void> _onSetRoute(
    ClientTripSetRouteEvent event,
    Emitter<ClientTripState> emit,
  ) {
    emit(state.copyWith(
      origenLatitud: event.origenLatitud,
      origenLongitud: event.origenLongitud,
      origenDireccion: event.origenDireccion,
      destinoLatitud: event.destinoLatitud,
      destinoLongitud: event.destinoLongitud,
      destinoDireccion: event.destinoDireccion,
      distanciaEstimadaKm: event.distanciaEstimadaKm,
    ));
  }

  FutureOr<void> _onRequest(
    ClientTripRequestEvent event,
    Emitter<ClientTripState> emit,
  ) async {
    emit(state.copyWith(status: ClientTripStatus.requesting));

    final result = await _requestTrip(
      userId: event.userId,
      origenLatitud: event.origenLatitud,
      origenLongitud: event.origenLongitud,
      origenDireccion: event.origenDireccion,
      destinoLatitud: event.destinoLatitud,
      destinoLongitud: event.destinoLongitud,
      destinoDireccion: event.destinoDireccion,
      distanciaEstimadaKm: event.distanciaEstimadaKm,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ClientTripStatus.error,
        errorMessage: failure.message,
      )),
      (trip) {
        emit(state.copyWith(
          status: ClientTripStatus.searching,
          activeTrip: trip,
        ));
        add(ClientTripConnectSocketEvent(tripId: trip.id));
      },
    );
  }

  FutureOr<void> _onConnectSocket(
    ClientTripConnectSocketEvent event,
    Emitter<ClientTripState> emit,
  ) {
    _socketSub?.cancel();
    _socketSub = _socket.connect(event.tripId).listen(
      (e) => add(ClientTripStatusUpdatedEvent(socketEvent: e)),
    );
  }

  FutureOr<void> _onStatusUpdated(
    ClientTripStatusUpdatedEvent event,
    Emitter<ClientTripState> emit,
  ) {
    final status = switch (event.socketEvent.status) {
      'ACEPTADO' => ClientTripStatus.accepted,
      'EN_CURSO' => ClientTripStatus.inProgress,
      'COMPLETADO' => ClientTripStatus.completed,
      _ => state.status,
    };

    emit(state.copyWith(
      status: status,
      activeTrip: event.socketEvent.trip ?? state.activeTrip,
    ));

    if (status == ClientTripStatus.completed) {
      _socketSub?.cancel();
      _socket.disconnect();
    }
  }

  FutureOr<void> _onCancel(
    ClientTripCancelEvent event,
    Emitter<ClientTripState> emit,
  ) async {
    final result = await _cancelTrip(
      userId: event.userId,
      tripId: event.tripId,
      motivo: event.motivo,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        _socketSub?.cancel();
        _socket.disconnect();
        emit(state.copyWith(
          status: ClientTripStatus.cancelled,
          clearTrip: true,
        ));
      },
    );
  }

  FutureOr<void> _onRateDriver(
    ClientTripRateDriverEvent event,
    Emitter<ClientTripState> emit,
  ) async {
    emit(state.copyWith(status: ClientTripStatus.rating));
    final result = await _rateDriver(
      userId: event.userId,
      tripId: event.tripId,
      calificacion: event.calificacion,
      comentario: event.comentario,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: ClientTripStatus.rated)),
    );
  }

  FutureOr<void> _onListenPosition(
    ClientTripListenPositionEvent event,
    Emitter<ClientTripState> emit,
  ) {
    _positionSub?.cancel();
    _positionSub = _positionListener.connect(event.tripId).listen(
      (update) => add(ClientTripDriverPositionEvent(
        latitude: update.latitude,
        longitude: update.longitude,
      )),
    );
    debugPrint('[ClientTrip] listening driver position for trip ${event.tripId}');
  }

  FutureOr<void> _onDriverPosition(
    ClientTripDriverPositionEvent event,
    Emitter<ClientTripState> emit,
  ) {
    emit(state.copyWith(
      driverLat: event.latitude,
      driverLng: event.longitude,
    ));
  }

  FutureOr<void> _onReset(
    ClientTripResetEvent event,
    Emitter<ClientTripState> emit,
  ) {
    _socketSub?.cancel();
    _socket.disconnect();
    _positionSub?.cancel();
    _positionListener.disconnect();
    emit(const ClientTripState());
  }

  // ignore: must_call_super
  @override
  Future<void> close() async {
    // Singleton gestionado por GetIt — no cerrar para evitar
    // "Cannot add new events after calling close"
  }
}
