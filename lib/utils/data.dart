import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Highscore {
  Highscore(this.playerIndex, this.score, this.date, {this.holes});
  int playerIndex;
  int score;
  String date;

  /// Schläge pro Loch (18 Werte), nur bei Gesamt-Highscores.
  /// Fehlt bei Einträgen, die vor dieser Erweiterung gespeichert wurden.
  List<int>? holes;

  Map<String, dynamic> toJson() => {
        'playerIndex': playerIndex,
        'score': score,
        'date': date,
        if (holes != null) 'holes': holes,
      };

  static Highscore fromJson(Map<String, dynamic> json) {
    List<int>? holes;
    final h = json['holes'];
    if (h is List && h.length == 18) {
      holes = h.map((e) => (e as num).toInt()).toList();
    }
    return Highscore(json['playerIndex'], json['score'], json['date'],
        holes: holes);
  }
}

class NamedHighscore {
  NamedHighscore(this.name, this.score, this.date, {this.holes});
  String name;
  int score;
  String date;
  List<int>? holes;
}

enum Locality { SALZBURG, WAGRAIN, GOLDBERG }

class PointPair {
  final int x;
  final double y;

  PointPair(this.x, this.y);
}

class Sum {
  Sum(this.playerIndex);
  static Sum fullSum(int playerIndex, int games, List<int> sums) {
    Sum s = Sum(playerIndex);
    s.games = games;
    s.sums = sums;
    return s;
  }

  int playerIndex;
  int games = 1;
  List<int> sums = <int>[];

  Map<String, dynamic> toJson() => {
        'playerIndex': playerIndex,
        'games': games,
        'sums': sums,
      };

  static List<int> getList(List<dynamic> l) {
    List<int> s = [];
    for (var i = 0; i < l.length; i++) s.add(l[i].toInt());
    return s;
  }

  static Sum fromJson(Map<String, dynamic> json) {
    //print("json " + json['sums']);
    return fullSum(json['playerIndex'], json['games'], getList(json['sums']));
  }
}

class PlayerPair {
  int id;
  String name;

  PlayerPair(this.id, this.name);
}

class Average {
  Average(this.name, this.avg, this.games);
  String name;
  double avg;
  int games;
}

class RoundData {
  RoundData(this.loc, this.names, this.scores);

  Locality loc;
  List<String> names;
  List<List<int>> scores;
}

class Data {
  static int STORED_ROUNDS = 10;
  static int MAX_PLAYER_CNT = 5;
  static int STORED_HIGHSCORES = 10;

  static String getFilenamePrefix(Locality loc) {
    String s = "soccerpark_";
    if (loc == Locality.SALZBURG) return s + 'salzburg_';
    if (loc == Locality.WAGRAIN) return s + 'wagrain_';
    return s + 'goldberg_';
  }

  static String getLocalityImageString(Locality loc) {
    if (loc == Locality.SALZBURG) return 'assets/pics/soccer.png';
    if (loc == Locality.WAGRAIN) return 'assets/pics/soccer_wagrain.png';
    return 'assets/pics/soccer_goldberg.png';
  }

  static String getLocalityGreyString(Locality loc) {
    if (loc == Locality.SALZBURG) return 'assets/pics/greyscale.png';
    if (loc == Locality.WAGRAIN) return 'assets/pics/greyscale_wagrain.png';
    return 'assets/pics/greyscale_goldberg.png';
  }

  static String getSoccerPicString(Locality loc) {
    if (loc == Locality.SALZBURG) return 'assets/pics/soccer_pic.jpg';
    if (loc == Locality.WAGRAIN) return 'assets/pics/soccer_pic_wagrain.jpg';
    return 'assets/pics/soccer_pic_goldberg.jpg';
  }

  static var parsSalzburg = <int>[
    3,
    4,
    3,
    4,
    6,
    3,
    5,
    4,
    3,
    5,
    4,
    5,
    3,
    4,
    4,
    4,
    5,
    3
  ];
  static var parsWagrain = <int>[
    3,
    4,
    4,
    3,
    4,
    5,
    5,
    4,
    4,
    3,
    5,
    4,
    3,
    3,
    5,
    5,
    4,
    4
  ];
  static var parsGoldberg = <int>[
    3,
    3,
    3,
    5,
    3,
    5,
    4,
    5,
    3,
    4,
    4,
    5,
    3,
    5,
    3,
    5,
    6,
    3
  ];

  static var lensSalzburg = <int>[
    85,
    115,
    80,
    90,
    170,
    70,
    135,
    65,
    75,
    105,
    100,
    135,
    80,
    95,
    90,
    110,
    140,
    105
  ];
  static var lensWagrain = <int>[
    75,
    80,
    80,
    60,
    60,
    95,
    105,
    80,
    75,
    45,
    65,
    80,
    85,
    55,
    90,
    95,
    100,
    80
  ];
  static var lensGoldberg = <int>[
    65,
    85,
    80,
    110,
    100,
    130,
    120,
    110,
    95,
    110,
    125,
    140,
    65,
    120,
    55,
    150,
    210,
    80
  ];

