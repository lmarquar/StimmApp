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
  String get hintTextTags => 'z.B. umwelt, verkehr';

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
  String get confirm => 'Bestätigen';

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
  String get colorTheme => 'Farbthema';

  @override
  String get colorMode => 'Farbmodus';

  @override
  String get login => 'Anmelden';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get lightMode => 'Heller Modus';

  @override
  String get systemDefault => 'Systemstandard';

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

  @override
  String get petition => 'Petition';

  @override
  String get petitions => 'Petitionen';

  @override
  String get profile => 'Profil';

  @override
  String get registerAccount => 'Konto registrieren';

  @override
  String get creator => 'Ersteller';

  @override
  String get polls => 'Umfragen';

  @override
  String get select => 'Auswählen';

  @override
  String get noOptions => 'Keine Optionen';

  @override
  String get createPetition => 'Petitition erstellen';

  @override
  String get createPoll => 'Umfrage erstellen';

  @override
  String get developerSandbox => 'Entwickler-Sandbox';

  @override
  String get testingWidgetsHere => 'Widgets testen';

  @override
  String get pleaseSignInFirst => 'Bitte zuerst anmelden';

  @override
  String get createdPetition => 'Petition erstellt';

  @override
  String get errorCreatingPetition => 'Fehler beim Erstellen der Petition';

  @override
  String get createdPoll => 'Umfrage erstellt';

  @override
  String get failedToCreatePoll => 'Fehler beim Erstellen der Umfrage';

  @override
  String get petitionDetails => 'Petitionsdetails';

  @override
  String get pollDetails => 'Umfragedetails';

  @override
  String get notFound => 'Nicht gefunden';

  @override
  String get noData => 'Keine Daten';

  @override
  String get signed => 'Unterzeichnet';

  @override
  String get voted => 'Abgestimmt';

  @override
  String get successfullyLoggedIn => 'Erfolgreich angemeldet';

  @override
  String get resetPasswordLinkSent =>
      'Link zum Zurücksetzen des Passworts gesendet';

  @override
  String get title => 'Titel';

  @override
  String get enterTitle => 'Titel eingeben';

  @override
  String get titleRequired => 'Titel ist erforderlich';

  @override
  String get titleTooShort => 'Titel ist zu kurz';

  @override
  String get description => 'Beschreibung';

  @override
  String get enterDescription => 'Beschreibung eingeben';

  @override
  String get descriptionRequired => 'Beschreibung ist erforderlich';

  @override
  String get descriptionTooShort => 'Beschreibung ist zu kurz';

  @override
  String get descriptioRequired => 'Beschreibung ist erforderlich';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'Komma-getrennte Tags';

  @override
  String get tagsRequired => 'Mindestens ein Tag ist erforderlich';

  @override
  String get options => 'Optionen';

  @override
  String get option => 'Option';

  @override
  String get optionRequired => 'Option ist erforderlich';

  @override
  String get addOption => 'Option hinzufügen';

  @override
  String get profilePictureUpdated => 'Profilbild aktualisiert';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt';
}
