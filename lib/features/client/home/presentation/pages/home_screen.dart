import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/packages/handler/handler.dart';
import 'package:auronix_app/app/core/permission/domain/models/interfaces/app_permission_type.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/client/home/home-client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/client/home/presentation/pages/pages.dart';
import 'package:auronix_app/features/client/home/presentation/widgets/bottom_navigation_home.dart';
import 'package:auronix_app/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenInit();
  }
}

class _HomeScreenInit extends StatelessWidget {
  const _HomeScreenInit();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: sl<HomeClientBloc>(),
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        appBar: null,
        bottomNavigationBar: BlocBuilder<HomeClientBloc, HomeClientState>(
          builder: (context, homeState) {
            return BlocBuilder<BottomNavCubit, BottomNavState>(
              builder: (context, state) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  child: BottomNavigationHome(
                    role:
                        homeState.dataProfile.role, // lo obtienes de tu sesión
                    currentIndex: state.currentIndex,
                    onTap: (i) => context.read<BottomNavCubit>().setIndex(i),
                  ),
                );
              },
            );
          },
        ),
        body: _HomeScreenController(),
      ),
    );
  }
}

class _HomeScreenController extends StatefulWidget {
  const _HomeScreenController();

  @override
  State<_HomeScreenController> createState() => _HomeScreenControllerState();
}

class _HomeScreenControllerState extends State<_HomeScreenController> {
  @override
  void initState() {
    super.initState();
    context.read<HomeClientBloc>().add(GetDataProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionBloc, SessionState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state is SessionAuthenticated
            ? _HomeScreenStructure()
            : SizedBox.shrink();
      },
    );
  }
}

class _HomeScreenStructure extends StatelessWidget {
  const _HomeScreenStructure();

  @override
  Widget build(BuildContext context) {
    return PermissionHandler(
      child: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, stateSession) {
          if (stateSession is SessionAuthenticated) {
            return _HomeClientAuthenticatedStructure();
          }

          return const Text('No autenticado');
        },
      ),
    );
  }
}

class _HomeClientAuthenticatedStructure extends StatefulWidget {
  const _HomeClientAuthenticatedStructure();

  @override
  State<_HomeClientAuthenticatedStructure> createState() =>
      _HomeClientAuthenticatedStructureState();
}

class _HomeClientAuthenticatedStructureState
    extends State<_HomeClientAuthenticatedStructure> {
  Future<void> _showCompleteProfileModal(BuildContext context) async {
    final bloc = context.read<HomeClientBloc>();

    context.read<DialogCubit>().showFullscreenDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      pageBuilder: (_) => BlocProvider.value(
        value: bloc,
        child: const ModalCompleteProfilePage(),
      ),
    );
  }

  Future<void> _checkPermissions(BuildContext context) async {
    final ok = await context.read<PermissionCubit>().ensure(
      AppPermissionType.locationAlways,
    );
    if (!ok) return;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeClientBloc, HomeClientState>(
      listenWhen: (prev, curr) =>
          prev.needCompleteProfile != curr.needCompleteProfile,
      listener: (context, state) {
        if (state.needCompleteProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showCompleteProfileModal(context);
          });
        } else {
          _checkPermissions(context);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
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
              ),
              FilledButton(
                onPressed: () => _showCompleteProfileModal(context),
                child: Text('Complete Profile'),
              ),
              Center(
                child: Text(
                  'Datos: ${state.dataProfile} Need complete ${state.needCompleteProfile}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
