import 'dart:async';
import 'package:auronix_app/app/core/permission/domain/models/interfaces/app_permission_type.dart';
import 'package:auronix_app/core/utils/permission_spec.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState>
    with WidgetsBindingObserver {
  PermissionCubit() : super(const PermissionState()) {
    WidgetsBinding.instance.addObserver(this);
    checkAll();
  }

  bool _isAsking = false;
  int _seq = 0;

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAll();
    }
  }

  Future<void> checkAll() async {
    final types = AppPermissionType.values;

    final entries = <AppPermissionType, PermissionStatus>{};
    for (final t in types) {
      final spec = specOf(t);
      entries[t] = await spec.permission.status;
    }

    emit(state.copyWith(statuses: entries, checking: false));
  }

  /// PRO: desde cualquier parte llamas ensure(type).
  /// Si falta, dispara UI fullscreen via handler y retorna false (por ahora).
  Future<bool> ensure(AppPermissionType type) async {
    final current = await specOf(type).permission.status;
    _updateStatus(type, current);

    if (current == PermissionStatus.granted) return true;

    // Si ya está preguntando, no spamear
    if (_isAsking) return false;

    // Si está permanentDenied/restricted, igual mostramos el fullscreen para ir a Settings
    _seq++;
    emit(
      state.copyWith(
        uiRequest: PermissionUiRequest(type: type, seq: _seq),
      ),
    );
    return false;
  }

  /// Lo llama la UI del fullscreen cuando el usuario presiona "Permitir"
  Future<void> request(AppPermissionType type) async {
    if (_isAsking) return;
    _isAsking = true;

    try {
      switch (type) {
        case AppPermissionType.locationAlways:
          // ✅ PRO: iOS requiere WhenInUse antes de Always
          final when = await Permission.locationWhenInUse.request();
          _updateStatus(AppPermissionType.locationWhenInUse, when);

          if (when != PermissionStatus.granted) {
            // No puedp seguir a Always si no dieron WhenInUse
            // Mantén la UI abierta (o ciérrala si prefieres) -> yo la cierro solo si granted
            return;
          }

          final always = await Permission.locationAlways.request();
          _updateStatus(AppPermissionType.locationAlways, always);

          emit(state.copyWith(uiRequest: null));
          return;

        default:
          final spec = specOf(type);
          final result = await spec.permission.request();
          _updateStatus(type, result);

          emit(state.copyWith(uiRequest: null));
          return;
      }
    } finally {
      _isAsking = false;
    }
  }

  void openSettings() => openAppSettings();

  void clearRequest() => emit(state.copyWith(uiRequest: null));

  void _updateStatus(AppPermissionType type, PermissionStatus st) {
    final next = Map<AppPermissionType, PermissionStatus>.from(state.statuses);
    next[type] = st;
    emit(state.copyWith(statuses: next));
  }
}
