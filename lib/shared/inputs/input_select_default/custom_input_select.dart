import 'package:auronix_app/app/theme/theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomInputSelect extends StatefulWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final bool isOutSideLabel;
  final String labelOutside;
  final String label;
  final bool isRequired;
  final bool hasTooltip;
  final String tooltipMessage;
  final String tooltipMessageFocus;

  const CustomInputSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.isOutSideLabel = false,
    this.labelOutside = '',
    this.isRequired = false,
    this.value,
    this.validator,
    this.hasTooltip = false,
    this.tooltipMessage = '',
    this.tooltipMessageFocus = '',
  });

  @override
  State<CustomInputSelect> createState() => _PlanDropdownState();
}

class _PlanDropdownState extends State<CustomInputSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final optionsSet = widget.options.toSet();
    final String? safeValue =
        (widget.value != null && optionsSet.contains(widget.value))
        ? widget.value
        : null;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.isOutSideLabel)
              RichText(
                text: TextSpan(
                  text: widget.labelOutside,
                  style: theme.textTheme.labelMedium,
                  children: [
                    if (widget.isRequired)
                      TextSpan(
                        text: '*',
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: AppColors.sevent,
                        ),
                      ),
                  ],
                ),
              ),
            if (widget.hasTooltip) 4.horizontalSpace,
            if (widget.hasTooltip)
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                waitDuration: Duration.zero,
                showDuration: const Duration(seconds: 6),
                preferBelow: false,
                verticalOffset: 8.h,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: theme.primaryColorDark,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                textAlign: TextAlign.center,
                richMessage: TextSpan(
                  text: widget.tooltipMessage,
                  style: theme.textTheme.bodyMedium,
                  children: [TextSpan(text: widget.tooltipMessageFocus)],
                ),
                child: SvgPicture.asset(
                  'assets/images/svg/iconSuggestion.svg',
                  width: 12.w,
                ),
              ),
          ],
        ),
        if (widget.isOutSideLabel) 10.verticalSpace,
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: safeValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.third),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.third),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.third),
            ),
          ),
          hint: Text('Seleccionar', style: theme.textTheme.bodyMedium),
          items: _addDividersAfterItems(widget.options, theme),
          validator: widget.validator,
          onChanged: widget.onChanged,
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.only(right: 12.w),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.primaryColorDark,
            ),
            iconSize: 0.065.sw,
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 1,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.third),
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.white,
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            customHeights: _getCustomItemsHeights(),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _addDividersAfterItems(
    List<String> items,
    ThemeData theme,
  ) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll([
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(item, style: theme.textTheme.bodyMedium),
          ),
        ),
        if (item != items.last)
          DropdownMenuItem<String>(
            enabled: false,
            child: Divider(
              height: 0.5.h,
              thickness: 0.5,
              color: AppColors.third,
            ),
          ),
      ]);
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (widget.options.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40.h);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4.h);
      }
    }
    return itemsHeights;
  }
}
