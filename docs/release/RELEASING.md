# Releasing

## Prepare

Use a full JDK 17–23. Gradle 8.12 in this beta does not support Java 25; a JRE
without `jlink` is also insufficient for Android's JDK image transform.

1. Use a clean checkout and verify no database, backup, imported media, local
   config, keystore or credential is tracked.
2. Update `pubspec.yaml`, `AppIdentity` and `CHANGELOG.md` consistently.
3. Run `tool/build_release_candidate.sh debug`, then the fresh-install smoke
   test in [Release hardening](RELEASE_HARDENING.md).
4. Verify the generated SHA-256 file and all CI checks.
5. Audit every reachable commit—not only `HEAD`—for credentials, private
   workflow material, copyrighted validation media, local paths/databases, and
   unintended large binaries before changing repository visibility.

Debug APKs are testing artifacts only: `flutter build apk --debug`.

## Signed Android release

Signing credentials are never committed. Create a local upload keystore and
configure signing through ignored `android/key.properties` (or CI secrets), then
enable the maintainer-owned release signing config in `build.gradle.kts`.
Release intentionally never falls back to a debug key.

```bash
flutter build apk --release
flutter build appbundle --release
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
```

Without local signing configuration,
`tool/build_release_candidate.sh release` fails clearly before building.

For the first beta, the locally prepared artifact is explicitly a debug-signed
development APK because no maintainer release key was supplied. Publish that
status beside the artifact; never describe it as production signed.

Tag `vX.Y.Z`, draft a GitHub Release from `.github/RELEASE_TEMPLATE.md`, attach
only the intended artifact/checksum, and verify the downloaded checksum. A future rename
requires updating `AppIdentity`, pubspec, platform display names/package IDs,
docs, and migration/reinstall notes.
