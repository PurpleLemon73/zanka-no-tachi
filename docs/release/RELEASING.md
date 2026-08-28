# Releasing

## Prepare

Use Flutter 3.47.2's supported Android stack: JDK 17–25, Gradle 9.3.1, AGP
9.1.0 and Kotlin 2.4.0. A JRE without `jlink` is insufficient.

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

Signing credentials are never committed. Configure the permanent external key
through ignored `android/key.properties`; see [Production signing](PRODUCTION_SIGNING.md).
Release intentionally never falls back to a debug key.

```bash
tool/release_android.sh
```

Without local signing configuration,
`tool/build_release_candidate.sh release` fails clearly before building.

Beta.1 was debug-signed. Beta.2 and later public Android releases use the
permanent fingerprint documented above. Publish the required beta.1
backup/uninstall/install/restore migration warning prominently.

Tag `vX.Y.Z`, draft a GitHub Release from `.github/RELEASE_TEMPLATE.md`, attach
only the intended artifact/checksum, and verify the downloaded checksum. A future rename
requires updating `AppIdentity`, pubspec, platform display names/package IDs,
docs, and migration/reinstall notes.
