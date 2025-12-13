import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState>
    with WidgetsBindingObserver {
  PermissionCubit() : super(PermissionState()) {
    WidgetsBinding.instance.addObserver(this);
    checkPermissions();
  }

  bool _isAsking = false;

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Revisa permisos al volver de Settings
      checkPermissions();
    }
  }

  Future<void> checkPermissions() async {
    final statuses = await Future.wait<PermissionStatus>([
      Permission.location.status,
      Permission.locationAlways.status,
      Permission.locationWhenInUse.status,
    ]);

    emit(
      state.copyWith(
        ubicacion: statuses[0],
        ubicacionAlways: statuses[1],
        ubicacionWhenInUse: statuses[2],
        checking: false,
      ),
    );
  }

  Future<void> requestLocationWhenInUse({
    bool automaticOpenAppSettings = true,
  }) async {
    final status = await Permission.locationWhenInUse.request();
    // muchos OEMs mapean location y whenInUse igual en debug
    emit(state.copyWith(ubicacionWhenInUse: status, ubicacion: status));
    _handlePermanentlyDenied(
      status: status,
      automaticOpenAppSettings: automaticOpenAppSettings,
    );
  }

  Future<bool> ensureLocationWhenInUse({
    bool automaticOpenAppSettings = true,
  }) async {
    if (state.ubicacionWhenInUseGranted || state.ubicacionGranted) return true;
    if (_isAsking) return false;
    _isAsking = true;
    try {
      final st = await Permission.locationWhenInUse.request();
      emit(state.copyWith(ubicacionWhenInUse: st, ubicacion: st));
      _handlePermanentlyDenied(
        status: st,
        automaticOpenAppSettings: automaticOpenAppSettings,
      );
      return st == PermissionStatus.granted;
    } finally {
      _isAsking = false;
    }
  }

  Future<bool> ensureLocationAlways({
    bool automaticOpenAppSettings = true,
  }) async {
    // debugPrint("Entra");
    if (state.ubicacionAlwaysGranted) return true;
    final okInUse = await ensureLocationWhenInUse(
      automaticOpenAppSettings: automaticOpenAppSettings,
    );
    if (!okInUse) return false;
    if (_isAsking) return false;
    _isAsking = true;
    try {
      final st = await Permission.locationAlways.request();
      emit(state.copyWith(ubicacionAlways: st));
      _handlePermanentlyDenied(
        status: st,
        automaticOpenAppSettings: automaticOpenAppSettings,
      );
      return st == PermissionStatus.granted;
    } finally {
      _isAsking = false;
    }
  }

  void openSettings() {
    openAppSettings();
  }

  void _handlePermanentlyDenied({
    required PermissionStatus status,
    bool automaticOpenAppSettings = false,
  }) {
    if (status == PermissionStatus.permanentlyDenied) {
      if (automaticOpenAppSettings) {
        openAppSettings();
      } else {
        null;
      }
    }
  }
}
