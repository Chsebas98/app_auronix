class PrefsTypeException implements Exception {
  final String message;

  PrefsTypeException([this.message = 'El tipo no es soportado']);

  @override
  String toString() {
    return message;
  }
}
