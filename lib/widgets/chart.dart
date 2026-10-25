import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../utils/data.dart';

/// Linienfarben, kontrastreichste zuerst (gut lesbar auf Weiß).
final List<Color> chartColors = [
  maincolor,
  mainred,
  mainblue,
  mainviolet,
  mainorange,
  mainpink,
  Color(0xFF00897B), // Petrol
  Color(0xFF795548), // Braun
  Color(0xFFB7950B), // dunkles Gelb
];

const Color _parColor = Color(0xFF9E9E9E);

/// Liniendiagramm für Schläge pro Loch, kumulierte Schläge oder den Verlauf
/// über mehrere Runden.
///
/// - [legendEntries]: Spielernamen in der Reihenfolge von [points]. Über den
///   Namen bekommt jeder Spieler immer dieselbe Farbe.
/// - [parLine]: optionale Par-Werte, Index = x-Wert. Wird gestrichelt
///   gezeichnet.
/// - [tooltipTitle]: Überschrift im Tooltip beim Antippen, z. B. "Bahn 5".
/// - [tightY]: Y-Achse eng um die Werte statt ab 0 (für den Verlauf).
class LineChartWidget extends StatefulWidget {
  final List<List<PointPair>> points;
  final List<String> xtitles;
  final List<String> legendEntries;
  final bool addDummy;
  final List<double>? parLine;
  final String Function(int x)? tooltipTitle;
  final bool tightY;

  LineChartWidget(this.points,
      {this.xtitles = const [],
      this.legendEntries = const [],
      this.addDummy = false,
      this.parLine,
      this.tooltipTitle,
      this.tightY = false,
      Key? key})
      : super(key: key);

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();

  /// Par je Loch für Diagramme mit x = Loch 1-18 (Index 0 bleibt leer).
  static List<double> holeParLine(List<int> pars) =>
      [double.nan, ...pars.map((p) => p.toDouble())];

  /// Kumuliertes Par je Loch für x = Loch 1-18 (Index 0 bleibt leer).
  static List<double> cumulativeParLine(List<int> pars) {
    final out = <double>[double.nan];
    var sum = 0;
    for (final p in pars) {
      sum += p;
      out.add(sum.toDouble());
    }
    return out;
  }

  /// Gleiches Par für alle Runden im Verlauf (x = 0 .. count-1).
  static List<double> constantParLine(int par, int count) =>
      List<double>.filled(count, par.toDouble());
}

class _LineChartWidgetState extends State<LineChartWidget> {
  /// Spielername -> Spieler-ID, für gleichbleibende Farben.
  static Map<String, int> _playerIds = {};

  @override
  void initState() {
    super.initState();
    Data.getAllPlayers().then((players) {
      final ids = {for (final p in players) p.name: p.id};
      if (!mounted) {
        _playerIds = ids;
        return;
      }
      setState(() => _playerIds = ids);
    });
  }

  final TextStyle style =
      GoogleFonts.lato(color: Colors.grey[700], fontSize: 11, height: 1.0);

