import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/packages/handler/handler.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: _HomeScreenController(),
    );
  }
}

class _HomeScreenController extends StatelessWidget {
  const _HomeScreenController();

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
            return Center(child: Text('Datos: ${stateSession.dataUser.role}'));
          }

          return const Text('No autenticado');
        },
      ),
    );
  }
}
