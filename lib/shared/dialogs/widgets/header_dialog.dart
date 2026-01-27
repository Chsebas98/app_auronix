import 'package:auronix_app/shared/dialogs/anims/rive_anim.dart';
import 'package:auronix_app/shared/dialogs/custom_dialog.dart';
import 'package:flutter/material.dart';

///Header of the [AwesomeDialog]
class AwesomeDialogHeader extends StatelessWidget {
  ///Constructor of the [AwesomeDialogHeader]
  const AwesomeDialogHeader({
    required this.dialogType,
    required this.loop,
    super.key,
  });

  ///Defines the type of [AwesomeDialogHeader]
  final DialogType dialogType;

  ///Defines if the animation loops or not
  final bool loop;

  @override
  Widget build(BuildContext context) {
    switch (dialogType) {
      case DialogType.info:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/info.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );
      case DialogType.infoReverse:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/info_reverse.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );

      case DialogType.question:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/question.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );
      case DialogType.warning:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/warning.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );
      case DialogType.error:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/error.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );
      case DialogType.success:
        return RiveAssetAnimation(
          assetPath: 'assets/images/rive/success.riv',
          animName: loop ? 'appear_loop' : 'appear',
        );
      case DialogType.noHeader:
        return const SizedBox.shrink();
    }
  }
}
