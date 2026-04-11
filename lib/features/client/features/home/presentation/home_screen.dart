import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/packages/handler/handler.dart';
import 'package:auronix_app/app/core/permission/domain/models/interfaces/app_permission_type.dart';
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
    return Scaffold(
      backgroundColor: theme.primaryColor,
      appBar: null,
      body: _HomeScreenController(),
    );
  }
}

class _HomeScreenController extends StatefulWidget {
  const _HomeScreenController();

  @override
  State<_HomeScreenController> createState() => _HomeScreenControllerState();
}

class _HomeScreenControllerState extends State<_HomeScreenController> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    if (_isInitialized) return;
    _isInitialized = true;
    final bloc = context.read<HomeClientBloc>();
    if (bloc.state.dataProfile.firstName.isEmpty) {
      bloc.add(GetDataProfileEvent());
    }
    _isInitialized = true;
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
  bool _completeProfileOpenOnce = false;

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
        if (state.needCompleteProfile && !_completeProfileOpenOnce) {
          _completeProfileOpenOnce = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showCompleteProfileModal(context);
          });
        } else {
          _checkPermissions(context);
        }
      },
      builder: (context, state) {
        return HomeClientPage();
      },
    );
  }
}
