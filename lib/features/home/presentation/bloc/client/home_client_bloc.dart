import 'dart:async';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_client_event.dart';
part 'home_client_state.dart';

class HomeClientBloc extends Bloc<HomeClientEvent, HomeClientState> {
  HomeClientBloc() : super(const HomeClientState()) {
    on<HomeClientInitEvent>(_onInit);
    on<GetCurrentLocationEvent>(_onGetLocation);
    on<HomeClientProfileLoadedEvent>(_onProfileLoaded);
    on<HomeClientTripUpdatedEvent>(_onTripUpdated);
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
    try {
      // Logica de geolocalizacion
      emit(
        state.copyWith(
          currentAddress: 'Direccion obtenida',
          isLoadingAddress: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingAddress: false));
    }
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
}
