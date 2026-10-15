import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final Set<String> _registered = <String>{};

/// Web: plain YouTube embed (privacy-friendly nocookie domain) in an iframe.
class RulesVideoBuilder extends StatelessWidget {
  const RulesVideoBuilder(
      {super.key, required this.videoId, required this.builder});

  final String videoId;
  final Widget Function(BuildContext context, Widget player) builder;

  @override
  Widget build(BuildContext context) {
    final viewType = 'soccerpark-youtube-$videoId';
    if (_registered.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = web.document.createElement('iframe')
            as web.HTMLIFrameElement
          ..src = 'https://www.youtube-nocookie.com/embed/$videoId'
          ..title = 'Soccerpark'
          ..allowFullscreen = true
          ..allow =
              'accelerometer; encrypted-media; picture-in-picture; fullscreen';
        iframe.style
          ..border = '0'
          ..width = '100%'
          ..height = '100%';
        return iframe;
      });
    }
    return builder(
      context,
      AspectRatio(
        aspectRatio: 16 / 9,
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}
