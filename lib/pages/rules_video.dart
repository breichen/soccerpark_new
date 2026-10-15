// Mobile keeps the existing InAppWebView based player (lib/youtube/...).
// On the web that player cannot work (no JS handlers / evaluateJavascript),
// so a plain YouTube iframe is used and lib/youtube is not compiled at all.
export 'rules_video_mobile.dart'
    if (dart.library.js_interop) 'rules_video_web.dart';
