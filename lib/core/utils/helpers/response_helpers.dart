class ResponseHelpers {
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
}
