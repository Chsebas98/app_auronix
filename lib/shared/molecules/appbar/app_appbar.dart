import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({
    required this.hasBackButton,
    this.goTo,
    this.isCenter = false,
    this.content,
    this.isModalAppBar = false,
    super.key,
  });

  final VoidCallback? goTo;
  final bool isCenter;
  final bool hasBackButton;
  final Widget? content;
  final bool isModalAppBar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      centerTitle: isCenter,
      automaticallyImplyLeading: false,
      actions: const [],
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasBackButton)
            IconButton(
              onPressed: () => isModalAppBar
                  ? _showExitDialog(context)
                  : (goTo ?? () => Navigator.of(context).maybePop()).call(),
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 24),
            ),
          if (content != null) Expanded(child: content!),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    CustomDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      useRootNavigator: true,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: true,
      title: '¿Salir?',
      desc: '¿Estás seguro de salir sin guardar?',
      btnCancelText: 'Cancelar',
      btnCancelOnPress: () {},
      btnOkOnPress: () =>
          (goTo ?? () => Navigator.of(context).maybePop()).call(),
      buttonsBorderRadius: BorderRadius.circular(AppRadius.md),
    ).show();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
