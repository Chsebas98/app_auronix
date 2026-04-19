import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/handlers/dialog_handler.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/l10n/gen/app_localizations.dart';
import 'package:auronix_app/shared/widgets/widgets.dart';
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
        BlocProvider.value(value: sl<GlobalCubit>()),
        BlocProvider.value(value: sl<AppLifeCycleCubit>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<SessionBloc>()),
        BlocProvider.value(value: sl<DialogCubit>()),
        BlocProvider.value(value: sl<PermissionCubit>()),
        BlocProvider.value(value: sl<BottomNavCubit>()),
      ],
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          ensureScreenSize: true,
          builder: (context, _) => Builder(
            builder: (context) {
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
                        // debugShowMaterialGrid: true,
                        debugShowCheckedModeBanner: false,
                        scaffoldMessengerKey: rootMessengerKey,
                        routerConfig: AppRouter.instance,
                        theme: AppTheme.light,
                        darkTheme: AppTheme.dark,
                        themeMode: themeMode,
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,
                        supportedLocales: AppLocalizations.supportedLocales,
                        builder: (context, child) {
                          return DialogHandler(
                            navigatorKey:
                                AppRouter.instance.routerDelegate.navigatorKey,
                            child: child ?? SizedBox.shrink(),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
