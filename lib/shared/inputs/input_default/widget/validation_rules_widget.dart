import 'package:auronix_app/shared/inputs/input_default/validation_rule.dart';
import 'package:auronix_app/shared/inputs/input_default/widget/widget.dart';
import 'package:flutter/material.dart';

typedef ValidationRulesBuilder =
    Widget Function(Set<ValidationRule> rules, String value);

class ValidationRulesWidget extends StatelessWidget {
  const ValidationRulesWidget({
    super.key,
    required String password,
    required Set<ValidationRule> validationRules,
    ValidationRulesBuilder? validationRuleBuilder,
  }) : _password = password,
       _validationRules = validationRules,
       _validationRuleBuilder = validationRuleBuilder;

  final String _password;
  final Set<ValidationRule> _validationRules;
  final ValidationRulesBuilder? _validationRuleBuilder;

  @override
  Widget build(BuildContext context) {
    return _validationRuleBuilder != null
        ? _validationRuleBuilder(_validationRules, _password)
        : DefaultValidationRulesWidget(
            value: _password,
            validationRules: _validationRules,
          );
  }
}
