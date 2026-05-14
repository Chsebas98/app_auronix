import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.isDisabled = false,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final checkbox = Checkbox(
      value: value,
      onChanged: isDisabled ? null : (v) => onChanged(v ?? false),
    );

    if (label == null) return checkbox;

    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: AppSpacing.x1),
          AppText(label!, variant: AppTextVariant.bodyMedium),
        ],
      ),
    );
  }
}
