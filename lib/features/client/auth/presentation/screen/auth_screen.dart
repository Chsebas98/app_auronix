import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/conductor/auth/presentation/pages/conductorLoginFormInline.dart';
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
          hasBackButton: true,
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

  void _showToastValidation(BuildContext ctx) {
    return SnackUtil.showToastValidation(
      context: context,
      isDefaultSnackbar: TypeToast.actionToast,
      theme: widget.theme,
      title: '',
      description: 'askdjaskldjals djakls jaskl jdakls j',
      onVisible: () => _isSnackOpen = false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.completeRegisterForm is FormSubmitProgress ||
            state.loginForm is FormSubmitProgress) {
          rootMessengerKey.currentState?.hideCurrentSnackBar();
          context.read<DialogCubit>().showLoading();
        } else {
          context.read<DialogCubit>().hideTop();
        }

        final statusRegister = state.completeRegisterForm;

        if (statusRegister is FormSubmitFailed) {
          context
              .read<DialogCubit>()
              .showConfirm(
                title: state.dialogRequest.title,
                message: state.dialogRequest.description,
              )
              .whenComplete(
                () => context.read<AuthBloc>().add(ResetFormStateEvent()),
              );
        }

        if (statusRegister is FormSubmitSuccesfull && !_isSnackOpen) {
          _isSnackOpen = true;
          _showToastValidation(context);
          // debugPrint('Hio');
        }
        if (state.showRegisterCompleteForm) {
          _showRegisterCompleteForm(context);
        }

        final statusLogin = state.loginForm;
        if (statusLogin is FormSubmitFailed) {
          context
              .read<DialogCubit>()
              .showConfirm(
                title: state.dialogRequest.title,
                message: state.dialogRequest.description,
              )
              .whenComplete(
                () => context.read<AuthBloc>().add(ResetFormStateEvent()),
              );
        }

        if (statusLogin is FormSubmitSuccesfull) {
          context.read<SessionBloc>().add(
            LoginUserEvent(dataUser: state.credentialsLogin),
          );
        }

        if (state.completeRegisterForm is FormSubmitSuccesfull) {
          context.read<SessionBloc>().add(
            LoginUserEvent(dataUser: state.credentialsLogin),
          );
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
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: AutoSizeText(
                        _getTitle(state),
                        style: themeText.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    10.verticalSpace,
                    AutoSizeText(
                      _getSubtitle(state),
                      style: themeText.bodyMedium,
                    ),
                    40.verticalSpace,

                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildForm(context, state),
                    ),
                    if (!state.showLoginConductorForm) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Divider(
                              color: AppColors.eight,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AutoSizeText(
                            'O ingresa con',
                            style: themeText.bodyMedium,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Divider(indent: 0, endIndent: 0),
                          ),
                        ],
                      ),

                      30.verticalSpace,

                      // Google Sign In
                      SizedBox(
                        width: double.infinity,
                        child: CustomOutlinedButton(
                          hasIcon: true,
                          icon: SvgPicture.asset(
                            'assets/images/svg/iconGoogle.svg',
                            width: 32,
                            fit: BoxFit.fitWidth,
                          ),
                          desc: 'Iniciar sesión con Google',
                          action: () {
                            context.read<AuthBloc>().add(
                              GoogleSignInRequestedEvent(),
                            );
                          },
                        ),
                      ),

                      20.verticalSpace,

                      SizedBox(
                        width: double.infinity,
                        child: CustomOutlinedButton(
                          desc: 'Soy conductor',
                          action: () {
                            context.read<AuthBloc>().add(
                              ConductorSignInRequestedEvent(),
                            );
                          },
                        ),
                      ),
                    ],

                    if (state.showLoginConductorForm) ...[
                      20.verticalSpace,
                      TextButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            ConductorSignInRequestedEvent(),
                          );
                        },
                        icon: Icon(Icons.arrow_back, color: AppColors.twelveth),
                        label: Text(
                          'Volver a inicio de sesión cliente',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: AppColorsExtension.textColor(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(AuthState state) {
    if (state.showLoginConductorForm) {
      return 'Ingreso de Conductor';
    }
    return state.showRegisterForm
        ? 'Bienvenido a Ando'
        : 'Bienvenido de vuelta!';
  }

  String _getSubtitle(AuthState state) {
    if (state.showLoginConductorForm) {
      return 'Ingresa tus credenciales de conductor';
    }
    return state.showRegisterForm
        ? 'Debes iniciar sesión para continuar'
        : 'Ingresa a tu cuenta';
  }

  Widget _buildForm(BuildContext context, AuthState state) {
    // Conductor Login
    if (state.showLoginConductorForm) {
      return ConductorLoginFormInline(key: const ValueKey('conductor_form'));
    }

    // Cliente Register
    if (state.showRegisterForm) {
      return ClientRegisterForm(
        key: const ValueKey('register_form'),
        authRegisterFormKey: _authRegisterFormKey,
      );
    }

    // Cliente Login
    return ClientLoginForm(
      key: const ValueKey('login_form'),
      authLoginFormKey: _authLoginFormKey,
    );
  }
}
