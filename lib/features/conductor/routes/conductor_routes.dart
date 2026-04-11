// Conductor_routes.dart

import 'package:auronix_app/core/models/interfaces/core_enums.dart';
import 'package:auronix_app/features/conductor/auth/presentation/login_conductor.dart';
import 'package:auronix_app/features/conductor/home/presentation/bloc/home_conductor_bloc.dart';
import 'package:auronix_app/features/conductor/routes/conductor_routes_path.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/features/messages/presentation/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auronix_app/shared/appbar/bottom_navigation_home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class ConductorRoutes {
  static List<RouteBase> routes({
    required GlobalKey<NavigatorState> rootNavKey,
  }) {
    return [
      GoRoute(
        name: 'loginConductor',
        path: ConductorRoutesPath.login,
        builder: (context, state) {
          final params = state.extra as GlobalKey<FormState>?;
          return LoginConductor(
            conductorLoginForm: params ?? GlobalKey<FormState>(),
          );
        },
      ),
      GoRoute(
        name: 'registerConductor',
        path: ConductorRoutesPath.register,
        builder: (context, state) {
          return Container();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ConductorShell(child: child);
        },
        routes: [
          GoRoute(
            name: 'homeConductor',
            path: ConductorRoutesPath.home,
            builder: (context, state) {
              return HomeScreen();
            },
          ),
          GoRoute(
            name: 'profileConductor',
            path: ConductorRoutesPath.profile,
            builder: (context, state) {
              return ProfileScreen();
            },
          ),
          GoRoute(
            name: 'saveTripsConductor',
            path: ConductorRoutesPath.saveTrips,
            builder: (context, state) {
              return SaveTripScreen();
            },
          ),
          GoRoute(
            name: 'messagesConductor',
            path: ConductorRoutesPath.messages,
            builder: (context, state) {
              final rolMessage = state.extra as Roles?;
              return MessageScreen(role: rolMessage ?? Roles.rolUser);
            },
          ),
          // Flujo de solicitar taxi
          GoRoute(
            name: 'selectDestinationConductor',
            path: ConductorRoutesPath.selectDestination,
            builder: (context, state) {
              return RequestTripScreen();
            },
          ),
          GoRoute(
            name: 'confirmTripConductor',
            path: ConductorRoutesPath.confirmTrip,
            builder: (context, state) {
              return ConfirmTripPage();
            },
          ),
          GoRoute(
            name: 'searchingDriverConductor',
            path: ConductorRoutesPath.searchingDriver,
            builder: (context, state) {
              return SearchingDriverPage();
            },
          ),
          GoRoute(
            name: 'tripInProgressConductor',
            path: ConductorRoutesPath.tripInProgress,
            builder: (context, state) {
              return TripInPorgressPage();
            },
          ),
          GoRoute(
            name: 'rateTripConductor',
            path: ConductorRoutesPath.rateTrip,
            builder: (context, state) {
              return RateTripPage();
            },
          ),
          GoRoute(
            name: 'tripCompletedConductor',
            path: ConductorRoutesPath.tripCompleted,
            builder: (context, state) {
              return TripCompletedPage();
            },
          ),
        ],
      ),
    ];
  }
}

class ConductorShell extends StatefulWidget {
  final Widget child;

  const ConductorShell({required this.child, Key? key}) : super(key: key);

  @override
  State<ConductorShell> createState() => _ConductorShellState();
}

class _ConductorShellState extends State<ConductorShell>
    with WidgetsBindingObserver {
  bool _isCheckingPermission = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Verificar permisos cada vez que la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  /// Verifica el permiso de ubicación y redirige si es necesario
  Future<void> _checkLocationPermission() async {
    // Evitar verificaciones simultáneas
    if (_isCheckingPermission) return;
    _isCheckingPermission = true;

    try {
      // Verificar el estado actual del permiso
      final status = await Permission.locationWhenInUse.status;

      debugPrint('🔍 Verificando permiso de ubicación: $status');

      // Solo redirigir si NO está concedido Y NO está en allow-location
      if (!status.isGranted && mounted) {
        final currentRoute = GoRouterState.of(context).uri.path;

        // Evitar loop: no redirigir si ya está en allow-location
        if (currentRoute != '/allow-location') {
          debugPrint('❌ Sin permiso → Redirigiendo a /allow-location');
          context.go('/allow-location');
        }
      } else {
        debugPrint('✅ Permiso concedido');
      }
    } catch (e) {
      debugPrint('⚠️ Error verificando permisos: $e');
    } finally {
      _isCheckingPermission = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: widget.child,
      bottomNavigationBar: BlocBuilder<HomeConductorBloc, HomeConductorState>(
        builder: (context, homeState) {
          return BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, navState) {
              // Sincronizar índice con ruta actual
              _syncIndexWithRoute(context);

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor, width: 1),
                  ),
                ),
                child: BottomNavigationHome(
                  role: Roles
                      .rolUser, // Siempre rolUser porque es ConductorRoutes
                  currentIndex: navState.currentIndex,
                  onTap: (index) {
                    // Actualizar índice
                    context.read<BottomNavCubit>().setIndex(index);
                    // Navegar
                    _navigateToIndex(context, index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Sincroniza el índice del navbar con la ruta actual
  /// Para rolUser: [Home, Mensajes, Guardados]
  void _syncIndexWithRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final cubit = context.read<BottomNavCubit>();

    int newIndex = 0;

    // Mapeo específico para Conductore/Pasajero
    if (location.startsWith(ConductorRoutesPath.home)) {
      newIndex = 0; // Home
    } else if (location.startsWith(ConductorRoutesPath.messages)) {
      newIndex = 1; // Mensajes
    } else if (location.startsWith(ConductorRoutesPath.saveTrips)) {
      newIndex = 2; // Guardados
    }
    // Profile y trips no están en el navbar, son pantallas secundarias

    // Solo actualizar si cambió
    if (cubit.state.currentIndex != newIndex) {
      cubit.setIndex(newIndex);
    }
  }

  /// Navega según el índice seleccionado
  /// Para rolUser: [Home, Mensajes, Guardados]
  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        context.go(ConductorRoutesPath.home);
        break;
      case 1: // Mensajes
        context.go(ConductorRoutesPath.messages, extra: Roles.rolDriver);
        break;
      case 2: // Guardados
        context.go(ConductorRoutesPath.saveTrips);
        break;
    }
  }
}
