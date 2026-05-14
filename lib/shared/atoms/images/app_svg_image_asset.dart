import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgImageAsset extends StatelessWidget {
  const AppSvgImageAsset({
    required this.imagePath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    super.key,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  static const _fallback = 'assets/images/png/not_found_image.png';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (_) =>
          Image.asset(_fallback, width: width, height: height, fit: fit),
    );
  }
}
