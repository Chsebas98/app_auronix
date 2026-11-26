import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/inputs/input_default/app_text_field.dart';
import 'package:flutter/material.dart';

/// Input de origen/destino con icono indicador, boton de limpiar y
/// contenido accesible (T20-C8: area tactil minima 44x44 + Semantics).
class LocationSearchInput extends StatelessWidget {
  const LocationSearchInput({
    required this.isOrigin,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.isLoading = false,
    super.key,
  });

  final bool isOrigin;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = isOrigin ? 'Origen' : 'Destino';

    return Semantics(
      textField: true,
      label: '$label: $hintText',
      child: AppTextField(
        key: Key(
          isOrigin ? 'location_search_origin' : 'location_search_destination',
        ),
        controller: controller,
        onChanged: onChanged,
        hasShowHidePassword: false,
        hasValidationRules: false,
        hasStrengthIndicator: false,
        hasSpace: true,
        allowTildes: true,
        allowSpecialCharacters: true,
        semanticsLabel: '$label: $hintText',
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: ExcludeSemantics(
            child: Icon(
              isOrigin ? Icons.my_location_rounded : Icons.location_on_outlined,
              color: isOrigin ? colors.button : colors.icon,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (controller.text.isNotEmpty && onClear != null)
              ? Semantics(
                  button: true,
                  label: 'Limpiar $label',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: IconButton(
                      tooltip: 'Limpiar $label',
                      icon: Icon(
                        Icons.clear_rounded,
                        color: colors.textSecondary,
                      ),
                      onPressed: onClear,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
