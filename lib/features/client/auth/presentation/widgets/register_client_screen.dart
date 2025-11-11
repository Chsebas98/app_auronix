import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<FormState> _registerClientFormKey = GlobalKey<FormState>();

class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RegisterClientScreenStructure();
  }
}

class _RegisterClientScreenStructure extends StatelessWidget {
  const _RegisterClientScreenStructure();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppbarDefault(goTo: () => Navigator.pop(context)),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Form(
              key: _registerClientFormKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  20.verticalSpace,
                  CustomTextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: false,
                    hasShowHidePassword: false,
                    hasValidationRules: false,
                    hasStrengthIndicator: false,
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu nombre',
                      labelText: 'Nombre',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,

                    validator: (value) {
                      return 'Hola';
                    },
                    onChanged: (value) {},
                    onSaved: (newValue) {},
                  ),
                  20.verticalSpace,
                  CustomTextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: false,
                    hasShowHidePassword: false,
                    hasValidationRules: false,
                    hasStrengthIndicator: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                    initialValue: state.email,
                  ),
                  Text('RegisterClientScreen'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
