import 'dart:async';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/home/data/datasources/remote/home_driver_remote_datasource.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';
import 'package:auronix_app/features/home/domain/usecases/get_driver_home_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

part 'home_driver_event.dart';
part 'home_driver_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  final GetDriverHomeUseCase _getDriverHome;
  final HomeDriverRemoteDatasource _remote;

  HomeDriverBloc({
    required GetDriverHomeUseCase getDriverHome,
    required HomeDriverRemoteDatasource remote,
  })  : _getDriverHome = getDriverHome,
        _remote = remote,
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
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(
          currentAddress: 'Activa el GPS para ver tu ubicación',
          isLoadingAddress: false,
        ));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          currentAddress: 'Permiso de ubicación no otorgado',
          isLoadingAddress: false,
        ));
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        emit(state.copyWith(
          currentAddress: 'No se pudo obtener la ubicación',
          isLoadingAddress: false,
        ));
        return;
      }

      String address = '${position.latitude.toStringAsFixed(4)}, '
          '${position.longitude.toStringAsFixed(4)}';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if (p.street?.isNotEmpty == true) p.street,
            if (p.locality?.isNotEmpty == true) p.locality,
          ];
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {
        // Si geocoding falla, mostramos coordenadas
      }

      emit(state.copyWith(
        currentAddress: address,
        currentLat: position.latitude,
        currentLng: position.longitude,
        isLoadingAddress: false,
      ));
    } catch (e) {
      debugPrint('[HomeDriverBloc] Error obteniendo ubicación: $e');
      emit(state.copyWith(
        currentAddress: 'Ubicación no disponible',
        isLoadingAddress: false,
      ));
    }
  }

  FutureOr<void> _onToggleAvailability(
    HomeDriverToggleAvailabilityEvent event,
    Emitter<HomeDriverState> emit,
  ) async {
    final newValue = !state.isAvailable;
    try {
      final success = await _remote.setAvailability(newValue);
      if (success) {
        emit(state.copyWith(isAvailable: newValue));
        debugPrint('[DriverHome] disponibilidad: $newValue');
      } else {
        emit(state.copyWith(
          errorMessage: 'No se pudo cambiar la disponibilidad',
        ));
      }
    } catch (e) {
      debugPrint('[DriverHome] setAvailability error: $e');
      emit(state.copyWith(
        errorMessage: 'Error al cambiar disponibilidad',
      ));
    }
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
