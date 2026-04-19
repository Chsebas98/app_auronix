import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.isDisabled = false,
    super.key,
  });

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String? label;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,

      onChanged: (T? v) {
        if (!isDisabled && v != null) onChanged(v);
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final radio = Radio<T>.adaptive(
      value: value,
      activeColor: context.appColors.button,
    );

    if (label == null) return radio;

    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radio,
          const SizedBox(width: AppSpacing.x2),
          AppText(label!, variant: AppTextVariant.bodyMedium),
        ],
      ),
    );
  }
}
