import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/firebase_options.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/utils/firebase.dart';

import 'utils/data.dart';
import 'pages/mainpage.dart';
import 'pages/languagesplashpage.dart';

const Color maincolor = const Color(0xFF005005);
const Color mainvariant = const Color(0xFF003300);
const int mainredValue = 0xFF7F0000;
final Color mainred = Color(mainredValue);
final Color mainyellow = Color(0xFFF1C40F);
final Color mainblue = Color(0xFF34495E);
final Color mainviolet = Color(0xFF8E44Ad);
final Color mainorange = Color(0xFFFF8800);
final Color mainturquoise = Color(0xFF08E8DE);
final Color maingrey = Colors.grey;
final Color mainpink = Color(0xFFEC3B83);
final Color bgcolor = Colors.grey[50]!;

final List<Color> colors = [
  maincolor,
  mainred,
  mainyellow,
  mainblue,
  mainviolet,
  mainorange,
  mainturquoise,
  maingrey,
  mainpink
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase (push notifications) is only configured for Android/iOS.
  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    listenForForegroundNotifications();
  }
  runApp(App());
}

class App extends StatefulWidget {
  //MaterialColor primary = generateMaterialColor(color: Color(0xFF005005));

  const App({super.key});

  @override
  State<App> createState() => _AppState();

  static _AppState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()!;
}

class _AppState extends State<App> {
  Locale _locale = Locale.fromSubtags(languageCode: 'de');
  bool _compare = false;
  bool _intermediate = true;
  Locality _locality = Locality.SALZBURG;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    loadSettings();
  }

  void loadSettings() {
    Data.isEnglish().then((english) {
      setState(() {
        _locale = Locale.fromSubtags(languageCode: english ? 'en' : 'de');
      });
      updateNotificationLanguage(english);
    });

    Data.getLocality().then((loc) => setState(() {
          _locality = loc;
        }));
    Data.isCompare().then((comp) => setState(() {
          _compare = comp;
        }));
    Data.isIntermediate().then((interm) => setState(() {
          _intermediate = interm;
        }));
  }

  Locality getLocality() {
    return _locality;
  }

  void setLocality(Locality loc) {
    _locality = loc;
    Data.setLocality(loc);
  }

  bool isCompare() {
    return _compare;
  }

  void setCompare(bool comp) {
    _compare = comp;
    Data.setCompare(comp);
  }

  bool isIntermediate() {
    return _intermediate;
  }

  void setIntermediate(bool interm) {
    // NOTE: Intermediate is always true!
    _intermediate = true;
    Data.setIntermediate(interm);
  }

  bool isEnglish() {
    return _locale == Locale.fromSubtags(languageCode: 'en');
  }

  void setLocale(bool english) {
    setLocaleImpl(Locale.fromSubtags(languageCode: english ? 'en' : 'de'));
    Data.setLanguage(english);
    updateNotificationLanguage(english);
  }

  void setLocaleImpl(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soccerpark',
      scaffoldMessengerKey: messengerKey,
      locale: _locale,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(color: maincolor),
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: StartPage(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final data = snapshot.data as bool;
            if (data) return const MainPage();

            return const LanguageSplashPage();
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: Data.isInitChosen());
  }
}
