import 'package:auronix_app/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientRegisterForm extends StatelessWidget {
  const ClientRegisterForm({super.key, required this.authRegisterFormKey});

  final GlobalKey<FormState> authRegisterFormKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            LoginFields(),
            10.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (authRegisterFormKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                      RegisterSubmitEvent(
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
                child: Text('Registrarse'),
              ),
            ),
          ],
        );
      },
    );
  }
}
