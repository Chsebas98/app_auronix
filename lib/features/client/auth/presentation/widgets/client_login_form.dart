import 'package:auronix_app/features/client/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/client/auth/presentation/widgets/login_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientLoginForm extends StatelessWidget {
  const ClientLoginForm({super.key, required this.authLoginFormKey});

  final GlobalKey<FormState> authLoginFormKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('AuthState.password ClientLogin = "${state.password}"');
        return Column(
          children: [
            LoginFields(isRegister: false),
            5.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Checkbox(
                  value: state.isRemember,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) =>
                      context.read<AuthBloc>().add(CheckedChangedEvent()),
                ),
                const SizedBox(width: 6),
                Text('Recuérdame', style: theme.textTheme.bodyMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            10.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (authLoginFormKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                      LoginSubmittedEvent(
                        email: state.email,
                        psw: state.password,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Iniciar sesión'),
              ),
            ),
          ],
        );
      },
    );
  }
}
