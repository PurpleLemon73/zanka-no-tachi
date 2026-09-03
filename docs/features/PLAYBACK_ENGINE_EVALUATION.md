# Playback Engine Evaluation

## M19-A Better Player compatibility baseline

**Checkpoint result: passed for dependency and Android build coexistence only.**
The original `jhomlala/betterplayer` package is pinned as
`better_player: 1.3.0` (hosted-package SHA-256
`002e84c20f8233af1108b1f8ad7bdade0d4dc5129363d2b85d9a1fa40059182d`)
in `pubspec.lock`. This is not `better_player_plus` or another fork. Its
required Dart floor remains `^3.12.0`; the existing Flutter 3.47.2 / Dart
3.13.2 installation satisfies its Flutter `>=3.47.0` floor.

The initial 1.2.0 baseline could build only while the aggregate Dart library
was unused. A subsequent real import exposed upstream references to the missing
`BetterPlayerUtils` class in 12 Dart files. Version 1.3.0 removes every
executable `BetterPlayerUtils` reference and routes those calls through its new
`PlayerLogger`. The retained focused test
(`test/player/better_player_compatibility_test.dart`) imports the public package,
constructs and disposes `BetterPlayerController`, and invokes
`BetterPlayerUiUtils`; both focused analysis and execution pass, so this
compatibility gate cannot be satisfied through application tree shaking.

M19-A adds no Better Player adapter, selector, fixture, or product code beyond
that compile regression. The production engine and Automatic selection remain
`video_player`; Better Player cannot yet be selected by Zanka. Runtime playback
and physical device approval are deliberately deferred to the full M19
integration.

### Dependency and toolchain evidence

- Pub resolves the aggregate `better_player` package at exactly 1.3.0. Its
  `better_player_android`, `better_player_ios`, and
  `better_player_platform_interface` packages remain exactly 1.2.0 with the
  same hashes as the earlier baseline. The Android bridge resolves `jni` 1.0.3,
  `jni_flutter` 1.0.3, and `jni_util` 1.0.0.
- The lockfile delta from 1.2.0 is only the aggregate package version and hash;
  the SDK floors and all transitive versions are unchanged. The aggregate has
  no Android project or bundled native artifacts.
- The complete Pub graph and Gradle `releaseRuntimeClasspath` were inspected.
  Better Player declares Media3 1.1.1, `androidx.media:media` 1.6.0,
  Lifecycle 2.4.0-beta01, annotation 1.2.0, and WorkManager 2.7.0.
- App conflict resolution selects Media3 1.9.2 throughout the packaged runtime,
  alongside `video_player_android` 2.12.1. It also selects media 1.7.0,
  Lifecycle 2.10.0, and annotation 1.10.0; WorkManager remains 2.7.0. Nothing
  forces Media3 down to 1.1.1.
- Better Player's module compile classpath remains Media3 1.1.1 while the final
  app runtime is 1.9.2. Debug D8 and release R8 both accept that boundary, but
  real source playback is still a mandatory M19 compatibility test.
- Better Player compiles Java and Kotlin to JVM 21. Local builds used Android
  Studio's JBR 25.0.2, which supports that target; CI now pins Temurin JDK 21
  explicitly. Zanka's Android project, compile/target SDK 36, minimum SDK 24,
  Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, and M14 native code were preserved.

### Build, registration, and package footprint

Both compatibility artifacts built successfully without integrating the
adapter. They are byte-identical to the 1.2.0 compatibility artifacts because
the application does not yet reference the aggregate library and the native
subpackages are unchanged; the focused test above is the independent Dart
compile gate:

| Artifact | Result | Bytes | Change from beta.4 | SHA-256 |
| --- | --- | ---: | ---: | --- |
| Debug APK | Pass | 197,366,024 | +39,134,756 (+24.73%) | `be0891fd98e5139bcfed29dd09780409d01dfde426e00f81726d69d229310681` |
| Signed release APK | Pass, including R8 | 92,747,514 | +669,934 (+0.73%) | `748a577e3888c6228102e0dd14095873684ba885755e9652c37acf4ad997a929` |

The release APK retains the permanent Zanka signer certificate whose SHA-256
is `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`.
R8 produced its release mapping and packaged the Better/JNI classes without a
missing-class or shrinker failure. `flutter pub get`, focused `dart analyze`,
the focused Flutter test, debug D8, and signed release/R8 all passed.

