import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';

class DriverHomeData {
  final String username;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final bool isAvailable;
  final String? currentAddress;
  final double rating;
  final double dailyEarnings;
  final int completedTrips;
  final List<EarningsPoint> earningsHistory;

  const DriverHomeData({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.isAvailable,
    this.currentAddress,
    required this.rating,
    required this.dailyEarnings,
    required this.completedTrips,
    required this.earningsHistory,
  });
}
