import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scaffold base de auth: appbar + body intercambiable + bottomNav condicional.
/// No contiene logica de negocio — solo estructura visual.
class AuthTemplate extends StatelessWidget {
  const AuthTemplate({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppAppbar(
          hasBackButton: true,
          goTo: () => AppRouter.go(Routes.onBoarding),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Spacer(), AppHorizontalLogo()],
          ),
        ),
        body: body,
        bottomNavigationBar: BlocBuilder<AuthFormCubit, AuthFormState>(
          builder: (context, state) {
            // El switcher login/register solo se muestra en flujo cliente
            if (state.showLoginConductorForm) return const SizedBox.shrink();
            return SafeArea(
              child: GestureDetector(
                onTap: () => context.read<AuthFormCubit>().toggleShowRegister(),
                child: _AuthTabSwitcher(showRegister: state.showRegisterForm),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthTabSwitcher extends StatelessWidget {
  const _AuthTabSwitcher({required this.showRegister});

  final bool showRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        text: showRegister
            ? '¿Ya tienes una cuenta? '
            : '¿No tienes una cuenta? ',
        style: baseStyle,
        children: [
          TextSpan(
            text: showRegister ? 'Inicia Sesión' : 'Regístrate',
            style: baseStyle.copyWith(color: AppColors.twelveth),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