Generated Android registration adds `BetterPlayerPlugin`, `JniPlugin`, and
`JniFlutterPlugin`; the Dart registrant selects `BetterPlayerAndroid`. JNI also
adds its generated FFI entry to Linux and Windows plugin CMake files, although
M19-A validates Android only. Better Player's AAR is JVM-only. The sole new
native library in the release APK is `libdartjni.so`:

| APK ABI | Uncompressed bytes |
| --- | ---: |
| arm64-v8a | 131,432 |
| armeabi-v7a | 81,628 |
| x86_64 | 116,824 |

Media3/AndroidX contribute no new `.so` codec runtime. No FFmpeg/libav, mpv, or
VLC binary is present. WorkManager's transitive manifest merge adds
`FOREGROUND_SERVICE` and `RECEIVE_BOOT_COMPLETED`, its initializer, services,
and receivers. Better Player itself does not schedule that work unless its
cache/pre-cache paths are used; this packaged background surface must still be
reviewed during the full adapter integration.

The 1.3.0 aggregate itself adds five pure-Dart logging files but no plugin,
manifest, JNI, ABI, Maven, or packaged `.so` change. Its default release log
level is INFO and controller setup can log the full data-source URL. The future
adapter must configure `PlayerLoggerConfiguration` with logging disabled so
ephemeral media locators never enter logs.

### Lifecycle and single-owner preflight

The resolved 1.3.0 aggregate over the 1.2.0 platform bridge permits the future
adapter to keep Zanka in control:

- `PlayerControlsConfiguration(showControls: false,
  showControlsOnInitialize: false)` suppresses stock controls;
- `handleLifecycle: false`, `autoDispose: false`, and final
  `dispose(forceDispose: true)` let Zanka own lifecycle and teardown;
- every source can use `NotificationConfiguration(showNotification: false)`;
  Better's Android MediaSession is created only by its notification path;
- `enablePip: false` keeps its controls from entering PiP, and Zanka will not
  call the still-available programmatic PiP API;
- explicit `setMixWithOthers(true)` maps to Media3 audio-focus handling being
  disabled, leaving the existing M14 bridge as the only MediaSession and audio
  focus owner.

The future adapter must enforce one active controller, because the native event
bridge broadcasts callbacks across active Better controllers. It must also
verify notification teardown, HOME/return behavior, exact resume, and the
rendered subtitle layer on real devices before any production approval.

### Resolved license inventory

The resolved Pub closure was audited beyond Better Player's top-level license:

- Apache-2.0: aggregate Better Player 1.3.0, its three Better Player 1.2.0
  platform packages, `clock` 1.1.2, and `material_color_utilities` 0.13.0;
- BSD-3-Clause: `args` 2.7.0, `async` 2.13.1, `code_assets` 2.0.0,
  `collection` 1.19.1, `crypto` 3.0.7, `csslib` 1.0.2, `cupertino_ui` 1.0.2,
  `ffi` 2.2.0, `ffi_leak_tracker` 0.1.2, `hooks` 2.2.0, `http` 1.6.0,
  `http_parser` 4.1.2, `intl` 0.20.3, the three JNI packages listed above,
  `logging` 1.3.0, `material_ui` 1.1.1, `meta` 1.19.0, `objective_c` 9.6.0,
  `package_config` 2.2.0, `package_info_plus` 10.2.1 and its interface 4.1.0,
  `path` 1.9.1, `path_provider` 2.1.6, `path_provider_android` 2.2.23,
  `path_provider_foundation` 2.5.1, `path_provider_linux` 2.2.1,
  `path_provider_platform_interface` 2.1.2, `path_provider_windows` 2.3.0,
  `platform` 3.1.6,
  `plugin_platform_interface` 2.1.8, `pub_semver` 2.2.0, `record_use` 1.1.1,
  `source_span` 1.10.2, `string_scanner` 1.4.1, `term_glyph` 1.2.2,
  `typed_data` 1.4.0, `vector_math` 2.4.2, `visibility_detector` 0.4.0+2,
  `wakelock_plus` 1.8.0 and its interface 1.7.0, `web` 1.1.1, `win32` 6.4.0,
  and `xdg_directories` 1.1.0;
- MIT: `cupertino_icons` 1.0.9, `flutter_widget_from_html_core` 0.17.3,
  `html` 0.15.6, `petitparser` 7.0.2, `xml` 7.0.1, and `yaml` 3.1.3;
- MPL-2.0: `dbus` 0.7.15, reached through `wakelock_plus`. This is file-level
  weak copyleft, not an LGPL/GPL codec runtime.

