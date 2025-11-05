import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultShowHidePasswordButton extends StatelessWidget {
  const DefaultShowHidePasswordButton({
    super.key,
    required bool hidePassword,
    Widget? showPasswordIcon,
    Widget? hidePasswordIcon,
    required Function() onPressed,
    required this.passwordIconColor,
  })  : _hidePassword = hidePassword,
        _showPasswordIcon = showPasswordIcon,
        _hidePasswordIcon = hidePasswordIcon,
        _onPressed = onPressed;

  final bool _hidePassword;
  final Color passwordIconColor;
  final Widget? _showPasswordIcon;
  final Widget? _hidePasswordIcon;
  final Function() _onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _onPressed,
          child: _hidePassword
              ? Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _hidePasswordIcon ??
                      Icon(
                        Icons.visibility,
                        color: passwordIconColor,
                        size: 0.05.sw,
                      ),
                )
              : Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _showPasswordIcon ??
                      Icon(
                        Icons.visibility_off,
                        color: passwordIconColor,
                        size: 0.05.sw,
                      ),
                ),
        ),
      ],
    );
  }
}
