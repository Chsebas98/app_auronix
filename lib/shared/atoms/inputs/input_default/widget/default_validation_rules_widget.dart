import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/shared/atoms/inputs/input_default/validation_rule.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
        rows.add(
          Row(
            children: [
              Expanded(child: widgets[i]),
              Expanded(child: widgets[i + 1]),
            ],
          ),
        );
      } else {
        // Impar sobrante — ocupa solo la mitad izquierda
        rows.add(
          Row(
            children: [
              Expanded(child: widgets[i]),
              const Expanded(child: SizedBox.shrink()),
            ],
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

// Alinear icono + texto a la izquierda
@visibleForTesting
class DefaultRulePassedWidget extends StatelessWidget {
  const DefaultRulePassedWidget(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // <-- no ocupa mas de lo necesario
      children: [
        Icon(Icons.check_circle, color: AppColors.fifth, size: 18),
        const SizedBox(width: 4),
        Flexible(
          child: AutoSizeText(
            name,
            maxLines: 2,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.fifth),
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min, // <-- no ocupa mas de lo necesario
      children: [
        Icon(Icons.cancel, color: AppColors.sevent, size: 18),
        const SizedBox(width: 4),
        Flexible(
          child: AutoSizeText(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.sevent),
          ),
        ),
      ],
    );
  }
}
