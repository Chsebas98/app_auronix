class EncryptHelpers {
  // ignore: avoid_unused_constructor_parameters
  EncryptHelpers({required dynamic dataJson});

  String get payload {
    // TODO: reimplementar cifrado híbrido RSA+AES sin dependencia de pointycastle/encrypt
    throw UnimplementedError(
      'EncryptHelpers.payload: las dependencias pointycastle y encrypt fueron retiradas. '
      'Reimplementar con una alternativa compatible.',
    );
  }
}
