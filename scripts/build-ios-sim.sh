#!/bin/sh
# Builds the iOS simulator app from a copy outside ~/Documents.
# Documents is synced by iCloud, which adds Finder attributes to build output
# and makes Xcode's CodeSign fail ("resource fork ... detritus not allowed").
set -eu
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${LUEUR_BUILD_DIR:-$HOME/Developer/.build/lueur}"
mkdir -p "$DEST"
rsync -a --delete --exclude .git --exclude build --exclude .dart_tool --exclude ios/Pods "$SRC/" "$DEST/"
cd "$DEST"
flutter pub get >/dev/null
flutter build ios --simulator --debug
echo "App: $DEST/build/ios/iphonesimulator/Runner.app"
