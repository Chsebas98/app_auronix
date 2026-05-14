import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/molecules/client/client_login_form.dart';
import 'package:auronix_app/features/auth/presentation/molecules/client/client_register_form.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

final _loginFormKey = GlobalKey<FormState>();
final _registerFormKey = GlobalKey<FormState>();

class AuthClientBody extends StatelessWidget {
  const AuthClientBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthFormCubit, AuthFormState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              20.verticalSpace,

              // Titulo animado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: AppText(
                  _getTitle(state),
                  key: ValueKey(_getTitle(state)),
                  variant: AppTextVariant.headlineMedium,
                  fontWeight: FontWeight.w600,
                  align: TextAlign.center,
                ),
              ),

              10.verticalSpace,

              AppText(
                _getSubtitle(state),
                variant: AppTextVariant.bodyMedium,
                align: TextAlign.center,
              ),

              40.verticalSpace,

              // Formulario animado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: state.showRegisterForm
                    ? ClientRegisterForm(
                        key: const ValueKey('register'),
                        formKey: _registerFormKey,
                      )
                    : ClientLoginForm(
                        key: const ValueKey('login'),
                        formKey: _loginFormKey,
                      ),
              ),

              24.verticalSpace,

              // Divisor + botones sociales
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: AppColors.eight, thickness: 1),
                  ),
                  10.horizontalSpace,
                  AppText('O ingresa con', variant: AppTextVariant.bodyMedium),
                  10.horizontalSpace,
                  const Expanded(child: Divider()),
                ],
              ),

              30.verticalSpace,

              AppButton(
                label: 'Iniciar sesión con Google',
                variant: AppButtonVariant.outlined,
                expand: true,
                icon: SvgPicture.asset(
                  'assets/images/svg/iconGoogle.svg',
                  width: 24,
                ),
                onPressed: () => context.read<AuthUnifiedBloc>().add(
                  const AuthGoogleSignInEvent(),
                ),
              ),

              16.verticalSpace,

              AppButton(
                label: 'Soy conductor',
                variant: AppButtonVariant.outlined,
                expand: true,
                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                onPressed: () => context.read<AuthFormCubit>().emit(
                  context.read<AuthFormCubit>().state.copyWith(
                    showLoginConductorForm: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTitle(AuthFormState state) =>
      state.showRegisterForm ? 'Bienvenido a Ando' : 'Bienvenido de vuelta!';

  String _getSubtitle(AuthFormState state) => state.showRegisterForm
      ? 'Debes iniciar sesión para continuar'
      : 'Ingresa a tu cuenta';
}
