// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

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
  String get language => 'Sprache';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get french => 'Französisch';

  @override
  String get settings => 'Einstellungen';

  @override
  String get alert => 'Warnung';

  @override
  String get aboutThisApp => 'Über diese App';

  @override
  String get activityHistory => 'Aktivitätsverlauf';

  @override
  String get areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion ist unwiderruflich';

  @override
  String get areYouSureYouWantToLogout =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get consumption => 'Verbrauch';

  @override
  String get continueNext => 'Weiter';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get dailyHabit => 'Tägliche Gewohnheit';

  @override
  String get deleted => 'Gelöscht';

  @override
  String get deleteMyAccount => 'Mein Konto löschen';

  @override
  String get deletePermanently => 'Endgültig löschen';

  @override
  String get email => 'E-Mail';

  @override
  String get energy => 'Energie';

  @override
  String get enterSomething => 'Geben Sie etwas ein';

  @override
  String get enterYourEmail => 'Geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get error => 'Fehler';

  @override
  String get exercise => 'Übung';

  @override
  String get explore => 'Entdecken';

  @override
  String get finalNotice => 'Letzter Hinweis';

  @override
  String get flutterPro => 'Flutter Pro';

  @override
  String get flutterProEmail => 'Flutter@pro.com';

  @override
  String get getStarted => 'Los geht\'s';

  @override
  String get growthStartsWithin => 'Wachstum beginnt von innen';

  @override
  String get stimmapp => 'stimmapp';

  @override
  String get invalidEmailEntered => 'Ungültige E-Mail-Adresse eingegeben';

  @override
  String get lastStep => 'Letzter Schritt!';

  @override
  String get logout => 'Abmelden';

  @override
  String get login => 'Anmelden';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get nameChangeFailed => 'Namensänderung fehlgeschlagen';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get newUsername => 'Neuer Benutzername';

  @override
  String get noActivityFound => 'Noch keine Aktivität gefunden.';

  @override
  String get other => 'Andere';

  @override
  String get password => 'Passwort';

  @override
  String get passwordChangedSuccessfully => 'Passwort erfolgreich geändert';

  @override
  String get passwordChangeFailed => 'Passwortänderung fehlgeschlagen';

  @override
  String get pleaseCheckYourEmail => 'Bitte überprüfen Sie Ihre E-Mails';

  @override
  String get products => 'Produkte';

  @override
  String get register => 'Registrieren';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get searchTextField => 'Schlagwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get theWelcomePhrase =>
      'Der ultimative Weg, sich über Emissionen auszutauschen';

  @override
  String get travel => 'Reisen';

  @override
  String get updateUsername => 'Benutzernamen aktualisieren';

  @override
  String get usernameChangedSuccessfully => 'Benutzername erfolgreich geändert';

  @override
  String get usernameChangeFailed =>
      'Änderung des Benutzernamens fehlgeschlagen';

  @override
  String get viewLicenses => 'Lizenzen anzeigen';

  @override
  String get welcomeTo => 'Willkommen bei ';
}
