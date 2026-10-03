import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import '../youtube/player/youtube_player.dart';
import '../youtube/utils/youtube_player_controller.dart';
import '../youtube/utils/youtube_player_flags.dart';
import '../youtube/widgets/youtube_player_builder.dart';
import '../youtube/widgets/duration_widgets.dart';
import '../youtube/widgets/full_screen_button.dart';
import '../youtube/widgets/progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  final double sep = 8;
  bool fullScreen = false;

  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'Xi9x7aQrEp8',
    flags: YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
  );

  String getVideoId() {
    var loc = App.of(context).getLocality();
    if (loc == Locality.WAGRAIN) return 'WHompKs4410';
    return 'Xi9x7aQrEp8';
  }

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: getVideoId(),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getContent();
  }

  Widget getContent() {
    return YoutubePlayerBuilder(
        player: getYouTubeVideo(),
        onEnterFullScreen: () {
          this.fullScreen = true;
        },
        onExitFullScreen: () {
          this.fullScreen = false;
        },
        builder: (context, player) {
          return Scaffold(
              appBar: CustomAppBar(context, AppLocalizations.of(context)!.rules,
                  MenuItemE.COUNT, []),
              body: Stack(children: [
                ListView(children: <Widget>[
                  Header(),
                  Visibility(
                      child: Row(children: [
                        SpaceH(14),
                        Expanded(child: player),
                        SpaceH(14)
                      ]),
                      visible:
                          App.of(context).getLocality() != Locality.GOLDBERG),
                  Space(5 * sep),
                  getTitle(),
                  Space(sep),
                  getTextBlock(context),
                  Space(10),
                  Visibility(
                      child: Footer(),
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true)
                ]),
                Column(children: [Spacer(), Footer()])
              ]));
        });
  }

  Widget getTitle() {
    return Container(
      child: Text(getTitleText(),
          style: GoogleFonts.lato(
              color: maincolor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3)),
      padding: EdgeInsets.fromLTRB(16, 0, 0, 6),
    );
  }

  String getTitleText() {
    var loc = App.of(context).getLocality();
    if (loc == Locality.SALZBURG)
      return AppLocalizations.of(context)!.rules_title;
    if (loc == Locality.WAGRAIN)
      return AppLocalizations.of(context)!.rules_wagrain_title;
    return AppLocalizations.of(context)!.rules_goldberg_title;
  }

  Widget getTextBlock(BuildContext context) {
    var keys = getTextKeys(context);

    List<Widget> rows = [];
    for (var i = 0; i < keys.length; i++) {
      rows.add(Space(sep));
      rows.add(FloatText(keys[i]));
    }

    return Column(children: rows);
  }

  List<String> getTextKeys(BuildContext context) {
    var loc = App.of(context).getLocality();

    if (loc == Locality.SALZBURG)
      return [
        AppLocalizations.of(context)!.rules1,
        AppLocalizations.of(context)!.rules2,
        AppLocalizations.of(context)!.rules3,
        AppLocalizations.of(context)!.rules4,
        AppLocalizations.of(context)!.rules5,
        AppLocalizations.of(context)!.rules6,
        AppLocalizations.of(context)!.rules7,
        AppLocalizations.of(context)!.rules8,
        AppLocalizations.of(context)!.rules9,
        AppLocalizations.of(context)!.rules10,
        AppLocalizations.of(context)!.rules11,
        AppLocalizations.of(context)!.rules12,
        AppLocalizations.of(context)!.rules13,
        AppLocalizations.of(context)!.rules14,
        AppLocalizations.of(context)!.rules15,
        AppLocalizations.of(context)!.rules16,
        AppLocalizations.of(context)!.rules17
      ];

    if (loc == Locality.WAGRAIN)
      return [
        AppLocalizations.of(context)!.rules1,
        AppLocalizations.of(context)!.rules2,
        AppLocalizations.of(context)!.rules3,
        AppLocalizations.of(context)!.rules4,
        AppLocalizations.of(context)!.rules5,
        AppLocalizations.of(context)!.rules6,
        AppLocalizations.of(context)!.rules7,
        AppLocalizations.of(context)!.rules_wagrain_8,
        AppLocalizations.of(context)!.rules10,
        AppLocalizations.of(context)!.rules11,
        AppLocalizations.of(context)!.rules12,
        AppLocalizations.of(context)!.rules14,
        AppLocalizations.of(context)!.rules15,
        AppLocalizations.of(context)!.rules16,
        AppLocalizations.of(context)!.rules17
      ];

    return [
      AppLocalizations.of(context)!.rules_goldberg_1,
    ];
  }

  YoutubePlayer getYouTubeVideo() {
    return YoutubePlayer(
      controller: _controller,
      bottomActions: [
        CurrentPosition(),
        const SizedBox(width: 4.0),
        ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
                playedColor: mainred,
                handleColor: mainred,
                backgroundColor: Colors.red[100],
                bufferedColor: Colors.red[300])),
        const SizedBox(width: 4.0),
        RemainingDuration(),
        FullScreenButton(
          controller: _controller,
        ),
      ],
      //onReady: () {
      //    _controller.addListener(listener);
      //},
    );
  }
}
