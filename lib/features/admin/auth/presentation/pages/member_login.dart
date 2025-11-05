import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/admin/auth/bloc/member_bloc.dart';
import 'package:auronix_app/features/admin/auth/presentation/widgets/member_login_form.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<FormState> _memberLoginFormKey = GlobalKey<FormState>();

class MemberLogin extends StatelessWidget {
  const MemberLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => sl<MemberBloc>()..add(MemberInitRememberEvent()),
      child: _MemberLoginInit(theme: theme),
    );
  }
}

class _MemberLoginInit extends StatelessWidget {
  const _MemberLoginInit({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => AppRouter.go(Routes.onBoarding),
                icon: Icon(Icons.arrow_back_ios_rounded, size: 24.r),
              ),
              const Spacer(),
              HorizontalLogo(),
            ],
          ),
          centerTitle: false,
        ),
        body: _MemberScreenController(theme: theme),
        bottomNavigationBar: SafeArea(
          child: BlocBuilder<MemberBloc, MemberState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_memberLoginFormKey.currentState!.validate()) {
                        context.read<MemberBloc>().add(
                          MemberLoginSubmittedEvent(
                            ciPassport: state.ciPassport,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MemberScreenController extends StatelessWidget {
  const _MemberScreenController({required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return _MemberScreenStructure(theme: theme);
  }
}

class _MemberScreenStructure extends StatelessWidget {
  const _MemberScreenStructure({required this.theme});

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
            BlocBuilder<MemberBloc, MemberState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.verticalSpace,
                    AutoSizeText(
                      'Bienvenido a Ando',
                      style: themeText.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    10.verticalSpace,
                    AutoSizeText(
                      'Debes iniciar sesión para continuar',
                      style: themeText.bodyMedium,
                    ),
                    40.verticalSpace,

                    Form(
                      key: _memberLoginFormKey,
                      child: Column(
                        children: [
                          MemberLoginForm(memberLoginForm: _memberLoginFormKey),
                          30.verticalSpace,
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