  /// Farbe je Datenreihe: nach Spieler-ID, ohne Doppelungen im Diagramm.
  List<Color> seriesColors() {
    final count = widget.points.length;
    final used = <int>{};
    final result = <Color>[];
    for (var i = 0; i < count; i++) {
      final name = i < widget.legendEntries.length ? widget.legendEntries[i] : null;
      var idx = (name != null ? _playerIds[name] : null) ?? i;
      idx = idx % chartColors.length;
      var tries = 0;
      while (used.contains(idx) && tries < chartColors.length) {
        idx = (idx + 1) % chartColors.length;
        tries++;
      }
      used.add(idx);
      result.add(chartColors[idx]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colors = seriesColors();
    final hasLegend = widget.legendEntries.isNotEmpty || widget.parLine != null;
    return LayoutBuilder(builder: (context, constraints) {
      // Mit fester Höhe (z. B. im Dialog) füllt das Diagramm den Platz neben
      // der Legende, sonst bestimmt das Seitenverhältnis die Höhe.
      final bounded = constraints.hasBoundedHeight;
      final chart = bounded
          ? Expanded(child: getChart(colors))
          : AspectRatio(aspectRatio: 1.8, child: getChart(colors));
      if (!hasLegend) {
        return bounded ? Column(children: [chart]) : chart;
      }
      return Column(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            chart,
            SizedBox(height: 8),
            getLegend(colors),
          ]);
    });
  }

  // ------------------------------------------------------------------
  // Werte und Achsen
  // ------------------------------------------------------------------

  List<double> allYValues() {
    final values = <double>[];
    for (final series in widget.points) {
      for (final p in series) {
        values.add(p.y);
      }
    }
    if (widget.parLine != null) values.addAll(parSpots().map((s) => s.y));
    return values;
  }

  double minY() {
    final values = allYValues();
    if (values.isEmpty) return 0;
    final min = values.reduce((a, b) => a < b ? a : b);
    if (widget.tightY) {
      final lower = (min - 2).floorToDouble();
      return lower < 0 ? 0 : lower;
    }
    return min < 0 ? min.floorToDouble() : 0;
  }

  double maxY() {
    final values = allYValues();
    if (values.isEmpty) return 1;
    final max = values.reduce((a, b) => a > b ? a : b);
    return widget.tightY ? (max + 2).ceilToDouble() : (max + 1).ceilToDouble();
  }

  double getInterval() {
    final range = maxY() - minY();
    if (range <= 8) return 1;
    if (range <= 16) return 2;
    if (range <= 40) return 5;
    if (range <= 80) return 10;
    return ((range / 8) / 10).ceil() * 10.0;
  }

  /// Höchster x-Wert der Spielerdaten (für die Länge der Par-Linie).
  int maxX() {
    var max = 0;
    for (final series in widget.points) {
      for (final p in series) {
        if (p.x > max) max = p.x;
      }
    }
    return max;
  }

  /// Par-Linie bis zum letzten x-Wert der Daten (bzw. bis Loch 18 bei
  /// addDummy, also im laufenden Rundenverlauf).
  List<FlSpot> parSpots() {
    final par = widget.parLine;
    if (par == null) return [];
    final last = widget.addDummy ? par.length - 1 : maxX();
    final spots = <FlSpot>[];
    for (var x = 0; x < par.length && x <= last; x++) {
      if (par[x].isNaN) continue;
      spots.add(FlSpot(x.toDouble(), par[x]));
    }
    return spots;
  }

  int? parAt(int x) {
    final par = widget.parLine;
    if (par == null || x < 0 || x >= par.length || par[x].isNaN) return null;
    return par[x].round();
  }

  String formatValue(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    final s = v.toStringAsFixed(1);
    return Localizations.localeOf(context).languageCode == 'de'
        ? s.replaceAll('.', ',')
        : s;
  }

  // ------------------------------------------------------------------
  // Diagramm
  // ------------------------------------------------------------------

  Widget getChart(List<Color> colors) {
    final List<LineChartBarData> data = [];
    final List<String?> barNames = [];
    for (var i = 0; i < widget.points.length; i++) {
      if (widget.points[i].isEmpty) continue;
      final color = colors[i];
      data.add(LineChartBarData(
          spots: widget.points[i]
              .map((point) => FlSpot(point.x.toDouble(), point.y.toDouble()))
              .toList(),
          isCurved: false,
          barWidth: 2.2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3, color: color, strokeWidth: 0),
          ),
          color: color));
      barNames.add(
          i < widget.legendEntries.length ? widget.legendEntries[i] : null);
    }

    final par = parSpots();
    if (par.isNotEmpty) {
      data.add(LineChartBarData(
          spots: par,
          isCurved: false,
          barWidth: 1.5,
          dashArray: [5, 4],
          dotData: FlDotData(show: false),
          color: _parColor));
      barNames.add(null); // Par-Linie: kein eigener Tooltip-Eintrag
    }
    final parBarIndex = par.isNotEmpty ? data.length - 1 : -1;

    if (widget.addDummy) {
      data.add(LineChartBarData(
          spots: [FlSpot(18.0, minY())],
          isCurved: false,
          barWidth: 0,
          dotData: FlDotData(show: false),
          color: Colors.transparent));
      barNames.add(null);
    }
    final dummyBarIndex = widget.addDummy ? data.length - 1 : -1;

    final interval = getInterval();

