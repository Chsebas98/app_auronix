import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/domain/usecases/change_email_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/change_phone_usecase.dart';
import 'package:auronix_app/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

/// Acciones de cuenta desde Perfil/Configuración (docs/flow.md sección
/// 11.1): eliminar cuenta y cambio de email/teléfono. Separado de
/// [AuthUnifiedBloc] porque no forma parte del flujo de login/registro.
class ProfileCubit extends Cubit<ProfileState> {
  final DeleteAccountUsecase _deleteAccount;
  final ChangeEmailUsecase _changeEmail;
  final ChangePhoneUsecase _changePhone;

  ProfileCubit(AuthUnifiedRepository repository)
    : _deleteAccount = DeleteAccountUsecase(repository),
      _changeEmail = ChangeEmailUsecase(repository),
      _changePhone = ChangePhoneUsecase(repository),
      super(const ProfileInitial());

  Future<void> deleteAccount() async {
    emit(const ProfileLoading());
    final result = await _deleteAccount();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileAccountDeleted()),
    );
  }

  Future<void> changeEmail(String newEmail) async {
    emit(const ProfileLoading());
    final result = await _changeEmail(newEmail);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(
        const ProfileActionSuccess(
          'Solicitud enviada. Confirma el nuevo email para completar el cambio.',
        ),
      ),
    );
  }

  Future<void> changePhone(String newPhone) async {
    emit(const ProfileLoading());
    final result = await _changePhone(newPhone);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(
        const ProfileActionSuccess(
          'Solicitud enviada. Confirma el nuevo teléfono para completar el cambio.',
        ),
      ),
    );
  }
}
