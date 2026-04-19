import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/shared/atoms/icons/app_image_icon.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

class AppHorizontalLogo extends StatelessWidget {
  const AppHorizontalLogo({this.size = 32, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppImageIcon(
          imagePath: 'assets/images/png/logoAndo.png',
          size: size,
          color: AppColors.third,
        ),
        const SizedBox(width: 2),
        AppText(
          'Ando',
          variant: AppTextVariant.headlineMedium,
          color: AppColors.fourth,
          fontWeight: FontWeight.w700,
          maxLines: 1,
        ),
      ],
    );
  }
}
