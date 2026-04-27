import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';

class HomeGreetingText extends StatelessWidget {
  const HomeGreetingText({required this.firstName, super.key});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.waving_hand_rounded, size: 24, color: AppColors.third),
        const SizedBox(width: 8),
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
