#!/usr/bin/env sh
# Downloads the Lato files the app uses (Light 300, Regular 400, Bold 700)
# plus the OFL license into assets/google_fonts/, where google_fonts finds them.
set -e
cd "$(dirname "$0")/../assets/google_fonts"
base=https://raw.githubusercontent.com/google/fonts/main/ofl/lato
for f in Lato-Light Lato-Regular Lato-Bold; do
  curl -fL -o "$f.ttf" "$base/$f.ttf"
done
curl -fL -o OFL.txt "$base/OFL.txt"
ls -l
