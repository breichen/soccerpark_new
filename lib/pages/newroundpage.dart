import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/persist_stub.dart'
    if (dart.library.js_interop) '../utils/persist_web.dart';
import '../widgets/appbar.dart';
import '../widgets/button.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/toast.dart';
import '../widgets/space.dart';
import '../dialogs/addplayerdialog.dart';
import '../dialogs/editplayerdialog.dart';
import '../dialogs/singlebuttoncanceldialog.dart';
import './roundpage.dart';

class NewRoundPage extends StatefulWidget {
  const NewRoundPage({super.key});

  @override
  State<NewRoundPage> createState() => _NewRoundPageState();
}

class _NewRoundPageState extends State<NewRoundPage> {
  final double outsep = 4;
  final double insep = 4;
  final double colsep = 4;
  final double vsep = 20;

  // ↓ hold tap position, set during onTapDown, using getPosition() method
  Offset tapXY = Offset.zero;
  // ↓ hold screen size, using first line in build() method
  late RenderBox overlay;

  List<PlayerPair> allPlayers = [];
  List<PlayerPair> selPlayers = [];

  @override
  void initState() {
    super.initState();

    Data.getAllPlayers().then((players) => {
          setState(() {
            selPlayers = [];
            allPlayers = players;
            allPlayers.sort((a, b) => a.name.compareTo(b.name));
            print("players size " + players.length.toString());
          })
        });
  }

  bool existsName(String name) {
    for (var i = 0; i < allPlayers.length; i++) {
      if (allPlayers[i].name == name) return true;
    }
    for (var i = 0; i < selPlayers.length; i++) {
      if (selPlayers[i].name == name) return true;
    }
    return false;
  }

