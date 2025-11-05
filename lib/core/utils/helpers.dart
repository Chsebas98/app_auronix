import 'package:auronix_app/core/core.dart';

class Helpers {
  //Devolver el message de validacion
  static String? getMessageFormValidation(ValidationFieldResult data) {
    return data.isValid ? null : data.message;
  }
}
