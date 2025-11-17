import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

List<TextInputFormatter> defaultFormatters({
  bool justUpperCase = false,
  bool justNumbers = false,
  bool allowSpecialCharacters = false,
  bool hasSpace = false,
  bool justText = false,
  bool allowSeparator = false,
  bool allowTildes = false,
}) {
  final formatters = <TextInputFormatter>[];
  // 1. Caso especial: solo números
  if (justNumbers) {
    final buffer = StringBuffer('[');

    // solo dígitos
    buffer.write('0-9');

    // guion como separador (ej: 09-123-456)
    if (allowSeparator) {
      buffer.write(r'\-');
    }

    // espacio si aplica
    if (hasSpace) {
      buffer.write(' ');
    }

    buffer.write(']');

    formatters.add(
      FilteringTextInputFormatter.allow(RegExp(buffer.toString())),
    );
  } else {
    // 2. Resto de casos: texto / texto+num / con o sin especiales
    final buffer = StringBuffer('[');

    // Base: solo letras o alfanumérico
    if (justText) {
      buffer.write('a-zA-Z');
    } else {
      buffer.write('a-zA-Z0-9');
    }

    // Tildes y ñ/Ñ
    if (allowTildes) {
      buffer.write('áéíóúÁÉÍÓÚñÑ');
    }

    // Separador: solo guion medio si se permite
    if (allowSeparator) {
      buffer.write(r'\-');
    }

    // Espacio en blanco si aplica
    if (hasSpace) {
      buffer.write(' ');
    }

    // Caracteres especiales (SIN guion medio, lo controla allowSeparator)
    if (allowSpecialCharacters) {
      buffer.write(r'!#$%&()*+,./:;<=>?@\\_,');
    }

    buffer.write(']');

    final pattern = buffer.toString();

    formatters.add(FilteringTextInputFormatter.allow(RegExp(pattern)));
  }

  // 3. Uppercase opcional
  if (justUpperCase) {
    formatters.add(UpperCaseTextFormatter());
  }

  return formatters;
}
