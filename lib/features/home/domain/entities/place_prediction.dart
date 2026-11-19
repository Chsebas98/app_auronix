/// Una sugerencia de autocompletado de lugar (T17), independiente del
/// formato crudo que devuelva el proveedor (Google Places u otro backend).
class PlacePrediction {
  const PlacePrediction({
    required this.id,
    required this.mainText,
    required this.secondaryText,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String mainText;
  final String secondaryText;
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlacePrediction &&
          other.id == id &&
          other.mainText == mainText &&
          other.secondaryText == secondaryText &&
          other.latitude == latitude &&
          other.longitude == longitude);

  @override
  int get hashCode =>
      Object.hash(id, mainText, secondaryText, latitude, longitude);
}
