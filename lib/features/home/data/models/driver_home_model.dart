import 'package:auronix_app/features/home/domain/models/interfaces/driver_home_data.dart';
import 'package:auronix_app/features/home/domain/models/interfaces/earnings_point.dart';

class DriverHomeModel {
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

  const DriverHomeModel({
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

  factory DriverHomeModel.fromJson(Map<String, dynamic> json) {
    final historyRaw = json['earnings_history'] as List<dynamic>? ?? [];
    return DriverHomeModel(
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? false,
      currentAddress: json['current_address'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      dailyEarnings: (json['daily_earnings'] as num?)?.toDouble() ?? 0.0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      earningsHistory: historyRaw
          .map((e) => EarningsPoint(
                label: e['label'] as String,
                amount: (e['amount'] as num).toDouble(),
                index: e['index'] as int,
              ))
          .toList(),
    );
  }

  DriverHomeData toEntity() => DriverHomeData(
        username: username,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        isAvailable: isAvailable,
        currentAddress: currentAddress,
        rating: rating,
        dailyEarnings: dailyEarnings,
        completedTrips: completedTrips,
        earningsHistory: earningsHistory,
      );
}
