/// Texte für "Über die App": Neuerungen und Datenschutz.
///
/// Bewusst nicht in den .arb-Dateien, weil es lange, mehrteilige Texte sind,
/// die am Stück gepflegt werden. Sprache: 'de' oder 'en'.

/// Neuerungen dieser Version (bei jedem Release anpassen).
List<String> whatsNew(String lang) => lang == 'de'
    ? [
        'Spiel um den Tages- und Monatssieg: Die besten Runden jeder Anlage kommen in die Online-Bestenliste',
        'Alle Bestenlisten auf einer Seite, mit Platz und Abstand zu Par',
        'Bei deinen Rekorden siehst du jetzt jede einzelne Bahn',
        'Neue Runde: Mitspielende antippen und die Reihenfolge per Ziehen festlegen',
        'Die Scorecard zeigt die aktuelle Bahn, deinen Fortschritt und den Abstand zu Par',
        'Schneller eintragen: Bahn für Bahn weiterblättern, ohne den Dialog zu schließen',
        'Laufende Runde direkt im Hauptmenü fortsetzen',
        'Diagramme mit Par-Linie, Antippen zeigt die Details',
        'Bahnen zum Durchwischen, mit Par, Länge und Hindernissen',
        'Anrufen, Route und E-Mail mit einem Tipp',
        'Etwas funktioniert nicht? Unter „Über die App“ kannst du uns direkt einen Fehler melden',
      ]
    : [
        'Play for the daily and monthly title: the best rounds at each venue make the online leaderboard',
        'All leaderboards on one page, with rank and score to par',
        'Your records now show every single hole',
        'New round: tap to add players and drag to set the playing order',
        'The scorecard shows the current hole, your progress and your score to par',
        'Faster scoring: move from hole to hole without closing the dialog',
        'Continue a running round straight from the main menu',
        'Charts with a par line, tap for details',
        'Swipe through the holes, with par, length and obstacles',
        'Call, get directions or send an email with one tap',
        'Something not working? Report a problem directly under "About the app"',
      ];

/// Ein Abschnitt der Datenschutzhinweise.
class PrivacySection {
  const PrivacySection(this.title, this.body);
  final String title;
  final String body;
}

/// ENTWURF der Datenschutzhinweise – vor der Veröffentlichung rechtlich
/// prüfen lassen! Beschreibt, was die App technisch tut.
List<PrivacySection> privacySections(String lang) =>
    lang == 'de' ? _privacyDe : _privacyEn;

const String privacyDate = '10/2026';

