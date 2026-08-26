#!/usr/bin/env bash
set -euo pipefail

mode="${1:-debug}"
if [[ "$mode" != "debug" && "$mode" != "release" ]]; then
  echo "Usage: $0 [debug|release]" >&2
  exit 2
fi
if [[ "$mode" == "release" && ! -f android/key.properties ]]; then
  echo "Release signing is not configured: add ignored android/key.properties and enable release signing." >&2
  exit 3
fi

flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk "--$mode"

source_apk="build/app/outputs/flutter-apk/app-$mode.apk"
mkdir -p artifacts
cp "$source_apk" "artifacts/zanka-no-tachi-$mode.apk"
shasum -a 256 "artifacts/zanka-no-tachi-$mode.apk" > "artifacts/zanka-no-tachi-$mode.apk.sha256"
echo "Created APK and SHA-256 in artifacts/"
