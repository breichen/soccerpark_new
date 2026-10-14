import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

import './export.dart';

/// Austrian/German Excel expects ';' as separator. Use ',' if your users
/// mainly open the files in Google Sheets or other tools.
const String csvDelimiter = ';';

Future<bool> generateCsvSingleRound(
    BuildContext context,
    String date,
    List<String> names,
    List<List<int>> scores,
    List<int> totalScores,
    String filename) {
  final data = getCsvDataSingleRound(date, names, scores, totalScores);
  return storeCsv(context, data, filename);
}

Future<bool> generateCsvMultipleRounds(
    BuildContext context,
    List<String> dates,
    List<List<String>> names,
    List<List<List<int>>> scores,
    List<List<int>> totalScores,
    String filename) {
  final data = getCsvDataMultipleRounds(dates, names, scores, totalScores);
  return storeCsv(context, data, filename);
}

Future<bool> storeCsv(
    BuildContext context, List<List<String>> data, String filename) {
  final csv = ListToCsvConverter(fieldDelimiter: csvDelimiter).convert(data);
  // UTF-8 BOM so Excel detects the encoding (umlauts in player names).
  final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
  return saveExportFile(context, bytes, filename, 'csv');
}

List<List<String>> getCsvDataSingleRound(String date, List<String> names,
    List<List<int>> scores, List<int> totalScores) {
  List<List<String>> data = [
    ["Hole"]
  ];
  for (var pl = 1; pl <= names.length; pl++) data.last.add(names[pl - 1]);

  for (var hole = 1; hole <= 18; hole++) {
    data.add([hole.toString()]);

    for (var pl = 1; pl <= names.length; pl++) {
      int score = scores[pl - 1][hole - 1];
      data.last.add(score.toString());
    }
  }

  data.add(["total"]);
  for (var pl = 1; pl <= names.length; pl++) {
    data.last.add(totalScores[pl - 1].toString());
  }

  data.add([]);
  data.add(["time", "name", "hole", "score"]);

  for (var pl = 1; pl <= names.length; pl++) {
    int sum = 0;
    for (var hole = 1; hole <= 18; hole++) {
      int score = scores[pl - 1][hole - 1];
      sum += score;
      data.add([date, names[pl - 1], hole.toString(), score.toString()]);
    }
    data.add([date, names[pl - 1], "total", sum.toString()]);
  }

  return data;
}

List<List<String>> getCsvDataMultipleRounds(
    List<String> dates,
    List<List<String>> names,
    List<List<List<int>>> scores,
    List<List<int>> totalScores) {
  List<List<String>> data = [];
  data.add(["time", "name", "hole", "score"]);

  assert(dates.length == names.length);
  assert(dates.length == scores.length);
  assert(dates.length == totalScores.length);

  for (var i = 0; i < names.length; i++) {
    for (var pl = 1; pl <= names[i].length; pl++) {
      int sum = 0;
      for (var hole = 1; hole <= 18; hole++) {
        int score = scores[i][pl - 1][hole - 1];
        sum += score;
        data.add(
            [dates[i], names[i][pl - 1], hole.toString(), score.toString()]);
      }
      data.add([dates[i], names[i][pl - 1], "total", sum.toString()]);
    }
  }

  return data;
}
