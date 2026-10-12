import 'dart:async';
import 'package:auronix_app/app/core/services/location_service.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/features/trips/safety/domain/repositories/emergency_contact_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

part 'home_driver_event.dart';
part 'home_driver_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  final LocationService _locationService;
  final EmergencyContactRepository _emergencyContactRepository;

  /// Tracking de baja frecuencia mientras el conductor está DISPONIBLE sin
  /// viaje activo (RNF3, ver docs/functionality.md) — se detiene apenas dejar
  /// de estar disponible; el tracking de alta frecuencia durante un viaje
  /// activo depende de RealtimeClient (T5.2, todavía bloqueado).
  StreamSubscription<Position>? _idlePositionSubscription;

  HomeDriverBloc({
    required LocationService locationService,
    required EmergencyContactRepository emergencyContactRepository,
  }) : _locationService = locationService,
       _emergencyContactRepository = emergencyContactRepository,
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

  @override
  Future<void> close() {
    _idlePositionSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onInit(
    HomeDriverInitEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    emit(state.copyWith(status: HomeDriverStatus.loading));

    // TODO: reemplazar con usecase real
    await Future.delayed(const Duration(seconds: 1));

    emit(
      state.copyWith(
        status: HomeDriverStatus.ready,
        dailyEarnings: 245.80,
        completedTrips: 14,
        earningsHistory: [
          const EarningsPoint(label: '8am', amount: 0, index: 0),
          const EarningsPoint(label: '10am', amount: 45, index: 1),
          const EarningsPoint(label: '11am', amount: 80, index: 2),
          const EarningsPoint(label: '12pm', amount: 95, index: 3),
          const EarningsPoint(label: '1pm', amount: 180, index: 4),
        ],
      ),
    );
  }

  FutureOr<void> _onGetCurrentLocationEvent(
    GetCurrentLocationEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    emit(state.copyWith(isLoadingAddress: true));
    final result = await _locationService.getCurrentPosition();
    result.fold(
      (_) => emit(state.copyWith(isLoadingAddress: false)),
      (position) => emit(
        state.copyWith(
          currentAddress:
              '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
          isLoadingAddress: false,
        ),
      ),
    );
  }

  FutureOr<void> _onToggleAvailability(
    HomeDriverToggleAvailabilityEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    final willBeAvailable = !state.isAvailable;

    // Los gates (GPS, contacto de emergencia) solo aplican al ACTIVAR
    // disponibilidad — desactivarla nunca debe bloquearse.
    if (willBeAvailable) {
      final gpsEnabled = await _locationService.isLocationEnabled();
      if (!gpsEnabled) {
        emit(state.copyWith(gpsRequired: true));
        return;
      }

      // Contacto de emergencia obligatorio (docs/flow.md sección 11.1) — si
      // la consulta falla, no se asume que ya tiene uno (fail-closed).
      final contactsResult = await _emergencyContactRepository.getContacts();
      final hasEmergencyContact = contactsResult.fold(
        (_) => false,
        (contacts) => contacts.isNotEmpty,
      );
      if (!hasEmergencyContact) {
        emit(state.copyWith(emergencyContactRequired: true));
        return;
      }
    }

    emit(
      state.copyWith(
        isAvailable: willBeAvailable,
        gpsRequired: false,
        emergencyContactRequired: false,
      ),
    );

    if (willBeAvailable) {
      _startIdleTracking();
    } else {
      _idlePositionSubscription?.cancel();
      _idlePositionSubscription = null;
    }
  }

  void _startIdleTracking() {
    _idlePositionSubscription?.cancel();
    _idlePositionSubscription = _locationService.getIdleDriverStream().listen(
      (position) {
        if (isClosed) return;
        add(
          HomeDriverLocationUpdatedEvent(
            address:
                '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
          ),
        );
      },
      onError: (_) {},
    );
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
