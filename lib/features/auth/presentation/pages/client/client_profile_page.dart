import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/auth/presentation/bloc/profile_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: const _ClientProfileView(),
    );
  }
}

class _ClientProfileView extends StatelessWidget {
  const _ClientProfileView();

  Future<void> _promptNewValue({
    required BuildContext context,
    required String title,
    required String hint,
    required ValueChanged<String> onSubmit,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) onSubmit(value);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final dialogCubit = context.read<DialogCubit>();
    final profileCubit = context.read<ProfileCubit>();

    final confirmed = await dialogCubit.showConfirm(
      title: '¿Eliminar tu cuenta?',
      message:
          'Esta acción es permanente. Perderás acceso a tu historial y '
          'datos asociados a esta cuenta.',
      okText: 'Eliminar cuenta',
      cancelText: 'Cancelar',
    );

    if (confirmed) {
      await profileCubit.deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        switch (state) {
          case ProfileActionSuccess(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case ProfileError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case ProfileAccountDeleted():
            context.read<SessionBloc>().add(const LoggoutUserEvent());
            AppRouter.goAndClear(Routes.auth);
          case ProfileInitial():
          case ProfileLoading():
        }
      },
      child: Scaffold(
        appBar: AppAppbar(
          hasBackButton: true,
          isCenter: true,
          content: AppText('Mi perfil', variant: AppTextVariant.titleMedium),
          goTo: () => AppRouter.pop(),
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, sessionState) {
            final email = sessionState is SessionAuthenticated
                ? sessionState.dataUser.email
                : '';
            final name = sessionState is SessionAuthenticated
                ? sessionState.dataUser.firstName
                : '';

            return BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final isLoading = state is ProfileLoading;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ListView(
                    children: [
                      20.verticalSpace,
                      if (name.isNotEmpty)
                        AppText(name, variant: AppTextVariant.titleMedium),
                      8.verticalSpace,
                      AppText(email, variant: AppTextVariant.bodyMedium),
                      32.verticalSpace,
                      AppButton(
                        label: 'Cambiar email',
                        variant: AppButtonVariant.outlined,
                        expand: true,
                        isDisabled: isLoading,
                        onPressed: () => _promptNewValue(
                          context: context,
                          title: 'Nuevo email',
                          hint: 'nuevo@correo.com',
                          onSubmit: (value) =>
                              context.read<ProfileCubit>().changeEmail(value),
                        ),
                      ),
                      16.verticalSpace,
                      AppButton(
                        label: 'Cambiar teléfono',
                        variant: AppButtonVariant.outlined,
                        expand: true,
                        isDisabled: isLoading,
                        onPressed: () => _promptNewValue(
                          context: context,
                          title: 'Nuevo número de celular',
                          hint: '09xxxxxxxx',
                          onSubmit: (value) =>
                              context.read<ProfileCubit>().changePhone(value),
                        ),
                      ),
                      32.verticalSpace,
                      AppButton(
                        label: 'Eliminar cuenta',
                        variant: AppButtonVariant.outlined,
                        expand: true,
                        isLoading: isLoading,
                        onPressed: () => _confirmDeleteAccount(context),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
