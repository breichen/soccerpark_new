// Tests für das Speicherformat der abgeschlossenen Runden
// (lib/utils/data.dart): Übernahme des alten Formats, Abschließen einer
// Runde, Zugriff über die Rundennummer und Löschen.
//   flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccerpark/utils/data.dart';

/// Alte Einträge einer Runde für Anlage Salzburg (Präfix "sbg").
Map<String, Object> oldRound(int round, String date, List<int> players,
    List<List<int>> scores) {
  final m = <String, Object>{'sbgdate$round': date};
  for (var pl = 0; pl < players.length; pl++) {
    m['sbground${round}player${pl + 1}idx'] = players[pl];
    for (var hole = 1; hole <= 18; hole++) {
      m['sbground${round}player${pl + 1}score$hole'] = scores[pl][hole - 1];
    }
  }
  return m;
}

List<int> holes(int value) => List<int>.filled(18, value);

void main() {
  setUp(() => Data.resetRoundsCache());

  test('altes Format wird übernommen und entfernt', () async {
    SharedPreferences.setMockInitialValues({
      // Runde 1 = neueste, Runde 2 = ältere
      ...oldRound(1, '20.10.2026 15:00', [3, 5], [holes(3), holes(4)]),
      ...oldRound(2, '01.10.2026 10:00', [3], [holes(5)]),
    });
    final prefs = await SharedPreferences.getInstance();

    expect(Data.pastRoundCountImm(prefs), 2);
    expect(Data.getDateImm(prefs, 1), '20.10.2026 15:00');
    expect(Data.getDateImm(prefs, 2), '01.10.2026 10:00');
    expect(Data.getPlayerIndexImm(prefs, 1, 2), 5);
    expect(Data.getPlayerIndexImm(prefs, 1, 3), -1);
    expect(Data.getScoreImm(prefs, 1, 2, 7), 4);
    expect(Data.getTotalScoreImm(prefs, 2, 1), 90);

    // Alte Einträge sind weg, neue Liste ist gespeichert.
    expect(prefs.getString('sbgdate1'), isNull);
    expect(prefs.getInt('sbground1player1idx'), isNull);
    expect(prefs.getStringList('sbg${Data.roundsV2Str}'), hasLength(2));

    // Auch nach "Neustart" (leerer Cache) noch da.
    Data.resetRoundsCache();
    expect(Data.pastRoundCountImm(prefs), 2);
  });

  test('ohne alte Runden: leere Liste', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(Data.pastRoundCountImm(prefs), 0);
    expect(await Data.isHistory(), isFalse);
    expect(await Data.getValidDates(), isEmpty);
  });

  test('mehr als 10 Runden bleiben erhalten', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    for (var i = 1; i <= 25; i++) {
      prefs.setString('sbgdate0', 'Runde $i');
      prefs.setInt('sbground0player1idx', 7);
      for (var hole = 1; hole <= 18; hole++) {
        prefs.setInt('sbground0player1score$hole', 3);
      }
      await Data.shift();
    }

    expect(Data.pastRoundCountImm(prefs), 25);
    expect(Data.getDateImm(prefs, 1), 'Runde 25'); // neueste
    expect(Data.getDateImm(prefs, 25), 'Runde 1'); // älteste
    expect((await Data.getValidDates()).first, 'Runde 25');

    // Laufende Runde ist nach dem Abschließen leer.
    expect(Data.getPlayerIndexImm(prefs, 0, 1), -1);
    expect(Data.getScoreImm(prefs, 0, 1, 1), 0);

    // Verlauf: letzte 20 bzw. alle Runden.
    final recent = await Data.getScoresAllRounds(0, limit: 20);
    final all = await Data.getScoresAllRounds(0);
    expect(recent.single, hasLength(20));
    expect(all.single, hasLength(25));
    expect(all.single.first.y, 54);
  });

  test('Historie löschen leert die Runden dauerhaft', () async {
    SharedPreferences.setMockInitialValues({
      ...oldRound(1, '20.10.2026 15:00', [3], [holes(3)]),
    });
    final prefs = await SharedPreferences.getInstance();
    expect(Data.pastRoundCountImm(prefs), 1);

    await Data.clear();
    expect(Data.pastRoundCountImm(prefs), 0);

    // Keine erneute Übernahme nach "Neustart".
    Data.resetRoundsCache();
    expect(Data.pastRoundCountImm(prefs), 0);
  });

  test('StoredRound: JSON hin und zurück', () {
    final r = StoredRound('25.10.2026 19:30', [1, 4], [holes(3), holes(5)]);
    final back = StoredRound.fromJson(r.toJson());
    expect(back.date, r.date);
    expect(back.players, [1, 4]);
    expect(back.scores[1][17], 5);
  });
}
