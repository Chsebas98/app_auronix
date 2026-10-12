/// Regex oficial de placa por país (confirmado, ver
/// docs/requerimientos_backend.md sección 2.1). El país se detecta por la
/// ubicación actual del dispositivo al momento del registro de conductor;
/// Ecuador es el fallback si no se pudo detectar (v1 se publica solo en
/// Ecuador, ver docs/questions.md).
class PlateValidationHelper {
  static const String defaultCountryCode = 'EC';

  static final Map<String, RegExp> _regexByCountry = {
    'EC': RegExp(r'^[A-Z]{3}-\d{3,4}$'),
    'PE': RegExp(r'^([A-Z]{3}-\d{3}|[A-Z]\d[A-Z]-\d{3})$'),
    'CO': RegExp(r'^([A-Z]{3}\d{3}|[A-Z]{2}\d{4})$'),
  };

  static const Map<String, String> hintByCountry = {
    'EC': 'ABC-1234',
    'PE': 'ABC-123',
    'CO': 'ABC123',
  };

  static RegExp regexFor(String? countryCode) =>
      _regexByCountry[countryCode] ?? _regexByCountry[defaultCountryCode]!;

  static bool isValid(String plate, String? countryCode) =>
      regexFor(countryCode).hasMatch(plate.trim());

  static String hintFor(String? countryCode) =>
      hintByCountry[countryCode] ?? hintByCountry[defaultCountryCode]!;
}
