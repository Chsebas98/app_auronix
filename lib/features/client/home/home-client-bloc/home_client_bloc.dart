import 'dart:async';

import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:auronix_app/features/client/home/domain/repository/home_client_repository.dart';
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
  }

  FutureOr<void> _onSetDataProfileEvent(
    GetDataProfileEvent event,
    Emitter<HomeClientState> emit,
  ) async {
    final res = await _homeClientRepository.fetchDataProfile();
    debugPrint('Data Profile fetched: $res');
    await _prefs.setString(StaticVariables.tokenKey, res.token);
    final needComplete =
        await _prefs.getBool(StaticVariables.needsProfileComplete) ?? false;
    if (needComplete) {
      emit(state.copyWith(needCompleteProfile: true));
    }
    emit(state.copyWith(dataProfile: res));
  }
}
