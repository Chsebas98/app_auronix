import 'dart:async';

import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

    final userId = JwtHelpers.getUserId(event.credentials.tokenAccess) ?? 0;

    emit(state.copyWith(
      status: HomeClientStatus.ready,
      dataProfile: event.credentials,
      userId: userId,
    ));

    add(const GetCurrentLocationEvent());
  }

  FutureOr<void> _onGetLocation(
    GetCurrentLocationEvent event,
    Emitter<HomeClientState> emit,
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

      final permission = await Geolocator.checkPermission();
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
      debugPrint('[HomeClientBloc] Error obteniendo ubicación: $e');
      emit(state.copyWith(
        currentAddress: 'Ubicación no disponible',
        isLoadingAddress: false,
      ));
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
