import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/conductor/auth/presentation/bloc/auth_conductor_bloc.dart';
import 'package:auronix_app/features/conductor/auth/presentation/widgets/conductor_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginConductor extends StatelessWidget {
  const LoginConductor({super.key, required this.conductorLoginForm});
  final GlobalKey<FormState> conductorLoginForm;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: sl<AuthConductorBloc>(),
      child: Column(
        children: [
          ConductorFields(),
          BlocBuilder<AuthConductorBloc, AuthConductorState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Checkbox(
                    value: state.isRemember,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) => context.read<AuthConductorBloc>().add(
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
          10.verticalSpace,
        ],
      ),
    );
  }
}
