import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
  ];

  /// Initial welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome {firstName} {lastName}!'**
  String helloAndWelcome(String firstName, String lastName);

  /// Number of new messages in inbox.
  ///
  /// In en, this message translates to:
  /// **'You have {newMessages, plural, =0{No new messages} =1 {One new message} two{Two new Messages} other {{newMessages} new messages}}'**
  String newMessages(int newMessages);

  /// No description provided for @hintTextTags.
  ///
  /// In en, this message translates to:
  /// **'e.g. environment, transport'**
  String get hintTextTags;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'english'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'german'**
  String get german;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'french'**
  String get french;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @aboutThisApp.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutThisApp;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible'**
  String get areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueNext;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @dailyHabit.
  ///
  /// In en, this message translates to:
  /// **'Daily habit'**
  String get dailyHabit;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @enterSomething.
  ///
  /// In en, this message translates to:
  /// **'Enter something'**
  String get enterSomething;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @finalNotice.
  ///
  /// In en, this message translates to:
  /// **'Final notice'**
  String get finalNotice;

  /// No description provided for @flutterPro.
  ///
  /// In en, this message translates to:
  /// **'Flutter Pro'**
  String get flutterPro;

  /// No description provided for @flutterProEmail.
  ///
  /// In en, this message translates to:
  /// **'Flutter@pro.com'**
  String get flutterProEmail;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @growthStartsWithin.
  ///
  /// In en, this message translates to:
  /// **'Growth starts within'**
  String get growthStartsWithin;

  /// No description provided for @stimmapp.
  ///
  /// In en, this message translates to:
  /// **'stimmapp'**
  String get stimmapp;

  /// No description provided for @invalidEmailEntered.
  ///
  /// In en, this message translates to:
  /// **'Invalid email entered'**
  String get invalidEmailEntered;

  /// No description provided for @lastStep.
  ///
  /// In en, this message translates to:
  /// **'Last step!'**
  String get lastStep;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @nameChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Name change failed'**
  String get nameChangeFailed;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsername;

  /// No description provided for @noActivityFound.
  ///
  /// In en, this message translates to:
  /// **'No activity found yet.'**
  String get noActivityFound;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get other;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Password change failed'**
  String get passwordChangeFailed;

  /// No description provided for @pleaseCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email'**
  String get pleaseCheckYourEmail;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @searchTextField.
  ///
  /// In en, this message translates to:
  /// **'Schlagwort'**
  String get searchTextField;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @theWelcomePhrase.
  ///
  /// In en, this message translates to:
  /// **'The ultimate way to exchange about emissions'**
  String get theWelcomePhrase;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @updateUsername.
  ///
  /// In en, this message translates to:
  /// **'Update username'**
  String get updateUsername;

  /// No description provided for @usernameChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Username changed successfully'**
  String get usernameChangedSuccessfully;

  /// No description provided for @usernameChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Username change failed'**
  String get usernameChangeFailed;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'View licenses'**
  String get viewLicenses;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcomeTo;

  /// No description provided for @petition.
  ///
  /// In en, this message translates to:
  /// **'Petition'**
  String get petition;

  /// No description provided for @petitions.
  ///
  /// In en, this message translates to:
  /// **'Petitions'**
  String get petitions;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @registerAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get registerAccount;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @polls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get polls;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get select;

  /// No description provided for @noOptions.
  ///
  /// In en, this message translates to:
  /// **'no options'**
  String get noOptions;

  /// No description provided for @createPetition.
  ///
  /// In en, this message translates to:
  /// **'Create Petition'**
  String get createPetition;

  /// No description provided for @createPoll.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get createPoll;

  /// No description provided for @developerSandbox.
  ///
  /// In en, this message translates to:
  /// **'Developer Sandbox'**
  String get developerSandbox;

  /// No description provided for @testingWidgetsHere.
  ///
  /// In en, this message translates to:
  /// **'Testing widgets here'**
  String get testingWidgetsHere;

  /// No description provided for @pleaseSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first'**
  String get pleaseSignInFirst;

  /// No description provided for @createdPetition.
  ///
  /// In en, this message translates to:
  /// **'Petition created'**
  String get createdPetition;

  /// No description provided for @errorCreatingPetition.
  ///
  /// In en, this message translates to:
  /// **'Error creating petition'**
  String get errorCreatingPetition;

  /// No description provided for @createdPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll created'**
  String get createdPoll;

  /// No description provided for @failedToCreatePoll.
  ///
  /// In en, this message translates to:
  /// **'Failed to create poll'**
  String get failedToCreatePoll;

  /// No description provided for @petitionDetails.
  ///
  /// In en, this message translates to:
  /// **'Petition details'**
  String get petitionDetails;

  /// No description provided for @pollDetails.
  ///
  /// In en, this message translates to:
  /// **'Poll details'**
  String get pollDetails;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @signed.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get signed;

  /// No description provided for @voted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get voted;

  /// No description provided for @successfullyLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in'**
  String get successfullyLoggedIn;

  /// No description provided for @resetPasswordLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset password link sent'**
  String get resetPasswordLinkSent;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @titleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title is too short'**
  String get titleTooShort;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @descriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Description is too short'**
  String get descriptionTooShort;

  /// No description provided for @descriptioRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptioRequired;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated tags'**
  String get tagsHint;

  /// No description provided for @tagsRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one tag is required'**
  String get tagsRequired;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @option.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get option;

  /// No description provided for @optionRequired.
  ///
  /// In en, this message translates to:
  /// **'Option is required'**
  String get optionRequired;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
