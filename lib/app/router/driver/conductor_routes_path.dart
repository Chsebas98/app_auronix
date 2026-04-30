class ConductorRoutesPath {
  static const String base = '/driver';

  static const String home = '$base/home';
  static const String trips = '$base/trips';
  static const String profile = '$base/profile';
  static const String metrics = '$base/metrics';
  static const String messages = '$base/messages';
  static const String vehicle = '$base/vehicle';

  //Flujo de solicitar taxi
  static const String searchPassenger = '$base/search-passenger';
  static const String confirmTrip = '$base/confirm-trip';
  static const String searchingDriver = '$base/searching-driver';
  static const String tripInProgress = '$base/trip-in-progress';
  static const String rateTrip = '$base/rate-trip';
  static const String tripCompleted = '$base/trip-completed';
}
