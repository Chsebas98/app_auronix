import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.desc,
    this.action,
    this.style,
    this.hasIcon = false,
    this.icon,
  });

  final bool hasIcon;
  final Widget? icon;
  final String desc;
  final VoidCallback? action;
  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: action,
      style: style ?? OutlinedButton.styleFrom(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [if (hasIcon) icon!, AutoSizeText(desc)],
      ),
    );
  }
}