AndroidX and Media3 Maven artifacts inspected in the release graph are
Apache-2.0. `libdartjni.so` combines BSD-3-Clause JNI sources with an
Apache-2.0 AOSP wrapper. No GPL, LGPL, AGPL, or bundled non-free media runtime
was found. Two Better sources retain Chromium-style BSD headers not reproduced
by the package-level Apache file, so a future distribution notice must include
the applicable BSD attribution. APK notices also do not enumerate individual
AndroidX/Media3 Maven coordinates; M19 must produce a complete third-party
notice/SBOM before approval. Device-provided Widevine can be requested by
Better's optional DRM API, but it is not bundled and Zanka will not configure
protected-content playback.

The `flutter`, `flutter_localizations`, and `flutter_web_plugins` SDK packages
are governed by the Flutter SDK distribution rather than Pub-cache package
licenses.

The iOS package references Hyperoslo Cache 6.x (MIT), but this repository does
not currently lock its exact native version. That and the newly generated
Linux/Windows JNI entries are supported-platform risks outside this Android
checkpoint and must be resolved before calling the optional engine portable.

## M17 production decision

M17 selects **Option 3: reject the experimental media_kit runtime for the
production application**. Television_4K did not advance HLS/DASH or preserve
exact reopen, the experiment had no integration with Zanka's single
MediaSession/audio-focus owner, added roughly 33.3 MB, and lacked a distributable
LGPL compliance package. Those mandatory gates were not passed.

The production package therefore contains only `video_player`. The probe entry
point, dependencies, generated plugin registrations, and lawful evaluation
fixtures were removed. The durable engine contract and registry remain, and an
unavailable future preference falls back explicitly to the approved production
engine. Automatic selection never chooses an unapproved engine.

No media_kit/libmpv code ships after M17, so it creates no LGPL runtime
obligations in the resulting APK. The historical M16 findings below remain the
evidence behind this decision.

## M17 package verification

A local signed release verification build is 91,913,516 bytes: +229,444 bytes
from the 91,684,072-byte beta.2 baseline. It has one RSA-4096 signer and the
established Zanka release certificate. The modest change is Player UI v2 and
engine-boundary code only; no experimental native media runtime, LGPL fixture,
or probe entry point is packaged.

## Decision

`video_player` remains Zanka's production playback engine. The M16
`media_kit` work was an isolated evaluation target; it is no longer present in
the application or its package graph. Canonical progress, watched state,
autoplay, source resolution, Smart Resume, lifecycle, and the Android
MediaSession bridge remain engine-neutral application concerns.

The spike demonstrates materially better track APIs, but it does not clear the
migration rule. On Television_4K the generated MP4 played and exposed two audio
tracks plus an external subtitle, while the local HLS/DASH fixtures did not
advance and reopening at an exact timestamp did not retain that timestamp. The
recommendation is **do not migrate in M17 without a focused reliability
investigation**.

## M17 engine boundary and selection policy

`PlaybackEngine` defines an engine-neutral surface, open/play/pause/seek/rate
operations, a `ValueListenable` of phase/buffering/duration/position/error/track
state, and explicit capabilities. `AnimePlayerScreen` sees no plugin controller,
libmpv object, or provider implementation. `VideoPlayerPlaybackEngine` is the
sole production adapter and owns the `video_player` controller.

The registry selects the approved production adapter for Automatic and
`video_player`. `mediaKit` remains only a compatibility value for a possible
future persisted preference: it returns a clear fallback reason and creates the
production adapter instead. It is neither listed in normal product UI nor
available for automatic selection. There is no debug flag, probe entry point,
runtime, or fixture left in this repository after M17.

## Historical M16 licensing audit

Audited inputs:

- `media_kit` 1.2.6 — MIT
- `media_kit_video` 2.0.1 — MIT
- `media_kit_libs_android_video` 1.3.8 — MIT wrapper
- exact native runtime: `libmpv-android-video-build` v1.1.7 `default-*` only
- runtime build source commit
  `fe8c3ac1a91c09aa6fb1deccbc833f1bafa54768`

The wrapper downloads only the four pinned `default` ABI artifacts. The exact
source build sets mpv `-Dgpl=false`; FFmpeg uses `--disable-gpl
--disable-nonfree --enable-version3`. The default dependency graph excludes
`libx264`, `libvpx`, `libvorbis`, `libogg`, and `fftools_ffi`; those enter the
separately named `encoders-gpl` flavor, which Zanka never references.

