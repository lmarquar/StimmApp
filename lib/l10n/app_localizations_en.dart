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
  String get stateUpdatedSuccessfully => 'State updated successfully';

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
  String get expiresOn => 'Expires on';

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
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get closed => 'Closed';

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
  String get colorTheme => 'Color Theme';

  @override
  String get updateState => 'Update state';

  @override
  String get colorMode => 'Color Mode';

  @override
  String get login => 'Login';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

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
  String get theWelcomePhrase => 'The ultimate way to share your opinion';

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
  String get petitions => 'Petitions';

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

  @override
  String get developerSandbox => 'Developer Sandbox';

  @override
  String get testingWidgetsHere => 'Testing widgets here';

  @override
  String get createdPetition => 'Petition created';

  @override
  String get errorCreatingPetition => 'Error creating petition';

  @override
  String get createdPoll => 'Poll created';

  @override
  String get failedToCreatePoll => 'Failed to create poll';

  @override
  String get petitionDetails => 'Petition details';

  @override
  String get pollDetails => 'Poll details';

  @override
  String get notFound => 'Not found';

  @override
  String get noData => 'No data';

  @override
  String get pleaseSignInFirst => 'Please sign in first';

  @override
  String get signed => 'Signed';

  @override
  String get voted => 'Voted';

  @override
  String get successfullyLoggedIn => 'Successfully logged in';

  @override
  String get resetPasswordLinkSent => 'Reset password link sent';

  @override
  String get title => 'Title';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get titleTooShort => 'Title is too short';

  @override
  String get description => 'Description';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get descriptionTooShort => 'Description is too short';

  @override
  String get descriptioRequired => 'Description is required';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'Comma-separated tags';

  @override
  String get hintTextTags => 'e.g. environment, transport';

  @override
  String get tagsRequired => 'At least one tag is required';

  @override
  String get options => 'Options';

  @override
  String get option => 'Option';

  @override
  String get optionRequired => 'Option is required';

  @override
  String get addOption => 'Add option';

  @override
  String get profilePictureUpdated => 'Profile picture updated';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get signedPetitions => 'Signed Petitions';

  @override
  String get signPetition => 'Sign Petition';

  @override
  String get entryNotYetImplemented => 'Lexicon entry not yet implemented';

  @override
  String get signatures => 'Signatures';

  @override
  String get supporters => 'Supporters';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get goal => 'Goal';

  @override
  String get petitionBy => 'Petition by';

  @override
  String get sharePetition => 'Share Petition';

  @override
  String get recentPetitions => 'Recent Petitions';

  @override
  String get popularPetitions => 'Popular Petitions';

  @override
  String get myPetitions => 'My Petitions';

  @override
  String get victory => 'Victory!';

  @override
  String get petitionSuccessfullySigned => 'Petition successfully signed!';

  @override
  String get thankYouForSigning => 'Thank you for signing!';

  @override
  String get shareThisPetition => 'Share this petition';

  @override
  String get updates => 'Updates';

  @override
  String get reasonsForSigning => 'Reasons for signing';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add a comment';

  @override
  String get updateLivingAddress => 'Change address';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get editPetition => 'Edit Petition';

  @override
  String get deletePetition => 'Delete Petition';

  @override
  String get areYouSureYouWantToDeleteThisPetition =>
      'Are you sure you want to delete this petition?';

  @override
  String get stateDependent => 'State dependent';

  @override
  String get devContactInformation =>
      'This app is developed by Team LeEd with help of yannic';

  @override
  String relatedToState(String state) {
    return 'Related to $state';
  }

  @override
  String get about => 'About';
}
