// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';

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
  // Conteo simple de rutas “overlay” abiertas por el handler.
  // Sirve para hideTop/hideAll sin volarte navegación normal.
  int _openOverlays = 0;

  NavigatorState? _nav({bool root = true}) {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return null;
    return Navigator.of(ctx, rootNavigator: root);
  }

  void _popTop() {
    final nav = _nav(root: true);
    if (nav == null) return;
    if (_openOverlays <= 0) return;
    if (nav.canPop()) {
      nav.pop();
      _openOverlays = (_openOverlays - 1).clamp(0, 999);
    }
  }

  void _popAll() {
    final nav = _nav(root: true);
    if (nav == null) return;
    while (_openOverlays > 0 && nav.canPop()) {
      nav.pop();
      _openOverlays--;
    }
    _openOverlays = 0;
  }

  Future<void> _showLoading(DialogLoading s) async {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _openOverlays++;
    await showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: s.dismissible,
      builder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
    ).whenComplete(() {
      _openOverlays = (_openOverlays - 1).clamp(0, 999);
    });
  }

  Future<void> _showMessage(DialogMessage s) async {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _openOverlays++;
    await showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: s.dismissible,
      builder: (dCtx) => AlertDialog(
        title: Text(s.title),
        content: s.message == null ? null : Text(s.message!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx, rootNavigator: true).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    ).whenComplete(() {
      _openOverlays = (_openOverlays - 1).clamp(0, 999);
    });
  }

  Future<void> _showConfirm(DialogConfirm s) async {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _openOverlays++;
    final result =
        await showDialog<bool>(
          context: ctx,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (dCtx) => AlertDialog(
            title: Text(s.title),
            content: Text(s.message),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dCtx, rootNavigator: true).pop(false),
                child: Text(s.cancelText),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dCtx, rootNavigator: true).pop(true),
                child: Text(s.okText),
              ),
            ],
          ),
        ).whenComplete(() {
          _openOverlays = (_openOverlays - 1).clamp(0, 999);
        });

    if (!s.completer.isCompleted) {
      s.completer.complete(result ?? false);
    }
  }

  Future<void> _showCustom(DialogCustom s) async {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _openOverlays++;
    await showDialog<void>(
      context: ctx,
      useRootNavigator: s.useRootNavigator,
      barrierDismissible: s.barrierDismissible,
      barrierColor: s.barrierColor,
      builder: s.builder,
    ).whenComplete(() {
      _openOverlays = (_openOverlays - 1).clamp(0, 999);
    });
  }

  Future<void> _showFullscreen(DialogFullscreen s) async {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _openOverlays++;
    await showGeneralDialog<void>(
      context: ctx,
      useRootNavigator: s.useRootNavigator,
      barrierDismissible: s.barrierDismissible,
      barrierColor: s.barrierColor ?? Colors.black54,
      pageBuilder: (c, a1, a2) => s.pageBuilder(c),
    ).whenComplete(() {
      _openOverlays = (_openOverlays - 1).clamp(0, 999);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogCubit, DialogState>(
      listener: (_, state) {
        final ctx = widget.navigatorKey.currentContext;
        if (ctx == null) return;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          // Close commands
          if (state is DialogHideAll) {
            _popAll();
            context.read<DialogCubit>().idle();
            return;
          }
          if (state is DialogHideTop) {
            _popTop();
            context.read<DialogCubit>().idle();
            return;
          }

          // Show commands
          if (state is DialogLoading) {
            if (state.presentation == DialogPresentation.replaceTop) _popTop();
            await _showLoading(state);
            context.read<DialogCubit>().idle();
            return;
          }

          if (state is DialogMessage) {
            if (state.presentation == DialogPresentation.replaceTop) _popTop();
            await _showMessage(state);
            context.read<DialogCubit>().idle();
            return;
          }

          if (state is DialogConfirm) {
            if (state.presentation == DialogPresentation.replaceTop) _popTop();
            await _showConfirm(state);
            context.read<DialogCubit>().idle();
            return;
          }

          if (state is DialogCustom) {
            if (state.presentation == DialogPresentation.replaceTop) _popTop();
            await _showCustom(state);
            context.read<DialogCubit>().idle();
            return;
          }

          if (state is DialogFullscreen) {
            if (state.presentation == DialogPresentation.replaceTop) _popTop();
            await _showFullscreen(state);
            context.read<DialogCubit>().idle();
            return;
          }
        });
      },
      child: widget.child,
    );
  }
}
