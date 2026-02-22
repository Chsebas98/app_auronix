import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'home_client_event.dart';
part 'home_client_state.dart';

class HomeClientBloc extends Bloc<HomeClientEvent, HomeClientState> {
  final HomeClientRepository _homeClientRepository;
  final RxSharedPreferences _prefs = sl<RxSharedPreferences>();
  HomeClientBloc(this._homeClientRepository) : super(HomeClientState()) {
    on<GetDataProfileEvent>(_onSetDataProfileEvent);
    on<CompleteProfileEvent>(_onCompleteProfileEvent);
    on<CheckCurrentTripEvent>(_onCheckCurrentTripEvent);
    on<CancelTripEvent>(_onCancelTripEvent);
    on<UpdateCurrentTripEvent>(_onUpdateCurrentTripEvent);
    on<ClearCurrentTripEvent>(_onClearCurrentTripEvent);
  }

  FutureOr<void> _onSetDataProfileEvent(
    GetDataProfileEvent event,
    Emitter<HomeClientState> emit,
  ) async {
    final res = await _homeClientRepository.fetchDataProfile();
    debugPrint('Data Profile fetched: $res');
    await _prefs.setString(StaticVariables.tokenKey, res.tokenAccess);
    final needComplete =
        await _prefs.getBool(StaticVariables.needsProfileComplete) ?? false;
    if (needComplete) {
      emit(state.copyWith(needCompleteProfile: true));
    }
    emit(state.copyWith(dataProfile: res));
    add(CheckCurrentTripEvent());
  }

  FutureOr<void> _onCompleteProfileEvent(
    CompleteProfileEvent event,
    Emitter<HomeClientState> emit,
  ) {
    emit(state.copyWith(needCompleteProfile: false));
    _prefs.setBool(StaticVariables.needsProfileComplete, false);
  }

  FutureOr<void> _onCheckCurrentTripEvent(
    CheckCurrentTripEvent event,
    Emitter<HomeClientState> emit,
  ) async {
    try {
      debugPrint('🚕 Verificando viaje actual...');

      // TODO: Cuando tengas backend, reemplazar esto:
      // final trip = await _homeClientRepository.getCurrentTrip();

      // 🔥 MOCK DATA para testing
      final mockTrip = _getMockTrip();

      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));

      if (mockTrip != null) {
        debugPrint('✅ Viaje actual encontrado: ${mockTrip.id}');
        debugPrint('   Estado: ${mockTrip.status}');
        debugPrint('   Conductor: ${mockTrip.driverName ?? "Sin asignar"}');
        emit(state.copyWith(currentTrip: mockTrip));
      } else {
        debugPrint('❌ No hay viaje activo');
        emit(state.copyWith(clearCurrentTrip: true));
      }
    } catch (e) {
      debugPrint('❌ Error al verificar viaje actual: $e');
      emit(state.copyWith(clearCurrentTrip: true));
    }
  }

  // 🔥 NUEVO - Cancelar viaje
  FutureOr<void> _onCancelTripEvent(
    CancelTripEvent event,
    Emitter<HomeClientState> emit,
  ) async {
    try {
      debugPrint('❌ Cancelando viaje: ${event.tripId}');

      // TODO: Cuando tengas backend:
      // await _homeClientRepository.cancelTrip(event.tripId);

      // Simular delay
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ Viaje cancelado');
      emit(state.copyWith(clearCurrentTrip: true));

      // TODO: Mostrar snackbar de confirmación
    } catch (e) {
      debugPrint('❌ Error al cancelar viaje: $e');
      // TODO: Mostrar error al usuario
    }
  }

  FutureOr<void> _onUpdateCurrentTripEvent(
    UpdateCurrentTripEvent event,
    Emitter<HomeClientState> emit,
  ) {
    debugPrint('🔄 Actualizando viaje: ${event.trip.id}');
    debugPrint('   Nuevo estado: ${event.trip.status}');
    emit(state.copyWith(currentTrip: event.trip));
  }

  FutureOr<void> _onClearCurrentTripEvent(
    ClearCurrentTripEvent event,
    Emitter<HomeClientState> emit,
  ) {
    debugPrint('🧹 Limpiando viaje actual');
    emit(state.copyWith(clearCurrentTrip: true));
  }

  TripModel? _getMockTrip() {
    // CAMBIA ESTO PARA PROBAR DIFERENTES ESTADOS:

    // Escenario 1: Buscando conductor
    // return TripModel(
    //   id: 'trip_123',
    //   status: TripStatus.searchingDriver,
    //   origin: '-0.180653,-78.467834',
    //   destination: '-0.210653,-78.497834',
    //   originAddress: 'Av. 10 de Agosto, Quito',
    //   destinationAddress: 'Centro Histórico, Quito',
    //   estimatedPrice: 5.50,
    //   createdAt: DateTime.now(),
    // );

    // Escenario 2: Conductor asignado (en camino)
    // return TripModel(
    //   id: 'trip_123',
    //   status: TripStatus.driverAssigned,
    //   origin: '-0.180653,-78.467834',
    //   destination: '-0.210653,-78.497834',
    //   originAddress: 'Av. 10 de Agosto, Quito',
    //   destinationAddress: 'Centro Histórico, Quito',
    //   estimatedPrice: 5.50,
    //   createdAt: DateTime.now(),
    //   driverId: 'driver_123',
    //   driverName: 'Carlos Pérez',
    //   driverPhotoUrl: null,
    //   driverPlate: 'ABC-1234',
    //   driverRating: 4.8,
    //   driverPhone: '+593999999999',
    //   estimatedArrivalMinutes: 5,
    // );

    // Escenario 3: En viaje
    return TripModel(
      id: 'trip_123',
      status: TripStatus.inProgress,
      origin: '-0.180653,-78.467834',
      destination: '-0.210653,-78.497834',
      originAddress: 'Av. 10 de Agosto, Quito',
      destinationAddress: 'Centro Histórico, Quito',
      estimatedPrice: 5.50,
      createdAt: DateTime.now(),
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      driverId: 'driver_123',
      driverName: 'Carlos Pérez',
      driverPhotoUrl: null,
      driverPlate: 'ABC-1234',
      driverRating: 4.8,
      driverPhone: '+593999999999',
      estimatedArrivalMinutes: 15,
    );

    // Escenario 4: Sin viaje activo
    // return null;
  }
}
