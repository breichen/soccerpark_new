# Deploying the Soccerpark PWA into a WordPress subfolder

Target address: https://www.soccerpark.at/app/
(Always use the `www` address everywhere: links, QR codes, printouts.
`soccerpark.at` and `www.soccerpark.at` have separate saved data in the browser.)

## One-time check
- You need FTP/SFTP or file-manager access to the web space of soccerpark.at.
  Self-hosted WordPress is fine. WordPress.com plans that block custom file
  uploads are not.

## Build
    flutter pub get
    flutter build web --release --base-href /app/

## Upload
1. In the web root (the folder containing `wp-content`), create a folder `app`.
2. Upload the CONTENTS of `build/web` into `app/` (not the `web` folder itself).
   `index.html` must end up at `app/index.html`.
3. Copy `deploy/wordpress/.htaccess` into `app/`.

## Link it from the website
In Elementor add a button or menu item to `https://www.soccerpark.at/app/`
(keep the trailing slash). Optional: a QR code of that address at the entrance.
Add a short "Add to Home Screen" note on the page:
- Android Chrome: menu (three dots) > Install app / Add to Home screen
- iPhone Safari: Share > Add to Home Screen

## Test (after every upload)
1. Open https://www.soccerpark.at/app/ in a private tab: the app loads, no blank page.
2. DevTools > Application > Manifest: no errors, icons visible.
3. DevTools > Application > Service Workers: one worker is "activated".
4. Start a round: DevTools > Application > Storage shows "Persistent".
5. Open the Anleitung page: the video loads.

## Updating the app
Build again and re-upload `build/web` over the old files (overwrite all).
Users receive the new version on their next visit, or the one after.

## Troubleshooting
- Blank page / 404 for main.dart.js: built without `--base-href /app/`, or files uploaded one level too deep.
- Old version still shown: purge the cache of LiteSpeed Cache, Wordfence or
  Cloudflare, and check that the `.htaccess` in `app/` is active.
- `.wasm` errors in the console: the host does not serve `application/wasm`;
  the `.htaccess` line `AddType application/wasm .wasm` fixes it on Apache/LiteSpeed.
- Nginx host (no `.htaccess` support): ask the host to add the same MIME type and
  `Cache-Control: no-cache` for index.html, flutter_bootstrap.js,
  flutter_service_worker.js, manifest.json and version.json.
