import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Text shown in the AppBar of the Home Page
  ///
  /// In en, this message translates to:
  /// **'SpaceX Demo'**
  String get homeAppBarTitle;

  /// Text included as title on the rockets tile on the home page
  ///
  /// In en, this message translates to:
  /// **'Rockets'**
  String get rocketSpaceXTileTitle;

  /// Text included as title on the crew tile on the home page
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewSpaceXTileTitle;

  /// Text shown in the AppBar of the Rockets Page
  ///
  /// In en, this message translates to:
  /// **'Rockets'**
  String get rocketsAppBarTitle;

  /// Error text shown on the Rockets Page when an error occurred while fetching rockets.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching rockets. Please try again later.'**
  String get rocketsFetchErrorMessage;

  /// Subtitle text shown on the Rocket Details Page that indicates when a rocket was or will be launched.
  ///
  /// In en, this message translates to:
  /// **'First launch: {date}'**
  String rocketDetailsFirstFlightSubtitle(Object date);

  /// Button text shown on the Rocket Details Page that opens the corresponding Wikipedia page.
  ///
  /// In en, this message translates to:
  /// **'Open Wikipedia'**
  String get openWikipediaButtonText;

  /// Text shown in the AppBar of the Crew Page
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewAppBarTitle;

  /// Error text shown on the Home Page when an error occurred while fetching crew members.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching crew members. Please try again later.'**
  String get crewFetchErrorMessage;

  /// Prefix word placed in the 1st subtitle of the crew member details page
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get crewMemberDetailsAgency;

  /// Prefix text placed in the 2nd subtitle of the crew member details page
  ///
  /// In en, this message translates to:
  /// **'Has participated in'**
  String get crewMemberDetailsParticipatedLaunches;

  /// Singular suffix word placed in the 2nd subtitle of the crew member details page
  ///
  /// In en, this message translates to:
  /// **'launch'**
  String get crewMemberDetailsLaunch;

  /// Plural suffix word placed in the 2nd subtitle of the crew member details page
  ///
  /// In en, this message translates to:
  /// **'launches'**
  String get crewMemberDetailsLaunches;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
