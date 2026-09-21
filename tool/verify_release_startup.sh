#!/usr/bin/env bash
set -euo pipefail

apk="${1:-}"
if [[ -z "$apk" || ! -f "$apk" ]]; then
  echo "Usage: $0 path/to/production-release.apk" >&2
  exit 2
fi

android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$android_sdk" && -f android/local.properties ]]; then
  android_sdk="$(sed -n 's/^sdk.dir=//p' android/local.properties | sed 's/\\\\/:backslash:/g; s/\\:/:/g; s/:backslash:/\\/g')"
fi
apkanalyzer="$android_sdk/cmdline-tools/latest/bin/apkanalyzer"
if [[ ! -x "$apkanalyzer" ]]; then
  echo "Release startup guard requires Android SDK cmdline-tools/latest (apkanalyzer)." >&2
  exit 2
fi

# Inspect the packaged DEX, not source rules or a possibly stale R8 mapping.
# Room loads this exact name and calls its public no-argument constructor before
# Flutter starts. A successful build alone does not prove it survived shrinking.
if ! database_code="$("$apkanalyzer" dex code --class androidx.work.impl.WorkDatabase_Impl "$apk")"; then
  echo "Release startup guard failed: WorkDatabase_Impl could not be inspected." >&2
  exit 1
fi
if ! grep -Eq '^\.method public constructor <init>\(\)V[[:space:]]*$' <<< "$database_code"; then
  echo "Release startup guard failed: WorkDatabase_Impl public no-argument constructor is missing." >&2
  exit 1
fi
echo "Release DEX startup guard passed. An actual device launch smoke test is still required."
