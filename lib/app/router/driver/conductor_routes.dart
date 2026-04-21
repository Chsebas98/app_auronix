class ConductorRoutesPath {
  static const String base = '/driver';

  static const String home = '$base/home';
  static const String trips = '$base/trips';
  static const String profile = '$base/profile';
  static const String saveTrips = '$base/save-trips';
  static const String messages = '$base/messages';

  //Flujo de solicitar taxi
  static const String selectDestination = '$base/select-destination';
  static const String confirmTrip = '$base/confirm-trip';
  static const String searchingDriver = '$base/searching-driver';
  static const String tripInProgress = '$base/trip-in-progress';
  static const String rateTrip = '$base/rate-trip';
  static const String tripCompleted = '$base/trip-completed';
}
