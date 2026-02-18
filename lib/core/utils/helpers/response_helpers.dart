class ResponseHelpers {
  static const _particulas = [
    'de',
    'del',
    'de la',
    'de las',
    'de los',
    'da',
    'das',
    'do',
    'dos',
    'van',
    'von',
    'der',
    'den',
    'al',
    'el',
  ];

  //Dividir nombre completo en nombre y apellido
  static (String, String?) compoundNamesGoogle(String name) {
    final s = name.trim();
    if (s.isEmpty) return ('', null);

    // Primer bloque de espacios (también cubre tabs/saltos)
    final match = RegExp(r'\s+').firstMatch(s);

    // Solo un "nombre"
    if (match == null) return (s, null);

    final firstName = s.substring(0, match.start);
    final rest = s.substring(match.end).trim();

    return (firstName, rest.isEmpty ? null : rest);
  }

  static ({
    String firstName,
    String? secondName,
    String lastName,
    String? secondLastName,
  })
  parseFullName(String fullName) {
    final trimmed = fullName.trim();

    if (trimmed.isEmpty) {
      return (
        firstName: '',
        secondName: null,
        lastName: '',
        secondLastName: null,
      );
    }

    final parts = trimmed.split(RegExp(r'\s+'));

    // Caso 1: Solo una palabra (ej: "Cher")
    if (parts.length == 1) {
      return (
        firstName: parts[0],
        secondName: null,
        lastName: parts[0], // Usar mismo nombre como apellido
        secondLastName: null,
      );
    }

    // Caso 2: Dos palabras (ej: "Juan Pérez")
    if (parts.length == 2) {
      return (
        firstName: parts[0],
        secondName: null,
        lastName: parts[1],
        secondLastName: null,
      );
    }

    // Caso 3: Tres palabras
    if (parts.length == 3) {
      // Detectar si la segunda palabra es partícula
      if (_esParticula(parts[1])) {
        // Ej: "Juan de Pérez" → nombre: Juan, ape1: de Pérez
        return (
          firstName: parts[0],
          secondName: null,
          lastName: '${parts[1]} ${parts[2]}',
          secondLastName: null,
        );
      } else {
        // Ej: "Juan Carlos Pérez" → nombre: Juan, nombre2: Carlos, ape1: Pérez
        return (
          firstName: parts[0],
          secondName: parts[1],
          lastName: parts[2],
          secondLastName: null,
        );
      }
    }

    // Caso 4: Cuatro o más palabras
    // Heurística: 2 primeras = nombres, resto = apellidos
    // PERO detectar partículas en apellidos

    final posibleNombre1 = parts[0];
    final posibleNombre2 = parts[1];

    // Verificar si hay partículas en las posiciones 2 o 3
    final apellidosIndex = _encontrarInicioApellidos(parts);

    if (apellidosIndex == 2) {
      // Nombres: 0,1 | Apellidos: 2,3,4...
      final apellidoParts = parts.sublist(2);
      final (ape1, ape2) = _separarApellidos(apellidoParts);

      return (
        firstName: posibleNombre1,
        secondName: posibleNombre2,
        lastName: ape1,
        secondLastName: ape2,
      );
    } else {
      // Caso especial: solo 1 nombre
      final apellidoParts = parts.sublist(1);
      final (ape1, ape2) = _separarApellidos(apellidoParts);

      return (
        firstName: posibleNombre1,
        secondName: null,
        lastName: ape1,
        secondLastName: ape2,
      );
    }
  }

  /// Encuentra dónde empiezan los apellidos
  static int _encontrarInicioApellidos(List<String> parts) {
    // Por defecto: después de 2 nombres
    int inicioApellidos = 2;

    // Si la tercera palabra es partícula, podría ser inicio de apellido
    if (parts.length > 2 && _esParticula(parts[2])) {
      inicioApellidos = 2;
    }

    return inicioApellidos;
  }

  /// Separa apellidos detectando partículas
  static (String, String?) _separarApellidos(List<String> apellidoParts) {
    if (apellidoParts.isEmpty) {
      return ('', null);
    }

    if (apellidoParts.length == 1) {
      return (apellidoParts[0], null);
    }

    // Detectar si hay partícula al inicio
    if (_esParticula(apellidoParts[0])) {
      // Ej: ["de", "la", "Torre", "Martínez"]

      // Buscar hasta dónde llega el apellido compuesto
      int endFirstLastName = apellidoParts.length;

      // Heurística: si hay 4+ palabras, asumir que las últimas 2 son segundo apellido
      if (apellidoParts.length >= 4) {
        endFirstLastName = apellidoParts.length - 1;
      }

      final ape1 = apellidoParts.sublist(0, endFirstLastName).join(' ');
      final ape2 = endFirstLastName < apellidoParts.length
          ? apellidoParts[endFirstLastName]
          : null;

      return (ape1, ape2);
    }

    // Caso normal: primer palabra = ape1, resto = ape2
    final ape1 = apellidoParts[0];
    final ape2 = apellidoParts.length > 1
        ? apellidoParts.sublist(1).join(' ')
        : null;

    return (ape1, ape2);
  }

  /// Verifica si una palabra es partícula
  static bool _esParticula(String word) {
    return _particulas.contains(word.toLowerCase());
  }

  /// 🔥 BONUS: Valida que un nombre sea razonable
  static bool isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.length < 2) return false;
    if (name.length > 50) return false;

    // Solo letras, espacios, guiones, apóstrofes, tildes
    final regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\-']+$");
    return regex.hasMatch(name);
  }
}
