import 'package:flutter/material.dart';

class AppImageIcon extends StatelessWidget {
  const AppImageIcon({
    required this.imagePath,
    required this.size,
    this.color,
    super.key,
  });

  final String imagePath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ImageIcon(AssetImage(imagePath), size: size, color: color);
  }
}
