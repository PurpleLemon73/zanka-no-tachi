#!/usr/bin/env bash
set -euo pipefail

mode="${1:-debug}"
if [[ "$mode" != "debug" && "$mode" != "release" ]]; then
  echo "Usage: $0 [debug|release]" >&2
  exit 2
fi
expected_package="dev.zanka.notachi"
expected_signer="3F4A86F7F4DDA398E04DD059DD33D7FC274CACB36217A468B6D8D7C7074C1341"

android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$android_sdk" && -f android/local.properties ]]; then
  android_sdk="$(sed -n 's/^sdk.dir=//p' android/local.properties | sed 's/\\\\/:backslash:/g; s/\\:/:/g; s/:backslash:/\\/g')"
fi

find_build_tool() {
  local tool="$1"
  local candidate
  candidate="$(find "$android_sdk/build-tools" -type f -name "$tool" -perm -u+x 2>/dev/null | sort -V | tail -1)"
  [[ -n "$candidate" ]] || {
    echo "Android SDK tool '$tool' was not found." >&2
    exit 4
  }
  printf '%s' "$candidate"
}

if [[ "$mode" == "release" ]]; then
  if [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then
    echo "Refusing release: Git working tree is not clean." >&2
    exit 3
  fi
  if [[ ! -f android/key.properties ]]; then
    echo "Release signing is not configured: create ignored android/key.properties." >&2
    exit 3
  fi
  if git ls-files --error-unmatch android/key.properties >/dev/null 2>&1; then
    echo "Refusing release: android/key.properties is tracked." >&2
    exit 3
  fi
  if [[ -z "$android_sdk" || ! -d "$android_sdk/build-tools" ]]; then
    echo "Android SDK build-tools could not be located." >&2
    exit 4
  fi
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
  apksigner="$(find_build_tool apksigner)"
  aapt="$(find_build_tool aapt)"
  badging="$($aapt dump badging "$artifact")"
  [[ "$badging" == *"package: name='$expected_package'"* ]] || {
    echo "Release package identity verification failed." >&2
    exit 5
  }
  [[ "$badging" == *"versionName='$version'"* ]] || {
    echo "Release version verification failed." >&2
    exit 5
  }
  "$apksigner" verify "$artifact"
  actual_signer="$($apksigner verify --print-certs "$artifact" | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' | tr -d '[:space:]:' | tr '[:lower:]' '[:upper:]')"
  [[ "$actual_signer" == "$expected_signer" ]] || {
    echo "Release signer fingerprint verification failed." >&2
    exit 6
  }
  echo "Created verified production-signed release APK and SHA-256: $artifact"
  echo "Signer SHA-256: 3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41"
fi
