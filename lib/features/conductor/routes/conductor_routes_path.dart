class ConductorRoutesPath {
  static const String base = '/conductor';
  static const String login = '$base/login';
  static const String register = '$base/register';

  static const String home = '$base/home';
  static const String profile = '$base/profile';
  static const String saveTrips = '$base/messages';
  static const String messages = '$base/save-trips';
  //Flujo de solicitar taxi
  static const String selectDestination = '$base/select-destination';
  static const String confirmTrip = '$base/confirm-trip';
  static const String searchingDriver = '$base/searching-driver';
  static const String tripInProgress = '$base/trip-in-progress';
  static const String rateTrip = '$base/rate-trip';
  static const String tripCompleted = '$base/trip-completed';
}
