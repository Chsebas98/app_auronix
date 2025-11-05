import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/shared/inputs/input_default/input_default_controller.dart';
import 'package:auronix_app/shared/inputs/input_default/validation_rule.dart';
import 'package:auronix_app/shared/inputs/input_default/widget/input_formatters.dart';
import 'package:auronix_app/shared/inputs/input_default/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.decoration,
    this.controller,
    this.validationRules = const {},
    this.hasShowHidePassword = true,
    this.hasShowPreffixIcon = true,
    this.showPasswordIcon,
    this.showPreffixIcon,
    this.hidePasswordIcon,
    this.showPreffixWidget,
    this.showPasswordWidget,
    this.hidePasswordWidget,
    this.hasStrengthIndicator = true,
    this.strengthIndicatorBuilder,
    this.hasValidationRules = true,
    this.validationRuleBuilder,
    this.passwordController,
    this.identifier,
    this.semanticsLabel,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.justUpperCase = false,
    this.justNumbers = false,
    this.allowSpecialCharacters = false,
    this.hasSpace = false,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.obscureText,
  }) : assert(
         showPasswordIcon == null || showPasswordWidget == null,
         "showPasswordIcon y showPasswordWidget no pueden ser usados al mismo tiempo",
       ),
       assert(
         hidePasswordIcon == null || hidePasswordWidget == null,
         "hidePasswordIcon y hidePasswordWidget no pueden ser usados al mismo tiempo",
       );

  // De forma análoga a la propiedad [onChanged] de [TextFormField].
  final ValueChanged<String>? onChanged;

  // De forma análoga a la propiedad [onSaved] de [TextFormField].
  final FormFieldSetter<String>? onSaved;

  // De forma análoga a la propiedad [validator] de [TextFormField].
  final FormFieldValidator<String>? validator;

  // De forma análoga a la propiedad [decoration] de [TextFormField].
  //
  // Si [decoration] es nulo, se creará un [InputDecoration] por defecto
  // para este widget. Se hace así principalmente para poder mostrar los
  // íconos de mostrar/ocultar contraseña.
  final InputDecoration? decoration;

  // Propiedad de [TextFormField].
  final TextEditingController? controller;

  // Conjunto de reglas de validación [ValidationRule].
  // Este paquete incluye varias reglas comunes predefinidas. Pero puedes
  // crear tus propias [ValidationRule].
  final Set<ValidationRule> validationRules;

  // Indica si el widget tendrá la funcionalidad de mostrar/ocultar contraseña.
  final bool hasShowHidePassword;

  // Indica si el widget tendrá un icono al inicio del input.
  final bool hasShowPreffixIcon;

  // Ícono ([Icon]) que se mostrará para revelar la contraseña. Solo se usa
  // si [showPasswordWidget] es nulo.
  // Solo tiene efecto si [hasShowHidePassword] es true.
  final Icon? showPasswordIcon;

  // Ícono ([Icon]) que se mostrará al inicio del input. Sólo se usa
  // si [hasShowPreffixIcon] es nulo.
  // Solo tiene efecto si [hasShowPreffixIcon] es true.
  final Icon? showPreffixIcon;

  // Ícono ([Icon]) que se mostrará para ocultar la contraseña.
  // Solo tiene efecto si [hasShowHidePassword] es true.
  final Icon? hidePasswordIcon;

  // Widget personalizado que se mostrará como Preffix Icon. Solo se
  // usa si [showPreffixIcon] es nulo.
  //
  // Solo tiene efecto si [hasShowPreffixIcon] es true.
  final Widget? showPreffixWidget;

  // Widget personalizado que se mostrará para revelar la contraseña. Solo se
  // usa si [showPasswordIcon] es nulo.
  //
  // Solo tiene efecto si [hasShowHidePassword] es true.
  final Widget? showPasswordWidget;

  // Widget personalizado que se mostrará para ocultar la contraseña. Solo se
  // usa si [hidePasswordIcon] es nulo.
  //
  // Solo tiene efecto si [hasShowHidePassword] es true.
  final Widget? hidePasswordWidget;

  // Indica si el widget mostrará el [StrengthIndicatorWidget].
  final bool hasStrengthIndicator;

  // Constructor para generar un widget de indicador de fuerza de contraseña.
  //
  // Solo tiene efecto si [hasStrengthIndicator] es true.
  final StrengthIndicatorBuilder? strengthIndicatorBuilder;

  // Indica si el widget mostrará la lista de reglas de validación ([ValidationRulesWidget]).
  final bool hasValidationRules;

  // Constructor para generar un widget que muestre las reglas de validación.
  //
  // Útil para que el usuario vea qué reglas cumple y cuáles no.
  final ValidationRulesBuilder? validationRuleBuilder;

  // Instancia de [FancyPasswordController].
  //
  // Útil cuando quieres obtener información del widget.
  final CustomTextFormFieldController? passwordController;

  // Identificador para el nodo de semántica en la jerarquía de accesibilidad nativa.
  // No se expone al usuario; suele usarse en pruebas de UI con herramientas
  // como UIAutomator, XCUITest o Appium.
  // En Android, se traduce en resource-id de AccessibilityNodeInfo.
  // En iOS, se asigna a UIAccessibilityElement.accessibilityIdentifier.
  final String? identifier;

  // Descripción textual del widget para TalkBack y VoiceOver.
  final String? semanticsLabel;

  // Propiedad de [TextFormField].
  final String? initialValue;

  // Propiedad de [TextFormField].
  final FocusNode? focusNode;

  // Propiedad de [TextFormField].
  final TextInputType? keyboardType;

  // Propiedad de [TextFormField].
  final TextCapitalization textCapitalization;

  // Propiedad de [TextFormField].
  final TextInputAction? textInputAction;

  // Propiedad de [TextFormField].
  final TextStyle? style;

  // Propiedad de [TextFormField].
  final StrutStyle? strutStyle;

  // Propiedad de [TextFormField].
  final TextDirection? textDirection;

  // Propiedad de [TextFormField].
  final TextAlign textAlign;

  // Propiedad de [TextFormField].
  final TextAlignVertical? textAlignVertical;

  // Propiedad de [TextFormField].
  final bool autofocus;

  // Propiedad de [TextFormField].
  final bool readOnly;

  // Propiedad de [TextFormField].
  final bool? showCursor;

  // Propiedad de [TextFormField].
  final String obscuringCharacter;

  // Propiedad de [TextFormField].
  final bool autocorrect;

  // Propiedad de [TextFormField].
  final SmartDashesType? smartDashesType;

  // Propiedad de [TextFormField].
  final SmartQuotesType? smartQuotesType;

  // Propiedad de [TextFormField].
  final bool enableSuggestions;

  // Propiedad de [TextFormField].
  final MaxLengthEnforcement? maxLengthEnforcement;

  // Propiedad de [TextFormField].
  final int? maxLines;

  // Propiedad de [TextFormField].
  final int? minLines;

  // Propiedad de [TextFormField].
  final bool expands;

  // Propiedad de [TextFormField].
  final int? maxLength;

  // Propiedad de [TextFormField].
  final GestureTapCallback? onTap;

  // Propiedad de [TextFormField].
  final VoidCallback? onEditingComplete;

  // Propiedad de [TextFormField].
  final ValueChanged<String>? onFieldSubmitted;

  // Condiciones para habilitar los formateadores del input.
  // Permite ingresar unicamente mayusculas definidos en el inputFormatter propiedad de [TextFormField].
  final bool justUpperCase;

  // Permite ingresar unicamente números definidos en el inputFormatter propiedad de [TextFormField].
  final bool justNumbers;

  // Permite ingresar caracteres especiales definidos en el inputFormatter propiedad de [TextFormField].
  final bool allowSpecialCharacters;

  // Permite ingresar espacios definidos en el inputFormatter propiedad de [TextFormField].
  final bool hasSpace;

  // Propiedad de [TextFormField].
  final bool? enabled;

  // Propiedad de [TextFormField].
  final double cursorWidth;

  // Propiedad de [TextFormField].
  final double? cursorHeight;

  // Propiedad de [TextFormField].
  final Radius? cursorRadius;

  // Propiedad de [TextFormField].
  final Color? cursorColor;

  // Propiedad de [TextFormField].
  final Brightness? keyboardAppearance;

  // Propiedad de [TextFormField].
  final EdgeInsets scrollPadding;

  // Propiedad de [TextFormField].
  final bool enableInteractiveSelection;

  // Propiedad de [TextFormField].
  final TextSelectionControls? selectionControls;

  // Propiedad de [TextFormField].
  final InputCounterWidgetBuilder? buildCounter;

  // Propiedad de [TextFormField].
  final ScrollPhysics? scrollPhysics;

  // Propiedad de [TextFormField].
  final Iterable<String>? autofillHints;

  // Propiedad de [TextFormField].
  final AutovalidateMode? autovalidateMode;

  // Propiedad de [TextFormField].
  final ScrollController? scrollController;

  // Propiedad de [TextFormField].
  final String? restorationId;

  // Propiedad de [TextFormField].
  final bool enableIMEPersonalizedLearning;

  // Propiedad de [TextFormField].
  final bool? obscureText;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  String _value = '';
  bool _hidePassword = true;
  late CustomTextFormFieldController _passwordController;

  @override
  void initState() {
    _passwordController =
        (widget.passwordController ?? CustomTextFormFieldController())
          ..setRules(widget.validationRules);
    // El orden no importa, porque TextEditingController fallará si initialValue y text están configurados.
    _value = widget.initialValue ?? widget.controller?.text ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Semantics(
        identifier: widget.identifier,
        label: widget.semanticsLabel,
        child: Column(
          children: [
            TextFormField(
              decoration: widget.decoration != null
                  ? widget.decoration!.copyWith(
                      // prefixIcon: widget.hasShowPreffixIcon
                      //     ? widget.decoration?.prefixIcon ??
                      //         widget.showPreffixWidget
                      //     : null,
                      suffixIcon: widget.hasShowHidePassword
                          ? widget.decoration?.suffixIcon ??
                                DefaultShowHidePasswordButton(
                                  passwordIconColor:
                                      theme.iconTheme.color ??
                                      AppColors.secondary,
                                  hidePassword: _hidePassword,
                                  showPasswordIcon:
                                      widget.showPasswordIcon ??
                                      widget.showPasswordWidget,
                                  hidePasswordIcon:
                                      widget.hidePasswordIcon ??
                                      widget.hidePasswordWidget,
                                  onPressed: () {
                                    setState(
                                      () => _hidePassword = !_hidePassword,
                                    );
                                  },
                                )
                          : null,
                    )
                  : InputDecoration(
                      suffixIcon: widget.hasShowHidePassword
                          ? DefaultShowHidePasswordButton(
                              passwordIconColor:
                                  theme.iconTheme.color ?? AppColors.secondary,
                              hidePassword: _hidePassword,
                              showPasswordIcon:
                                  widget.showPasswordIcon ??
                                  widget.showPasswordWidget,
                              hidePasswordIcon:
                                  widget.hidePasswordIcon ??
                                  widget.hidePasswordWidget,
                              onPressed: () {
                                setState(() => _hidePassword = !_hidePassword);
                              },
                            )
                          : null,
                    ),
              obscureText: widget.obscureText ?? _hidePassword,
              onChanged: (changedValue) {
                _value = changedValue;
                if (widget.onChanged != null) {
                  widget.onChanged!(changedValue);
                }
                _passwordController.onChange(changedValue);
                setState(() {});
              },
              onSaved: (value) {
                if (widget.onSaved != null) {
                  widget.onSaved!(value);
                }
              },
              validator: widget.validator != null
                  ? (value) => widget.validator!(value)
                  : null,
              initialValue: widget.initialValue,
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textDirection: widget.textDirection,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              showCursor: widget.showCursor,
              obscuringCharacter: widget.obscuringCharacter,
              autocorrect: widget.autocorrect,
              smartDashesType: widget.smartDashesType,
              smartQuotesType: widget.smartQuotesType,
              enableSuggestions: widget.enableSuggestions,
              maxLengthEnforcement: widget.maxLengthEnforcement,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              expands: widget.expands,
              maxLength: widget.maxLength,
              onTap: widget.onTap,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onFieldSubmitted,
              inputFormatters: [
                widget.justUpperCase
                    ? UpperCaseTextFormatter()
                    : widget.justNumbers
                    ? FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    : widget.allowSpecialCharacters && widget.hasSpace
                    ? FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9\s!#$%&()*+,-./:;<=>?@\\_,]'),
                      ) // Permite caracteres especiales CON espacio
                    : widget.allowSpecialCharacters && !widget.hasSpace
                    ? FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9!#$%&()*+,-./:;<=>?@\\_,]'),
                      ) // Permite caracteres especiales SIN espacio
                    : widget.hasSpace
                    ? FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9\- ]'),
                      )
                    : FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9]'),
                      ), // Solo permite letras, números
              ],
              enabled: widget.enabled,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor,
              keyboardAppearance: widget.keyboardAppearance,
              scrollPadding: widget.scrollPadding,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              selectionControls: widget.selectionControls,
              buildCounter: widget.buildCounter,
              scrollPhysics: widget.scrollPhysics,
              autofillHints: widget.autofillHints,
              autovalidateMode: widget.autovalidateMode,
              scrollController: widget.scrollController,
              restorationId: widget.restorationId,
              enableIMEPersonalizedLearning:
                  widget.enableIMEPersonalizedLearning,
            ),
            if (widget.hasStrengthIndicator && _value.isNotEmpty)
              StrengthIndicatorWidget(
                password: _value,
                strengthIndicatorBuilder: widget.strengthIndicatorBuilder,
              ),
            if (widget.hasValidationRules && widget.validationRules.isNotEmpty)
              ExcludeSemantics(
                child: ValidationRulesWidget(
                  password: _value,
                  validationRules: widget.validationRules,
                  validationRuleBuilder: widget.validationRuleBuilder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