  void start() {
    for (var i = 0; i < selPlayers.length; i++) {
      Data.storePlayerIndex(0, i + 1, selPlayers[i].id);
      //for (var hole = 1; hole <= 18; hole++)
      //  Data.storeScore(0, i + 1, hole, (i + hole) % 6 + 6); // TODO: Remove
    }
    Data.storeCurrentDate();

    // Web only: ask the browser to keep this data (no-op on Android/iOS).
    requestPersistentStorage();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoundPage(0)),
    ).whenComplete(() => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.newRound,
            MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Space(0),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SpaceH(outsep),
              Expanded(flex: 1, child: getLeftColumn()),
              SpaceH(colsep),
              Expanded(flex: 1, child: getRightColumn()),
              SpaceH(outsep),
            ]),
            Space(20),
            Visibility(
                child: Footer(),
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true)
          ]),
          Column(children: [Spacer(), Footer()])
        ]));
  }

  Widget getLeftColumn() {
    return Column(
        children: [Card(color: Colors.grey[200], child: getLeftList())]);
  }

  Widget getLeftList() {
    return allPlayers.isEmpty ? getLeftEmpty() : getLeftListFilled();
  }

  Widget getLeftListFilled() {
    var indices = [];
    for (var i = 0; i < allPlayers.length; i++) indices.add(i);

    return ListView(
        padding: EdgeInsets.all(insep),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: indices
            .map((idx) => InkWell(
                  child: Card(
                      color: Colors.grey[400],
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                          child: Row(children: [
                            Text(allPlayers[idx].name,
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    height: 1.3)),
                          ]))),
                  onTap: () {
                    if (selPlayers.length < Data.MAX_PLAYER_CNT)
                      setState(() {
                        selPlayers.add(allPlayers[idx]);
                        allPlayers.remove(allPlayers[idx]);
                      });
                  },
                  onTapDown: getPosition,
                  onLongPress: () {
                    getMenu(allPlayers, idx);
                  },
                ))
            .toList());
  }

  // ↓ create the RelativeRect from size of screen and where you tapped
  RelativeRect get relRectSize =>
      RelativeRect.fromSize(tapXY & const Size(40, 40), overlay.size);

  // ↓ get the tap position Offset
  void getPosition(TapDownDetails detail) {
    tapXY = detail.globalPosition;
  }

  Widget getLeftEmpty() {
    return ListView(
        padding: EdgeInsets.all(insep),
        shrinkWrap: true,
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: Text(AppLocalizations.of(context)!.noPlayerAvailable,
                  style: GoogleFonts.lato(
                      color: Colors.black, fontSize: 16, height: 1.3)))
        ]);
  }

  Widget getRightColumn() {
    return Column(children: [
      Card(color: Colors.grey[200], child: getRightList()),
      Space(15),
      getAddButton(),
      Space(15),
      getStartButton(),
    ]);
  }

  Widget getRightList() {
    var indices = [];
    for (var i = 0; i < Data.MAX_PLAYER_CNT; i++) indices.add(i);

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(insep),
        child: Column(
            children: indices.map((index) => getRightElement(index)).toList()));
  }

  Widget getRightElement(int idx) {
    return idx < selPlayers.length
        ? getRightElementName(idx)
        : getRightElementEmpty();
  }

  Widget getRightElementName(int idx) {
    return InkWell(
      child: Card(
          color: maincolor,
          child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: Text(selPlayers[idx].name,
                  style: GoogleFonts.lato(
                      color: Colors.white, fontSize: 16, height: 1.3)))),
      onTap: () {
        setState(() {
          allPlayers.add(selPlayers[idx]);
          allPlayers.sort((a, b) => a.name.compareTo(b.name));
          selPlayers.remove(selPlayers[idx]);
        });
      },
      onTapDown: getPosition,
      onLongPress: () {
        getMenu(selPlayers, idx);
      },
    );
  }

  Widget getRightElementEmpty() {
    return Card(
        color: Colors.grey[300],
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: Text("",
                style: GoogleFonts.lato(
                    color: Colors.white, fontSize: 16, height: 1.3))));
  }

  Widget getAddButton() {
    return Visibility(
        child: FlActionButton(
            AppLocalizations.of(context)!.addPlayer, Icons.add_circle, () {
          AddPlayerDialog dialog = AddPlayerDialog((String text) {
            text = text.trim();
            bool stored = false;
            setState(() {
              if (!existsName(text)) {
                Data.getCurrPlayerIndex().then((id) => {
                      selPlayers.add(PlayerPair(id, text)),
                      Data.addPlayer(text)
                    });
                stored = true;
              }
            });
            return stored;
          });
          showDialog(
              context: context, builder: (BuildContext context) => dialog);
        }),
        visible: selPlayers.length < 5,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true);
  }

  Widget getStartButton() {
    return FullWidthButton(AppLocalizations.of(context)!.start, () {
      if (selPlayers.isEmpty) {
        CustomToast.showToast(
          context,
          AppLocalizations.of(context)!.none_selected_error,
        );
        return;
      }

      SingleButtonCancelDialog dialog;
      Data.isStarted().then((started) => {
            if (started)
              {
                Data.isPlayStarted().then((playStarted) => {
                      if (playStarted)
                        {
                          dialog = SingleButtonCancelDialog(
                              context,
                              AppLocalizations.of(context)!.existing_round,
                              AppLocalizations.of(context)!.start_started,
                              AppLocalizations.of(context)!.start_new, () {
                            Data.clearCurrent();

                            Navigator.of(context).pop();
                            start();
                          }),
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => dialog)
                        }
                      else
                        {Data.clearCurrent(), start()}
                    }),
              }
            else
              {start()}
          });
    });
  }

  getMenu(List<PlayerPair> players, int idx) {
    return showMenu(
      context: context,
      position: relRectSize,
      items: <PopupMenuEntry>[
        PopupMenuItem(
            value: 0,
            child: Text(AppLocalizations.of(context)!.edit,
                style: GoogleFonts.lato(color: Color(mainredValue))),
            onTap: () {
              EditPlayerDialog dialog =
                  EditPlayerDialog(players[idx].name, (String text) {
                text = text.trim();
                bool stored = false;
                setState(() {
                  if (text == players[idx].name || (!existsName(text))) {
                    players[idx].name = text;
                    Data.setPlayerName(players[idx].id, text);
                    allPlayers.sort((a, b) => a.name.compareTo(b.name));
                    stored = true;
                  }
                });
                //Navigator.of(context).pop();
                return stored;
              });
              Future.delayed(
                  const Duration(seconds: 0),
                  () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialog)
                      });
            }),
        PopupMenuItem(
            value: 1,
            child: Text(AppLocalizations.of(context)!.delete,
                style: GoogleFonts.lato(color: Color(mainredValue))),
            onTap: () {
              SingleButtonCancelDialog dialog = SingleButtonCancelDialog(
                  context,
                  AppLocalizations.of(context)!.delete,
                  AppLocalizations.of(context)!.ask_delete_player,
                  AppLocalizations.of(context)!.delete, () {
                setState(() {
                  int id = players[idx].id;
                  players.remove(players[idx]);
                  Data.deletePlayer(id);
                });
                Navigator.of(context).pop();
                CustomToast.showToastIcon(context,
                    AppLocalizations.of(context)!.deleted_player, Icons.check);
              });
              Future.delayed(
                  const Duration(seconds: 0),
                  () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialog)
                      });
            }),
      ],
    );
  }
}
