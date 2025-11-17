import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

GlobalKey<FormState> _authLoginFormKey = GlobalKey<FormState>();
GlobalKey<FormState> _authRegisterFormKey = GlobalKey<FormState>();

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(InitRememberEvent()),
      child: _AuthScreenInit(theme: theme),
    );
  }
}

class _AuthScreenInit extends StatelessWidget {
  const _AuthScreenInit({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        appBar: AppbarDefault(
          goTo: () => AppRouter.go(Routes.onBoarding),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Spacer(), HorizontalLogo()],
          ),
        ),
        body: _AuthScreenController(theme: theme),
        bottomNavigationBar: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () => context.read<AuthBloc>().add(
                  ShowRegisterFormEvent(showRegister: !state.showRegisterForm),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: state.showRegisterForm
                        ? '¿Ya tienes una cuenta?'
                        : '¿No tienes una cuenta?',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: state.showRegisterForm
                            ? ' Inicia Sesión'
                            : ' Registrate',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: AppColors.twelveth,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthScreenController extends StatefulWidget {
  const _AuthScreenController({required this.theme});

  final ThemeData theme;

  @override
  State<_AuthScreenController> createState() => _AuthScreenControllerState();
}

class _AuthScreenControllerState extends State<_AuthScreenController> {
  bool _isSnackOpen = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    rootMessengerKey.currentState?.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _showRegisterCompleteForm(BuildContext ctx) {
    final bloc = ctx.read<AuthBloc>();
    return showGeneralDialog(
      context: ctx,
      barrierDismissible: false,
      fullscreenDialog: true,
      useRootNavigator: false,
      pageBuilder: (_, __, ___) =>
          BlocProvider.value(value: bloc, child: RegisterClientScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.registerForm is FormSubmitSuccesfull && !_isSnackOpen) {
          _isSnackOpen = true;
          SnackUtil.showToastValidation(
            context: context,
            isDefaultSnackbar: TypeToast.actionToast,
            theme: widget.theme,
            title: '',
            description: 'askdjaskldjals djakls jaskl jdakls j',
            onVisible: () => _isSnackOpen = false,
          );
          debugPrint('Hio');
        }
        if (state.showRegisterCompleteForm) {
          _showRegisterCompleteForm(context);
        }
      },
      child: _AuthScreenStructure(theme: widget.theme),
    );
  }
}

class _AuthScreenStructure extends StatelessWidget {
  const _AuthScreenStructure({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final themeText = theme.textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        child: ListView(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.verticalSpace,
                    AutoSizeText(
                      state.showRegisterForm
                          ? 'Bienvenido a Ando'
                          : 'Bienvenido de vuelta!',
                      style: themeText.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    10.verticalSpace,
                    AutoSizeText(
                      state.showRegisterForm
                          ? 'Debes iniciar sesión para continuar'
                          : 'Ingresa a tu cuenta',
                      style: themeText.bodyMedium,
                    ),
                    40.verticalSpace,

                    Form(
                      key: state.showRegisterForm
                          ? _authRegisterFormKey
                          : _authLoginFormKey,
                      child: Column(
                        children: [
                          state.showRegisterForm
                              ? ClientRegisterForm(
                                  authRegisterFormKey: _authRegisterFormKey,
                                )
                              : ClientLoginForm(
                                  authLoginFormKey: _authLoginFormKey,
                                ),
                          30.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.eight,
                                  thickness: 1.r,
                                ),
                              ),
                              10.horizontalSpace,
                              AutoSizeText(
                                'O ingresa con',
                                style: themeText.bodyMedium,
                              ),
                              10.horizontalSpace,
                              Expanded(child: Divider(indent: 0, endIndent: 0)),
                            ],
                          ),
                          30.verticalSpace,
                          SizedBox(
                            width: double.infinity,
                            child: CustomOutlinedButton(
                              hasIcon: true,
                              icon: SvgPicture.asset(
                                'assets/images/svg/iconGoogle.svg',
                                width: 24.r,
                                height: 24.r,
                              ),
                              desc: 'Iniciar sesión con Google',
                              action: () {},
                            ),
                          ),
                          20.verticalSpace,
                          SizedBox(
                            width: double.infinity,
                            child: CustomOutlinedButton(
                              desc: 'Soy conductor',
                              action: () => AppRouter.go(Routes.loginMember),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
