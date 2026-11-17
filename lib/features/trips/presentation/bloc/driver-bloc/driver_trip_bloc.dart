import 'dart:async';

import 'package:auronix_app/features/trips/data/datasources/socket/driver_position_sender.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/driver_trip_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/accept_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/complete_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/get_available_trips_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/rate_passenger_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/reject_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/start_trip_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

part 'driver_trip_event.dart';
part 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  final GetAvailableTripsUseCase _getAvailableTrips;
  final AcceptTripUseCase _acceptTrip;
  final RejectTripUseCase _rejectTrip;
  final StartTripUseCase _startTrip;
  final CompleteTripUseCase _completeTrip;
  final RatePassengerUseCase _ratePassenger;
  final DriverTripSocket _socket;
  final DriverPositionSender _positionSender;

  StreamSubscription<TripRequestEvent>? _socketSub;
  int _driverId = 0;

  DriverTripBloc({
    required GetAvailableTripsUseCase getAvailableTrips,
    required AcceptTripUseCase acceptTrip,
    required RejectTripUseCase rejectTrip,
    required StartTripUseCase startTrip,
    required CompleteTripUseCase completeTrip,
    required RatePassengerUseCase ratePassenger,
    required DriverTripSocket socket,
    required DriverPositionSender positionSender,
  })  : _getAvailableTrips = getAvailableTrips,
        _acceptTrip = acceptTrip,
        _rejectTrip = rejectTrip,
        _startTrip = startTrip,
        _completeTrip = completeTrip,
        _ratePassenger = ratePassenger,
        _socket = socket,
        _positionSender = positionSender,
        super(const DriverTripState()) {
    on<DriverTripLoadNearbyEvent>(_onLoadNearby);
    on<DriverTripConnectSocketEvent>(_onConnectSocket);
    on<DriverTripSocketReceivedEvent>(_onSocketReceived);
    on<DriverTripSelectRequestEvent>(_onSelectRequest);
    on<DriverTripDismissRequestEvent>(_onDismiss);
    on<DriverTripAcceptEvent>(_onAccept);
    on<DriverTripRejectEvent>(_onReject);
    on<DriverTripStartEvent>(_onStart);
    on<DriverTripCompleteEvent>(_onComplete);
    on<DriverTripRatePassengerEvent>(_onRatePassenger);
  }

  FutureOr<void> _onLoadNearby(
    DriverTripLoadNearbyEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(status: DriverTripStatus.loading));

    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos != null) {
        emit(state.copyWith(
          driverLat: pos.latitude,
          driverLng: pos.longitude,
        ));
        debugPrint('[DriverTrip] GPS: ${pos.latitude}, ${pos.longitude}');
      }
    } catch (e) {
      debugPrint('[DriverTrip] GPS error: $e');
    }

    final result = await _getAvailableTrips(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (entities) {
        debugPrint('[DriverTrip] viajes disponibles: ${entities.length}');
        emit(state.copyWith(
          status: DriverTripStatus.ready,
          nearbyRequests: entities.map(_entityToRequest).toList(),
        ));
      },
    );
  }

  FutureOr<void> _onConnectSocket(
    DriverTripConnectSocketEvent event,
    Emitter<DriverTripState> emit,
  ) {
    _driverId = event.driverId;
    _socketSub?.cancel();
    _socketSub = _socket.connect(event.driverId).listen(
      (socketEvent) => add(DriverTripSocketReceivedEvent(event: socketEvent)),
    );
  }

  FutureOr<void> _onSocketReceived(
    DriverTripSocketReceivedEvent event,
    Emitter<DriverTripState> emit,
  ) {
    final incoming = _socketEventToRequest(event.event);
    final updated = [...state.nearbyRequests, incoming];
    emit(state.copyWith(nearbyRequests: updated));
  }

  FutureOr<void> _onSelectRequest(
    DriverTripSelectRequestEvent event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(selectedRequest: event.request));
  }

  FutureOr<void> _onDismiss(
    DriverTripDismissRequestEvent event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(clearSelected: true));
  }

  FutureOr<void> _onAccept(
    DriverTripAcceptEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    debugPrint('[DriverTrip] accept userId=${event.userId} tripId=${event.tripId}');
    emit(state.copyWith(status: DriverTripStatus.accepting));

    final result = await _acceptTrip(
      userId: event.userId,
      tripId: event.tripId,
    );

    result.fold(
      (failure) {
        debugPrint('[DriverTrip] accept FAILED: ${failure.message}');
        emit(state.copyWith(
          status: DriverTripStatus.error,
          errorMessage: failure.message,
        ));
      },
      (trip) {
        debugPrint('[DriverTrip] accept OK → trip ${trip.id} estado: ${trip.estado}');
        _positionSender.start(_driverId);
        emit(state.copyWith(
          status: DriverTripStatus.accepted,
          activeTrip: trip,
          clearSelected: true,
        ));
      },
    );
  }

  FutureOr<void> _onReject(
    DriverTripRejectEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    final updated =
        state.nearbyRequests.where((r) => r.id != event.requestId).toList();
    emit(state.copyWith(nearbyRequests: updated, clearSelected: true));

    await _rejectTrip(
      userId: event.userId,
      tripId: event.tripId,
      motivo: event.motivo,
    );
  }

  TripRequest _entityToRequest(TripEntity e) => TripRequest(
        id: e.id.toString(),
        clientName: '',
        clientRating: 0,
        distanceKm: e.distanciaKm,
        originAddress: e.origenDireccion,
        originEta: '',
        destinationAddress: e.destinoDireccion,
        destinationEta: '',
        estimatedFare: e.precioTotal,
        latitude: e.origenLatitud,
        longitude: e.origenLongitud,
      );

  TripRequest _socketEventToRequest(TripRequestEvent e) => TripRequest(
        id: e.id.toString(),
        clientName: '',
        clientRating: 0,
        distanceKm: e.distanciaKm,
        originAddress: e.origenDireccion,
        originEta: '',
        destinationAddress: e.destinoDireccion,
        destinationEta: '',
        estimatedFare: e.precioTotal,
        latitude: e.origenLatitud,
        longitude: e.origenLongitud,
      );

  FutureOr<void> _onStart(
    DriverTripStartEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(status: DriverTripStatus.starting));

    final result = await _startTrip(userId: event.userId, tripId: event.tripId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (trip) => emit(state.copyWith(
        status: DriverTripStatus.inProgress,
        activeTrip: trip,
      )),
    );
  }

  FutureOr<void> _onComplete(
    DriverTripCompleteEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(status: DriverTripStatus.completing));

    final result = await _completeTrip(
      userId: event.userId,
      tripId: event.tripId,
      distanciaFinalKm: event.distanciaFinalKm,
      duracionMinutos: event.duracionMinutos,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (result) {
        _positionSender.stop();
        emit(state.copyWith(
          status: DriverTripStatus.completed,
          completedTrip: result,
        ));
      },
    );
  }

  FutureOr<void> _onRatePassenger(
    DriverTripRatePassengerEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(status: DriverTripStatus.rating));

    final result = await _ratePassenger(
      userId: event.userId,
      tripId: event.tripId,
      calificacion: event.calificacion,
      comentario: event.comentario,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: DriverTripStatus.rated)),
    );
  }

  // ignore: must_call_super
  @override
  Future<void> close() async {
    // Singleton gestionado por GetIt — no cerrar
  }
}