| Component | Version | Distribution choice |
| --- | --- | --- |
| mpv/libmpv | pinned `78d4374…` | LGPL mode (`gpl=false`) |
| FFmpeg | 6.0 | LGPL v3-compatible; GPL/non-free disabled |
| libass | 0.17.1 | ISC |
| FreeType | 2.13.0 | FreeType License choice |
| HarfBuzz | 7.2.0 | MIT |
| FriBidi | 1.0.12 | LGPL 2.1+ |
| mbedTLS | 3.4.0 | Apache-2.0 |
| dav1d | 1.2.0 | BSD-2-Clause |
| libxml2 | 2.10.3 | MIT |

No GPL or non-free runtime was enabled in the historical experiment. Any future
production migration would still need the applicable notices, relinking or
corresponding-source duties, and the exact-native-build audit. That compliance
package was not created. M17 ships none of these dependencies, so this history
does not create a current APK obligation.

## Historical M16 comparison evidence

### Production `video_player`

Phase A used the same Samsung and Television_4K targets. Local H.264/AAC MP4,
play/pause, seek, Smart Resume, HOME/return, exact source timestamp, natural
completion/autoplay, native MediaSession, media keys, and single-owner audio
focus passed. Television_4K live playback advanced from 0:10, HOME paused, and
return restored 0:16. The production release APK is 91,684,072 bytes.

### `media_kit` on Television_4K

- default libmpv loaded on Android 16 arm64;
- original MP4 rendered and played to completion;
- two embedded audio tracks were discovered and switched;
- external SRT loaded as a truthful subtitle track;
- seek reached approximately 7.5 seconds;
- invalid input failed with a bounded timeout;
- local HLS and DASH reported duration/tracks but did not advance;
- reopen-at-7-seconds returned to zero, failing exact-resume parity;
- the emulator forced software rendering and showed a material initial stall;
- the probe intentionally does not activate Zanka's MediaSession bridge, so it
  cannot create a second competing session. Full bridge parity is unproven.

### Samsung Android 16

The final probe APK checksum was matched byte-for-byte before launch and ran
beside production as `dev.zanka.notachi.debug`. On the physical Samsung Android
16 device with Vulkan rendering:

- MP4 play, seek, two-audio discovery/switching, and external SRT passed;
- exact reopen requested 7.000 seconds and resumed at 7.083 seconds (a second
  run observed 7.125 seconds);
- loopback-served HLS and DASH both advanced beyond 500 ms;
- invalid input emitted only redacted errors and a bounded timeout;
- during active MP4 playback, HOME paused at 3.541 seconds; return preserved
  exactly 3.541 seconds and remained paused;
- no crash, protected media, screenshots, or provider locators were involved.

The experimental probe deliberately has no Zanka MediaSession. Thus native
media buttons, Zanka audio-focus ownership, watched state, source switching and
autoplay remain proven only on the production `video_player` path. They cannot
be credited to media_kit without a real integration.

### Size

- production beta.2 release APK: 91,684,072 bytes (91.7 MB decimal)
- experimental release-mode probe: approximately 125.0 MB
- increase: approximately 33.3 MB, including about 3.6 MB of original fixtures
  and the four-ABI default runtime

## Feature matrix

| Requirement | video_player production | media_kit spike |
| --- | --- | --- |
| MP4 play/pause/seek | Pass | Pass on TV |
| Exact source resume | Pass | Samsung pass; TV fail |
| HOME/return | Pass | Samsung pause/hold pass; bridge parity unproven |
| MediaSession/audio focus | Pass, single Zanka owner | Not integrated |
| Audio discovery/switch | Not reliably exposed | Pass (2 tracks) |
| Embedded subtitles | Not reliably exposed | API present; not fixture-tested |
| External subtitles | Not exposed | Pass (SRT) |
| HLS | Live production path passes | Samsung pass; TV fail |
| DASH | Not currently required | Samsung pass; TV fail |
| Invalid input | Product error UX/retry | Bounded failure |
| TV D-pad/product controls | Pass | Probe only |
| Watched/autoplay/source switch | Pass | Kept outside engine |
| Fire OS | Physical deferred | Physical deferred |

## M17 conclusion

M17 does not migrate automatically. The Samsung result proved material track and
format advantages, but Television_4K still failed exact reopen and segmented
playback. A future experiment must first explain those failures, integrate with
the existing single-owner MediaSession/audio-focus contract, complete the
release-grade LGPL package, and repeat the Samsung and TV matrix. Only then
could it become a product candidate.

M17 removed the experimental packages, generated registrants, probe source, and
lawful fixtures before this work can enter a production artifact. The Player UI
v2 and engine-neutral contract remain independently useful with the approved
production engine.
