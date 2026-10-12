import 'dart:async';

import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/domain/usecases/auth_complete_register_client_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/login_client_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/login_driver_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/register_driver_usecase.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

export 'auth_form_cubit.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

class AuthUnifiedBloc extends Bloc<AuthUnifiedEvent, AuthUnifiedState> {
  final LoginClientUseCase _loginClient;
  final LoginDriverUseCase _loginDriver;
  final GoogleLoginUseCase _googleLogin;
  final RegisterClientUseCase _registerClient;
  final RegisterDriverUseCase _registerDriver;
  final RefreshTokenUseCase _refreshToken;
  final LogoutUseCase _logout;
  final AuthCompleteRegisterClientUsecase _completeRegisterClient;
  final RxSharedPreferences _prefs;

  AuthUnifiedBloc({
    required AuthUnifiedRepository repository,
    required RxSharedPreferences prefs,
  }) : _loginClient = LoginClientUseCase(repository),
       _loginDriver = LoginDriverUseCase(repository),
       _googleLogin = GoogleLoginUseCase(repository),
       _registerClient = RegisterClientUseCase(repository),
       _registerDriver = RegisterDriverUseCase(repository),
       _refreshToken = RefreshTokenUseCase(repository),
       _logout = LogoutUseCase(repository),
       _completeRegisterClient = AuthCompleteRegisterClientUsecase(repository),
       _prefs = prefs,
       super(const AuthUnifiedIdle()) {
    on<AuthLoginClientEvent>(_onLoginClient);
    on<AuthLoginDriverEvent>(_onLoginDriver);
    on<AuthGoogleSignInEvent>(_onGoogleSignIn);
    on<AuthVerifyRegisterClientEvent>(_onVerifyRegisterClient);
    on<AuthRegisterClientEvent>(_onRegisterClient);
    on<AuthVerifyRegisterOtpEvent>(_onVerifyRegisterOtp);
    on<AuthResendRegisterOtpEvent>(_onResendRegisterOtp);
    on<AuthRegisterDriverEvent>(_onRegisterDriver);
    on<AuthRestoreClientSessionEvent>(_onRestoreClientSession);
    on<AuthRestoreDriverSessionEvent>(_onRestoreDriverSession);
    on<AuthCompleteRegisterClientEvent>(_onAuthCompleteRegisterClientEvent);
    on<AuthLogoutEvent>(_onLogout);
  }

  FutureOr<void> _onLoginClient(
    AuthLoginClientEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _loginClient(
      email: event.email,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Login cliente falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (creds) {
        debugPrint('[AuthBloc] Login cliente exitoso');
        emit(AuthUnifiedSuccess(credentials: creds));
      },
    );
  }

  FutureOr<void> _onLoginDriver(
    AuthLoginDriverEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _loginDriver(
      ciPassport: event.ciPassport,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Login conductor falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (creds) {
        debugPrint('[AuthBloc] Login conductor exitoso');
        emit(AuthUnifiedSuccess(credentials: creds));
      },
    );
  }

