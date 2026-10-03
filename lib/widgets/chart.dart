import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../utils/data.dart';
import './space.dart';

class LineChartWidget extends StatelessWidget {
  final List<List<PointPair>> points;
  final List<String> xtitles;
  final List<String> legendEntries;
  final bool addDummy;

  LineChartWidget(this.points,
      {this.xtitles = const [],
      this.legendEntries = const [],
      this.addDummy = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (legendEntries.isEmpty) return getChart();
    return Column(children: [getChart(), Space(0), getLegend()]);
  }

  Widget getChart() {
    List<LineChartBarData> data = [];
    for (var i = 0; i < points.length; i++) {
      if (points[i].isEmpty) continue;

      data.add(LineChartBarData(
          spots: points[i]
              .map((point) => FlSpot(point.x.toDouble(), point.y.toDouble()))
              .toList(),
          isCurved: false,
          dotData: FlDotData(
            show: true,
          ),
          color: colors[i % colors.length]));
    }
    if (addDummy) {
      data.add(LineChartBarData(
          spots: [FlSpot(18.0, 0.0)],
          isCurved: false,
          dotData: FlDotData(
            show: false,
          ),
          color: Colors.black));
    }

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.grey[300],
          lineBarsData: data,
          borderData: FlBorderData(
              border: const Border(bottom: BorderSide(), left: BorderSide())),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: _bottomTitles),
            leftTitles: AxisTitles(sideTitles: _leftTitles),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  Widget getLegend() {
    List<int> indices = [];
    for (var i = 0; i < legendEntries.length; i++) indices.add(i);

    List<Widget> entries = [];
    for (var i = 0; i < legendEntries.length; i++) {
      if (i < points.length && !points.isEmpty) {
        entries.add(Row(children: [
          Icon(Icons.circle, size: 14, color: colors[i % colors.length]),
          SpaceH(2),
          Text(legendEntries[i]),
          SpaceH(i == legendEntries.length - 1 ? 0 : 8),
        ]));
      }
    }

    return SizedBox(
        height: 20,
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: entries));
  }

  TextStyle style =
      GoogleFonts.lato(color: Colors.black, fontSize: 12, height: 1.0);

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) {
          if (xtitles.isEmpty)
            return Container(
                padding: EdgeInsets.only(top: 2),
                child: Text(value.toInt().toString(), style: style));
          return Container(
              padding: EdgeInsets.only(top: 2),
              child: Text(xtitles[value.toInt()], style: style));
        },
      );

  SideTitles get _leftTitles => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: getInterval(),
        getTitlesWidget: (value, meta) {
          return Container(
              child: Text(
                value.toInt().toString(),
                textAlign: TextAlign.right,
                style: style,
              ),
              padding: EdgeInsets.only(right: 2));
        },
      );

  double getInterval() {
    int guess = (getMaxY() - getMinY()) ~/ 10;
    if (guess == 0) return 1;
    if (guess <= 2) return guess.toDouble();
    if (guess <= 5) return 5;
    if (guess <= 10) return 10;
    return (guess / 10).floor() * 10;
  }

  int getMaxY() {
    int max = 0;
    for (var i = 0; i < points.length; i++) {
      for (var j = 0; j < points[i].length; j++) {
        if (points[i][j].y > max) max = points[i][j].y.toInt();
      }
    }
    return max;
  }

  int getMinY() {
    int min = 0;
    for (var i = 0; i < points.length; i++) {
      for (var j = 0; j < points[i].length; j++) {
        if (points[i][j].y < min) min = points[i][j].y.toInt();
      }
    }
    return min;
  }
}
