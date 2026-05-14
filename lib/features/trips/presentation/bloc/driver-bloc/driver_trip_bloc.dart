import 'dart:async';

import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

part 'driver_trip_event.dart';
part 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  DriverTripBloc() : super(const DriverTripState()) {
    on<DriverTripLoadNearbyEvent>(_onLoadNearby);
    on<DriverTripSelectRequestEvent>(_onSelectRequest);
    on<DriverTripDismissRequestEvent>(_onDismiss);
    on<DriverTripAcceptEvent>(_onAccept);
    on<DriverTripRejectEvent>(_onReject);
  }

  FutureOr<void> _onLoadNearby(
    DriverTripLoadNearbyEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(status: DriverTripStatus.loading));

    // TODO: reemplazar con usecase real
    await Future.delayed(const Duration(seconds: 1));

    emit(
      state.copyWith(
        status: DriverTripStatus.ready,
        driverPosition: const LatLng(4.7110, -74.0721), // Bogotá mock
        nearbyRequests: [
          TripRequest(
            id: '1',
            clientName: 'David L.',
            clientRating: 4.9,
            distanceKm: 1.2,
            originAddress: 'Calle 95 #12-34',
            originEta: '4 min',
            destinationAddress: 'Aeropuerto El Dorado',
            destinationEta: '40 min',
            estimatedFare: 45.00,
            position: const LatLng(4.7150, -74.0680),
          ),
          TripRequest(
            id: '2',
            clientName: 'Maria G.',
            clientRating: 4.7,
            distanceKm: 2.5,
            originAddress: 'Carrera 15 #85-20',
            originEta: '7 min',
            destinationAddress: 'Centro Comercial Andino',
            destinationEta: '25 min',
            estimatedFare: 28.00,
            position: const LatLng(4.7090, -74.0750),
          ),
          TripRequest(
            id: '3',
            clientName: 'Juan P.',
            clientRating: 4.5,
            distanceKm: 3.1,
            originAddress: 'Calle 72 #10-07',
            originEta: '10 min',
            destinationAddress: 'Usaquén',
            destinationEta: '30 min',
            estimatedFare: 35.00,
            position: const LatLng(4.7200, -74.0700),
          ),
        ],
      ),
    );
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
    // TODO: usecase aceptar viaje
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: DriverTripStatus.ready, clearSelected: true));
  }

  FutureOr<void> _onReject(
    DriverTripRejectEvent event,
    Emitter<DriverTripState> emit,
  ) {
    final updated = state.nearbyRequests
        .where((r) => r.id != event.requestId)
        .toList();
    emit(state.copyWith(nearbyRequests: updated, clearSelected: true));
  }
}
