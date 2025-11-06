import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppAuronixMain extends StatelessWidget {
  const AppAuronixMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GlobalCubit()),
        BlocProvider(create: (context) => AppLifeCycleCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => SessionBloc()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        ensureScreenSize: true,
        builder: (context, child) => Builder(
          builder: (context) {
            final sessionCubit = context.read<SessionBloc>();
            AppRouter.initialize(sessionCubit);
            return BlocListener<AppLifeCycleCubit, AppLifecycleState>(
              listener: (context, state) async {
                switch (state) {
                  case AppLifecycleState.resumed:
                    // Reanudar: refrescar sesión, validar token, etc.
                    // await sessionCubit.onAppResumed();
                    break;

                  case AppLifecycleState.paused:
                    // Pausa: marcar timestamp, pausar streams, etc.
                    // sessionCubit.onAppPaused();
                    break;
                  case AppLifecycleState.inactive:
                    break;
                  default:
                }
              },
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.noScaling),
                    child: MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      // debugShowMaterialGrid: true,
                      scaffoldMessengerKey: rootMessengerKey,
                      routerConfig: AppRouter.instance,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeMode,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
