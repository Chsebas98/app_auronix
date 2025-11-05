import 'package:auronix_app/core/interfaces/interfaces.dart';

class FormValidators {
  static ValidationFieldResult validateLoginEmail(String mail) {
    //Mail vacío
    if (mail == '') {
      return const ValidationFieldResult(
        isValid: false,
        message: 'El correo no puede estar vacío',
      );
    }

    //Validación mail regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(mail)) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'Por favor ingrese un correo válido',
      );
    }
    return const ValidationFieldResult(isValid: true);
  }

  //--------------------------------------------------------
  static ValidationFieldResult validateLoginPassword(String password) {
    if (password.isEmpty) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña no puede estar vacía',
      );
    }
    if (password.length < 8) {
      return const ValidationFieldResult(
        isValid: false,
        message: "La contraseña debe tener al menos 8 caracteres",
      );
    }

    // Verifica longitud máxima de 20 caracteres
    if (password.length > 20) {
      return const ValidationFieldResult(
        isValid: false,
        message: "La contraseña no puede tener más de 20 caracteres",
      );
    }
    return const ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateDateOfBirth(String dateOfBirth) {
    //Fecha de Nacimiento vacío
    if (dateOfBirth == '') {
      return const ValidationFieldResult(isValid: false, message: '');
    }

    try {
      final parsedDate = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      final isSameDay =
          parsedDate.year == today.year &&
          parsedDate.month == today.month &&
          parsedDate.day == today.day;

      if (parsedDate.isAfter(today) || isSameDay) {
        return const ValidationFieldResult(
          isValid: false,
          message: 'La fecha de nacimiento no puede ser una fecha futura',
        );
      }
    } catch (e) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La fecha de nacimiento es incorrecta',
      );
    }

    return const ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateSearchField(String searchField) {
    if (searchField == '') {
      return const ValidationFieldResult(
        isValid: false,
        message: 'Debe ingresar un valor para que pueda ser buscado',
      );
    }

    if (searchField.length > 20) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'No puede tener más de 20 caracteres',
      );
    }
    return const ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateCheckMarked(bool isMarked) {
    if (!isMarked) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'Debe aceptar los términos y condiciones',
      );
    }
    return const ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateName(String name) {
    if (name.trim().isEmpty) {
      return ValidationFieldResult(
        isValid: false,
        message: 'El campo es necesario',
      );
    } else if (name.length < 2) {
      return ValidationFieldResult(
        isValid: false,
        message: 'Es necesario que tenga al menos 2 caracteres',
      );
    }

    return ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validatePhone(String phone) {
    if (phone.isEmpty) {
      return ValidationFieldResult(
        isValid: false,
        message: 'El celular es necesario',
      );
    } else if (phone.length > 10 || phone.length < 10) {
      return ValidationFieldResult(
        isValid: false,
        message: 'El celular debe tener 10 números',
      );
    }
    return ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateRegisterPassword(String password) {
    // al validator forms
    if (password.isEmpty) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña no puede estar vacía',
      );
    }
    if (password.length < 8) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña debe tener al menos 8 caracteres',
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña debe contener al menos una letra mayúscula',
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña debe contener al menos una letra minúscula',
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return const ValidationFieldResult(
        isValid: false,
        message: 'La contraseña debe contener al menos un número',
      );
    }
    if (!RegExp(r'[@#+$%]').hasMatch(password)) {
      return const ValidationFieldResult(
        isValid: false,
        message:
            'La contraseña debe contener al menos un carácter especial (@#+\$%)',
      );
    }
    return const ValidationFieldResult(isValid: true);
  }

  static ValidationFieldResult validateCiPassport(String username) {
    // Verifica el vació del input
    if (username == '') {
      return const ValidationFieldResult(
        isValid: false,
        message: "La cédula o pasaporte no puede estar vacío",
      );
    }

    // Verifica longitud mínima de 8 caracteres
    if (username.length < 8) {
      return const ValidationFieldResult(
        isValid: false,
        message: "Por favor ingrese una cédula o pasaporte válido",
      );
    }
    // Verifica si es pasaporte
    final passportVerify = RegExp(r'[A-Za-z]');
    if (passportVerify.hasMatch(username)) {
      // Verifica longitud máxima de 10 caracteres
      if (username.length > 20) {
        return const ValidationFieldResult(
          isValid: false,
          message: "Por favor ingrese una cédula o pasaporte válido",
        );
      }
    } else {
      // Verifica longitud máxima de 10 caracteres
      if (username.length > 10) {
        return const ValidationFieldResult(
          isValid: false,
          message: "Por favor ingrese una cédula o pasaporte válido",
        );
      }
    }

    //Si todo está posi regresa true
    return const ValidationFieldResult(isValid: true);
  }
}
