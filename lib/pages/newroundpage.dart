import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/persist_stub.dart'
    if (dart.library.js_interop) '../utils/persist_web.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/toast.dart';
import '../widgets/space.dart';
import '../dialogs/addplayerdialog.dart';
import '../dialogs/editplayerdialog.dart';
import '../dialogs/singlebuttoncanceldialog.dart';
import './roundpage.dart';

/// Neue Runde: Mitspieler wählen und ordnen, dann starten.
class NewRoundPage extends StatefulWidget {
  const NewRoundPage({super.key});

  @override
  State<NewRoundPage> createState() => _NewRoundPageState();
}

class _NewRoundPageState extends State<NewRoundPage> {
  /// Position des letzten Tipps (für das Bearbeiten/Löschen-Menü).
  Offset tapXY = Offset.zero;

  /// Gespeicherte, noch nicht gewählte Spieler (alphabetisch).
  List<PlayerPair> allPlayers = [];

  /// Mitspieler in Spielreihenfolge.
  List<PlayerPair> selPlayers = [];

  bool get isFull => selPlayers.length >= Data.MAX_PLAYER_CNT;

  @override
  void initState() {
    super.initState();
    Data.getAllPlayers().then((players) {
      if (!mounted) return;
      setState(() {
        selPlayers = [];
        allPlayers = players;
        sortAvailable();
      });
    });
  }

  void sortAvailable() =>
      allPlayers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  bool existsName(String name) =>
      allPlayers.any((p) => p.name == name) ||
      selPlayers.any((p) => p.name == name);

  void select(PlayerPair p) {
    if (isFull) return;
    setState(() {
      allPlayers.remove(p);
      selPlayers.add(p);
    });
  }

  void deselect(PlayerPair p) {
    setState(() {
      selPlayers.remove(p);
      allPlayers.add(p);
      sortAvailable();
    });
  }

