#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: tool/with_android_jdk.sh <command> [arguments...]" >&2
  exit 2
fi

# Explicit local selection wins; setup-java supplies JAVA_HOME in CI. Never
# discover Android Studio's JDK or rewrite Flutter's global jdk-dir setting.
android_jdk="${ZANKA_JAVA_HOME:-${JAVA_HOME:-}}"
if [[ -z "$android_jdk" ]]; then
  echo "Set ZANKA_JAVA_HOME (or JAVA_HOME) to a full JDK 21 installation." >&2
  exit 2
fi
for binary in java javac jlink; do
  if [[ ! -x "$android_jdk/bin/$binary" ]]; then
    echo "Android builds require a full JDK 21 with java, javac and jlink." >&2
    exit 2
  fi
done
android_jdk="$(cd "$android_jdk" && pwd -P)"
java_version="$("$android_jdk/bin/java" -version 2>&1)"
javac_version="$("$android_jdk/bin/javac" -version 2>&1)"
if [[ ! "$java_version" =~ version\ \"21([.\"]|$) ]] ||
   [[ ! "$javac_version" =~ ^javac\ 21([.[:space:]]|$) ]]; then
  echo "Android build baseline is JDK 21; select it via ZANKA_JAVA_HOME." >&2
  exit 2
fi

export JAVA_HOME="$android_jdk"
export PATH="$android_jdk/bin:$PATH"
# Flutter may override JAVA_HOME using its existing global configuration.
# Gradle's explicit daemon property still selects our checked compiler JDK.
# Quote for gradlew's JVM-option parser, including installation paths with spaces.
printf -v android_jdk_option '%q' "-Dorg.gradle.java.home=$android_jdk"
export GRADLE_OPTS="${GRADLE_OPTS:-} $android_jdk_option"
exec "$@"
