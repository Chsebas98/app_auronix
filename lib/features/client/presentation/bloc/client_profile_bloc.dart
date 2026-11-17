import 'dart:async';

import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/data/models/profile_update_request_model.dart';
import 'package:auronix_app/features/client/domain/usecases/get_client_profile_usecase.dart';
import 'package:auronix_app/features/client/domain/usecases/update_client_profile_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'client_profile_event.dart';
part 'client_profile_state.dart';

class ClientProfileBloc
    extends Bloc<ClientProfileEvent, ClientProfileState> {
  final GetClientProfileUseCase _getProfile;
  final UpdateClientProfileUseCase _updateProfile;

  ClientProfileBloc({
    required GetClientProfileUseCase getProfile,
    required UpdateClientProfileUseCase updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ClientProfileState()) {
    on<ClientProfileLoadEvent>(_onLoad);
    on<ClientProfileUpdateEvent>(_onUpdate);
  }

  FutureOr<void> _onLoad(
    ClientProfileLoadEvent event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(state.copyWith(status: ClientProfileStatus.loading));

    final result = await _getProfile(event.userId);

    result.fold(
      (failure) {
        debugPrint('[ProfileBloc] Load falló: ${failure.message}');
        emit(state.copyWith(
          status: ClientProfileStatus.error,
          errorMessage: failure.message,
        ));
      },
      (profile) => emit(state.copyWith(
        status: ClientProfileStatus.ready,
        profile: profile,
      )),
    );
  }

  FutureOr<void> _onUpdate(
    ClientProfileUpdateEvent event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(state.copyWith(status: ClientProfileStatus.saving));

    final result = await _updateProfile(
      userId: event.userId,
      data: ProfileUpdateRequestModel(
        firstName: event.firstName,
        secondName: event.secondName,
        lastName: event.lastName,
        secondLastName: event.secondLastName,
        phone: event.phone,
        photoUrl: event.photoUrl,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[ProfileBloc] Update falló: ${failure.message}');
        emit(state.copyWith(
          status: ClientProfileStatus.error,
          errorMessage: failure.message,
        ));
      },
      (updated) => emit(state.copyWith(
        status: ClientProfileStatus.saved,
        profile: updated,
      )),
    );
  }
}
