import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';

class AppLifeCycleCubit extends Cubit<AppLifecycleState>
    with WidgetsBindingObserver {
  AppLifeCycleCubit({this.resumeDebounce = const Duration(milliseconds: 200)})
    : super(
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      ) {
    //Se incializa el observador
    WidgetsBinding.instance.addObserver(this);
  }

  final Duration resumeDebounce;
  Timer? _resumeTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Opcional: suavizar "resumed" para evitar dobles disparos inmediatos
    if (state == AppLifecycleState.resumed && resumeDebounce > Duration.zero) {
      _resumeTimer?.cancel();
      _resumeTimer = Timer(
        resumeDebounce,
        () => emit(AppLifecycleState.resumed),
      );
      return;
    }

    emit(state);
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeTimer?.cancel();
    return super.close();
  }
}
