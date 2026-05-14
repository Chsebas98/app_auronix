import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.iconAndroid,
    required this.iconIOS,
    required this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    this.size,
    this.color,
    super.key,
  });

  final IconData iconAndroid;
  final IconData iconIOS;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final double? size;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS
            ? iconIOS
            : iconAndroid,
        size: size,
        color: color ?? context.appColors.icon,
      ),
    );
  }
}
