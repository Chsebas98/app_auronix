import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalLogo extends StatelessWidget {
  const HorizontalLogo({super.key, this.sizeIcon = 32});

  final double sizeIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconFromImage(
          imagePath: 'assets/images/png/logoAndo.png',
          size: sizeIcon.w,
          color: AppColors.third,
        ),
        2.horizontalSpace,
        AutoSizeText(
          'Ando',
          maxLines: 1,
          style: theme.headlineMedium!.copyWith(
            color: AppColors.fourth,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
