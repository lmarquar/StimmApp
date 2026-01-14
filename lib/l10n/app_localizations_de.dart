// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String helloAndWelcome(String firstName, String lastName) {
    return 'Wilkommen $firstName $lastName!';
  }

  @override
  String get participants => 'Teilnehmer';

  @override
  String newMessages(int newMessages) {
    String _temp0 = intl.Intl.pluralLogic(
      newMessages,
      locale: localeName,
      other: '$newMessages neue Nachrichten',
      two: 'zwei neue Nachrichten',
      one: 'Eine neue Nachricht',
      zero: 'Keine neuen Nachrichten',
    );
    return 'Sie haben $_temp0';
  }

  @override
  String get sign => 'Unterzeichen';

  @override
  String get language => 'Sprache';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get english => 'Englisch';

  @override
  String get stateUpdatedSuccessfully => 'Bundesland erfolgreich aktualisiert';

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
  String get expiresOn => 'Läuft ab am';

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
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get closed => 'Beended';

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
  String get updateState => 'Bundesland aktualisieren';

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
  String get theWelcomePhrase => 'Der ultimative Weg deine Meinung zu äußern';

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
  String get pleaseSignInFirst => 'Bitte zuerst anmelden';

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
  String get hintTextTags => 'z.B. umwelt, verkehr';

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

  @override
  String get signedPetitions => 'Unterzeichnete Petitionen';

  @override
  String get signPetition => 'Petition unterzeichnen';

  @override
  String get entryNotYetImplemented =>
      'Lexikon-Eintrag noch nicht implementiert';

  @override
  String get signatures => 'Unterschriften';

  @override
  String get supporters => 'Unterstützer';

  @override
  String get daysLeft => 'Verbleibende Tage';

  @override
  String get goal => 'Ziel';

  @override
  String get petitionBy => 'Petition von';

  @override
  String get sharePetition => 'Petition teilen';

  @override
  String get recentPetitions => 'Aktuelle Petitionen';

  @override
  String get popularPetitions => 'Beliebte Petitionen';

  @override
  String get myPetitions => 'Meine Petitionen';

  @override
  String get victory => 'Sieg!';

  @override
  String get petitionSuccessfullySigned =>
      'Petition erfolgreich unterzeichnet!';

  @override
  String get thankYouForSigning => 'Danke für deine Unterschrift!';

  @override
  String get shareThisPetition => 'Teile diese Petition';

  @override
  String get updates => 'Updates';

  @override
  String get reasonsForSigning => 'Gründe für die Unterzeichnung';

  @override
  String get comments => 'Kommentare';

  @override
  String get addComment => 'Einen Kommentar hinzufügen';

  @override
  String get updateLivingAddress => 'Anschrift ändern';

  @override
  String get anonymous => 'Anonym';

  @override
  String get editPetition => 'Petition bearbeiten';

  @override
  String get deletePetition => 'Petition löschen';

  @override
  String get areYouSureYouWantToDeleteThisPetition =>
      'Sind Sie sicher, dass Sie diese Petition löschen möchten?';

  @override
  String get stateDependent => 'Bundeslandabhängig';

  @override
  String get devContactInformation =>
      'Diese App wurde von Team LeEd mit Hilfe von Yannic entwickelt';

  @override
  String relatedToState(String state) {
    return 'Bezogen auf $state';
  }

  @override
  String get about => 'Über';

  @override
  String get viewParticipants => 'Teilnehmer anzeigen';

  @override
  String get participantsList => 'Teilnehmerliste';

  @override
  String get adminInterface => 'Admin-Oberfläche';

  @override
  String get adminDashboard => 'Admin-Dashboard';

  @override
  String get deleteUser => 'Benutzer löschen';

  @override
  String get deletePoll => 'Umfrage löschen';

  @override
  String get areYouSureYouWantToDeleteThisUser =>
      'Sind Sie sicher, dass Sie diesen Benutzer löschen möchten?';

  @override
  String get areYouSureYouWantToDeleteThisPoll =>
      'Sind Sie sicher, dass Sie diese Umfrage löschen möchten?';

  @override
  String get users => 'Benutzer';

  @override
  String get idScan => 'Ausweisscan';

  @override
  String get scanYourId => 'Bitte scannen Sie Ihren deutschen Personalausweis';

  @override
  String get frontSide => 'Vorderseite';

  @override
  String get backSide => 'Rückseite';

  @override
  String get processId => 'Ausweis verarbeiten';

  @override
  String get scannedData => 'Gescannte Daten';

  @override
  String get confirmAndFinish => 'Bestätigen & Fertigstellen';

  @override
  String get scanAgain => 'Erneut scannen';

  @override
  String get surname => 'Nachname';

  @override
  String get givenName => 'Vorname';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get nationality => 'Staatsangehörigkeit';

  @override
  String get placeOfBirth => 'Geburtsort';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get idNumber => 'Ausweisnummer';

  @override
  String get address => 'Anschrift';

  @override
  String get height => 'Größe';

  @override
  String get state => 'Bundesland';
}
