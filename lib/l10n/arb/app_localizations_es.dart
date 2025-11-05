// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeAppBarTitle => 'SpaceX Demo';

  @override
  String get rocketSpaceXTileTitle => 'Rockets';

  @override
  String get crewSpaceXTileTitle => 'Crew';

  @override
  String get rocketsAppBarTitle => 'Rockets';

  @override
  String get rocketsFetchErrorMessage =>
      'Something went wrong while fetching rockets. Please try again later.';

  @override
  String rocketDetailsFirstFlightSubtitle(Object date) {
    return 'First launch: $date';
  }

  @override
  String get openWikipediaButtonText => 'Open Wikipedia';

  @override
  String get crewAppBarTitle => 'Crew';

  @override
  String get crewFetchErrorMessage =>
      'Something went wrong while fetching crew members. Please try again later.';

  @override
  String get crewMemberDetailsAgency => 'Agency';

  @override
  String get crewMemberDetailsParticipatedLaunches => 'Has participated in';

  @override
  String get crewMemberDetailsLaunch => 'launch';

  @override
  String get crewMemberDetailsLaunches => 'launches';
}
