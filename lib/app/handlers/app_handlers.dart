import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppHandlers extends StatelessWidget {
  const AppHandlers({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        //
      },
      child: child,
    );
  }
}
