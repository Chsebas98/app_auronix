import 'dart:async';

import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Paso de verificación por OTP del registro de pasajero (docs/flow.md
/// sección 11.1): código de 6 dígitos enviado por email, expira en 10 min,
/// reenviable con cooldown de 60s.
class RegisterOtpPage extends StatefulWidget {
  const RegisterOtpPage({required this.email, super.key});

  final String email;

  @override
  State<RegisterOtpPage> createState() => _RegisterOtpPageState();
}

class _RegisterOtpPageState extends State<RegisterOtpPage> {
  static const _cooldownSeconds = 60;

  String _code = '';
  int _secondsLeft = _cooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppbar(
          hasBackButton: true,
          isCenter: true,
          content: AppText('Verificar correo', variant: AppTextVariant.titleMedium),
          goTo: () => Navigator.pop(context),
        ),
        body: BlocListener<AuthUnifiedBloc, AuthUnifiedState>(
          listenWhen: (prev, curr) =>
              curr is AuthUnifiedOtpSent && curr.email == widget.email,
          listener: (context, state) {
            _startCooldown();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Código reenviado')),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ListView(
              children: [
                20.verticalSpace,
                AppText(
                  'Ingresa el código de 6 dígitos que enviamos a',
                  variant: AppTextVariant.bodyMedium,
                ),
                4.verticalSpace,
                AppText(
                  widget.email,
                  variant: AppTextVariant.bodyMedium,
                  fontWeight: FontWeight.w700,
                ),
                24.verticalSpace,
                AppOtpInput(onChanged: (code) => setState(() => _code = code)),
                24.verticalSpace,
                AppButton(
                  label: 'Verificar',
                  expand: true,
                  isDisabled: _code.length != 6,
                  onPressed: () {
                    context.read<AuthUnifiedBloc>().add(
                      AuthVerifyRegisterOtpEvent(
                        email: widget.email,
                        code: _code,
                      ),
                    );
                  },
                ),
                16.verticalSpace,
                Center(
                  child: _secondsLeft > 0
                      ? AppText(
                          'Reenviar código en ${_secondsLeft}s',
                          variant: AppTextVariant.bodySmall,
                        )
                      : TextButton(
                          onPressed: () {
                            context.read<AuthUnifiedBloc>().add(
                              AuthResendRegisterOtpEvent(email: widget.email),
                            );
                          },
                          child: const Text('Reenviar código'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
