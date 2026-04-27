import 'dart:async';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_driver_event.dart';
part 'home_driver_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  HomeDriverBloc() : super(const HomeDriverState()) {
    on<HomeDriverInitEvent>(_onInit);
    on<HomeDriverToggleAvailabilityEvent>(_onToggleAvailability);
    on<HomeDriverLocationUpdatedEvent>(_onLocationUpdated);
    on<HomeDriverTripRequestedEvent>(_onTripRequested);
    on<HomeDriverTripAcceptedEvent>(_onTripAccepted);
    on<HomeDriverTripRejectedEvent>(_onTripRejected);
    on<HomeDriverProfileLoadedEvent>(_onProfileLoaded);
  }

  FutureOr<void> _onInit(
    HomeDriverInitEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    emit(state.copyWith(status: HomeDriverStatus.ready));
  }

  FutureOr<void> _onToggleAvailability(
    HomeDriverToggleAvailabilityEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(state.copyWith(isAvailable: !state.isAvailable));
  }

  FutureOr<void> _onLocationUpdated(
    HomeDriverLocationUpdatedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(
      state.copyWith(currentAddress: event.address, isLoadingAddress: false),
    );
  }

  FutureOr<void> _onTripRequested(
    HomeDriverTripRequestedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(
      state.copyWith(
        incomingTrip: event.trip,
        status: HomeDriverStatus.tripIncoming,
      ),
    );
  }

  FutureOr<void> _onTripAccepted(
    HomeDriverTripAcceptedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(
      state.copyWith(
        activeTrip: state.incomingTrip,
        incomingTrip: null,
        status: HomeDriverStatus.tripActive,
      ),
    );
  }

  FutureOr<void> _onTripRejected(
    HomeDriverTripRejectedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(state.copyWith(incomingTrip: null, status: HomeDriverStatus.ready));
  }

  FutureOr<void> _onProfileLoaded(
    HomeDriverProfileLoadedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(state.copyWith(dataProfile: event.profile));
  }
}
