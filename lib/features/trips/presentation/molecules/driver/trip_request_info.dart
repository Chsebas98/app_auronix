import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripRequestInfoRow extends StatelessWidget {
  const TripRequestInfoRow({
    required this.label,
    required this.address,
    required this.eta,
    super.key,
  });

  final String label;
  final String address;
  final String eta;

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.text;
    final mutedColor = context.appColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: mutedColor,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '  ($eta)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
