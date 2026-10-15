# Soccerpark als Flutter-PWA

Diese Dateien in dein echtes Projekt kopieren (überschreiben/ergänzen). Android-/iOS-Ordner bleiben unberührt.

## Bauen und testen
    flutter pub get
    flutter run -d chrome                 # Entwicklung
    flutter build web --release           # erzeugt build/web inkl. Service Worker
    cd build/web && python3 -m http.server 8080   # lokal testen (localhost zählt als sicher)

## Deployment (Firebase Hosting, HTTPS)
    firebase deploy --only hosting        # in firebase.json ist "hosting" schon eingetragen

## Hinweise
- Anleitung-Seite: Android/iOS nutzen weiter den InAppWebView-Player aus `lib/youtube`; im Web zeigt
  `rules_video_web.dart` ein YouTube-iframe. `lib/youtube` wird für Web nicht kompiliert.
- `lib/youtube_player_flutter` wird von der App nicht importiert (reine Kopie des Pakets).
- Mobile weiter wie bisher: `flutter build apk` / `flutter build ipa`.
