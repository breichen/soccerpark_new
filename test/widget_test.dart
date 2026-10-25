// Tests für die Ranglogik der Online-Bestenliste
// (lib/utils/online_highscores.dart). Laufen ohne Server und Gerät:
//   flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:soccerpark/utils/online_highscores.dart';

/// Testeintrag mit [total] Schlägen; die Reihenfolge der Liste entspricht
/// der Server-Sortierung (Schläge, dann früherer Eintrag zuerst).
OnlineHighscore entry(int id, int total) => OnlineHighscore(
    id, 'Spieler $id', total, List<int>.filled(18, 3), DateTime(2026, 10, 1));

List<OnlineHighscore> list(List<int> totals) =>
    [for (var i = 0; i < totals.length; i++) entry(i + 1, totals[i])];

void main() {
  group('prospectiveRank', () {
    test('leere Liste: Platz 1', () {
      expect(OnlineHighscores.prospectiveRank([], 60), 1);
    });

    test('besser als alle: Platz 1', () {
      expect(OnlineHighscores.prospectiveRank(list([50, 52, 55]), 48), 1);
    });

    test('Platz zwischen bestehenden Einträgen', () {
      expect(OnlineHighscores.prospectiveRank(list([50, 52, 55]), 53), 3);
    });

    test('Gleichstand teilt sich den angezeigten Platz', () {
      expect(OnlineHighscores.prospectiveRank(list([50, 52, 55]), 52), 2);
    });

    test('Liste nicht voll: auch schlechteste Runde kommt hinein', () {
      expect(OnlineHighscores.prospectiveRank(list([50, 52, 55]), 90), 4);
    });

    test('volle Liste: schlechter als Platz 10 reicht nicht', () {
      final full = list([50, 51, 52, 53, 54, 55, 56, 57, 58, 59]);
      expect(OnlineHighscores.prospectiveRank(full, 60), isNull);
    });

    test('volle Liste: gleich wie Platz 10 reicht nicht (früherer gewinnt)',
        () {
      final full = list([50, 51, 52, 53, 54, 55, 56, 57, 58, 59]);
      expect(OnlineHighscores.prospectiveRank(full, 59), isNull);
    });

    test('volle Liste: besser als Platz 10 reicht', () {
      final full = list([50, 51, 52, 53, 54, 55, 56, 57, 58, 59]);
      expect(OnlineHighscores.prospectiveRank(full, 58), 9);
    });
  });

  group('displayRanks', () {
    test('ohne Gleichstand fortlaufend', () {
      expect(OnlineHighscores.displayRanks(list([50, 52, 55])), [1, 2, 3]);
    });

    test('Gleichstand bekommt gleichen Platz, danach wird übersprungen', () {
      expect(OnlineHighscores.displayRanks(list([50, 52, 52, 55])),
          [1, 2, 2, 4]);
    });
  });

  group('Namen', () {
    test('Leerzeichen werden bereinigt', () {
      expect(OnlineHighscores.sanitizeName('  Max   Muster  '), 'Max Muster');
    });

    test('2 bis 20 Zeichen sind gültig', () {
      expect(OnlineHighscores.isValidName('A'), isFalse);
      expect(OnlineHighscores.isValidName('Al'), isTrue);
      expect(OnlineHighscores.isValidName('A' * 20), isTrue);
      expect(OnlineHighscores.isValidName('A' * 21), isFalse);
      expect(OnlineHighscores.isValidName('   '), isFalse);
    });
  });
}
