import 'package:flutter/material.dart';

class IconFromImage extends StatelessWidget {
  const IconFromImage({
    super.key,
    required this.imagePath,
    required this.size,
    this.color,
    this.action,
  });
  final String imagePath;
  final double size;
  final VoidCallback? action;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: action,

      icon: ImageIcon(AssetImage(imagePath), size: size, color: color),
    );
  }
}
