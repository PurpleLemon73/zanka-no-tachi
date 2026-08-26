# Releasing

## Prepare

1. Use a clean checkout and verify no database, backup, imported media, local
   config, keystore or credential is tracked.
2. Update `pubspec.yaml`, `AppIdentity` and `CHANGELOG.md` consistently.
3. Run `tool/build_release_candidate.sh debug`, then the fresh-install smoke
   test in `RELEASE_HARDENING.md`.
4. Verify the generated SHA-256 file and all CI checks.

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

Tag `vX.Y.Z`, draft a GitHub Release from `.github/RELEASE_TEMPLATE.md`, attach
signed artifacts/checksums, and verify the downloaded checksum. A future rename
requires updating `AppIdentity`, pubspec, platform display names/package IDs,
docs, and migration/reinstall notes.