const List<PrivacySection> _privacyDe = [
  PrivacySection('Verantwortlich',
      'Soccerpark Salzburg, Hans Klegraefe\nOberaustraße 33, A-5072 Wals-Siezenheim\nsoccerpark.salzburg@gmail.com'),
  PrivacySection('Daten auf deinem Gerät',
      'Spielernamen, Runden, Ergebnisse, Rekorde und Einstellungen werden nur auf deinem Gerät gespeichert und nicht übertragen. Du kannst sie jederzeit über „Historie löschen“ entfernen oder indem du die App deinstallierst. Ein Benutzerkonto gibt es nicht.'),
  PrivacySection('Online-Bestenliste',
      'Nur wenn du nach einer Runde ausdrücklich „Eintragen“ wählst, werden folgende Daten übertragen: der von dir gewählte Anzeigename, die Schläge je Bahn und gesamt, die Anlage und der Zeitpunkt. Der Eintrag ist für alle Nutzerinnen und Nutzer der App sichtbar. Es werden keine Gerätekennung und kein Konto gespeichert.\n\nDie Daten werden beim Dienstleister Supabase auf Servern in der EU gespeichert. Technisch bedingt verarbeitet der Server dabei kurzzeitig deine IP-Adresse. Rechtsgrundlage ist deine Einwilligung (Art. 6 Abs. 1 lit. a DSGVO), die du jederzeit widerrufen kannst. Pro Monat und Anlage werden nur die 50 besten Runden aufbewahrt; ältere Monate bleiben als Archiv sichtbar. Für die Tageswertung werden zusätzlich die 20 besten Runden des laufenden Tages gespeichert; sie werden danach automatisch gelöscht, sofern sie nicht in der Monatswertung sind. Die Tageswertung zeigt nur Anzeigename und Schläge, keine Uhrzeit. Auf Wunsch löschen wir deinen Eintrag – schreib uns einfach eine E-Mail.'),
  PrivacySection('Push-Mitteilungen',
      'In der Android- und iOS-App nutzen wir Firebase Cloud Messaging von Google, um Mitteilungen der Anlage zu senden. Dafür wird eine zufällige Gerätekennung (Token) verarbeitet, zusammen mit der gewählten Sprache. Google kann Daten auch in den USA verarbeiten; die Übermittlung stützt sich auf das EU-US Data Privacy Framework. Mitteilungen kannst du in den Einstellungen deines Geräts jederzeit abschalten.'),
  PrivacySection('Video in der Anleitung',
      'Das Erklärvideo wird von YouTube (Google) bereitgestellt. Erst wenn du es abspielst, werden Daten wie deine IP-Adresse an YouTube übertragen.'),
  PrivacySection('Links zu anderen Apps',
      'Anrufen, E-Mail, Route, Website und Facebook öffnen andere Apps oder Websites. Dort gelten deren Datenschutzbestimmungen.'),
  PrivacySection('Deine Rechte',
      'Du hast das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung, Datenübertragbarkeit und Widerspruch sowie auf Widerruf deiner Einwilligung. Wende dich dafür an die oben genannte E-Mail-Adresse. Außerdem kannst du dich bei der Österreichischen Datenschutzbehörde beschweren (www.dsb.gv.at).'),
];

const List<PrivacySection> _privacyEn = [
  PrivacySection('Controller',
      'Soccerpark Salzburg, Hans Klegraefe\nOberaustraße 33, A-5072 Wals-Siezenheim, Austria\nsoccerpark.salzburg@gmail.com'),
  PrivacySection('Data on your device',
      'Player names, rounds, scores, records and settings are stored only on your device and are not transmitted. You can remove them at any time via "Delete history" or by uninstalling the app. There is no user account.'),
  PrivacySection('Online leaderboard',
      'Only if you explicitly choose "Submit" after a round, the following data is transmitted: the display name you choose, the strokes per hole and in total, the venue and the time. The entry is visible to all users of the app. No device ID and no account is stored.\n\nThe data is stored by the service provider Supabase on servers in the EU. For technical reasons the server briefly processes your IP address. The legal basis is your consent (Art. 6(1)(a) GDPR), which you can withdraw at any time. Only the 50 best rounds per month and venue are kept; previous months remain visible as an archive. For the daily ranking, the 20 best rounds of the current day are kept as well; they are deleted automatically afterwards unless they are in the monthly ranking. The daily ranking shows only the display name and strokes, no time. We will delete your entry on request – just send us an email.'),
  PrivacySection('Push notifications',
      'In the Android and iOS app we use Firebase Cloud Messaging by Google to send notifications from the venue. This processes a random device identifier (token) together with the selected language. Google may also process data in the USA; the transfer is based on the EU-US Data Privacy Framework. You can turn off notifications in your device settings at any time.'),
  PrivacySection('Video in the rules',
      'The explanatory video is provided by YouTube (Google). Data such as your IP address is only transmitted to YouTube when you play it.'),
  PrivacySection('Links to other apps',
      'Call, email, directions, website and Facebook open other apps or websites. Their privacy policies apply there.'),
  PrivacySection('Your rights',
      'You have the right to access, rectification, erasure, restriction of processing, data portability and objection, and to withdraw your consent. Please contact the email address above. You can also lodge a complaint with the Austrian Data Protection Authority (www.dsb.gv.at).'),
];