  void start() {
    for (var i = 0; i < selPlayers.length; i++) {
      Data.storePlayerIndex(0, i + 1, selPlayers[i].id);
    }
    Data.storeCurrentDate();

    // Web only: ask the browser to keep this data (no-op on Android/iOS).
    requestPersistentStorage();

    // Diese Seite durch die Runde ersetzen: "Zurück" aus der Runde führt
    // dann nicht mehr hierher. (Früher wurde sie nach Ende der Runde
    // nachträglich geschlossen; das schloss nach "Zum Menü" versehentlich
    // das neue Hauptmenü und hinterließ eine leere App.)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RoundPage(0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(context, l.newRound, MenuItemE.COUNT, []),
        bottomNavigationBar: getStartBar(l),
        body: ListView(padding: EdgeInsets.all(16), children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: sectionTitle(l.players_title)),
            Text(l.players_count(selPlayers.length, Data.MAX_PLAYER_CNT),
                style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 13)),
          ]),
          Space(8),
          getSelectedList(l),
          Space(20),
          sectionTitle(l.add_players),
          Space(8),
          getAvailableChips(l),
          Space(8),
          Text(l.long_press_hint,
              style: GoogleFonts.lato(color: Colors.grey[500], fontSize: 12)),
          Space(16),
        ]));
  }

  Widget sectionTitle(String text) => Text(text,
      style: GoogleFonts.lato(
          color: maincolor, fontSize: 17, fontWeight: FontWeight.bold));

  /// Mitspieler: nummeriert, per Griff verschiebbar, mit Kreuz entfernbar.
  Widget getSelectedList(AppLocalizations l) {
    final decoration = BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12));

    if (selPlayers.isEmpty) {
      return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: decoration,
          child: Text(l.select_players_hint,
              style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 15)));
    }

    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: decoration,
        child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: selPlayers.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final p = selPlayers.removeAt(oldIndex);
                selPlayers.insert(newIndex, p);
              });
            },
            proxyDecorator: (child, index, animation) => Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: child),
            itemBuilder: (context, i) {
              final p = selPlayers[i];
              return Material(
                  key: ValueKey(p.id),
                  color: Colors.white,
                  child: InkWell(
                      onTapDown: (d) => tapXY = d.globalPosition,
                      onLongPress: () => showPlayerMenu(selPlayers, p),
                      child: Container(
                          decoration: BoxDecoration(
                              border: i == 0
                                  ? null
                                  : Border(
                                      top: BorderSide(
                                          color: Colors.grey[200]!))),
                          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                          child: Row(children: [
                            ReorderableDragStartListener(
                                index: i,
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.drag_indicator,
                                        color: Colors.grey[400]))),
                            Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: maincolor, shape: BoxShape.circle),
                                child: Text((i + 1).toString(),
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                            SpaceH(12),
                            Expanded(
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            IconButton(
                                icon: Icon(Icons.close,
                                    color: Colors.grey[500], size: 20),
                                onPressed: () => deselect(p)),
                          ]))));
            }));
  }

  /// Gespeicherte Spieler als Chips plus "Neuer Spieler".
  Widget getAvailableChips(AppLocalizations l) {
    final chips = <Widget>[
      for (final p in allPlayers)
        GestureDetector(
            onTapDown: (d) => tapXY = d.globalPosition,
            onLongPress: () => showPlayerMenu(allPlayers, p),
            child: Material(
                color: isFull ? Colors.grey[200] : dropdownChipColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: isFull
                        ? () => CustomToast.showToast(
                            context, l.players_full_error)
                        : () => select(p),
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add,
                              size: 16,
                              color: isFull ? Colors.grey[500] : maincolor),
                          SpaceH(4),
                          Text(p.name,
                              style: GoogleFonts.lato(
                                  color: isFull ? Colors.grey[600] : maincolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ]))))),
      // Neuer Spieler (gestrichelter Rahmen gibt es in Flutter nicht direkt;
      // ein heller Rand mit Icon unterscheidet ihn von den anderen Chips)
      Material(
          color: Colors.white,
          shape: StadiumBorder(side: BorderSide(color: maincolor)),
          child: InkWell(
              customBorder: StadiumBorder(),
              onTap: addPlayer,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.person_add_alt_1_outlined,
                        size: 18, color: maincolor),
                    SpaceH(6),
                    Text(l.new_player,
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ])))),
    ];
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  /// Neuen Spieler anlegen; ist noch Platz, spielt er gleich mit.
  void addPlayer() {
    AddPlayerDialog dialog = AddPlayerDialog((String text) {
      text = text.trim();
      if (text.isEmpty || existsName(text)) return false;
      Data.getCurrPlayerIndex().then((id) {
        Data.addPlayer(text);
        if (!mounted) return;
        setState(() {
          final p = PlayerPair(id, text);
          if (isFull) {
            allPlayers.add(p);
            sortAvailable();
          } else {
            selPlayers.add(p);
          }
        });
      });
      return true;
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  /// Fester Startknopf am unteren Rand.
  Widget getStartBar(AppLocalizations l) {
    final enabled = selPlayers.isNotEmpty;
    return SafeArea(
        child: Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: Material(
                color: enabled ? maincolor : Colors.grey[300],
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: enabled
                        ? onStart
                        : () => CustomToast.showToast(
                            context, l.none_selected_error),
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: enabled
                                      ? Colors.white
                                      : Colors.grey[600]),
                              SpaceH(6),
                              Text(
                                  enabled
                                      ? (selPlayers.length == 1
                                          ? l.start_round_one
                                          : l.start_round(selPlayers.length))
                                      : l.select_players_hint,
                                  style: GoogleFonts.lato(
                                      color: enabled
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ]))))));
  }

  /// Start; fragt nach, wenn bereits eine Runde mit Schlägen läuft.
  void onStart() {
    final l = AppLocalizations.of(context)!;
    Data.isStarted().then((started) {
      if (!started) {
        start();
        return;
      }
      Data.isPlayStarted().then((playStarted) {
        if (!mounted) return;
        if (!playStarted) {
          Data.clearCurrent();
          start();
          return;
        }
        final dialog = SingleButtonCancelDialog(
            context, l.existing_round, l.start_started, l.start_new, () {
          Data.clearCurrent();
          Navigator.of(context).pop();
          start();
        }, destructive: true);
        showDialog(context: context, builder: (BuildContext context) => dialog);
      });
    });
  }

  /// Menü zum Bearbeiten oder Löschen (langes Drücken).
  void showPlayerMenu(List<PlayerPair> list, PlayerPair player) {
    final l = AppLocalizations.of(context)!;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<int>(
      context: context,
      position: RelativeRect.fromSize(tapXY & const Size(40, 40), overlay.size),
      items: [
        PopupMenuItem(
            value: 0,
            child: Row(children: [
              Icon(Icons.edit_outlined, color: maincolor, size: 20),
              SpaceH(12),
              Text(l.edit,
                  style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ])),
        PopupMenuItem(
            value: 1,
            child: Row(children: [
              Icon(Icons.delete_outline, color: mainred, size: 20),
              SpaceH(12),
              Text(l.delete,
                  style: GoogleFonts.lato(
                      color: mainred,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ])),
      ],
    ).then((value) {
      if (!mounted || value == null) return;
      if (value == 0) {
        final dialog = EditPlayerDialog(player.name, (String text) {
          text = text.trim();
          if (text.isEmpty) return false;
          if (text != player.name && existsName(text)) return false;
          setState(() {
            player.name = text;
            Data.setPlayerName(player.id, text);
            sortAvailable();
          });
          return true;
        });
        showDialog(context: context, builder: (BuildContext context) => dialog);
      } else {
        final dialog = SingleButtonCancelDialog(
            context, l.delete, l.ask_delete_player, l.delete, () {
          setState(() {
            list.remove(player);
            Data.deletePlayer(player.id);
          });
          Navigator.of(context).pop();
          CustomToast.showToastIcon(context, l.deleted_player, Icons.check);
        }, destructive: true);
        showDialog(context: context, builder: (BuildContext context) => dialog);
      }
    });
  }
}
