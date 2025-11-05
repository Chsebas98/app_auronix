import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/shared/inputs/input_default/validation_rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef RuleBuilder = Widget Function(String ruleName);

class DefaultValidationRulesWidget extends StatelessWidget {
  const DefaultValidationRulesWidget({
    super.key,
    required String value,
    required Set<ValidationRule> validationRules,
  }) : _value = value,
       _validationRules = validationRules;

  final String _value;
  final Set<ValidationRule> _validationRules;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 6.h),
        _buildValidationGrid(),
      ],
    );

    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     const SizedBox(height: 6),
    //     Wrap(
    //       children: _validationRules
    //           .where((rule) => rule.showName)
    //           .map(
    //             (rule) => rule.validate(_value) && _value.isNotEmpty
    //                 ? DefaultRulePassedWidget(rule.name)
    //                 : DefaultRuleNotPassedWidget(rule.name),
    //           )
    //           .toList(),
    //     ),
    //   ],
    // );
  }

  Widget _buildValidationGrid() {
    final rules = _validationRules.where((r) => r.showName).toList();
    final widgets = rules.map((rule) {
      final passed = rule.validate(_value) && _value.isNotEmpty;
      return passed
          ? DefaultRulePassedWidget(rule.name)
          : DefaultRuleNotPassedWidget(rule.name);
    }).toList();

    final rows = <Widget>[];
    for (int i = 0; i < widgets.length; i += 2) {
      if (i + 1 < widgets.length) {
        // Par completo
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [widgets[i], 8.horizontalSpace, widgets[i + 1]],
          ),
        );
      } else {
        // Único sobrante: ocupa todo el ancho
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [29.horizontalSpace, widgets[i]],
          ),
        );
      }
      rows.add(8.verticalSpace);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

@visibleForTesting
class DefaultRulePassedWidget extends StatelessWidget {
  const DefaultRulePassedWidget(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: theme.primaryColor, size: 0.05.sw),
        Text(
          name,
          maxLines: 2,
          style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.fifth),
        ),
      ],
    );
  }
}

@visibleForTesting
class DefaultRuleNotPassedWidget extends StatelessWidget {
  const DefaultRuleNotPassedWidget(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.cancel, color: AppColors.sevent, size: 0.05.sw),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.sevent),
        ),
      ],
    );
  }
}
