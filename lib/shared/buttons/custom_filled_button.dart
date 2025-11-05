import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    required this.desc,
    this.action,
    this.style,
  });
  final String desc;
  final VoidCallback? action;
  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: action,
      style: style ?? FilledButton.styleFrom(),
      child: Text(desc),
    );
  }
}
