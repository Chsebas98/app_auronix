import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/shared/atoms/images/app_svg_image_asset.dart';
import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class AppInputSelect extends StatelessWidget {
  const AppInputSelect({
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.validator,
    this.outsideLabel,
    this.isRequired = false,
    this.tooltipMessage,
    this.tooltipMessageFocus,
    super.key,
  });

  final String label;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? value;
  final FormFieldValidator<String>? validator;

  /// Si es null no se muestra label exterior
  final String? outsideLabel;
  final bool isRequired;

  /// Si es null no se muestra tooltip
  final String? tooltipMessage;
  final String? tooltipMessageFocus;

  // ✅ Derivado — no necesita estado
  String? get _safeValue => options.contains(value) ? value : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOutsideLabel = outsideLabel != null;
    final hasTooltip = tooltipMessage != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Outside label + tooltip ──────────────────────────────────────
        if (hasOutsideLabel) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: outsideLabel,
                  style: theme.textTheme.labelMedium,
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: ' *',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.sevent,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasTooltip) ...[
                SizedBox(width: AppSpacing.x1),
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  waitDuration: Duration.zero,
                  showDuration: const Duration(seconds: 6),
                  preferBelow: false,
                  verticalOffset: 8,
                  padding: const EdgeInsets.all(AppSpacing.x3),
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
                  textAlign: TextAlign.center,
                  richMessage: TextSpan(
                    text: tooltipMessage,
                    style: theme.textTheme.bodyMedium,
                    children: [
                      if (tooltipMessageFocus != null)
                        TextSpan(text: tooltipMessageFocus),
                    ],
                  ),
                  child: AppSvgImageAsset(
                    imagePath: 'assets/images/svg/iconSuggestion.svg',
                    width: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
        ],

        // ── Dropdown ─────────────────────────────────────────────────────
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: _safeValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x2,
            ),
          ),
          hint: const Text('Seleccionar'),
          items: _buildItems(theme),
          validator: validator,
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.primaryColorDark,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 6,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.third),
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: theme.primaryColor,
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            customHeights: _buildItemHeights(),
            padding: EdgeInsets.zero,
            selectedMenuItemBuilder: (_, child) =>
                Align(alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildItems(ThemeData theme) {
    final result = <DropdownMenuItem<String>>[];
    for (final item in options) {
      result.add(
        DropdownMenuItem<String>(
          value: item,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
            child: Text(item, style: theme.textTheme.bodyMedium),
          ),
        ),
      );
      if (item != options.last) {
        result.add(
          DropdownMenuItem<String>(
            enabled: false,
            child: Divider(height: 0.5, thickness: 0.5, color: AppColors.third),
          ),
        );
      }
    }
    return result;
  }

  List<double> _buildItemHeights() {
    return [
      for (var i = 0; i < options.length * 2 - 1; i++) i.isEven ? 40.0 : 4.0,
    ];
  }
}
