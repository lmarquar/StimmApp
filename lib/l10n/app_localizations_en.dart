// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String helloAndWelcome(String firstName, String lastName) {
    return 'Welcome $firstName $lastName!';
  }

  @override
  String newMessages(int newMessages) {
    String _temp0 = intl.Intl.pluralLogic(
      newMessages,
      locale: localeName,
      other: '$newMessages new messages',
      two: 'Two new Messages',
      one: 'One new message',
      zero: 'No new messages',
    );
    return 'You have $_temp0';
  }

  @override
  String get language => 'language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'english';

  @override
  String get german => 'german';

  @override
  String get french => 'french';

  @override
  String get settings => 'Settings';

  @override
  String get alert => 'Alert';

  @override
  String get aboutThisApp => 'About this app';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible =>
      'Are you sure you want to delete your account? This action is irreversible';

  @override
  String get areYouSureYouWantToLogout => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get changePassword => 'Change password';

  @override
  String get consumption => 'Consumption';

  @override
  String get continueNext => 'Continue';

  @override
  String get confirm => 'Confirm';

  @override
  String get currentPassword => 'Current password';

  @override
  String get dailyHabit => 'Daily habit';

  @override
  String get deleted => 'Deleted';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get email => 'Email';

  @override
  String get energy => 'Energy';

  @override
  String get enterSomething => 'Enter something';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get error => 'Error';

  @override
  String get exercise => 'Exercise';

  @override
  String get explore => 'Explore';

  @override
  String get finalNotice => 'Final notice';

  @override
  String get flutterPro => 'Flutter Pro';

  @override
  String get flutterProEmail => 'Flutter@pro.com';

  @override
  String get getStarted => 'Get started';

  @override
  String get growthStartsWithin => 'Growth starts within';

  @override
  String get stimmapp => 'stimmapp';

  @override
  String get invalidEmailEntered => 'Invalid email entered';

  @override
  String get lastStep => 'Last step!';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get myProfile => 'My Profile';

  @override
  String get nameChangeFailed => 'Name change failed';

  @override
  String get newPassword => 'New password';

  @override
  String get newUsername => 'New username';

  @override
  String get noActivityFound => 'No activity found yet.';

  @override
  String get other => 'other';

  @override
  String get password => 'Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get passwordChangeFailed => 'Password change failed';

  @override
  String get pleaseCheckYourEmail => 'Please check your email';

  @override
  String get products => 'Products';

  @override
  String get register => 'Register';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get searchTextField => 'Schlagwort';

  @override
  String get signIn => 'Sign in';

  @override
  String get theWelcomePhrase => 'The ultimate way to exchange about emissions';

  @override
  String get travel => 'Travel';

  @override
  String get updateUsername => 'Update username';

  @override
  String get usernameChangedSuccessfully => 'Username changed successfully';

  @override
  String get usernameChangeFailed => 'Username change failed';

  @override
  String get viewLicenses => 'View licenses';

  @override
  String get welcomeTo => 'Welcome to ';

  @override
  String get petition => 'Petition';

  @override
  String get profile => 'Profile';

  @override
  String get registerAccount => 'Register Account';

  @override
  String get creator => 'Creator';

  @override
  String get polls => 'Polls';

  @override
  String get select => 'Pick';

  @override
  String get noOptions => 'no options';

  @override
  String get createPetition => 'Create Petition';

  @override
  String get createPoll => 'Create Poll';
}
