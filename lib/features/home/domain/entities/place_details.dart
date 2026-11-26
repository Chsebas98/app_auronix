/// Coordenadas y direccion formateada de un lugar resuelto (T17).
class PlaceDetails {
  const PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceDetails &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.formattedAddress == formattedAddress);

  @override
  int get hashCode => Object.hash(latitude, longitude, formattedAddress);
}
