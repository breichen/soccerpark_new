import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:csv/csv.dart';

import './export.dart';
import '../widgets/toast.dart';

void generateCsvSingleRound(
    BuildContext context,
    String date,
    List<String> names,
    List<List<int>> scores,
    List<int> totalScores,
    String filename) async {
  List<List<String>> data =
      getCsvDataSingleRound(date, names, scores, totalScores);

  storeCsv(context, data, filename);
}

void generateCsvMultipleRounds(
    BuildContext context,
    List<String> dates,
    List<List<String>> names,
    List<List<List<int>>> scores,
    List<List<int>> totalScores,
    String filename) async {
  List<List<String>> data =
      getCsvDataMultipleRounds(dates, names, scores, totalScores);

  storeCsv(context, data, filename);
}

void storeCsv(
    BuildContext context, List<List<String>> data, String filename) async {
  final path = await getFilePath(context, filename + ".csv");
  if (path == "") {
    CustomToast.showToast(
        context, AppLocalizations.of(context)!.could_not_store);
    return;
  }
  final File file = await File(path).create(recursive: true);

  String csvData = ListToCsvConverter().convert(data);
  await file.writeAsString(csvData);

  CustomToast.showToastIcon(
      context, AppLocalizations.of(context)!.saved_as + " " + path, Icons.check,
      dur: 5);
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
