# Contributing

Use Flutter 3.47.2 and full JDK 21, matching CI. Set local `ZANKA_JAVA_HOME` or
`JAVA_HOME` to that JDK; see [JDK selection](docs/features/BUILD_PROFILES.md#jdk-21-selection).
The Android wrapper does not change global machine configuration. Run
`flutter pub get`, then before every PR run:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --flavor development
flutter test --flavor production test/app/build_profile_test.dart
tool/with_android_jdk.sh flutter build apk --debug --flavor development
tool/with_android_jdk.sh flutter build apk --debug --flavor production
```

Profiles are compile-time Flutter flavors, not runtime settings. Development
tests intentionally include lawful demo assets. Unflavored Dart invocations
default to production policy; Android builds must select a flavor. See
[Build profiles](docs/features/BUILD_PROFILES.md) for production builds and
package/asset separation.

## Rules

- Canonical identity is independent of provider IDs, domains and file paths.
- Library/progress survive adapter replacement, refresh and merge/split.
- HTTP/parsing and payload resolution stay outside widgets.
- Capabilities are explicit; metadata-only sources remain metadata-only.
- Never auto-merge different providers from title similarity alone.
- Imports use canonical bindings; destructive actions distinguish state,
  bindings and physical files.
- Backups/archives are untrusted, bounded and traversal-safe.

Protected page/stream extraction, hidden-token resolution, DRM/access-control,
anti-bot/CAPTCHA bypass and blocked-domain discovery are out of scope.

Fixtures must be lawful, minimized, representative, free of secrets/personal
data, and parsed offline in normal tests. Add positive and failure tests. Update
the relevant public document under `docs/` when architecture changes.

Keep PRs focused and explain the user outcome, invariant impact, tests, manual
validation and migration/backup implications. Never commit build output,
databases, backups, imported media, credentials or personal paths. Bug reports
should include platform/Flutter version, reproducible steps and a redacted
Developer Diagnostics report—never private media, tokens or backup contents.
