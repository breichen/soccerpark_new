import 'dart:js_interop';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web/web.dart' as web;

bool _asked = false;

/// Asks the browser not to evict this site's storage (localStorage holds the
/// rounds, players and settings) when it runs low on space.
///
/// Browsers decide on their own: Chrome/Edge grant it silently for installed
/// or frequently used sites, Firefox asks the user, Safari grants it for
/// sites added to the home screen. A refusal is harmless, so errors and
/// missing support (older browsers) are ignored.
Future<void> requestPersistentStorage() async {
  if (_asked) return; // once per app start is enough
  _asked = true;
  try {
    final storage = web.window.navigator.storage;
    final already = (await storage.persisted().toDart).toDart;
    if (already) return;
    final granted = (await storage.persist().toDart).toDart;
    debugPrint('Persistent storage ${granted ? 'granted' : 'not granted'}');
  } catch (e) {
    debugPrint('Persistent storage not available: $e');
  }
}
