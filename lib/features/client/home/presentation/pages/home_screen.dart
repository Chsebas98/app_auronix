import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/packages/handler/handler.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/client/home/home-client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/client/home/presentation/pages/pages.dart';
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
    return BlocProvider.value(
      value: sl<HomeClientBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
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
  bool _needShowModal = false;

  Future<void> _showCompleteProfileModal(BuildContext context) {
    final bloc = context.read<HomeClientBloc>();
    _needShowModal = false;
    return showGeneralDialog(
      context: context,
      barrierDismissible: false, //cambiar a false
      fullscreenDialog: true,
      useRootNavigator: false,
      pageBuilder: (_, __, ___) =>
          BlocProvider.value(value: bloc, child: ModalCompleteProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeClientBloc, HomeClientState>(
      listener: (context, state) {
        if (state.needCompleteProfile && !_needShowModal) {
          _needShowModal = true;
          _showCompleteProfileModal(context);
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
        );
      },
    );
  }
}