  FutureOr<void> _onGoogleSignIn(
    AuthGoogleSignInEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final googleResult = await _googleLogin.getGoogleCredentials();
    final googleFailure = googleResult.fold<Failure?>((f) => f, (_) => null);

    if (googleFailure != null) {
      emit(AuthUnifiedFailure(failure: googleFailure));
      return;
    }

    final googleCreds = googleResult.getOrElse(
      () => const AuthenticationCredentials.empty(),
    );

    if (googleCreds.tokenAccess.isEmpty) {
      emit(
        const AuthUnifiedFailure(
          failure: AuthFailure(
            message: 'No se pudieron obtener las credenciales de Google',
          ),
        ),
      );
      return;
    }

    final result = await _googleLogin.loginOrRegister(googleCreds);

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Google login falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (creds) {
        debugPrint('[AuthBloc] Google login exitoso');
        if (creds.photoUrl.isEmpty || creds.username.isEmpty) {
          _prefs.setBool(StaticVariables.needsProfileComplete, true);
        }
        emit(AuthUnifiedSuccess(credentials: creds));
      },
    );
  }

  FutureOr<void> _onRegisterClient(
    AuthRegisterClientEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final email = event.verifyRequest.email;
    final result = await _registerClient.sendOtp(email);

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Envío de OTP falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (_) {
        debugPrint('[AuthBloc] OTP enviado a $email');
        emit(AuthUnifiedOtpSent(email: email, sentAt: DateTime.now()));
      },
    );
  }

  FutureOr<void> _onVerifyRegisterOtp(
    AuthVerifyRegisterOtpEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _registerClient.verifyOtp(
      email: event.email,
      code: event.code,
    );

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Verificación de OTP falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (_) {
        debugPrint('[AuthBloc] OTP verificado para ${event.email}');
        emit(AuthUnifiedVerified(email: event.email));
      },
    );
  }

  FutureOr<void> _onResendRegisterOtp(
    AuthResendRegisterOtpEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _registerClient.sendOtp(event.email);

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Reenvío de OTP falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (_) {
        debugPrint('[AuthBloc] OTP reenviado a ${event.email}');
        emit(AuthUnifiedOtpSent(email: event.email, sentAt: DateTime.now()));
      },
    );
  }

  FutureOr<void> _onVerifyRegisterClient(
    AuthVerifyRegisterClientEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    // TODO: implementar verificación de email real cuando el evento incluya RegisterVerifyRequest completo
    throw UnimplementedError(
      '_onVerifyRegisterClient: requiere RegisterVerifyRequest con email+password+rol, '
      'pero AuthVerifyRegisterClientEvent solo provee email. Extender el evento o el repositorio.',
    );
  }

  FutureOr<void> _onRegisterDriver(
    AuthRegisterDriverEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _registerDriver(
      ciPassport: event.ciPassport,
      password: event.password,
      email: event.email,
      licenseNumber: event.licenseNumber,
      licenseType: event.licenseType,
      plateNumber: event.plateNumber,
      vehicleBrand: event.vehicleBrand,
      vehicleModel: event.vehicleModel,
      vehicleYear: event.vehicleYear,
      birthDate: event.birthDate,
      terminosVersion: StaticVariables.currentTerminosVersion,
      terminosAceptadosEn: DateTime.now(),
    );

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Registro conductor falló: ${failure.message}');
        emit(AuthUnifiedFailure(failure: failure));
      },
      (creds) {
        debugPrint('[AuthBloc] Registro conductor exitoso');
        emit(AuthUnifiedSuccess(credentials: creds));
      },
    );
  }

  FutureOr<void> _onRestoreClientSession(
    AuthRestoreClientSessionEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _refreshToken.forClient();

    result.fold((failure) => emit(AuthUnifiedFailure(failure: failure)), (
      creds,
    ) {
      if (creds == null) {
        emit(const AuthUnifiedIdle());
      } else {
        emit(AuthUnifiedSuccess(credentials: creds));
      }
    });
  }

  FutureOr<void> _onRestoreDriverSession(
    AuthRestoreDriverSessionEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _refreshToken.forDriver();

    result.fold((failure) => emit(AuthUnifiedFailure(failure: failure)), (
      creds,
    ) {
      if (creds == null) {
        emit(const AuthUnifiedIdle());
      } else {
        emit(AuthUnifiedSuccess(credentials: creds));
      }
    });
  }

  FutureOr<void> _onAuthCompleteRegisterClientEvent(
    AuthCompleteRegisterClientEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());

    final result = await _completeRegisterClient(
      name: event.name,
      email: event.email,
      gender: event.gender,
      phone: event.phone,
      password: event.password,
      birthDate: event.birthDate,
    );
    result.fold(
      (failure) {
        debugPrint(
          '[AuthBloc] Completar registro cliente falló: ${failure.message}',
        );
        emit(AuthUnifiedFailure(failure: failure));
      },
      (creds) {
        debugPrint('[AuthBloc] Completar registro cliente exitoso');
        emit(AuthUnifiedSuccess(credentials: creds));
      },
    );
  }

  FutureOr<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthUnifiedState> emit,
  ) async {
    emit(const AuthUnifiedLoading());
    await _logout();
    emit(const AuthUnifiedIdle());
  }
}
