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
version="$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)"
artifact="artifacts/zanka-no-tachi-v$version.apk"
mkdir -p artifacts
cp "$source_apk" "$artifact"
shasum -a 256 "$artifact" > "$artifact.sha256"
if [[ "$mode" == "debug" ]]; then
  echo "Created debug-signed development APK and SHA-256: $artifact"
else
  echo "Created maintainer-signed release APK and SHA-256: $artifact"
fi
