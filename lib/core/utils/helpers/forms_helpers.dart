import 'package:auronix_app/core/core.dart';

class FormsHelpers {
  //Devolver el message de validacion
  static String? getMessageFormValidation(ValidationFieldResult data) {
    return data.isValid ? null : data.message;
  }

  //Capitalizar - hacer mayusculas - minusculas
  static String getTextTransform(
    String text, {
    bool capitalize = false,
    bool upperCase = false,
    bool lowerCase = false,
  }) {
    if (capitalize) {
      return text.isNotEmpty
          ? text[0].toUpperCase() + text.substring(1).toLowerCase()
          : text;
    } else if (upperCase) {
      return text.toUpperCase();
    } else if (lowerCase) {
      return text.toLowerCase();
    }
    return text;
  }
}
