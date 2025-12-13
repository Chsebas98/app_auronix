import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/features.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _publicRoutes = <String>{
  Routes.onBoarding,
  Routes.about,
  Routes.auth,
  Routes.register,
  Routes.login,
  Routes.newVersion,
  Routes.root,
  Routes.sessionExpired,
};

final _publicPrefixes = <String>{'/recuperar-password'};

class AppRouter {
  static late GoRouter _router;
  static GoRouter get instance => _router;

  static void initialize(SessionBloc sessionBloc) {
    _router = GoRouter(
      initialLocation: Routes.onBoarding,
      refreshListenable: AuthChangeNotifier(sessionBloc),
      // errorBuilder: (context, state) => const NotFoundScreen(),
      redirect: (context, state) {
        // final currentLocation = state.uri.toString();
        // final isLoginPage = currentLocation == '/login';
        final sessionState = sessionBloc.state;
        final currentLocation = state.uri.path;
        final isPublic =
            _publicRoutes.contains(currentLocation) ||
            _publicPrefixes.any((p) {
              debugPrint("QUE ES P: $p");
              return currentLocation.contains(p);
            });

        debugPrint(
          'Router redirect - Ruta actual: $currentLocation, Session state: ${sessionState.runtimeType}',
        );

        if (sessionState is SessionUnauthenticated ||
            sessionState is SessionTokenExpired) {
          if (sessionState is SessionTokenExpired) {
            debugPrint(
              'Router detecto State AuthTokenExpired, message: ${sessionState.message}',
            );
            return Routes.sessionExpired;
          }
          if (!isPublic) {
            debugPrint('Redirect a /session_expired from $currentLocation');
            return Routes.auth;
          }
          debugPrint('Already on public route');
          return null;
        }

        if (sessionState is SessionAuthenticated && isPublic) {
          debugPrint(
            'User Autenticado, redirect to /summary from $currentLocation',
          );
          return Routes.home;
        }

        debugPrint('No redirect needed');
        return null;
      },
      routes: [
        //Generales
        GoRoute(
          name: 'allowLocation',
          path: Routes.allowLocation,
          builder: (context, state) {
            return AllowPermitsScreen();
          },
        ),
        //Protegidas - Cliente
        GoRoute(
          name: 'onBoarding',
          path: Routes.onBoarding,
          builder: (context, state) {
            return OnBoardingScreen();
          },
        ),
        GoRoute(
          name: 'about',
          path: Routes.about,
          builder: (context, state) {
            return AboutScreen();
          },
        ),
        GoRoute(
          name: 'authClient',
          path: Routes.auth,
          builder: (context, state) {
            return AuthScreen();
          },
        ),

        GoRoute(
          name: 'root',
          path: Routes.root,
          builder: (context, state) {
            return RootScreen();
          },
        ),
        // GoRoute(
        //   name: 'sesionExpired',
        //   path: Routes.sessionExpired,
        //   builder: (context, state) {
        //     return SessionScreen();
        //   },
        // ),
        GoRoute(
          name: 'homeClient',
          path: Routes.home,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
        //Protegidas - Conductor
        GoRoute(
          name: 'loginMember',
          path: Routes.loginMember,
          builder: (context, state) {
            return MemberLogin();
          },
        ),
        GoRoute(
          name: 'registerMember',
          path: Routes.registerMember,
          builder: (context, state) {
            return MemberLogin();
          },
        ),
        //Protegidas - Socio
        GoRoute(
          name: 'loginConductor',
          path: Routes.loginConductor,
          builder: (context, state) {
            return Container();
          },
        ),
        GoRoute(
          name: 'registerConductor',
          path: Routes.register,
          builder: (context, state) {
            return Container();
          },
        ),
        GoRoute(
          name: 'homeConductor',
          path: Routes.homeConductor,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
        //Protegidas - Gerente
        //Protegidas - SuperAdming
      ],
    );
  }

  static void go(String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }
}

class AuthChangeNotifier extends ChangeNotifier {
  final SessionBloc _sessionCubit;

  AuthChangeNotifier(this._sessionCubit) {
    _sessionCubit.stream.listen((_) {
      notifyListeners();
    });
  }
}
