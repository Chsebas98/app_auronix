import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/router/router.dart';

import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/l10n/app_localizations.dart';
import 'package:auronix_app/l10n/gen/app_localizations.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: OnBoardingController(l10n: l10n),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: CustomFilledButton(
                  desc: 'Continuar',
                  action: () {
                    AppRouter.go(Routes.auth);
                  },
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Developed By: ',
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Image.asset(
                      'assets/images/png/auronixDark.png',

                      height: 50.h,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnBoardingController extends StatelessWidget {
  const OnBoardingController({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _OnBoardingStructure(l10n: l10n);
  }
}

class _OnBoardingStructure extends StatelessWidget {
  const _OnBoardingStructure({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/png/backgroundStart.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          40.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HorizontalLogo(),

              IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(
                  context.read<ThemeCubit>().state == ThemeMode.light
                      ? Icons.nightlight_rounded
                      : Icons.sunny,
                  color: context.read<ThemeCubit>().state == ThemeMode.light
                      ? AppColors.black
                      : AppColors.white,
                ),
              ),
            ],
          ),
          30.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AutoSizeText(
              'Le brindamos una experiencia profesional de reserva de taxis',
              maxLines: 2,
              style: theme.displaySmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
