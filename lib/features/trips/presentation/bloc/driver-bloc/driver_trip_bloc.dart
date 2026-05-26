import 'dart:async';

import 'package:auronix_app/features/trips/data/datasources/socket/driver_trip_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/accept_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/complete_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/get_available_trips_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/rate_passenger_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/start_trip_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

part 'driver_trip_event.dart';
part 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  final GetAvailableTripsUseCase _getAvailableTrips;
  final AcceptTripUseCase _acceptTrip;
  final StartTripUseCase _startTrip;
  final CompleteTripUseCase _completeTrip;
  final RatePassengerUseCase _ratePassenger;
  final DriverTripSocket _socket;

  StreamSubscription<TripRequestEvent>? _socketSub;

  DriverTripBloc({
    required GetAvailableTripsUseCase getAvailableTrips,
    required AcceptTripUseCase acceptTrip,
    required StartTripUseCase startTrip,
    required CompleteTripUseCase completeTrip,
    required RatePassengerUseCase ratePassenger,
    required DriverTripSocket socket,
  })  : _getAvailableTrips = getAvailableTrips,
        _acceptTrip = acceptTrip,
        _startTrip = startTrip,
        _completeTrip = completeTrip,
        _ratePassenger = ratePassenger,
        _socket = socket,
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

    final result = await _getAvailableTrips(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (entities) => emit(state.copyWith(
        status: DriverTripStatus.ready,
        nearbyRequests: entities.map(_entityToRequest).toList(),
      )),
    );
  }

  FutureOr<void> _onConnectSocket(
    DriverTripConnectSocketEvent event,
    Emitter<DriverTripState> emit,
  ) {
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
    emit(state.copyWith(status: DriverTripStatus.accepting));

    final result = await _acceptTrip(
      userId: event.userId,
      tripId: event.tripId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: DriverTripStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: DriverTripStatus.accepted,
        clearSelected: true,
      )),
    );
  }

  FutureOr<void> _onReject(
    DriverTripRejectEvent event,
    Emitter<DriverTripState> emit,
  ) {
    final updated =
        state.nearbyRequests.where((r) => r.id != event.requestId).toList();
    emit(state.copyWith(nearbyRequests: updated, clearSelected: true));
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
        position: LatLng(e.origenLatitud, e.origenLongitud),
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
        position: LatLng(e.origenLatitud, e.origenLongitud),
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
      (result) => emit(state.copyWith(
        status: DriverTripStatus.completed,
        completedTrip: result,
      )),
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

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _socket.disconnect();
    return super.close();
  }
}
