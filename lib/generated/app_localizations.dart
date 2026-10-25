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
/// import 'generated/app_localizations.dart';
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
    Locale('en')
  ];

  /// No description provided for @newRound.
  ///
  /// In de, this message translates to:
  /// **'Neue Runde'**
  String get newRound;

  /// No description provided for @currRound.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Runde'**
  String get currRound;

  /// No description provided for @history.
  ///
  /// In de, this message translates to:
  /// **'Historie'**
  String get history;

  /// No description provided for @info.
  ///
  /// In de, this message translates to:
  /// **'Über den Soccerpark'**
  String get info;

  /// No description provided for @faqs.
  ///
  /// In de, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @rules.
  ///
  /// In de, this message translates to:
  /// **'Anleitung'**
  String get rules;

  /// No description provided for @holes.
  ///
  /// In de, this message translates to:
  /// **'Bahnen'**
  String get holes;

  /// No description provided for @orders.
  ///
  /// In de, this message translates to:
  /// **'Platzordnung'**
  String get orders;

  /// No description provided for @venue.
  ///
  /// In de, this message translates to:
  /// **'Anfahrt'**
  String get venue;

  /// No description provided for @version.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contact;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @main.
  ///
  /// In de, this message translates to:
  /// **'Hauptmenü'**
  String get main;

  /// No description provided for @round.
  ///
  /// In de, this message translates to:
  /// **'Spielrunde'**
  String get round;

  /// No description provided for @player.
  ///
  /// In de, this message translates to:
  /// **'SpielerIn'**
  String get player;

  /// No description provided for @hole.
  ///
  /// In de, this message translates to:
  /// **'Bahn'**
  String get hole;

  /// No description provided for @hole_short.
  ///
  /// In de, this message translates to:
  /// **'B.'**
  String get hole_short;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @currversion.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Version'**
  String get currversion;

  /// No description provided for @addPlayer.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get addPlayer;

  /// No description provided for @noPlayerAvailable.
  ///
  /// In de, this message translates to:
  /// **'Kein(e) SpielerIn verfügbar'**
  String get noPlayerAvailable;

  /// No description provided for @addPlayerTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue(r) SpielerIn'**
  String get addPlayerTitle;

  /// No description provided for @clear_hole_score.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get clear_hole_score;

  /// No description provided for @location.
  ///
  /// In de, this message translates to:
  /// **'Oberaustraße 33, A-5072 Wals-Siezenheim'**
  String get location;

  /// No description provided for @location1.
  ///
  /// In de, this message translates to:
  /// **'Oberaustraße 33'**
  String get location1;

  /// No description provided for @location2.
  ///
  /// In de, this message translates to:
  /// **'A-5072 Wals-Siezenheim'**
  String get location2;

  /// No description provided for @phone.
  ///
  /// In de, this message translates to:
  /// **'+43 (0) 662 216217'**
  String get phone;

  /// No description provided for @mail.
  ///
  /// In de, this message translates to:
  /// **'info@soccerpark.at'**
  String get mail;

  /// No description provided for @home.
  ///
  /// In de, this message translates to:
  /// **'www.soccerpark.at'**
  String get home;

  /// No description provided for @copyright.
  ///
  /// In de, this message translates to:
  /// **'Soccerpark Salzburg'**
  String get copyright;

  /// No description provided for @location_wagrain.
  ///
  /// In de, this message translates to:
  /// **'Moadörfl 65, A-5602 Wagrain'**
  String get location_wagrain;

  /// No description provided for @location1_wagrain.
  ///
  /// In de, this message translates to:
  /// **'Moadörfl 65'**
  String get location1_wagrain;

  /// No description provided for @location2_wagrain.
  ///
  /// In de, this message translates to:
  /// **'A-5602 Wagrain'**
  String get location2_wagrain;

  /// No description provided for @phone_wagrain.
  ///
  /// In de, this message translates to:
  /// **'+43 (0) 664 3563004'**
  String get phone_wagrain;

  /// No description provided for @mail_wagrain.
  ///
  /// In de, this message translates to:
  /// **'info@soccerpark-wagrain-kleinarl.at'**
  String get mail_wagrain;

  /// No description provided for @home_wagrain.
  ///
  /// In de, this message translates to:
  /// **'www.soccerpark-wagrain.at'**
  String get home_wagrain;

  /// No description provided for @copyright_wagrain.
  ///
  /// In de, this message translates to:
  /// **'Soccerpark Wagrain-Kleinarl'**
  String get copyright_wagrain;

  /// No description provided for @location_goldberg.
  ///
  /// In de, this message translates to:
  /// **'Weichstettenstraße 119, A-4521 Schiedlberg'**
  String get location_goldberg;

  /// No description provided for @location1_goldberg.
  ///
  /// In de, this message translates to:
  /// **'Weichstettenstraße 119'**
  String get location1_goldberg;

  /// No description provided for @location2_goldberg.
  ///
  /// In de, this message translates to:
  /// **'A-4521 Schiedlberg'**
  String get location2_goldberg;

  /// No description provided for @phone_goldberg.
  ///
  /// In de, this message translates to:
  /// **'+43 (0) 660 1305000'**
  String get phone_goldberg;

  /// No description provided for @mail_goldberg.
  ///
  /// In de, this message translates to:
  /// **'office@soccerpark-goldberg.at'**
  String get mail_goldberg;

  /// No description provided for @home_goldberg.
  ///
  /// In de, this message translates to:
  /// **'www.soccerpark-goldberg.at'**
  String get home_goldberg;

  /// No description provided for @copyright_goldberg.
  ///
  /// In de, this message translates to:
  /// **'Soccerpark Goldberg'**
  String get copyright_goldberg;

  /// No description provided for @switch_error.
  ///
  /// In de, this message translates to:
  /// **'Vor dem Wechseln das aktuelle Spiel beenden!'**
  String get switch_error;

  /// No description provided for @empty_name_error.
  ///
  /// In de, this message translates to:
  /// **'Der Name darf nicht leer sein!'**
  String get empty_name_error;

  /// No description provided for @duplicate_name_error.
  ///
  /// In de, this message translates to:
  /// **'Der Name existiert bereits!'**
  String get duplicate_name_error;

  /// No description provided for @none_selected_error.
  ///
  /// In de, this message translates to:
  /// **'Es muss mindestens ein(e) SpielerIn gewählt werden!'**
  String get none_selected_error;

  /// No description provided for @negative_score_error.
  ///
  /// In de, this message translates to:
  /// **'Eine negative Anzahl von Schlägen ist nicht möglich!'**
  String get negative_score_error;

  /// No description provided for @max_score_error.
  ///
  /// In de, this message translates to:
  /// **'Die maximale Anzahl von Schlägen für dieses Loch ist bereits erreicht!'**
  String get max_score_error;

  /// No description provided for @url_error.
  ///
  /// In de, this message translates to:
  /// **'Die Website kann nicht geöffnet werden.'**
  String get url_error;

  /// No description provided for @sum.
  ///
  /// In de, this message translates to:
  /// **'Summe'**
  String get sum;

  /// No description provided for @sum_short.
  ///
  /// In de, this message translates to:
  /// **'Ges.'**
  String get sum_short;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get share;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @timeline.
  ///
  /// In de, this message translates to:
  /// **'Rundenverlauf'**
  String get timeline;

  /// No description provided for @start.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @cancel_round.
  ///
  /// In de, this message translates to:
  /// **'Runde abbrechen'**
  String get cancel_round;

  /// No description provided for @existing_round.
  ///
  /// In de, this message translates to:
  /// **'Runde existiert'**
  String get existing_round;

  /// No description provided for @ask_cancel_round.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Runde wirklich abbrechen?'**
  String get ask_cancel_round;

  /// No description provided for @finish.
  ///
  /// In de, this message translates to:
  /// **'Rundenende'**
  String get finish;

  /// No description provided for @finish_round.
  ///
  /// In de, this message translates to:
  /// **'Abschließen'**
  String get finish_round;

  /// No description provided for @overview.
  ///
  /// In de, this message translates to:
  /// **'Zur Runde'**
  String get overview;

  /// No description provided for @delete_hist.
  ///
  /// In de, this message translates to:
  /// **'Historie löschen'**
  String get delete_hist;

  /// No description provided for @menu.
  ///
  /// In de, this message translates to:
  /// **'Zum Menü'**
  String get menu;

  /// No description provided for @bus.
  ///
  /// In de, this message translates to:
  /// **'Zum Busplan'**
  String get bus;

  /// No description provided for @description.
  ///
  /// In de, this message translates to:
  /// **'Zur Beschreibung'**
  String get description;

  /// No description provided for @map.
  ///
  /// In de, this message translates to:
  /// **'Zur Karte'**
  String get map;

  /// No description provided for @versionNumber.
  ///
  /// In de, this message translates to:
  /// **'1.0'**
  String get versionNumber;

  /// No description provided for @compare.
  ///
  /// In de, this message translates to:
  /// **'Vergleich mit Par'**
  String get compare;

  /// No description provided for @intermediate.
  ///
  /// In de, this message translates to:
  /// **'Zwischensumme nach 10 Bahnen'**
  String get intermediate;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @started_on.
  ///
  /// In de, this message translates to:
  /// **'Gestartet am'**
  String get started_on;

  /// No description provided for @time_at.
  ///
  /// In de, this message translates to:
  /// **'um'**
  String get time_at;

  /// No description provided for @summary.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung'**
  String get summary;

  /// No description provided for @date.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get date;

  /// No description provided for @time.
  ///
  /// In de, this message translates to:
  /// **'Zeit'**
  String get time;

  /// No description provided for @plan.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get plan;

  /// No description provided for @personal_records.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Rekorde'**
  String get personal_records;

  /// No description provided for @average.
  ///
  /// In de, this message translates to:
  /// **'Durchschnitt'**
  String get average;

  /// No description provided for @trend.
  ///
  /// In de, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @single_rounds.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Runden'**
  String get single_rounds;

  /// No description provided for @rounds.
  ///
  /// In de, this message translates to:
  /// **'Runden'**
  String get rounds;

  /// No description provided for @round_short.
  ///
  /// In de, this message translates to:
  /// **'Runde'**
  String get round_short;

  /// No description provided for @total.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get total;

  /// No description provided for @games.
  ///
  /// In de, this message translates to:
  /// **'Runden'**
  String get games;

  /// No description provided for @game.
  ///
  /// In de, this message translates to:
  /// **'Runde'**
  String get game;

  /// No description provided for @saved_as.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert als'**
  String get saved_as;

  /// No description provided for @single.
  ///
  /// In de, this message translates to:
  /// **'einzeln'**
  String get single;

  /// No description provided for @cumulated.
  ///
  /// In de, this message translates to:
  /// **'kumuliert'**
  String get cumulated;

  /// No description provided for @current_round.
  ///
  /// In de, this message translates to:
  /// **'aktuelle Runde'**
  String get current_round;

  /// No description provided for @comp.
  ///
  /// In de, this message translates to:
  /// **'Vergleich zur vorherigen Runde'**
  String get comp;

  /// No description provided for @on.
  ///
  /// In de, this message translates to:
  /// **'ein'**
  String get on;

  /// No description provided for @off.
  ///
  /// In de, this message translates to:
  /// **'aus'**
  String get off;

  /// No description provided for @venue_salzburg.
  ///
  /// In de, this message translates to:
  /// **'Salzburg'**
  String get venue_salzburg;

  /// No description provided for @venue_wagrain.
  ///
  /// In de, this message translates to:
  /// **'Wagrain'**
  String get venue_wagrain;

  /// No description provided for @venue_goldberg.
  ///
  /// In de, this message translates to:
  /// **'Goldberg'**
  String get venue_goldberg;

  /// No description provided for @choose_park.
  ///
  /// In de, this message translates to:
  /// **'Bitte Soccerpark wählen!'**
  String get choose_park;

  /// No description provided for @choose_remark.
  ///
  /// In de, this message translates to:
  /// **'Die Einstellungen können später im Drop-Down-Menü geändert werden.'**
  String get choose_remark;

  /// No description provided for @delete_hist_question.
  ///
  /// In de, this message translates to:
  /// **'Gelöschte Daten können nicht mehr wiederhergestellt werden. Alle Daten löschen?'**
  String get delete_hist_question;

  /// No description provided for @start_started.
  ///
  /// In de, this message translates to:
  /// **'Es existiert eine nicht abgeschlossene Runde. Beim Starten einer neuen Runde geht diese verloren. Fortfahren?'**
  String get start_started;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @start_new.
  ///
  /// In de, this message translates to:
  /// **'Neue Runde starten'**
  String get start_new;

  /// No description provided for @ask_delete_player.
  ///
  /// In de, this message translates to:
  /// **'SpielerIn löschen?'**
  String get ask_delete_player;

  /// No description provided for @deleted_player.
  ///
  /// In de, this message translates to:
  /// **'SpielerIn wurde gelöscht.'**
  String get deleted_player;

  /// No description provided for @deleted_data.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten wurden gelöscht.'**
  String get deleted_data;

  /// No description provided for @could_not_store.
  ///
  /// In de, this message translates to:
  /// **'Die Datei konnte nicht erstellt werden.'**
  String get could_not_store;

  /// No description provided for @share_text.
  ///
  /// In de, this message translates to:
  /// **'Meine Fußballgolf-Runde im Soccerpark '**
  String get share_text;

  /// No description provided for @share_text_playhole.
  ///
  /// In de, this message translates to:
  /// **'Mein Score auf Bahn'**
  String get share_text_playhole;

  /// No description provided for @share_text_holes.
  ///
  /// In de, this message translates to:
  /// **'Das sind die Bahnen im Soccerpark'**
  String get share_text_holes;

  /// No description provided for @share_text_hole1.
  ///
  /// In de, this message translates to:
  /// **'Das ist die Bahn'**
  String get share_text_hole1;

  /// No description provided for @share_text_hole2.
  ///
  /// In de, this message translates to:
  /// **'im Soccerpark'**
  String get share_text_hole2;

  /// No description provided for @share_text_history.
  ///
  /// In de, this message translates to:
  /// **'Das ist meine Statistik im Soccerpark'**
  String get share_text_history;

  /// No description provided for @share_text_main.
  ///
  /// In de, this message translates to:
  /// **'Ich verwende die Soccerpark-App für den Soccerpark'**
  String get share_text_main;

  /// No description provided for @share_text_venue.
  ///
  /// In de, this message translates to:
  /// **'So findest du zum Soccerpark'**
  String get share_text_venue;

  /// No description provided for @share_text2.
  ///
  /// In de, this message translates to:
  /// **'. Hier geht\'s zur Website: '**
  String get share_text2;

  /// No description provided for @export_rounds.
  ///
  /// In de, this message translates to:
  /// **'Runde(n) wählen'**
  String get export_rounds;

  /// No description provided for @export_pdf.
  ///
  /// In de, this message translates to:
  /// **'PDF exportieren'**
  String get export_pdf;

  /// No description provided for @export_csv.
  ///
  /// In de, this message translates to:
  /// **'CSV exportieren'**
  String get export_csv;

  /// No description provided for @check_rounds.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie die zu exportierenden Runden.'**
  String get check_rounds;

  /// No description provided for @none_chosen_error.
  ///
  /// In de, this message translates to:
  /// **'Keine Runde gewählt!'**
  String get none_chosen_error;

  /// No description provided for @faq_title.
  ///
  /// In de, this message translates to:
  /// **'Wissenswertes über Fußballgolf'**
  String get faq_title;

  /// No description provided for @info1.
  ///
  /// In de, this message translates to:
  /// **'Der Soccerpark vereint die Sportarten Fußball und Golf mit viel Spaß. Hier hat der eine Chance, der taktisch spielt und einen kühlen Kopf behält.'**
  String get info1;

  /// No description provided for @info2.
  ///
  /// In de, this message translates to:
  /// **'Dieser Funsport kommt aus Skandinavien. Vor ca. 15 Jahren wurde dort das erst Mal Fußballgolf gespielt. Inzwischen ist dieser Sport sehr populär – es gibt dort ungefähr 30 Fußballgolf-Anlagen.'**
  String get info2;

  /// No description provided for @info3.
  ///
  /// In de, this message translates to:
  /// **'Im Frühjahr 2006 wurde die erste Anlage in Deutschland eröffnet. Seitdem breitet sich der Sport im ganzen Bundesgebiet aus. Es gibt bis jetzt ca. 20 Anlagen, jedes Jahr kommen neue hinzu.'**
  String get info3;

  /// No description provided for @info4.
  ///
  /// In de, this message translates to:
  /// **'Auf diesen Anlagen werden inzwischen jährlich verschiedene Meisterschaften ausgetragen. Es gibt auch einen Weltverband (\"World Footballgolf Association\"), der jährlich eine Welt- und eine Europameisterschaft austrägt.'**
  String get info4;

  /// No description provided for @info5.
  ///
  /// In de, this message translates to:
  /// **'Unsere Anlage in Salzburg ist die 1. in Österreich.'**
  String get info5;

  /// No description provided for @info6.
  ///
  /// In de, this message translates to:
  /// **'Fußballgolf wird wie Golf auf 18 Bahnen gespielt mit Par 72. Dabei wird ein Ball mit dem Fuß ohne Einsatz eines Schlägers mit möglichst wenigen \"Schlägen\" über verschiedenste Hindernisse bis zum Loch gespielt.'**
  String get info6;

  /// No description provided for @info7.
  ///
  /// In de, this message translates to:
  /// **'Unsere Freiluft-Fußballgolf-Anlage umfasst eine Spielfläche von rund 32.000 qm. Die Bahnen sind zwischen 50 und 175 Meter lang, die Gesamtstrecke aller 18 Bahnen zusammen beträgt ca. 2 km.'**
  String get info7;

  /// No description provided for @info8.
  ///
  /// In de, this message translates to:
  /// **'Es sind rund 1,5 – 2 Stunden Zeit nötig, um diesen außergewöhnlichen Spaß in vollen Zügen zu genießen!'**
  String get info8;

  /// No description provided for @info9.
  ///
  /// In de, this message translates to:
  /// **'Diese neue Fun-Sportart ist ideal für Familien, Firmen, Vereine, Geburtstage, Gruppen oder einfach mit Freunden.'**
  String get info9;

  /// No description provided for @info10.
  ///
  /// In de, this message translates to:
  /// **'Geübte Fußballer sind dabei nicht immer im Vorteil! Auch Profimannschaften zählen auf den vorhandenen Anlagen in Skandinavien und Deutschland seit Jahren zu den Stammkunden.'**
  String get info10;

  /// No description provided for @info11.
  ///
  /// In de, this message translates to:
  /// **'Für Teambuilding-Events ist Fußballgolf bestens geeignet!'**
  String get info11;

  /// No description provided for @orderA1.
  ///
  /// In de, this message translates to:
  /// **'Die Benutzung des Soccerparks erfolgt auf eigene Gefahr.'**
  String get orderA1;

  /// No description provided for @orderA2.
  ///
  /// In de, this message translates to:
  /// **'Angetrunkene Gäste erhalten keinen Zutritt.'**
  String get orderA2;

  /// No description provided for @orderA3.
  ///
  /// In de, this message translates to:
  /// **'Nach der fertig gespielten Runde die Bahnen bitte nicht mehr betreten.'**
  String get orderA3;

  /// No description provided for @orderA4.
  ///
  /// In de, this message translates to:
  /// **'Kinder nur in Begleitung und Beaufsichtigung durch einen Erwachsenen.'**
  String get orderA4;

  /// No description provided for @order1.
  ///
  /// In de, this message translates to:
  /// **'Bitte keine eigenen Speisen und Getränke auf die Anlage mitnehmen.'**
  String get order1;

  /// No description provided for @order2.
  ///
  /// In de, this message translates to:
  /// **'Bitte keine Fußballschuhe mit Stollen anziehen.'**
  String get order2;

  /// No description provided for @order3.
  ///
  /// In de, this message translates to:
  /// **'Bitte die maximale Gruppengröße von 5 Spielern pro Flight einhalten.'**
  String get order3;

  /// No description provided for @order4.
  ///
  /// In de, this message translates to:
  /// **'Bitte kleinere Gruppen überholen lassen.'**
  String get order4;

  /// No description provided for @order5.
  ///
  /// In de, this message translates to:
  /// **'Bitte den Müll in die entsprechenden Behälter geben.'**
  String get order5;

  /// No description provided for @order6.
  ///
  /// In de, this message translates to:
  /// **'Bitte keine Hunde auf den Parcour mitnehmen.'**
  String get order6;

  /// No description provided for @order7.
  ///
  /// In de, this message translates to:
  /// **'Bitte bei Unwetter und Blitzschlag die Anlage sofort verlassen und nicht am Gelände unterstellen.'**
  String get order7;

  /// No description provided for @order8.
  ///
  /// In de, this message translates to:
  /// **'Bitte betretet und verlasst die Anlage nur über den Haupteingang.'**
  String get order8;

  /// No description provided for @order9.
  ///
  /// In de, this message translates to:
  /// **'Bitte keine eigene Soundanlage mitnehmen.'**
  String get order9;

  /// No description provided for @order10.
  ///
  /// In de, this message translates to:
  /// **'Bitte Rücksicht auf Familien und Kinder nehmen.'**
  String get order10;

  /// No description provided for @order11.
  ///
  /// In de, this message translates to:
  /// **'Eltern haften für ihre Kinder und haben Aufsichtspflicht.'**
  String get order11;

  /// No description provided for @rules_title.
  ///
  /// In de, this message translates to:
  /// **'Herzlich willkommen am Soccerpark Salzburg!'**
  String get rules_title;

  /// No description provided for @rules1.
  ///
  /// In de, this message translates to:
  /// **'Um einen fairen Vergleich zu haben, gibt es beim Soccergolf ganz klare Richtlinien und Spielregeln. Natürlich hat zum Schluss immer die Person gewonnen, die am wenigsten Schüsse gebraucht hat.'**
  String get rules1;

  /// No description provided for @rules2.
  ///
  /// In de, this message translates to:
  /// **'Jede Bahn hat eine extra Bahnbeschreibung: eine Bahntafel. Hier sind deutlich der Bahnverlauf und der Abschuss auf der grünen Matte zu sehen. Bevor ihr also eine Bahn spielt, bitte immer diese Bahntafel genau betrachten.'**
  String get rules2;

  /// No description provided for @rules3.
  ///
  /// In de, this message translates to:
  /// **'Die roten Pfeile bei den Hindernissen geben an, in welche Richtung der Ball das Hindernis durchqueren muss. Wenn der Ball am Hindernis aus Versehen vorbei geschossen wird, muss er wieder zurück gespielt werden, um danach das Hindernis in die richtige Richtung durchqueren zu können.'**
  String get rules3;

  /// No description provided for @rules4.
  ///
  /// In de, this message translates to:
  /// **'Der Abschuss erfolgt immer auf der grünen Matte. Der Ball muss auf der weißen Linie oder dahinter platziert werden. Das Ziel ist immer eine Fahne mit verschiedenen Einschusslöchern.'**
  String get rules4;

  /// No description provided for @rules5.
  ///
  /// In de, this message translates to:
  /// **'Liegt der Ball im Rough (rechts oder links neben der Spielbahn) oder in einem Bunker, muss er von dort aus weitergespielt werden. Wird der Ball jedoch auf die Nebenbahn geschossen, ist er im Aus und er muss an die letzte Ausgangsposition zurück gelegt werden, von der aus er gespielt wurde, und es muß ein Strafpunkt dazu gezählt werden.'**
  String get rules5;

  /// No description provided for @rules6.
  ///
  /// In de, this message translates to:
  /// **'Wichtig ist, dass die Spieler einer Gruppe immer zusammen spielen: Jeder aus der Gruppe schießt einmal seinen Ball ab und merkt sich dessen Position. Derjenige, dessen Ball am weitesten vom Ziel entfernt liegt, macht zuerst den zweiten Schuss. Dann machen alle anderen aus der Gruppe in gleicher Reihenfolge weiter. Und so geht es weiter, bis die Bälle im Loch versenkt sind. Wenn der Ball im Loch ist, wird die benötigte Schusszahl auf der Scorecard oder in der App notiert.'**
  String get rules6;

  /// No description provided for @rules7.
  ///
  /// In de, this message translates to:
  /// **'Wenn ein Ball im Weg liegt, kann er entweder gespielt oder mit einem Marker gesichert werden. Wird ein Ball jedoch aus Versehen angeschossen, dann wird der angeschossene Ball zurück gelegt und der andere Ball wird dort liegen gelassen, wo er ausrollt.'**
  String get rules7;

  /// No description provided for @rules8.
  ///
  /// In de, this message translates to:
  /// **'Die maximale Schusszahl errechnet sich aus der Parvorgabe. Diese steht auf jeder Bahntafel, auf der Scorecard und in dieser App. Die maximale Schusszahl ist immer das Zweifache der Parvorgabe. Zum Beispiel muss auf einer Par-3-Bahn der Ball spätestens mit dem 6. Schuß im Zielloch liegen. Sollte das nicht der Fall sein, muss ein Strafpunkt dazugerechnet werden, d. h. man muss 7 Schüsse aufschreiben. Auf der Anlage gibt es Par-3-, Par-4-, Par-5 und Par-6-Bahnen.'**
  String get rules8;

  /// No description provided for @rules9.
  ///
  /// In de, this message translates to:
  /// **'Auf Bahn 9 gibt es ein Wasserhindernis. Aus Sicherheitsgründen ist das Betreten des Wassers strengstens verboten. Bälle, die sich im Wasser befinden, können mit dem Kescher herausgeholt werden. Die Sonderregelung findet ihr auf der Bahntafel.'**
  String get rules9;

  /// No description provided for @rules10.
  ///
  /// In de, this message translates to:
  /// **'Unsere Toiletten befinden sich am Ende des Gebäudes und sind ausgeschildert. Großen Wert legen wir auf Ordnung und Sauberkeit und wir bitten euch, Müll in den entsprechenden Behältern zu entsorgen.'**
  String get rules10;

  /// No description provided for @rules11.
  ///
  /// In de, this message translates to:
  /// **'Feierrunden bitten wir natürlich, auf der gesamten Anlage Rücksicht auf andere Gäste zu nehmen, vor allem auf Familien und Kinder. Bitte auch keine Soundanlagen am Gelände benutzen!'**
  String get rules11;

  /// No description provided for @rules12.
  ///
  /// In de, this message translates to:
  /// **'Aus Fairplay-Gründen und um größere Staus zu vermeiden, lassen größere Gruppen kleinere Gruppen überholen. Die ideale und maximale Gruppengröße beträgt 4-5 Personen!'**
  String get rules12;

  /// No description provided for @rules13.
  ///
  /// In de, this message translates to:
  /// **'Ein spezieller Hinweis für Kindergeburtstagsfeiern: Eltern haben die Aufsichtspflicht für Ihre Kinder!'**
  String get rules13;

  /// No description provided for @rules14.
  ///
  /// In de, this message translates to:
  /// **'Wenn eine Bahn fertig gespielt ist, bitte diese zügig verlassen! Nach Beendigung der 18 Bahnen bitte gleich die Bälle immer gruppenweise an der Kasse zurückgeben! Gerne könnt Ihr natürlich eine 2. Runde oder Tageskarte bei uns zum ermäßigten Preis lösen.'**
  String get rules14;

  /// No description provided for @rules15.
  ///
  /// In de, this message translates to:
  /// **'Wir versorgen euch gerne mit kühlen Getränken, Eis und Kleinigkeiten zum Essen. Bitte keine eigenen Speisen und Getränke auf die Anlage mitnehmen!'**
  String get rules15;

  /// No description provided for @rules16.
  ///
  /// In de, this message translates to:
  /// **'Als besonderen Service bieten wir euch kostenloses WLAN. Hat es euch bei uns gefallen, würden wir uns über positives Feedback sehr freuen!'**
  String get rules16;

  /// No description provided for @rules17.
  ///
  /// In de, this message translates to:
  /// **'Geschenkgutscheine für jeden Anlass erhaltet Ihr an der Kasse. Habt Ihr noch Fragen oder Wünsche, dann kommt doch einfach zu uns - wir helfen euch gerne weiter!'**
  String get rules17;

  /// No description provided for @rules_wagrain_title.
  ///
  /// In de, this message translates to:
  /// **'Herzlich willkommen am Soccerpark Wagrain-Kleinarl!'**
  String get rules_wagrain_title;

  /// No description provided for @rules_wagrain_8.
  ///
  /// In de, this message translates to:
  /// **'Die maximale Schusszahl errechnet sich aus der Parvorgabe. Diese steht auf jeder Bahntafel, auf der Scorecard und in dieser App. Die maximale Schusszahl ist immer das Zweifache der Parvorgabe. Zum Beispiel muss auf einer Par-3-Bahn der Ball spätestens mit dem 6. Schuß im Zielloch liegen. Sollte das nicht der Fall sein, muss ein Strafpunkt dazugerechnet werden, d. h. man muss 7 Schüsse aufschreiben. Auf der Anlage gibt es Par-3-, Par-4- und Par-5-Bahnen.'**
  String get rules_wagrain_8;

  /// No description provided for @rules_wagrain_10.
  ///
  /// In de, this message translates to:
  /// **'Unsere Toiletten befinden sich im Kassengebäude und sind ausgeschildert. Großen Wert legen wir auf Ordnung und Sauberkeit und wir bitten euch, Müll in den entsprechenden Behältern zu entsorgen.'**
  String get rules_wagrain_10;

  /// No description provided for @rules_goldberg_title.
  ///
  /// In de, this message translates to:
  /// **'Herzlich willkommen am Soccerpark Goldberg!'**
  String get rules_goldberg_title;

  /// No description provided for @rules_goldberg_1.
  ///
  /// In de, this message translates to:
  /// **'Anleitung folgt!'**
  String get rules_goldberg_1;

  /// No description provided for @question1.
  ///
  /// In de, this message translates to:
  /// **'Ab welchem Alter kann man Fußballgolf spielen?'**
  String get question1;

  /// No description provided for @question2.
  ///
  /// In de, this message translates to:
  /// **'Was muss ich zum Fußballgolf mitbringen?'**
  String get question2;

  /// No description provided for @question3.
  ///
  /// In de, this message translates to:
  /// **'Wie lange ist die Wartezeit an den Bahnen?'**
  String get question3;

  /// No description provided for @question4.
  ///
  /// In de, this message translates to:
  /// **'Wie lange dauert eine Runde Fußballgolf?'**
  String get question4;

  /// No description provided for @question5.
  ///
  /// In de, this message translates to:
  /// **'Brauche ich Vorkenntnisse im Fußballgolfen?'**
  String get question5;

  /// No description provided for @question6.
  ///
  /// In de, this message translates to:
  /// **'Kann man reservieren?'**
  String get question6;

  /// No description provided for @question7.
  ///
  /// In de, this message translates to:
  /// **'Was machen wir bei schlechter Wetterprognose mit unserer Reservierung?'**
  String get question7;

  /// No description provided for @question8.
  ///
  /// In de, this message translates to:
  /// **'Ist die Aufteilung einer größeren Gruppe in mehrere kleine Gruppen nötig?'**
  String get question8;

  /// No description provided for @question9.
  ///
  /// In de, this message translates to:
  /// **'Darf man Verpflegung (Essen, Getränke) auf die Anlage mitnehmen?'**
  String get question9;

  /// No description provided for @question10.
  ///
  /// In de, this message translates to:
  /// **'Muss ich mich umziehen oder spezielle Kleidung tragen?'**
  String get question10;

  /// No description provided for @question11.
  ///
  /// In de, this message translates to:
  /// **'Wie komme ich an die aktuellsten Termine und Neuigkeiten rund um den Soccerpark und Fußballgolf?'**
  String get question11;

  /// No description provided for @question12.
  ///
  /// In de, this message translates to:
  /// **'Dürfen Hunde mit?'**
  String get question12;

  /// No description provided for @question13.
  ///
  /// In de, this message translates to:
  /// **'Gibt es auch Geschenk-Gutscheine?'**
  String get question13;

  /// No description provided for @question14.
  ///
  /// In de, this message translates to:
  /// **'Sind Feste, Feiern und Events möglich?'**
  String get question14;

  /// No description provided for @answer1.
  ///
  /// In de, this message translates to:
  /// **'Fußballgolf kann ab 6 Jahren bis ins hohe Alter gespielt werden.'**
  String get answer1;

  /// No description provided for @answer2.
  ///
  /// In de, this message translates to:
  /// **'Gute Laune und Sportschuhe (Achtung: keine Noppen oder Stollenschuhe). Die Bälle könnt ihr gegen ein Pfand ausleihen - eigene Bälle können gerne mitgebracht werden!'**
  String get answer2;

  /// No description provided for @answer3.
  ///
  /// In de, this message translates to:
  /// **'Wartezeiten sind möglich. Es gilt die sportliche Regel, dass größere Gruppen kleinere Gruppen überholen lassen!'**
  String get answer3;

  /// No description provided for @answer4.
  ///
  /// In de, this message translates to:
  /// **'Für 18 Bahnen braucht ein Durchschnittsspieler ca. 2 Stunden.'**
  String get answer4;

  /// No description provided for @answer5.
  ///
  /// In de, this message translates to:
  /// **'Nein. Du bekommst von uns beim Start eine Einweisung, bei der alle Fragen beantwortet werden.'**
  String get answer5;

  /// No description provided for @answer6.
  ///
  /// In de, this message translates to:
  /// **'Eine Reservierung ist für Polterrunden und Gruppen ab 10 Personen notwendig! So können wir besser planen und gemeinsam mit euch einen passenden Termin bzw. eine Startzeit vereinbaren.'**
  String get answer6;

  /// No description provided for @answer7.
  ///
  /// In de, this message translates to:
  /// **'Wenn die Wettervorhersage nur leichten Regen meldet, ist Fußballgolf kein Problem. Nur bei sicherer Schlechtwettervorhersage oder Unwetterwarnung bitten wir um telefonische Absprache.'**
  String get answer7;

  /// No description provided for @answer8.
  ///
  /// In de, this message translates to:
  /// **'Ja. Eine Gruppe besteht aus max. 5 Personen, die parallel an verschiedenen Bahnen starten können (Kanonenstart). Als Kanonenstart bezeichnet man den Modus, wenn bei einer Spielrunde alle Teilnehmer zur gleichen Startzeit, jedoch an verschieden Bahnen loslegen - dadurch werden unnötige Wartezeiten vermieden!'**
  String get answer8;

  /// No description provided for @answer9.
  ///
  /// In de, this message translates to:
  /// **'Es dürfen keine eigenen Speisen und Getränke auf die Anlage mitgebracht werden. Am Kiosk erhaltet Ihr Getränke, Eis und Kleinigkeiten zum Essen, diese können gerne mitgenommen werden.'**
  String get answer9;

  /// No description provided for @answer10.
  ///
  /// In de, this message translates to:
  /// **'Nein, es kann mit normaler, sportlicher Kleidung gespielt werden. Schuhreinigung möglich!'**
  String get answer10;

  /// No description provided for @answer11.
  ///
  /// In de, this message translates to:
  /// **'Hier empfiehlt es sich, regelmäßig unsere stets aktualisierte Facebook-Seite zu besuchen.'**
  String get answer11;

  /// No description provided for @answer12.
  ///
  /// In de, this message translates to:
  /// **'Nein, Hunde dürfen nicht auf die Fußballgolfanlage mitgenommen werden. Am Kiosk dürfen sie nur angeleint warten.'**
  String get answer12;

  /// No description provided for @answer13.
  ///
  /// In de, this message translates to:
  /// **'Ja, an der Kasse oder auf der Website.'**
  String get answer13;

  /// No description provided for @answer14.
  ///
  /// In de, this message translates to:
  /// **'Auf unserer Anlage hast du alle Möglichkeiten! Sprich uns am besten rechtzeitig an, dann können wir bei der Planung auf deine speziellen Wünsche gerne eingehen. Sonderwünsche für euren Event können wir gerne besprechen.'**
  String get answer14;

  /// No description provided for @holeAddSbg_1_1.
  ///
  /// In de, this message translates to:
  /// **'3 Steinblöcke'**
  String get holeAddSbg_1_1;

  /// No description provided for @holeAddSbg_1_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 10x5m'**
  String get holeAddSbg_1_2;

  /// No description provided for @holeAddSbg_2_1.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm stehend'**
  String get holeAddSbg_2_1;

  /// No description provided for @holeAddSbg_2_2.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm liegend, innen hohl'**
  String get holeAddSbg_2_2;

  /// No description provided for @holeAddSbg_2_3.
  ///
  /// In de, this message translates to:
  /// **'1 Steinblock'**
  String get holeAddSbg_2_3;

  /// No description provided for @holeAddSbg_2_4.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca 10x4m'**
  String get holeAddSbg_2_4;

  /// No description provided for @holeAddSbg_2_5.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca 8x4m'**
  String get holeAddSbg_2_5;

  /// No description provided for @holeAddSbg_3_1.
  ///
  /// In de, this message translates to:
  /// **'3 Steinblöcke'**
  String get holeAddSbg_3_1;

  /// No description provided for @holeAddSbg_3_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker 9x5m'**
  String get holeAddSbg_3_2;

  /// No description provided for @holeAddSbg_3_3.
  ///
  /// In de, this message translates to:
  /// **'1 Betonring'**
  String get holeAddSbg_3_3;

  /// No description provided for @holeAddSbg_4_1.
  ///
  /// In de, this message translates to:
  /// **'1 Steinblock'**
  String get holeAddSbg_4_1;

  /// No description provided for @holeAddSbg_4_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker 5x4m'**
  String get holeAddSbg_4_2;

  /// No description provided for @holeAddSbg_5_1.
  ///
  /// In de, this message translates to:
  /// **'4 Holzstämme hoch liegend'**
  String get holeAddSbg_5_1;

  /// No description provided for @holeAddSbg_5_2.
  ///
  /// In de, this message translates to:
  /// **'2 Steinblöcke'**
  String get holeAddSbg_5_2;

  /// No description provided for @holeAddSbg_5_3.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm liegend'**
  String get holeAddSbg_5_3;

  /// No description provided for @holeAddSbg_5_4.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 9x4m'**
  String get holeAddSbg_5_4;

  /// No description provided for @holeAddSbg_6_1.
  ///
  /// In de, this message translates to:
  /// **'4 Steinblöcke'**
  String get holeAddSbg_6_1;

  /// No description provided for @holeAddSbg_6_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 7x2m'**
  String get holeAddSbg_6_2;

  /// No description provided for @holeAddSbg_6_3.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 8x5m'**
  String get holeAddSbg_6_3;

  /// No description provided for @holeAddSbg_7_1.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm liegend'**
  String get holeAddSbg_7_1;

  /// No description provided for @holeAddSbg_7_2.
  ///
  /// In de, this message translates to:
  /// **'3 Steinblöcke'**
  String get holeAddSbg_7_2;

  /// No description provided for @holeAddSbg_7_3.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 10x4m'**
  String get holeAddSbg_7_3;

  /// No description provided for @holeAddSbg_8_1.
  ///
  /// In de, this message translates to:
  /// **'2 Reifen stehend'**
  String get holeAddSbg_8_1;

  /// No description provided for @holeAddSbg_8_2.
  ///
  /// In de, this message translates to:
  /// **'1 Betonkonus'**
  String get holeAddSbg_8_2;

  /// No description provided for @holeAddSbg_9_1.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm stehend'**
  String get holeAddSbg_9_1;

  /// No description provided for @holeAddSbg_9_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 10x5m'**
  String get holeAddSbg_9_2;

  /// No description provided for @holeAddSbg_9_3.
  ///
  /// In de, this message translates to:
  /// **'2 Steinblöcke'**
  String get holeAddSbg_9_3;

  /// No description provided for @holeAddSbg_10_1.
  ///
  /// In de, this message translates to:
  /// **'1 Steinblock'**
  String get holeAddSbg_10_1;

  /// No description provided for @holeAddSbg_10_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 12x4m'**
  String get holeAddSbg_10_2;

  /// No description provided for @holeAddSbg_10_3.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm liegend'**
  String get holeAddSbg_10_3;

  /// No description provided for @holeAddSbg_10_4.
  ///
  /// In de, this message translates to:
  /// **'1 Wurzel'**
  String get holeAddSbg_10_4;

  /// No description provided for @holeAddSbg_11_1.
  ///
  /// In de, this message translates to:
  /// **'2 Steinblöcke'**
  String get holeAddSbg_11_1;

  /// No description provided for @holeAddSbg_11_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 12x4m'**
  String get holeAddSbg_11_2;

  /// No description provided for @holeAddSbg_11_3.
  ///
  /// In de, this message translates to:
  /// **'1 Zweierbob als Zielloch'**
  String get holeAddSbg_11_3;

  /// No description provided for @holeAddSbg_12_1.
  ///
  /// In de, this message translates to:
  /// **'4 Zäune 3x1,5m'**
  String get holeAddSbg_12_1;

  /// No description provided for @holeAddSbg_12_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 12x4m'**
  String get holeAddSbg_12_2;

  /// No description provided for @holeAddSbg_12_3.
  ///
  /// In de, this message translates to:
  /// **'1 Hügel'**
  String get holeAddSbg_12_3;

  /// No description provided for @holeAddSbg_12_4.
  ///
  /// In de, this message translates to:
  /// **'2 Steinblöcke'**
  String get holeAddSbg_12_4;

  /// No description provided for @holeAddSbg_13_1.
  ///
  /// In de, this message translates to:
  /// **'3 Steinblöcke'**
  String get holeAddSbg_13_1;

  /// No description provided for @holeAddSbg_13_2.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm stehend'**
  String get holeAddSbg_13_2;

  /// No description provided for @holeAddSbg_14_1.
  ///
  /// In de, this message translates to:
  /// **'2 Steinblöcke'**
  String get holeAddSbg_14_1;

  /// No description provided for @holeAddSbg_14_2.
  ///
  /// In de, this message translates to:
  /// **'2 Sandbunker ca. 10x4m'**
  String get holeAddSbg_14_2;

  /// No description provided for @holeAddSbg_15_1.
  ///
  /// In de, this message translates to:
  /// **'6 Holzstämme stehend'**
  String get holeAddSbg_15_1;

  /// No description provided for @holeAddSbg_15_2.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 12x2m'**
  String get holeAddSbg_15_2;

  /// No description provided for @holeAddSbg_16_1.
  ///
  /// In de, this message translates to:
  /// **'2 Bodenwellen'**
  String get holeAddSbg_16_1;

  /// No description provided for @holeAddSbg_16_2.
  ///
  /// In de, this message translates to:
  /// **'1 Steinblock'**
  String get holeAddSbg_16_2;

  /// No description provided for @holeAddSbg_16_3.
  ///
  /// In de, this message translates to:
  /// **'1 Metallring mit Tornetz'**
  String get holeAddSbg_16_3;

  /// No description provided for @holeAddSbg_17_1.
  ///
  /// In de, this message translates to:
  /// **'1 Holzstamm stehend'**
  String get holeAddSbg_17_1;

  /// No description provided for @holeAddSbg_17_2.
  ///
  /// In de, this message translates to:
  /// **'1 Steinblock'**
  String get holeAddSbg_17_2;

  /// No description provided for @holeAddSbg_17_3.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 7x4m'**
  String get holeAddSbg_17_3;

  /// No description provided for @holeAddSbg_17_4.
  ///
  /// In de, this message translates to:
  /// **'1 Holzwand zum Durchschießen'**
  String get holeAddSbg_17_4;

  /// No description provided for @holeAddSbg_17_5.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 25x2m'**
  String get holeAddSbg_17_5;

  /// No description provided for @holeAddSbg_18_1.
  ///
  /// In de, this message translates to:
  /// **'1 Sandbunker ca. 12x6m'**
  String get holeAddSbg_18_1;

  /// No description provided for @holeAddSbg_18_2.
  ///
  /// In de, this message translates to:
  /// **'1 Vulkan'**
  String get holeAddSbg_18_2;

  /// No description provided for @online_highscores.
  ///
  /// In de, this message translates to:
  /// **'Online (Monat)'**
  String get online_highscores;

  /// No description provided for @online_hs_title.
  ///
  /// In de, this message translates to:
  /// **'Monats-Highscore!'**
  String get online_hs_title;

  /// No description provided for @online_hs_text.
  ///
  /// In de, this message translates to:
  /// **'{name} schafft mit {score} Schlägen Platz {rank} der Monatsbestenliste {locality}. Unter welchem Namen soll der Eintrag öffentlich angezeigt werden?'**
  String online_hs_text(String name, int score, int rank, String locality);

  /// No description provided for @online_hs_name_label.
  ///
  /// In de, this message translates to:
  /// **'Anzeigename'**
  String get online_hs_name_label;

  /// No description provided for @online_hs_name_invalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte 2 bis 20 Zeichen eingeben.'**
  String get online_hs_name_invalid;

  /// No description provided for @online_hs_submit.
  ///
  /// In de, this message translates to:
  /// **'Eintragen'**
  String get online_hs_submit;

  /// No description provided for @online_hs_skip.
  ///
  /// In de, this message translates to:
  /// **'Nicht eintragen'**
  String get online_hs_skip;

  /// No description provided for @online_hs_saved.
  ///
  /// In de, this message translates to:
  /// **'In die Monatsbestenliste eingetragen!'**
  String get online_hs_saved;

  /// No description provided for @online_hs_too_late.
  ///
  /// In de, this message translates to:
  /// **'Leider war jemand schneller: Die Runde reicht nicht mehr für die Top 10.'**
  String get online_hs_too_late;

  /// No description provided for @online_hs_error.
  ///
  /// In de, this message translates to:
  /// **'Eintragen fehlgeschlagen. Bitte Internetverbindung prüfen.'**
  String get online_hs_error;

  /// No description provided for @online_hs_load_error.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste konnte nicht geladen werden. Bitte Internetverbindung prüfen.'**
  String get online_hs_load_error;

  /// No description provided for @online_hs_empty.
  ///
  /// In de, this message translates to:
  /// **'In diesem Monat gibt es noch keine Einträge.'**
  String get online_hs_empty;

  /// No description provided for @leaderboards.
  ///
  /// In de, this message translates to:
  /// **'Bestenlisten'**
  String get leaderboards;

  /// No description provided for @best_score.
  ///
  /// In de, this message translates to:
  /// **'Bestwert'**
  String get best_score;

  /// No description provided for @last_round.
  ///
  /// In de, this message translates to:
  /// **'Letzte Runde'**
  String get last_round;

  /// No description provided for @no_entries.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge.'**
  String get no_entries;

  /// No description provided for @continue_round.
  ///
  /// In de, this message translates to:
  /// **'Runde fortsetzen'**
  String get continue_round;

  /// No description provided for @round_progress.
  ///
  /// In de, this message translates to:
  /// **'{players} Spieler · {holes} von 18 Bahnen gespielt'**
  String round_progress(int players, int holes);

  /// No description provided for @order_important.
  ///
  /// In de, this message translates to:
  /// **'Wichtig'**
  String get order_important;

  /// No description provided for @order_notes.
  ///
  /// In de, this message translates to:
  /// **'Bitte beachten'**
  String get order_notes;

  /// No description provided for @contact_call.
  ///
  /// In de, this message translates to:
  /// **'Anrufen'**
  String get contact_call;

  /// No description provided for @contact_route.
  ///
  /// In de, this message translates to:
  /// **'Route'**
  String get contact_route;

  /// No description provided for @contact_mail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get contact_mail;

  /// No description provided for @contact_web.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get contact_web;

  /// No description provided for @rules_section_game.
  ///
  /// In de, this message translates to:
  /// **'Spielregeln'**
  String get rules_section_game;

  /// No description provided for @rules_section_info.
  ///
  /// In de, this message translates to:
  /// **'Gut zu wissen'**
  String get rules_section_info;

  /// No description provided for @rules_t1.
  ///
  /// In de, this message translates to:
  /// **'Grundprinzip'**
  String get rules_t1;

  /// No description provided for @rules_t2.
  ///
  /// In de, this message translates to:
  /// **'Bahntafel'**
  String get rules_t2;

  /// No description provided for @rules_t3.
  ///
  /// In de, this message translates to:
  /// **'Rote Pfeile'**
  String get rules_t3;

  /// No description provided for @rules_t4.
  ///
  /// In de, this message translates to:
  /// **'Abschuss'**
  String get rules_t4;

  /// No description provided for @rules_t5.
  ///
  /// In de, this message translates to:
  /// **'Rough, Bunker und Aus'**
  String get rules_t5;

  /// No description provided for @rules_t6.
  ///
  /// In de, this message translates to:
  /// **'Spielreihenfolge'**
  String get rules_t6;

  /// No description provided for @rules_t7.
  ///
  /// In de, this message translates to:
  /// **'Ball im Weg'**
  String get rules_t7;

  /// No description provided for @rules_t8.
  ///
  /// In de, this message translates to:
  /// **'Maximale Schusszahl'**
  String get rules_t8;

  /// No description provided for @rules_t9.
  ///
  /// In de, this message translates to:
  /// **'Wasserhindernis'**
  String get rules_t9;

  /// No description provided for @rules_max_hint.
  ///
  /// In de, this message translates to:
  /// **'Höchstens 2 × Par – sonst 2 × Par + 1 aufschreiben'**
  String get rules_max_hint;

  /// No description provided for @rules_t10.
  ///
  /// In de, this message translates to:
  /// **'Toiletten'**
  String get rules_t10;

  /// No description provided for @rules_t11.
  ///
  /// In de, this message translates to:
  /// **'Rücksicht'**
  String get rules_t11;

  /// No description provided for @rules_t12.
  ///
  /// In de, this message translates to:
  /// **'Überholen lassen'**
  String get rules_t12;

  /// No description provided for @rules_t13.
  ///
  /// In de, this message translates to:
  /// **'Kindergeburtstage'**
  String get rules_t13;

  /// No description provided for @rules_t14.
  ///
  /// In de, this message translates to:
  /// **'Nach der Runde'**
  String get rules_t14;

  /// No description provided for @rules_t15.
  ///
  /// In de, this message translates to:
  /// **'Getränke und Snacks'**
  String get rules_t15;

  /// No description provided for @rules_t16.
  ///
  /// In de, this message translates to:
  /// **'WLAN und Feedback'**
  String get rules_t16;

  /// No description provided for @rules_t17.
  ///
  /// In de, this message translates to:
  /// **'Gutscheine und Fragen'**
  String get rules_t17;

  /// No description provided for @contact_address_label.
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get contact_address_label;

  /// No description provided for @contact_phone_label.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get contact_phone_label;

  /// No description provided for @contact_copy_hint.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Lange drücken kopiert Adresse, Nummer oder Link.'**
  String get contact_copy_hint;

  /// No description provided for @copied.
  ///
  /// In de, this message translates to:
  /// **'In die Zwischenablage kopiert'**
  String get copied;

  /// No description provided for @about.
  ///
  /// In de, this message translates to:
  /// **'Über die App'**
  String get about;

  /// No description provided for @whats_new.
  ///
  /// In de, this message translates to:
  /// **'Was ist neu'**
  String get whats_new;

  /// No description provided for @feedback_title.
  ///
  /// In de, this message translates to:
  /// **'Feedback'**
  String get feedback_title;

  /// No description provided for @rate_app.
  ///
  /// In de, this message translates to:
  /// **'App bewerten'**
  String get rate_app;

  /// No description provided for @report_bug.
  ///
  /// In de, this message translates to:
  /// **'Fehler melden'**
  String get report_bug;

  /// No description provided for @legal_title.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get legal_title;

  /// No description provided for @privacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get privacy;

  /// No description provided for @licenses.
  ///
  /// In de, this message translates to:
  /// **'Open-Source-Lizenzen'**
  String get licenses;

  /// No description provided for @venue_route.
  ///
  /// In de, this message translates to:
  /// **'Route starten'**
  String get venue_route;

  /// No description provided for @venue_route_sub.
  ///
  /// In de, this message translates to:
  /// **'Navigation zur Anlage öffnen'**
  String get venue_route_sub;

  /// No description provided for @venue_map_title.
  ///
  /// In de, this message translates to:
  /// **'Anfahrtsplan'**
  String get venue_map_title;

  /// No description provided for @venue_transit.
  ///
  /// In de, this message translates to:
  /// **'Mit Bus und Bahn'**
  String get venue_transit;

  /// No description provided for @venue_transit_sub.
  ///
  /// In de, this message translates to:
  /// **'Fahrplanauskunft'**
  String get venue_transit_sub;

  /// No description provided for @venue_description.
  ///
  /// In de, this message translates to:
  /// **'Wegbeschreibung'**
  String get venue_description;

  /// No description provided for @venue_description_sub.
  ///
  /// In de, this message translates to:
  /// **'Ausführlich auf der Website'**
  String get venue_description_sub;
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
      'that was used.');
}