    return Padding(
        padding: EdgeInsets.only(top: 8, right: 8),
        child: LineChart(
          LineChartData(
            minY: minY(),
            maxY: maxY(),
            lineBarsData: data,
            borderData: FlBorderData(
                show: true,
                border: Border(bottom: BorderSide(color: Colors.grey[400]!))),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: _bottomTitles),
              leftTitles: AxisTitles(sideTitles: _leftTitles(interval)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (bar, indices) => indices
                  .map((i) => TouchedSpotIndicatorData(
                      FlLine(color: Colors.grey[300]!, strokeWidth: 1),
                      FlDotData(show: true)))
                  .toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Colors.white,
                tooltipBorder: BorderSide(color: Colors.grey[300]!),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (spots) {
                  var headerDone = false;
                  return spots.map((spot) {
                    if (spot.barIndex == parBarIndex ||
                        spot.barIndex == dummyBarIndex) {
                      return null;
                    }
                    final name = spot.barIndex < barNames.length
                        ? barNames[spot.barIndex]
                        : null;
                    final color = spot.bar.color ?? Colors.black;
                    final line = (name != null ? name + "  " : "") +
                        formatValue(spot.y);
                    if (headerDone) {
                      return LineTooltipItem(
                          line,
                          GoogleFonts.lato(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left);
                    }
                    headerDone = true;
                    return LineTooltipItem(
                        tooltipHeader(spot.x.round()),
                        GoogleFonts.lato(color: Colors.grey[700], fontSize: 12),
                        textAlign: TextAlign.left,
                        children: [
                          TextSpan(
                              text: line,
                              style: GoogleFonts.lato(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ]);
                  }).toList();
                },
              ),
            ),
          ),
        ));
  }

  String tooltipHeader(int x) {
    final parts = <String>[];
    if (widget.tooltipTitle != null) {
      parts.add(widget.tooltipTitle!(x));
    } else if (widget.xtitles.isNotEmpty && x >= 0 && x < widget.xtitles.length) {
      parts.add(widget.xtitles[x]);
    }
    final par = parAt(x);
    if (par != null) parts.add("Par " + par.toString());
    return parts.isEmpty ? "" : parts.join(" · ") + "\n";
  }

  Widget getLegend(List<Color> colors) {
    final List<Widget> entries = [];
    for (var i = 0; i < widget.legendEntries.length; i++) {
      if (i < widget.points.length && widget.points[i].isNotEmpty) {
        entries.add(Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 12, color: colors[i]),
          SizedBox(width: 4),
          Text(widget.legendEntries[i],
              style: GoogleFonts.lato(color: Colors.grey[800], fontSize: 13)),
        ]));
      }
    }
    if (widget.parLine != null) {
      entries.add(Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 18,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    3,
                    (_) => Container(
                        width: 4, height: 2, color: _parColor)))),
        SizedBox(width: 4),
        Text("Par",
            style: GoogleFonts.lato(color: Colors.grey[800], fontSize: 13)),
      ]));
    }

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(spacing: 14, runSpacing: 6, children: entries));
  }

  /// Nur so viele Beschriftungen, dass sie sich nicht überlappen
  /// (bei Rundendaten höchstens ca. 5).
  int labelStep() {
    if (widget.xtitles.isEmpty) return 1;
    return (widget.xtitles.length / 5).ceil().clamp(1, 100);
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        interval: 1,
        reservedSize: 22,
        getTitlesWidget: (value, meta) {
          final x = value.toInt();
          if (value != x.toDouble()) return SizedBox.shrink();
          String text;
          if (widget.xtitles.isEmpty) {
            text = x.toString();
          } else {
            if (x < 0 || x >= widget.xtitles.length || x % labelStep() != 0) {
              return SizedBox.shrink();
            }
            text = widget.xtitles[x];
          }
          return Container(
              padding: EdgeInsets.only(top: 4), child: Text(text, style: style));
        },
      );

  SideTitles _leftTitles(double interval) => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: interval,
        getTitlesWidget: (value, meta) {
          return Container(
              child: Text(
                formatValue(value),
                textAlign: TextAlign.right,
                style: style,
              ),
              padding: EdgeInsets.only(right: 4));
        },
      );
}
