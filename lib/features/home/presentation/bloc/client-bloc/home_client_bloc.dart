import 'dart:async';
import 'package:auronix_app/app/core/services/location_service.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/trips/safety/domain/repositories/emergency_contact_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_client_event.dart';
part 'home_client_state.dart';

class HomeClientBloc extends Bloc<HomeClientEvent, HomeClientState> {
  final LocationService _locationService;
  final EmergencyContactRepository _emergencyContactRepository;

  HomeClientBloc({
    required LocationService locationService,
    required EmergencyContactRepository emergencyContactRepository,
  }) : _locationService = locationService,
       _emergencyContactRepository = emergencyContactRepository,
       super(const HomeClientState()) {
    on<HomeClientInitEvent>(_onInit);
    on<GetCurrentLocationEvent>(_onGetLocation);
    on<HomeClientProfileLoadedEvent>(_onProfileLoaded);
    on<HomeClientTripUpdatedEvent>(_onTripUpdated);
    on<HomeClientRequestTripEvent>(_onRequestTrip);
  }

  FutureOr<void> _onInit(
    HomeClientInitEvent event,
    Emitter<HomeClientState> emit,
  ) async {
    emit(state.copyWith(status: HomeClientStatus.loading));
    // Cargar perfil, viajes recientes, etc.
    emit(state.copyWith(status: HomeClientStatus.ready));
  }

  FutureOr<void> _onGetLocation(
    GetCurrentLocationEvent event,
    Emitter<HomeClientState> emit,
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

  FutureOr<void> _onProfileLoaded(
    HomeClientProfileLoadedEvent event,
    Emitter<HomeClientState> emit,
  ) {
    emit(state.copyWith(dataProfile: event.profile));
  }

  FutureOr<void> _onTripUpdated(
    HomeClientTripUpdatedEvent event,
    Emitter<HomeClientState> emit,
  ) {
    emit(state.copyWith(currentTrip: event.trip));
  }

  FutureOr<void> _onRequestTrip(
    HomeClientRequestTripEvent event,
    Emitter<HomeClientState> emit,
  ) async {
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

    emit(
      state.copyWith(
        emergencyContactRequired: false,
        tripRequestNonce: state.tripRequestNonce + 1,
      ),
    );
  }
}