  static final String playerStr = "player";
  static final String scoreStr = "score";
  static final String nameStr = "name";
  static final String playerIdxStr = "idx";
  static final String currPlayerIdxStr = "currIdx";
  static final String usedPlayerIndicesStr = "used";
  static final String roundStr = "round";
  static final String dateStr = "date";
  static final String personalHighscoreNamesStr = "personalHighscoreNames";
  static final String personalHighscoreStr = "personalHighscore";
  static final String overallHighscoreNamesStr = "overallHighscoreNames";
  static final String overallHighscoreDatesStr = "overallHighscoreDates";
  static final String overallHighscoreScoresStr = "overallHighscoreScores";
  static final String overallHighscoreStr = "overallHighscore";
  static final String holeStr = "hole";
  static final String compareStr = "compare";
  static final String intermediateStr = "interm";
  static final String languageStr = "lang";
  static final String localityStr = "locality";
  static final String initChosen = "initChosen";
  static final String sbgStr = "sbg";
  static final String wagStr = "wag";
  static final String goldStr = "gold";
  static final String sumsStr = "sums";

  static void setLanguage(bool english) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(languageStr, english);
  }

  static Future<bool> isEnglish() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(languageStr) ?? false;
  }

  static void setLocality(Locality loc) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(localityStr, loc.index);
  }

  static Future<Locality> getLocality() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return getLocalityImm(prefs);
  }

  static Future<int> getLocalityInt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return getLocalityImm(prefs).index;
  }

  static Locality getLocalityImm(SharedPreferences prefs) {
    return Locality.values[prefs.getInt(localityStr) ?? 0];
  }

  static Future<String> getLocalityString() async {
    Locality loc = await getLocality();
    if (loc == Locality.SALZBURG) return "Salzburg";
    if (loc == Locality.WAGRAIN) return "Wagrain-Kleinarl";
    return "Goldberg";
  }

  static String getLocalityStringImm(Locality loc) {
    if (loc == Locality.SALZBURG) return "Salzburg";
    if (loc == Locality.WAGRAIN) return "Wagrain-Kleinarl";
    return "Goldberg";
  }

  static Future<String> getWebsiteString(BuildContext context) async {
    Locality loc = await getLocality();
    if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.home;
    if (loc == Locality.WAGRAIN)
      return AppLocalizations.of(context)!.home_wagrain;
    return AppLocalizations.of(context)!.home_goldberg;
  }

  static String getWebsiteStringImm(BuildContext context, Locality loc) {
    if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.home;
    if (loc == Locality.WAGRAIN)
      return AppLocalizations.of(context)!.home_wagrain;
    return AppLocalizations.of(context)!.home_goldberg;
  }

  static String getAddress1StringImm(BuildContext context, Locality loc) {
    if (loc == Locality.SALZBURG)
      return AppLocalizations.of(context)!.location1;
    if (loc == Locality.WAGRAIN)
      return AppLocalizations.of(context)!.location1_wagrain;
    return AppLocalizations.of(context)!.location1_goldberg;
  }

  static String getAddress2StringImm(BuildContext context, Locality loc) {
    if (loc == Locality.SALZBURG)
      return AppLocalizations.of(context)!.location2;
    if (loc == Locality.WAGRAIN)
      return AppLocalizations.of(context)!.location2_wagrain;
    return AppLocalizations.of(context)!.location2_goldberg;
  }

  static Future<bool> isInitChosen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(initChosen) ?? false;
  }

  static void setInitChosen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(initChosen, true);
  }

  static void setCompare(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(compareStr, value);
  }

  static Future<bool> isCompare() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(compareStr) ?? true;
  }

  static void setIntermediate(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(intermediateStr, value);
  }

  static Future<bool> isIntermediate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(intermediateStr) ?? true;
  }

  static Future<String> getLogoStr() async {
    Locality loc = await getLocality();
    if (loc == Locality.SALZBURG) return "assets/pics/soccer.png";
    if (loc == Locality.WAGRAIN) return "assets/pics/soccer_wagrain.png";
    return "assets/pics/soccer_goldberg.png";
  }

  static Future<String> getPicStr() async {
    Locality loc = await getLocality();
    if (loc == Locality.SALZBURG) return "assets/pics/soccer_pic.png";
    if (loc == Locality.WAGRAIN) return "assets/pics/soccer_pic_wagrain.png";
    return "assets/pics/soccer_pic_goldberg.png";
  }

  static Future<String> getHolePicStr(int hole) async {
    Locality loc = await getLocality();
    return getHolePicStrImm(loc, hole);
  }

  static String getHolePicStrImm(Locality loc, int hole) {
    if (loc == Locality.SALZBURG)
      return "assets/pics/bahn" + hole.toString() + ".jpg";
    if (loc == Locality.WAGRAIN)
      return "assets/pics/bahn_wagrain_" + hole.toString() + ".png";
    return "assets/pics/bahn_goldberg_" + hole.toString() + ".jpg";
  }

  static Future<String> getHolesPicStr() async {
    Locality loc = await getLocality();
    return getHolesPicStrImm(loc);
  }

  static String getHolesPicStrImm(Locality loc) {
    if (loc == Locality.SALZBURG) return "assets/pics/bahnen.png";
    if (loc == Locality.WAGRAIN) return "assets/pics/bahnen_wagrain.png";
    return "assets/pics/bahnen_goldberg.png";
  }

  static String getHoleAdd(
      Locality loc, BuildContext context, int hole, int idx) {
    AppLocalizations a = AppLocalizations.of(context)!;
    if (loc != Locality.SALZBURG) return "";

    switch (hole) {
      case 1:
        switch (idx) {
          case 1:
            return a.holeAddSbg_1_1;
          case 2:
            return a.holeAddSbg_1_2;
          default:
            break;
        }
        break;
      case 2:
        switch (idx) {
          case 1:
            return a.holeAddSbg_2_1;
          case 2:
            return a.holeAddSbg_2_2;
          case 3:
            return a.holeAddSbg_2_3;
          case 4:
            return a.holeAddSbg_2_4;
          case 5:
            return a.holeAddSbg_2_5;
        }
        break;
      case 3:
        switch (idx) {
          case 1:
            return a.holeAddSbg_3_1;
          case 2:
            return a.holeAddSbg_3_2;
          case 3:
            return a.holeAddSbg_3_3;
        }
        break;
      case 4:
        switch (idx) {
          case 1:
            return a.holeAddSbg_4_1;
          case 2:
            return a.holeAddSbg_4_2;
        }
        break;
      case 5:
        switch (idx) {
          case 1:
            return a.holeAddSbg_5_1;
          case 2:
            return a.holeAddSbg_5_2;
          case 3:
            return a.holeAddSbg_5_3;
          case 4:
            return a.holeAddSbg_5_4;
        }
        break;
      case 6:
        switch (idx) {
          case 1:
            return a.holeAddSbg_6_1;
          case 2:
            return a.holeAddSbg_6_2;
          case 3:
            return a.holeAddSbg_6_3;
        }
        break;
      case 7:
        switch (idx) {
          case 1:
            return a.holeAddSbg_7_1;
          case 2:
            return a.holeAddSbg_7_2;
          case 3:
            return a.holeAddSbg_7_3;
        }
        break;
      case 8:
        switch (idx) {
          case 1:
            return a.holeAddSbg_8_1;
          case 2:
            return a.holeAddSbg_8_2;
        }
        break;
      case 9:
        switch (idx) {
          case 1:
            return a.holeAddSbg_9_1;
          case 2:
            return a.holeAddSbg_9_2;
          case 3:
            return a.holeAddSbg_9_3;
        }
        break;
      case 10:
        switch (idx) {
          case 1:
            return a.holeAddSbg_10_1;
          case 2:
            return a.holeAddSbg_10_2;
          case 3:
            return a.holeAddSbg_10_3;
          case 4:
            return a.holeAddSbg_10_4;
        }
        break;
      case 11:
        switch (idx) {
          case 1:
            return a.holeAddSbg_11_1;
          case 2:
            return a.holeAddSbg_11_2;
          case 3:
            return a.holeAddSbg_11_3;
        }
        break;
      case 12:
        switch (idx) {
          case 1:
            return a.holeAddSbg_12_1;
          case 2:
            return a.holeAddSbg_12_2;
          case 3:
            return a.holeAddSbg_12_3;
          case 4:
            return a.holeAddSbg_12_4;
        }
        break;
      case 13:
        switch (idx) {
          case 1:
            return a.holeAddSbg_13_1;
          case 2:
            return a.holeAddSbg_13_2;
        }
        break;
      case 14:
        switch (idx) {
          case 1:
            return a.holeAddSbg_14_1;
          case 2:
            return a.holeAddSbg_14_2;
        }
        break;
      case 15:
        switch (idx) {
          case 1:
            return a.holeAddSbg_15_1;
          case 2:
            return a.holeAddSbg_15_2;
        }
        break;
      case 16:
        switch (idx) {
          case 1:
            return a.holeAddSbg_16_1;
          case 2:
            return a.holeAddSbg_16_2;
          case 3:
            return a.holeAddSbg_16_3;
        }
        break;
      case 17:
        switch (idx) {
          case 1:
            return a.holeAddSbg_17_1;
          case 2:
            return a.holeAddSbg_17_2;
          case 3:
            return a.holeAddSbg_17_3;
          case 4:
            return a.holeAddSbg_17_4;
          case 5:
            return a.holeAddSbg_17_5;
        }
        break;
      case 18:
        switch (idx) {
          case 1:
            return a.holeAddSbg_18_1;
          case 2:
            return a.holeAddSbg_18_2;
        }
        break;
    }

    return "";
  }

  static Future<int> getPar(int hole) async {
    Locality loc = await getLocality();
    return getParWithLoc(loc, hole);
  }

  static int getParWithLoc(Locality loc, int hole) {
    if (loc == Locality.SALZBURG) return parsSalzburg[hole - 1];
    if (loc == Locality.WAGRAIN) return parsWagrain[hole - 1];
    return parsGoldberg[hole - 1];
  }

  static List<int> getPars(Locality loc) {
    if (loc == Locality.SALZBURG) return parsSalzburg;
    if (loc == Locality.WAGRAIN) return parsWagrain;
    return parsGoldberg;
  }

  static Future<int> getLength(int hole) async {
    Locality loc = await getLocality();
    return getLengthWithLoc(loc, hole);
  }

  static int getLengthWithLoc(Locality loc, int hole) {
    if (loc == Locality.SALZBURG) return lensSalzburg[hole - 1];
    if (loc == Locality.WAGRAIN) return lensWagrain[hole - 1];
    return lensGoldberg[hole - 1];
  }

  static Future<String> getLocPrefix() async {
    Locality loc = await getLocality();
    if (loc == Locality.SALZBURG) return sbgStr;
    if (loc == Locality.WAGRAIN) return wagStr;
    return goldStr;
  }

  static String getLocPrefixImm(SharedPreferences prefs) {
    Locality loc = getLocalityImm(prefs);
    if (loc == Locality.SALZBURG) return sbgStr;
    if (loc == Locality.WAGRAIN) return wagStr;
    return goldStr;
  }

  static Future<String> getNameString(int id) async {
    return await getLocPrefix() + playerStr + id.toString() + nameStr;
  }

  static String getNameStringImm(SharedPreferences prefs, int id) {
    return getLocPrefixImm(prefs) + playerStr + id.toString() + nameStr;
  }

  static Future<String> getPlayerIdxString(int round, int id) async {
    return await getLocPrefix() +
        roundStr +
        round.toString() +
        playerStr +
        id.toString() +
        playerIdxStr;
  }

  static String getPlayerIdxStringImm(
      SharedPreferences prefs, int round, int id) {
    return getLocPrefixImm(prefs) +
        roundStr +
        round.toString() +
        playerStr +
        id.toString() +
        playerIdxStr;
  }

  static void checkAddName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var names =
        prefs.getStringList(await getLocPrefix() + "names") ?? <String>[];
    if (!names.contains(name)) {
      names.add(name);
      prefs.setStringList("names", names);
    }
  }

  static void storeUsedPlayerIndicesImm(
      SharedPreferences prefs, List<int> indices) {
    List<String> strs = [];
    for (var i = 0; i < indices.length; i++) strs.add(indices[i].toString());
    prefs.setStringList(getLocPrefixImm(prefs) + usedPlayerIndicesStr, strs);
  }

  static List<int> getUsedPlayerIndicesImm(SharedPreferences prefs) {
    List<String> strs =
        prefs.getStringList(getLocPrefixImm(prefs) + usedPlayerIndicesStr) ??
            <String>[];

    return strs.map(int.parse).toList();
  }

  static Future<List<PlayerPair>> getAllPlayers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> indices = getUsedPlayerIndicesImm(prefs);

    List<PlayerPair> players = [];
    for (var i = 0; i < indices.length; i++) {
      players.add(PlayerPair(indices[i], getPlayerNameImm(prefs, indices[i])));
    }
    return players;
  }

  static void setPlayerName(int id, String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setPlayerNameImm(prefs, id, name);
  }

  static void setPlayerNameImm(SharedPreferences prefs, int id, String name) {
    prefs.setString(getNameStringImm(prefs, id), name);
  }

  static void removePlayerNameImm(SharedPreferences prefs, int id) {
    prefs.remove(getNameStringImm(prefs, id));
  }

  static Future<String> getPlayerName(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(await getNameString(id)) ?? "";
  }

  static String getPlayerNameImm(SharedPreferences prefs, int id) {
    return prefs.getString(getNameStringImm(prefs, id)) ?? "";
  }

  static Future<int> getCurrPlayerIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return getCurrPlayerIndexImm(prefs);
  }

  static int getCurrPlayerIndexImm(SharedPreferences prefs) {
    return prefs.getInt(getLocPrefixImm(prefs) + currPlayerIdxStr) ?? 0;
  }

  static void setCurrPlayerIndexImm(SharedPreferences prefs, int idx) {
    prefs.setInt(getLocPrefixImm(prefs) + currPlayerIdxStr, idx);
  }

  static void addPlayer(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = getCurrPlayerIndexImm(prefs);
    setPlayerNameImm(prefs, id, name);
    setCurrPlayerIndexImm(prefs, id + 1);

    var l = getUsedPlayerIndicesImm(prefs);
    l.add(id);
    storeUsedPlayerIndicesImm(prefs, l);
  }

  static void deletePlayer(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var l = getUsedPlayerIndicesImm(prefs);
    l.remove(id);
    storeUsedPlayerIndicesImm(prefs, l);
  }

  static void storePlayerIndex(int round, int id, int idx) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(await getPlayerIdxString(round, id), idx);
  }

  static void storePlayerIndexCurrent(int id, int idx) {
    storePlayerIndex(0, id, idx);
  }

  static Future<int> getPlayerIndex(int round, int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(await getPlayerIdxString(round, id)) ?? -1;
  }

  static int getPlayerIndexImm(SharedPreferences prefs, int round, int id) {
    return prefs.getInt(getPlayerIdxStringImm(prefs, round, id)) ?? -1;
  }

  static Future<int> getPlayerIndexCurrent(int id) async {
    return getPlayerIndex(0, id);
  }

  static int getPlayerIndexCurrentImm(SharedPreferences prefs, int id) {
    return getPlayerIndexImm(prefs, 0, id);
  }

  static List<int> getPlayerIndicesImm(SharedPreferences prefs, int round) {
    List<int> indices = [];
    for (var pl = 1; pl <= MAX_PLAYER_CNT; pl++) {
      int idx = getPlayerIndexImm(prefs, round, pl);
      if (idx == -1) break;

      indices.add(idx);
    }
    return indices;
  }

  static Future<List<List<int>>> getPlayerIndicesInRoundsToBeInc(
      List<int> roundsToBeIncremented) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<int>> indices = [];
    for (var i = 0; i < roundsToBeIncremented.length; i++) {
      indices.add(getPlayerIndicesImm(prefs, roundsToBeIncremented[i] + 1));
    }

    return indices;
  }

  static Future<List<String>> getPlayerNames(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> indices = getPlayerIndicesImm(prefs, round);
    List<String> names = [];
    for (var i = 0; i < indices.length; i++)
      names.add(getPlayerNameImm(prefs, indices[i]));
    return names;
  }

  static Future<List<List<PointPair>>> getScorePointsInRound(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<PointPair>> scores = [];
    for (var pl = 1; pl <= MAX_PLAYER_CNT; pl++) {
      int idx = getPlayerIndexImm(prefs, round, pl);
      if (idx == -1) break;

      scores.add([]);
      for (var hole = 1; hole <= 18; hole++)
        scores.last.add(
            PointPair(hole, getScoreImm(prefs, round, pl, hole).toDouble()));
    }
    return scores;
  }

  static List<int> getPlayerIndicesAllRoundsImm(SharedPreferences prefs) {
    Set<int> indices = Set<int>();
    for (var round = 1; round <= STORED_ROUNDS; round++) {
      for (var pl = 1; pl <= MAX_PLAYER_CNT; pl++) {
        int idx = getPlayerIndexImm(prefs, round, pl);
        if (idx == -1) break;

        indices.add(idx);
      }
    }
    return indices.toList();
  }

  static Future<List<String>> getPlayerNamesAllRounds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> indices = getPlayerIndicesAllRoundsImm(prefs);
    List<String> names = [];
    for (var i = 0; i < indices.length; i++)
      names.add(getPlayerNameImm(prefs, indices[i]));
    return names;
  }

  static Future<List<List<int>>> getScoresInRound(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<int>> scores = [];
    for (var pl = 1; pl <= Data.MAX_PLAYER_CNT; pl++) {
      int idx = Data.getPlayerIndexImm(prefs, round, pl);
      if (idx == -1) break;

      scores.add([]);
      for (var hole = 1; hole <= 18; hole++)
        scores.last.add(Data.getScoreImm(prefs, round, pl, hole));
    }
    return scores;
  }

  static Future<List<int>> getTotalScoresInRound(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<int> scores = [];
    for (var pl = 1; pl <= Data.MAX_PLAYER_CNT; pl++) {
      int idx = Data.getPlayerIndexImm(prefs, round, pl);
      if (idx == -1) break;

      scores.add(Data.getTotalScoreImm(prefs, round, pl));
    }
    return scores;
  }

  static Future<List<List<List<int>>>> getScoresInRounds(
      List<int> rounds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<List<int>>> scores = [];
    for (var i = 0; i < rounds.length; i++) {
      var round = rounds[i] + 1;
      scores.add([]);

      for (var pl = 1; pl <= Data.MAX_PLAYER_CNT; pl++) {
        int idx = Data.getPlayerIndexImm(prefs, round, pl);
        if (idx == -1) break;

        scores.last.add([]);
        for (var hole = 1; hole <= 18; hole++)
          scores.last.last.add(Data.getScoreImm(prefs, round, pl, hole));
      }
    }
    return scores;
  }

  static Future<List<List<int>>> getTotalScoresInRounds(
      List<int> rounds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<int>> scores = [];
    for (var i = 0; i < rounds.length; i++) {
      var round = rounds[i] + 1;
      scores.add([]);

      for (var pl = 1; pl <= Data.MAX_PLAYER_CNT; pl++) {
        int idx = Data.getPlayerIndexImm(prefs, round + 1, pl);
        if (idx == -1) break;

        scores.last..add(Data.getTotalScoreImm(prefs, round, pl));
      }
    }
    return scores;
  }

  static Future<List<List<PointPair>>> getScoresAllRounds(int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<int> indices = getPlayerIndicesAllRoundsImm(prefs);
    List<List<PointPair>> scores = [];
    for (var i = 0; i < indices.length; i++) {
      scores.add([]);
      int counter = 0;
      for (var round = STORED_ROUNDS; round >= 1; round--) {
        var date = getDateImm(prefs, round);
        if (date == "") continue;

        int score =
            Data.getScoreForPlayerIndexImm(prefs, round, indices[i], hole);
        if (score > 0) scores.last.add(PointPair(counter, score.toDouble()));
        counter++;
      }
    }
    return scores;
  }

  static Future<String> getDateString(int round) async {
    return await getLocPrefix() + dateStr + round.toString();
  }

  static String getDateStringImm(SharedPreferences prefs, int round) {
    return getLocPrefixImm(prefs) + dateStr + round.toString();
  }

  static void storeDate(int round, String date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(await getDateString(round), date);
  }

  static void storeCurrentDate() {
    DateTime date = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
    storeDate(0, formattedDate);
  }

  static Future<String> getDate(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(await getDateString(round)) ?? "";
  }

  static String getDateImm(SharedPreferences prefs, int round) {
    return prefs.getString(getDateStringImm(prefs, round)) ?? "";
  }

  static Future<String> getScoreString(int round, int id, int hole) async {
    return await getLocPrefix() +
        roundStr +
        round.toString() +
        playerStr +
        id.toString() +
        scoreStr +
        hole.toString();
  }

  static String getScoreStringImm(
      SharedPreferences prefs, int round, int id, int hole) {
    return getLocPrefixImm(prefs) +
        roundStr +
        round.toString() +
        playerStr +
        id.toString() +
        scoreStr +
        hole.toString();
  }

  static void storeScore(int round, int id, int hole, int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(await getScoreString(round, id, hole), score);
  }

  static void storeScoreCurrent(int id, int hole, int score) {
    storeScore(0, id, hole, score);
  }

  static void incrementScore(int id, int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int curr = prefs.getInt(await getScoreString(0, id, hole)) ?? 0;
    prefs.setInt(await getScoreString(0, id, hole), curr + 1);
  }

  static void incrementScoreCurrent(int id, int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int curr = prefs.getInt(await getScoreString(0, id, hole)) ?? 1;
    prefs.setInt(await getScoreString(0, id, hole), curr - 1);
  }

  static Future<int> getScore(int round, int id, int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(await getScoreString(round, id, hole)) ?? 0;
  }

  static Future<List<List<int>>> getPreviousScores(bool current) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<List<int>> scores = [];
    int round = current ? 0 : 1;
    for (var pl = 1; pl <= MAX_PLAYER_CNT; pl++) {
      int index = getPlayerIndexImm(prefs, round, pl);
      if (index == -1) break;

      scores.add([]);
      int prevId = getIndexForPlayerIndexImm(prefs, round + 1, index);
      if (prevId == -1) continue;

      for (var hole = 1; hole <= 18; hole++)
        scores.last.add(getScoreImm(prefs, round + 1, prevId, hole));
    }
    return scores;
  }

  static int getScoreImm(SharedPreferences prefs, int round, int id, int hole) {
    return prefs.getInt(getScoreStringImm(prefs, round, id, hole)) ?? 0;
  }

  static Future<int> getScoreCurrent(int id, int hole) {
    return getScore(0, id, hole);
  }

  static int getScoreCurrentImm(SharedPreferences prefs, int id, int hole) {
    return getScoreImm(prefs, 0, id, hole);
  }

  static Future<int> getTotalScore(int round, int id) async {
    int total = 0;
    for (var i = 1; i <= 18; i++) total += await getScore(round, id, i);
    return total;
  }

  static int getTotalScoreImm(SharedPreferences prefs, int round, int id) {
    int total = 0;
    for (var i = 1; i <= 18; i++) total += getScoreImm(prefs, round, id, i);
    return total;
  }

  static int getScoreForPlayerIndexImm(
      SharedPreferences prefs, int round, int index, int hole) {
    int pl = getIndexForPlayerIndexImm(prefs, round, index);
    if (pl < 0) return 0;

    if (hole == 0) return getTotalScoreImm(prefs, round, pl);
    return getScoreImm(prefs, round, pl, hole);
  }

  static Future<int> getTotalScoreForPlayerIndex(int round, int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return getScoreForPlayerIndexImm(prefs, round, index, 0);
  }

  static int getIndexForPlayerIndexImm(
      SharedPreferences prefs, int round, int id) {
    if (round > STORED_ROUNDS) return -1;

    for (var pl = 1; pl <= 5; pl++) {
      int n = getPlayerIndexImm(prefs, round, pl);
      if (n == id) {
        return pl;
      }
    }
    return -1;
  }

  static void clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var round = 0; round <= STORED_ROUNDS; round++) {
      for (var pl = 1; pl <= MAX_PLAYER_CNT; pl++) {
        for (var hole = 1; hole <= 18; hole++) {
          prefs.remove(getScoreStringImm(prefs, round, pl, hole));
        }

        prefs.remove(getPlayerIdxStringImm(prefs, round, pl));
      }
      prefs.remove(getDateStringImm(prefs, round));
    }
    prefs.remove(getSumsString(prefs));

    // 0 is for total.
    for (var hole = 0; hole <= 18; hole++) {
      prefs.remove(getPersonalHighscoreStr(prefs, hole));
      prefs.remove(getOverallHighscoreStr(prefs, hole));
    }
  }

  static void shift() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var round = STORED_ROUNDS; round >= 1; round--) {
      for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
        int id = getPlayerIndexImm(prefs, round - 1, player);
        storePlayerIndex(round, player, id);

        for (var hole = 1; hole <= 18; hole++) {
          int score = getScoreImm(prefs, round - 1, player, hole);
          storeScore(round, player, hole, score);
        }
      }
      String date = getDateImm(prefs, round - 1);
      storeDate(round, date);
    }

    for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
      int id = getPlayerIndexImm(prefs, 0, player);
      if (id == -1) continue;
      int total = 0;
      var scores = <int>[];
      for (var hole = 1; hole <= 18; hole++) {
        int score = getScoreImm(prefs, 0, player, hole);
        total += score;
        scores.add(score);
        checkStoreScore(prefs, id, hole, score);
      }
      checkStoreScore(prefs, id, 0, total, holes: List<int>.of(scores));
      storeToSum(prefs, id, scores);
    }

    for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
      storePlayerIndex(0, player, -1);
      for (var hole = 1; hole <= 18; hole++) storeScore(0, player, hole, 0);
    }
    storeDate(0, "");
  }

  static Future<bool> finished() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
      int id = getPlayerIndexCurrentImm(prefs, player);
      if (id == -1) return true;
      for (var hole = 1; hole <= 18; hole++) {
        if (getScoreCurrentImm(prefs, player, hole) == 0) return false;
      }
    }
    return true;
  }

  static Future<bool> isStarted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = getPlayerIndexCurrentImm(prefs, 1);
    return id != -1;
  }

  static Future<bool> isPlayStarted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var i = 1; i <= MAX_PLAYER_CNT; i++) {
      int id = getPlayerIndexCurrentImm(prefs, 1);
      if (id == -1) continue;

      for (var hole = 1; hole <= 18; hole++) {
        var score = getScoreCurrentImm(prefs, i, hole);
        if (score > 0) return true;
      }
    }
    return false;
  }

  static Future<bool> isHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = getPlayerIndexImm(prefs, 1, 1);
    return id != -1;
  }

  static void clearCurrent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var pl = 1; pl <= 5; pl++) {
      prefs.remove(getPlayerIdxStringImm(prefs, 0, pl));
      for (var i = 1; i <= 18; i++)
        prefs.remove(getScoreStringImm(prefs, 0, pl, i));
    }
  }

  static Future<List<String>> getValidDates() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var dates = <String>[];
    for (var round = 1; round <= STORED_ROUNDS; round++) {
      var date = getDateImm(prefs, round);
      if (date == "") break;
      dates.add(date);
    }
    return dates;
  }

  static Future<List<String>> getNamesInRound(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> list = [];
    int id = getPlayerIndexImm(prefs, round, 1);
    if (id == -1) return list;

    for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
      int id = getPlayerIndexImm(prefs, round, player);
      if (id == -1) break;

      list.add(getPlayerNameImm(prefs, id));
    }

    return list;
  }

  static Future<List<List<String>>> getAllRoundNames() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<List<String>> list = [];
    for (var round = 1; round <= STORED_ROUNDS; round++) {
      int id = getPlayerIndexImm(prefs, round, 1);
      if (id == -1) break;

      list.add([]);
      for (var player = 1; player <= MAX_PLAYER_CNT; player++) {
        int id = getPlayerIndexImm(prefs, round, player);
        if (id == -1) break;

        list.last.add(getPlayerNameImm(prefs, id));
      }
    }
    return list;
  }

  static String getPersonalHighscoreNamesString(SharedPreferences prefs) {
    return getLocPrefixImm(prefs) + personalHighscoreNamesStr;
  }

  static void checkAddPersonalHighscoreName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var names =
        prefs.getStringList(getPersonalHighscoreNamesString(prefs)) ?? [];
    if (names.isEmpty || !names.contains(name)) {
      names.add(name);
      prefs.setStringList(getPersonalHighscoreNamesString(prefs), names);
    }
  }

  static Future<List<String>> getPersonalHighscoreNames() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(getPersonalHighscoreNamesString(prefs)) ?? [];
  }

  static String getHighscoreString(
      SharedPreferences prefs, String name, int hole) {
    return getLocPrefixImm(prefs) +
        personalHighscoreStr +
        name +
        holeStr +
        hole.toString();
  }

  static String getHighscoreDateString(
      SharedPreferences prefs, String name, int hole) {
    return getLocPrefixImm(prefs) +
        personalHighscoreStr +
        name +
        holeStr +
        hole.toString() +
        dateStr;
  }

  /// [holes]: Schläge pro Loch, nur für den Gesamt-Highscore (hole == 0).
  static void checkStoreScore(
      SharedPreferences prefs, int playerIndex, int hole, int score,
      {List<int>? holes}) {
    checkStoreScorePersonal(prefs, playerIndex, hole, score, holes: holes);
    checkStoreScoreOverall(prefs, playerIndex, hole, score, holes: holes);
  }

  static String encodeHighscoreList(List<Highscore> list) => json.encode(
        list
            .map<Map<String, dynamic>>((highscore) => highscore.toJson())
            .toList(),
      );

  static List<Highscore> decodeHighscoreList(String highscoresStr) {
    if (highscoresStr == "") return [];
    return (json.decode(highscoresStr) as List<dynamic>)
        .map<Highscore>((item) => Highscore.fromJson(item))
        .toList();
  }

  static void checkStoreScorePersonal(
      SharedPreferences prefs, int playerIndex, int hole, int score,
      {List<int>? holes}) {
    var list = getPersonalHighscoresImm(prefs, hole);
    DateTime date = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy hh:mm').format(date);

    bool found = false;
    bool modified = false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].playerIndex == playerIndex) {
        found = true;
        if (score < list[i].score) {
          list[i].score = score;
          list[i].date = formattedDate;
          list[i].holes = holes;
          modified = true;
        }
        break;
      }
    }

    if (!found) {
      list.add(Highscore(playerIndex, score, formattedDate, holes: holes));
      modified = true;
    }

    if (modified) {
      list.sort((a, b) => a.score.compareTo(b.score));
      String json = encodeHighscoreList(list);
      prefs.setString(getPersonalHighscoreStr(prefs, hole), json);
    }
  }

  static String getPersonalHighscoreStr(SharedPreferences prefs, int hole) {
    return getLocPrefixImm(prefs) + personalHighscoreStr + hole.toString();
  }

  static Future<List<NamedHighscore>> getPersonalHighscores(int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(getPersonalHighscoreStr(prefs, hole)) ?? "";
    var list = decodeHighscoreList(json);

    List<NamedHighscore> out = [];
    for (var i = 0; i < list.length; i++)
      out.add(NamedHighscore(getPlayerNameImm(prefs, list[i].playerIndex),
          list[i].score, list[i].date,
          holes: list[i].holes));
    out.sort((a, b) => a.score.compareTo(b.score));
    return out;
  }

  static List<Highscore> getPersonalHighscoresImm(
      SharedPreferences prefs, int hole) {
    String json = prefs.getString(getPersonalHighscoreStr(prefs, hole)) ?? "";
    var list = decodeHighscoreList(json);
    return list;
  }

  static String getOverallHighscoreStr(SharedPreferences prefs, int hole) {
    return getLocPrefixImm(prefs) + overallHighscoreStr + hole.toString();
  }

  static Future<List<NamedHighscore>> getOverallHighscores(int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var json = prefs.getString(getOverallHighscoreStr(prefs, hole)) ?? "";
    var list = decodeHighscoreList(json);

    List<NamedHighscore> out = [];
    for (var i = 0; i < list.length; i++)
      out.add(NamedHighscore(getPlayerNameImm(prefs, list[i].playerIndex),
          list[i].score, list[i].date,
          holes: list[i].holes));
    out.sort((a, b) => a.score.compareTo(b.score));
    return out;
  }

  static List<Highscore> getOverallHighscoresImm(
      SharedPreferences prefs, int hole) {
    var json = prefs.getString(getOverallHighscoreStr(prefs, hole)) ?? "";
    var list = decodeHighscoreList(json);
    return list;
  }

  static void checkStoreScoreOverall(
      SharedPreferences prefs, int playerIndex, int hole, int score,
      {List<int>? holes}) {
    var list = getOverallHighscoresImm(prefs, hole);
    DateTime date = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy hh:mm').format(date);

    bool stored = false;
    for (var i = 0; i < list.length; i++) {
      if (score < list[i].score) {
        list.insert(
            i, Highscore(playerIndex, score, formattedDate, holes: holes));
        stored = true;
        break;
      }
    }

    if (stored && list.length > STORED_HIGHSCORES)
      list.removeLast();
    else if (!stored && list.length < STORED_HIGHSCORES) {
      list.add(Highscore(playerIndex, score, formattedDate, holes: holes));
      stored = true;
    }

    if (stored) {
      String json = encodeHighscoreList(list);
      prefs.setString(getOverallHighscoreStr(prefs, hole), json);
    }
  }

  static Future<RoundData> getRoundData(int round) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> names = [];
    List<List<int>> scores = [];
    for (var pl = 1; pl <= 5; pl++) {
      int id = getPlayerIndexImm(prefs, round, pl);
      if (id == -1) break;

      names.add(getPlayerNameImm(prefs, id));
      scores.add([]);
      for (var hole = 1; hole <= 18; hole++)
        scores.last.add(getScoreImm(prefs, round, pl, hole));
    }

    return RoundData(getLocalityImm(prefs), names, scores);
  }

  static int getHighscore(SharedPreferences prefs, String name, int hole) {
    return prefs.getInt(getHighscoreString(prefs, name, hole)) ?? 0;
  }

  static String getHighscoreDate(
      SharedPreferences prefs, String name, int hole) {
    return prefs.getString(getHighscoreDateString(prefs, name, hole)) ?? "";
  }

  static String encodeSumList(List<Sum> list) => json.encode(
        list.map<Map<String, dynamic>>((sum) => sum.toJson()).toList(),
      );

  static List<Sum> decodeSumList(String str) {
    if (str == "") return [];
    return (json.decode(str) as List<dynamic>)
        .map<Sum>((item) => Sum.fromJson(item))
        .toList();
  }

  static String getSumsString(SharedPreferences prefs) {
    return getLocPrefixImm(prefs) + sumsStr;
  }

  static Future<List<Sum>> getSums() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return getSumsImm(prefs);
  }

  static List<Sum> getSumsImm(SharedPreferences prefs) {
    var json = prefs.getString(getSumsString(prefs)) ?? "";
    var list = decodeSumList(json);
    return list;
  }

  static Future<List<Average>> getPersonalAverages(int hole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var sums = getSumsImm(prefs);
    var list = <Average>[];

    for (var i = 0; i < sums.length; i++) {
      Sum s = sums[i];
      if (hole > 0) {
        list.add(Average(getPlayerNameImm(prefs, s.playerIndex),
            s.sums[hole - 1].toDouble() / s.games.toDouble(), s.games));
      } else {
        list.add(Average(
            getPlayerNameImm(prefs, s.playerIndex),
            s.sums.reduce((a, b) => a + b).toDouble() / s.games.toDouble(),
            s.games));
      }
    }
    list.sort((a, b) => a.avg.compareTo(b.avg));

    return list;
  }

  static Future<List<List<PointPair>>> getPersonalAverageScores() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var sums = getSumsImm(prefs);
    print("sums len " + sums.length.toString());
    List<List<PointPair>> list = [];

    for (var i = 0; i < sums.length; i++) {
      Sum s = sums[i];

      list.add([]);
      for (var hole = 1; hole <= 18; hole++) {
        list.last.add(
            PointPair(hole, s.sums[hole - 1].toDouble() / s.games.toDouble()));
      }
    }

    return list;
  }

  static Future<List<String>> getPersonalAverageNames() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var sums = getSumsImm(prefs);
    List<String> list = [];

    for (var i = 0; i < sums.length; i++) {
      Sum s = sums[i];

      list.add(getPlayerNameImm(prefs, s.playerIndex));
    }

    return list;
  }

  static void storeToSum(
      SharedPreferences prefs, int playerIndex, List<int> scores) {
    var list = getSumsImm(prefs);

    var found = false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].playerIndex == playerIndex) {
        found = true;
        list[i].games += 1;
        for (var j = 0; j < list[i].sums.length; j++)
          list[i].sums[j] += scores[j];
        break;
      }
    }

    if (!found) {
      var s = Sum(playerIndex);
      for (var i = 0; i < scores.length; i++) s.sums.add(scores[i]);
      list.add(s);
    }

    String json = encodeSumList(list);
    prefs.setString(getSumsString(prefs), json);
  }
}
