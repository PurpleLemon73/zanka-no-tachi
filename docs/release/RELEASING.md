# Releasing

Current preparation: **1.0.0-rc.1+6**, not a stable release or a published RC.
See [RC.1](v1.0.0-rc.1.md) for artifact paths, prior evidence and pending checks.

## Prepare

Use Flutter 3.47.2, full JDK 21 (CI uses Temurin), Gradle 9.3.1, AGP 9.1.0 and
Kotlin 2.4.0. Select the JDK with local `ZANKA_JAVA_HOME` or CI's `JAVA_HOME`;
see [JDK selection](../features/BUILD_PROFILES.md#jdk-21-selection). A JRE without
`javac`/`jlink` is insufficient. The build helper checks and pins JDK 21 without
changing global Flutter settings.

1. Use a clean checkout and verify no database, backup, imported media, local
   config, keystore or credential is tracked.
2. Update `pubspec.yaml`, `AppIdentity` and `CHANGELOG.md` consistently.
3. From the clean preparation commit, run `tool/release_android.sh` with JDK 21.
   Test that exact signed production artifact using the non-destructive
   [RC checklist](v1.0.0-rc.1.md#candidate-installation-checklist).
4. Verify the generated SHA-256 file and all CI checks.
5. Audit every reachable commit—not only `HEAD`—for credentials, private
   workflow material, copyrighted validation media, local paths/databases, and
   unintended large binaries before changing repository visibility.

Debug APKs are testing artifacts only:
`tool/with_android_jdk.sh flutter build apk --debug --flavor development`.
CI additionally checks `tool/with_android_jdk.sh flutter build apk --debug --flavor production`
without release credentials. The signed production variant is maintainer/local
only: `tool/with_android_jdk.sh flutter build apk --release --flavor production`. See
[Build profiles](../features/BUILD_PROFILES.md) for identities and exclusions.

## Signed Android release

Signing credentials are never committed. Configure the permanent external key
through ignored `android/key.properties`; see [Production signing](PRODUCTION_SIGNING.md).
Release intentionally never falls back to a debug key.

```bash
tool/release_android.sh
```

Without local signing configuration,
`tool/build_release_candidate.sh release` fails clearly before building.

The release helper also runs `tool/verify_release_startup.sh` against the actual
APK before copying it to `artifacts/`. This requires SDK cmdline-tools/latest.
It checks that `WorkDatabase_Impl` retains its public no-argument constructor:
Better Player's Android dependency brings WorkManager 2.7.0 / Room 2.2.5, whose
consumer rules alone do not retain that reflected constructor under strict R8
full mode. The narrow application rule preserves it without disabling shrinking.

This artifact check is **not** a launch certification. Install the signed
production APK as an in-place update (`adb -s SERIAL install -r APK`), without
uninstalling or clearing data. Launch `dev.zanka.notachi/.MainActivity`, verify
Home and basic navigation, close/reopen, and inspect fresh package-scoped logs
for startup failures. An `am start` success alone is insufficient: Android
startup providers can still crash before Flutter displays Home. Keep physical
Samsung/Fire verification of each new candidate explicitly pending until those
devices are retested. The maintainer has confirmed startup and primary flows
on both devices for the corrected pre-RC build at `98d3b2e`; that evidence does
not certify the newly versioned RC.1 artifact.

The workflow writes `build/app/outputs/flutter-apk/app-production-release.apk`,
then `artifacts/zanka-no-tachi-v1.0.0-rc.1.apk` and its `.sha256` for RC.1.
It does not commit, push, tag, upload or create a GitHub Release. Check Android
`versionName=1.0.0-rc.1` and `versionCode=6`, not just the filename. Retain the
APK checksum and corresponding R8 mapping privately with the candidate.

Production is `dev.zanka.notachi`; development is `dev.zanka.notachi.debug`.
Production excludes demo assets, Developer UI and experimental engine selection.
`video_player` is its only selectable engine; Better Player's native plugin and
transitive dependencies remain packaged. RC.1 changes neither database schema
6 nor backup format 3. Older supported backups remain readable; exact engine
and Video Display Mode preferences stay device-local during restore.

Beta.2 and later production-signed builds update in place with the permanent
fingerprint documented above. Never uninstall or clear an existing production
installation for RC testing. The old debug-signed beta.1 has a separate
[migration guide](BETA1_TO_BETA2_MIGRATION.md), not an RC update procedure.

Publication is a separate, explicitly authorized action after candidate gates
pass. RC.1 preparation creates no tag or GitHub Release. If later authorized,
use `.github/RELEASE_TEMPLATE.md`, attach only the intended artifact/checksum,
and verify the downloaded checksum. A future rename
requires updating `AppIdentity`, pubspec, platform display names/package IDs,
docs, and migration/reinstall notes.
