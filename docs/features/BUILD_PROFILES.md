# Development and production builds

Zanka uses two explicit compile-time Flutter flavors: `development` and
`production`. One typed `BuildProfile` reads Flutter's reserved
`FLUTTER_APP_FLAVOR` constant. Flutter supplies it from `--flavor`; do not set
that reserved value manually. There is no runtime preference or production
unlock gesture. Missing, misspelled or unknown values fail closed to production
Dart policy. Android builds require an explicit flavor; no global default
flavor is imposed on other platforms' existing native configurations.

## Commands and identities

```bash
flutter pub get
flutter run --flavor development
flutter test --flavor development
flutter test --flavor production test/app/build_profile_test.dart
flutter build apk --debug --flavor development
flutter build apk --release --flavor production
```

| Profile | Android application ID | Launcher label | Primary artifact |
| --- | --- | --- | --- |
| Development | `dev.zanka.notachi.debug` | Zanka no Tachi Dev | `build/app/outputs/flutter-apk/app-development-debug.apk` |
| Production | `dev.zanka.notachi` | Zanka no Tachi | `build/app/outputs/flutter-apk/app-production-release.apk` |

The identity suffix belongs to the **product flavor**, not the debug build type.
Development and production therefore have separate app-owned storage and can
coexist. A production-flavor debug build still has the production application ID
but a debug signer: do not install it over a signed production app. Use the
development flavor for everyday debugging. Existing development debug installs
retain their ID; existing signed production installs retain their upgrade ID.

Reuse the existing supported toolchain. No dependency, Flutter, Gradle, AGP or
Kotlin upgrade is part of this split. Better Player's retained development
plugin requires a full JDK 21+; use a compatible installed JDK for the build
process without changing another project's global configuration.

Production signing continues to use ignored `android/key.properties` and the
external permanent keystore. Never commit either or print passwords. The
expected certificate SHA-256 is
`3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`.
`tool/build_release_candidate.sh debug` selects development, while its `release`
mode and `tool/release_android.sh` select production and retain the existing
clean-tree/signing checks. Neither publishes a release.

## Product boundary

Both profiles retain Home, Search, Library, manga/anime Details, real metadata
editing, imports/backup, source enablement and manually reviewed base addresses,
the reader/player, canonical progress, exact source resume, watched management,
Display Mode, fullscreen and semantic TV support. Source address configuration
is available in normal Sources settings on mobile and TV rather than requiring
the developer harness. It never discovers alternative domains automatically.

Only development exposes sample installers, demo metadata enrichment, Developer
Sources/Adapter Diagnostics, local diagnostic copying/clearing, and the
experimental playback-engine selector. The existing mobile developer gesture
works only in development; production cannot unlock it. Hidden sections include
their spacing/dividers, leaving real Settings and About content intact.

Automatic remains `video_player`. Production composition only selects that
engine, even if an older device-local preference names Better Player; it does
not rewrite the preference or display an experimental fallback message.
Development retains Better Player 1.3.0 on Android and all its tests. This is
**not native dependency removal**: Flutter still registers the retained plugin
and may package its native/transitive dependencies in both variants. Its
runtime is not opened by production composition. No further engine certification
or native dependency pruning is implied.

## Demo assets and data

Flutter's supported flavor-scoped asset declarations bundle these directories
only for development, without moving or duplicating them:

- `assets/sample_anime/`
- `assets/showcase/ashen_blade/`
- `assets/showcase/nova_pulse/`

Both profiles start without demo seed data by default. Development provides
manual sample installation and may explicitly opt into deterministic bootstrap:

```bash
flutter run --flavor development --dart-define=ZANKA_SHOWCASE=true
```

`ZANKA_SHOWCASE_TV=true` remains a development-only showcase override. Both
showcase flags are ignored by production. Real TV detection is unchanged.

On upgrade, the production product projection hides the two app-owned showcase
IDs only while all their media bindings are known showcase bindings. A reviewed
merge that retains a showcase ID with a real binding stays visible. No database
rows, canonical IDs, library records, progress, resume, local files or backups
are deleted or migrated. Development can still display previously installed
showcases. Generic local-file resolvers remain registered because they can
serve legitimate existing user data; they are not fake providers.

## Privacy and verification

Production does not wire the app-owned diagnostic recorder or expose its UI.
Development retains bounded/redacted diagnostics. Better Player logging remains
disabled; no analytics, telemetry or media-locator logging was added. Platform
runtime errors are not a new app-owned logging surface.

The complete regression suite runs with `--flavor development` to retain its
lawful fixtures. The focused profile suite also runs as production and verifies
asset-manifest exclusion, empty bootstrap, blocked demo entry points, real
editing/configuration, retained user progress, and inaccessible developer UI.
Unflavored tests use production policy; use the documented development command
for the full historical regression suite.

For artifact checks, inspect APK entries under `assets/flutter_assets/assets/`,
check package/label and debug status using Android `aapt`, and verify the
production certificate with `apksigner verify --print-certs`. Do not infer asset
exclusion from hidden UI alone.

### Verified split checkpoint

- Repository-wide formatting: 157 files checked, zero changes.
- `flutter analyze`: no issues.
- `flutter test --flavor development`: **413 tests passed**, including the
  historical reader/player/TV suite and the repaired developer-flow test. Its
  ProductShell assertion now uses `product-primary-navigation`, not branding copy.
- Production profile tests: **10 passed**, with both `ZANKA_SHOWCASE` and
  `ZANKA_SHOWCASE_TV` deliberately enabled to prove they cannot enable demos or
  override production presentation. Five additional production product-flow
  tests passed (phone/tablet navigation, search/Library, offline Continue and
  anime Details).
- Both APKs built with the existing installed JDK 23.0.2 using a command-local
  Gradle Java-home override; no global toolchain or dependency change.

| Inspected artifact | Bytes | Demo asset entries | Verified identity |
| --- | ---: | ---: | --- |
| Development/debug APK | 207,442,672 | 11 | `dev.zanka.notachi.debug`, “Zanka no Tachi Dev”, debuggable |
| Production/release APK | 69,203,561 | 0 | `dev.zanka.notachi`, “Zanka no Tachi”, not debuggable |

`apksigner` verified the production APK against the permanent certificate above.
Its SHA-256 is
`dd9fae2239395713044b64cad3368952d30474704e973322cb86814dd4dbefde`.
Both artifacts retain MainActivity's phone and Leanback launch entries; the
production manifest keeps Leanback and touchscreen optional. APKs are local
build outputs, not tracked files or published release assets. The application
version remains `0.2.0-beta.4+5`.

Physical follow-up: install both variants side by side without uninstalling
production; confirm distinct names/data, empty production Home, real import and
backup, Sources, absent developer unlock, development sample/engine controls,
and TV launcher/remote navigation. Use lawful content for reader/player smoke
checks. These changes do not claim physical Fire TV certification.
