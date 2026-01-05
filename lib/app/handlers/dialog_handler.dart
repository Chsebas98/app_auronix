import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogHandler extends StatefulWidget {
  const DialogHandler({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<DialogHandler> createState() => _DialogHandlerState();
}

class _DialogHandlerState extends State<DialogHandler> {
  bool _dialogOpen = false;

  void _closeIfOpen() {
    final ctx = widget.navigatorKey.currentContext;
    if (!_dialogOpen || ctx == null) return;

    final nav = Navigator.of(ctx, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogCubit, DialogState>(
      listener: (_, state) {
        debugPrint('DialogHandler - new state: $state');
        final ctx = widget.navigatorKey.currentContext;
        if (ctx == null) return;

        // ejecuta después del frame para evitar casos raros
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (state is DialogHidden) {
            _closeIfOpen();
            return;
          }

          _closeIfOpen();

          if (state is DialogLoading) {
            _dialogOpen = true;
            showDialog<void>(
              context: ctx,
              useRootNavigator:
                  true, // empuja al root navigator :contentReference[oaicite:2]{index=2}
              barrierDismissible: state.dismissible,
              builder: (dCtx) =>
                  const Center(child: CircularProgressIndicator.adaptive()),
            ).then((_) {
              _dialogOpen = false;
            });
            return;
          }

          if (state is DialogMessage) {
            _dialogOpen = true;
            showDialog<void>(
              context: ctx,
              useRootNavigator: true,
              barrierDismissible: false,
              builder: (dCtx) => AlertDialog(
                title: Text(state.title),
                content: state.message == null ? null : Text(state.message!),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        dCtx,
                        rootNavigator: true,
                      ).pop(); // recomendado si hay múltiples Navigators :contentReference[oaicite:3]{index=3}
                      dCtx.read<DialogCubit>().hide();
                    },
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ).then((_) {
              _dialogOpen = false;
            });
          }
        });
      },
      child: widget.child,
    );
  }
}
