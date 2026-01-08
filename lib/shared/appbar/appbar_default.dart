import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppbarDefault extends StatelessWidget implements PreferredSizeWidget {
  const AppbarDefault({
    super.key,
    this.goTo,
    this.isCenter = false,
    this.content,
    this.isModalAppBar = false,
    required this.hasBackButton,
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
      actions: [],
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasBackButton)
            IconButton(
              onPressed: () {
                if (isModalAppBar) {
                  _showExitWithoutSavingDialog(context);
                } else {
                  (goTo ?? () => Navigator.of(context).maybePop()).call();
                }
              },
              icon: Icon(Icons.arrow_back_ios_rounded, size: 24.r),
            ),
          if (content != null) Expanded(child: content!),
        ],
      ),
    );
  }

  void _showExitWithoutSavingDialog(BuildContext context) {
    CustomDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      animType: AnimType.rightSlide,
      useRootNavigator: true,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: true,

      title: '¿Salir?',
      desc: '¿Estás seguro de salir sin guardar?',

      btnCancelText: 'Cancelar',
      btnOkText: 'Salir',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        (goTo ?? () => Navigator.of(context).maybePop()).call();
      },

      // opcional: si quieres redondeo más "moderno"
      buttonsBorderRadius: BorderRadius.circular(12.r),
    ).show();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
