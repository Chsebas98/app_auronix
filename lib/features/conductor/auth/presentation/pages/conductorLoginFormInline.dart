import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/features/conductor/auth/presentation/bloc/auth_conductor_bloc.dart';
import 'package:auronix_app/features/conductor/auth/presentation/widgets/conductor_fields.dart';
import 'package:auronix_app/features/conductor/routes/conductor_routes_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConductorLoginFormInline extends StatefulWidget {
  const ConductorLoginFormInline({super.key});

  @override
  State<ConductorLoginFormInline> createState() =>
      _ConductorLoginFormInlineState();
}

class _ConductorLoginFormInlineState extends State<ConductorLoginFormInline> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<AuthConductorBloc>()..add(ConductorInitRememberEvent()),
      child: BlocListener<AuthConductorBloc, AuthConductorState>(
        listener: (context, state) {
          if (state.loginForm is FormSubmitProgress) {
            context.read<DialogCubit>().showLoading();
          } else {
            context.read<DialogCubit>().hideTop();
          }

          if (state.loginForm is FormSubmitSuccesfull) {
            AppRouter.go(ConductorRoutesPath.home);
          }

          if (state.loginForm is FormSubmitFailed) {
            context
                .read<DialogCubit>()
                .showConfirm(
                  title: state.dialogRequest.title,
                  message: state.dialogRequest.description,
                )
                .whenComplete(
                  () => context.read<AuthConductorBloc>().add(
                    ConductorResetFormStateEvent(),
                  ),
                );
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const ConductorFields(),

              16.verticalSpace,

              BlocBuilder<AuthConductorBloc, AuthConductorState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Checkbox(
                        value: state.isRemember,
                        visualDensity: VisualDensity.compact,
                        onChanged: (_) => context.read<AuthConductorBloc>().add(
                          ConductorCheckedChangedEvent(),
                        ),
                      ),
                      6.horizontalSpace,
                      Text('Recuérdame', style: theme.textTheme.bodyMedium),
                      const Spacer(),
                    ],
                  );
                },
              ),

              24.verticalSpace,

              BlocBuilder<AuthConductorBloc, AuthConductorState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthConductorBloc>().add(
                            ConductorLoginSubmittedEvent(
                              ciPassport: state.ciPassport,
                              psw: state.password,
                            ),
                          );
                        }
                      },
                      child: Text('Iniciar sesión como conductor'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
