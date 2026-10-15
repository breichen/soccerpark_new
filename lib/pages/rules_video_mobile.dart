import 'package:flutter/material.dart';

import '../main.dart';
import '../youtube/player/youtube_player.dart';
import '../youtube/utils/youtube_player_controller.dart';
import '../youtube/utils/youtube_player_flags.dart';
import '../youtube/widgets/duration_widgets.dart';
import '../youtube/widgets/full_screen_button.dart';
import '../youtube/widgets/progress_bar.dart';
import '../youtube/widgets/youtube_player_builder.dart';

/// Android/iOS: same player as before, moved out of rulespage.dart.
class RulesVideoBuilder extends StatefulWidget {
  const RulesVideoBuilder(
      {super.key, required this.videoId, required this.builder});

  final String videoId;
  final Widget Function(BuildContext context, Widget player) builder;

  @override
  State<RulesVideoBuilder> createState() => _RulesVideoBuilderState();
}

class _RulesVideoBuilderState extends State<RulesVideoBuilder> {
  late final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: widget.videoId,
    flags: YoutubePlayerFlags(autoPlay: false, mute: false),
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
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
          FullScreenButton(controller: _controller),
        ],
      ),
      builder: widget.builder,
    );
  }
}
