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
  String get aboutthisapp => 'About this app';

  @override
  String get settings => 'Settings';
}
