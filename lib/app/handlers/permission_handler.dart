import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/permission/presentation/permission_rationale_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionHandler extends StatelessWidget {
  const PermissionHandler({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionCubit, PermissionState>(
      listenWhen: (prev, curr) => prev.uiRequest != curr.uiRequest,
      listener: (context, state) {
        final req = state.uiRequest;
        if (req == null) return;

        // Abre fullscreen usando tu DialogCubit (centralizado)
        context.read<DialogCubit>().showFullscreenDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          pageBuilder: (_) => PermissionRationalePage(type: req.type),
        );
      },
      child: child,
    );
  }
}
