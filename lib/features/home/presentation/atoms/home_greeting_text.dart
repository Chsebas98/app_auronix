import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeGreetingText extends StatelessWidget {
  const HomeGreetingText({required this.firstName, super.key});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // context.appColors.button respeta light/dark (third en light, twelveth en dark)
        Icon(
          Icons.waving_hand_rounded,
          size: 24,
          color: context.appColors.button,
        ),
        8.horizontalSpace,
        Expanded(
          child: AppText(
            'Hola, $firstName!',
            variant: AppTextVariant.headlineMedium,
            fontWeight: FontWeight.w700,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
