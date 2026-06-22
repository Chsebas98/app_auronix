import 'dart:async';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/features/home/domain/usecases/get_driver_home_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_driver_event.dart';
part 'home_driver_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  final GetDriverHomeUseCase _getDriverHome;

  HomeDriverBloc({required GetDriverHomeUseCase getDriverHome})
      : _getDriverHome = getDriverHome,
        super(const HomeDriverState()) {
    on<HomeDriverInitEvent>(_onInit);
    on<GetCurrentLocationEvent>(_onGetCurrentLocationEvent);
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

    final result = await _getDriverHome(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: HomeDriverStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: HomeDriverStatus.ready,
        dataProfile: state.dataProfile.copyWith(
          firstName: data.firstName,
          lastName: data.lastName,
          username: data.username,
          photoUrl: data.photoUrl,
        ),
        isAvailable: data.isAvailable,
        currentAddress: data.currentAddress ?? '',
        dailyEarnings: data.dailyEarnings,
        completedTrips: data.completedTrips,
        earningsHistory: data.earningsHistory,
      )),
    );
  }

  FutureOr<void> _onGetCurrentLocationEvent(
    GetCurrentLocationEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    emit(state.copyWith(isLoadingAddress: true));
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        currentAddress: 'Dirección obtenida',
        isLoadingAddress: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingAddress: false));
    }
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
    emit(state.copyWith(
        currentAddress: event.address, isLoadingAddress: false));
  }

  FutureOr<void> _onTripRequested(
    HomeDriverTripRequestedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(state.copyWith(
      incomingTrip: event.trip,
      status: HomeDriverStatus.tripIncoming,
    ));
  }

  FutureOr<void> _onTripAccepted(
    HomeDriverTripAcceptedEvent event,
    Emitter<HomeDriverState> emit,
  ) {
    emit(state.copyWith(
      activeTrip: state.incomingTrip,
      incomingTrip: null,
      status: HomeDriverStatus.tripActive,
    ));
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
