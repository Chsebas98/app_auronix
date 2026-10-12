import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/verification/domain/models/driver_verification_status.dart';
import 'package:auronix_app/features/verification/presentation/bloc/verification_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerificationCubit>()..loadStatus(),
      child: const _VerificationPendingView(),
    );
  }
}

void _logout(BuildContext context) {
  context.read<SessionBloc>().add(const LoggoutUserEvent());
  AppRouter.go(Routes.auth);
}

class _VerificationPendingView extends StatelessWidget {
  const _VerificationPendingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: BlocConsumer<VerificationCubit, VerificationState>(
            listener: (context, state) {
              if (state is VerificationLoaded && state.resendMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.resendMessage!)),
                );
              }
            },
            builder: (context, state) {
              return switch (state) {
                VerificationInitial() ||
                VerificationLoading() => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                VerificationError(:final message) => _ErrorContent(
                  message: message,
                ),
                VerificationLoaded() => _StatusContent(state: state),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, size: 96.r, color: AppColors.third),
        32.verticalSpace,
        AppText(
          message,
          variant: AppTextVariant.bodyMedium,
          align: TextAlign.center,
        ),
        24.verticalSpace,
        AppButton(
          label: 'Reintentar',
          expand: true,
          onPressed: () => context.read<VerificationCubit>().loadStatus(),
        ),
        16.verticalSpace,
        AppButton(
          label: 'Cerrar sesión',
          variant: AppButtonVariant.outlined,
          expand: true,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.state});

  final VerificationLoaded state;

  @override
  Widget build(BuildContext context) {
    final status = state.status;

    // Estado transitorio: el guard del router (app_router.dart) redirige a
    // Home apenas SessionBloc confirme APROBADO — evita mostrar el texto de
    // "en proceso" mientras ese redirect todavía no se dispara.
    if (status.estado == EstadoVerificacion.aprobado) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final isRechazado = status.estado == EstadoVerificacion.rechazado;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRechazado ? Icons.cancel_outlined : Icons.access_time_rounded,
          size: 96.r,
          color: AppColors.third,
        ),
        32.verticalSpace,
        AppText(
          isRechazado ? 'Verificación rechazada' : 'Verificación en proceso',
          variant: AppTextVariant.headlineMedium,
          fontWeight: FontWeight.w700,
          align: TextAlign.center,
        ),
        16.verticalSpace,
        AppText(
          isRechazado
              ? 'Tu solicitud de verificación fue rechazada. Revisa el correo enviado por la cooperativa para más detalles.'
              : 'Estamos revisando tus documentos. Este proceso puede tomar hasta 24 horas.',
          variant: AppTextVariant.bodyMedium,
          align: TextAlign.center,
        ),
        if (!isRechazado && status.cooperativaNombre != null) ...[
          12.verticalSpace,
          AppText(
            'Cooperativa asignada: ${status.cooperativaNombre}',
            variant: AppTextVariant.bodySmall,
            align: TextAlign.center,
          ),
        ],
        if (!isRechazado) ...[
          12.verticalSpace,
          const AppText(
            'Recibirás un correo cuando tu cuenta sea aprobada.',
            variant: AppTextVariant.bodySmall,
            align: TextAlign.center,
          ),
        ],
        40.verticalSpace,
        if (!isRechazado)
          AppButton(
            label: 'Reenviar correo de verificación',
            variant: AppButtonVariant.outlined,
            expand: true,
            isLoading: state.isResending,
            onPressed: () => context.read<VerificationCubit>().resendEmail(),
          ),
        16.verticalSpace,
        AppButton(
          label: 'Actualizar estado',
          expand: true,
          onPressed: () {
            context.read<VerificationCubit>().loadStatus();
            // Refresca también SessionBloc: si ya está APROBADO, el guard
            // del router (app_router.dart) saca de esta pantalla solo.
            context.read<SessionBloc>().add(const CheckLoggedUserEvent());
          },
        ),
        16.verticalSpace,
        AppButton(
          label: 'Cerrar sesión',
          variant: AppButtonVariant.outlined,
          expand: true,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}
