import 'package:flutter/material.dart';

class AppImageAsset extends StatelessWidget {
  const AppImageAsset({
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  static const _fallback = 'assets/images/png/not_found_image.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          Image.asset(_fallback, width: width, height: height, fit: fit),
    );
  }
}
