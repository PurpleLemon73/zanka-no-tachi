# Playback Engine Evaluation

## M19-B experimental adapter and selector

M19-B integrates the original `better_player: 1.3.0` package as an optional
Android-only adapter for controlled basic-MP4 comparison. It does not replace
the production adapter: **Automatic** and explicit **video_player** both create
`VideoPlayerPlaybackEngine`. **Better Player (Experimental)** must be selected
explicitly under Settings → Developer; if that adapter is unavailable on the
current platform/build, the registry creates `video_player` and reports the
fallback. A changed selection applies when the next player session is created,
never by replacing an active decoder.

The preference is part of device-local playback settings. It is deliberately
omitted from portable backup serialization, and restore preserves the receiving
device's existing engine choice. Choosing an engine cannot change canonical
progress, watched state, exact binding-specific resume, source preference, or
Video Display Mode.

### Basic-MP4 boundary

`BetterPlayerPlaybackEngine` implements the existing plugin-neutral
`PlaybackEngine` contract through a private Better Player driver. Widgets see
only normalized readiness, play/pause, buffering, duration, position,
completion, errors, intrinsic ratio, seek, and playback-rate state. The M19-B
adapter accepts local `file:` MP4s and HTTP(S) locators whose path identifies an
MP4; unsupported formats fail before a native controller is created. It does
not claim HLS, DASH, audio-track selection, subtitle selection, or external
subtitle support, so Player UI v2 renders no untruthful track controls.

Opening is bounded and remains paused after applying the requested
binding-specific resume. A resume at or beyond the observed duration safely
starts from zero. Public failures are fixed, locator-free messages. Each open
has a generation fence, and a process-wide experimental-engine lease retires
the prior controller before a new one can receive Android's broadcast plugin
events. Listener removal, forced native texture disposal, timer/readiness
cancellation, and engine disposal are idempotent; late events cannot update a
replacement or disposed session.

### Zanka ownership and locator hygiene

Better Player supplies only its decoder texture. Stock controls, autoplay,
automatic lifecycle handling, automatic disposal, notifications, PiP,
background behavior, ASMS track discovery, and retry UI are disabled. Zanka
continues to own Player UI v2, lifecycle/HOME handling, canonical navigation,
progress/resume persistence, and its M14 MediaSession/audio-focus bridge. The
controller is paused before Zanka explicitly chooses playback, and
`setMixWithOthers(true)` disables Better's competing Media3 focus request.
Notifications remain off, so Better's notification-owned MediaSession path is
not activated.

Better Player 1.3.0 otherwise defaults to INFO logging and its upstream setup
messages can contain a complete media URL. Every M19-B controller instead uses
`PlayerLogLevel.none`, no caller information, and an empty output list. Its
uncaught asynchronous source-error zone and teardown paths convert errors to
fixed messages without printing exception objects, headers, file paths, or
locators. Logging must remain disabled unless a later milestone introduces an
explicitly redacted diagnostic wrapper.

Video Display Mode remains outside both engines. Its single authoritative
surface computes Auto/Original, Fit, Fill/Crop, Fit Width, Fit Height, Stretch,
aspect presets, and custom ratios. Better's raw texture uses `BoxFit.fill` only
inside that already calculated tight frame; it performs no second aspect-ratio
or fit transform. Live display changes therefore do not reopen the engine,
seek, or write progress.

### Android manifest and dependency scope

The Better Android bridge retains its transitive WorkManager declarations,
including `FOREGROUND_SERVICE`, `RECEIVE_BOOT_COMPLETED`, the initializer,
services, and receivers. The native player constructor calls
`WorkManager.getInstance(context)` even for ordinary playback; removing the
initializer without supplying and maintaining an equivalent application-level
configuration could make controller creation fail. M19-B therefore does not
strip those components. Zanka never invokes Better's cache/pre-cache APIs, so
the adapter does not enqueue cache work, request a foreground notification, or
enable background playback.

The compatibility inventory remains the M19-A 1.3.0 inventory below: Better's
Android platform package is 1.2.0, `libdartjni.so` is its only added native
library, and no FFmpeg/libav, libmpv, VLC, GPL, LGPL, or bundled non-free media
runtime is introduced.

### M19-B closure evidence

M19-B passed its bounded experimental basic-MP4 gate on 2026-09-07. Formatting
changed no files, `flutter analyze` reported no issues, and all 204 Flutter
tests passed. The large-library guard passed in 304 ms. The final artifacts
were:

| Artifact | Result | Bytes | Change from beta.4 | SHA-256 |
| --- | --- | ---: | ---: | --- |
| Debug APK | Pass | 233,576,394 | n/a (debug baseline differs) | `6af673791ccd03a4ef97d2c7a3250b2f673576e9eadfc4b55e8195e88f5d781d` |
| Signed release APK | Pass, including R8 | 94,451,450 | +2,373,870 (+2.58%) | `e5570b27f21e69ad79e681309e46f42c9ab76d429ede5cd95f403592e91b0ddf` |

The release adapter delta over the M19-A dependency-only artifact is
1,703,936 bytes (+1.84%). R8 produced a 22,732,942-byte mapping. Final Gradle
`dependencyInsight` still selected Media3 1.9.2 over Better's 1.1.1 request;
no dependency was forced downward. The release APK contains only the existing
three Android ABIs and Better's `libdartjni.so` additions (131,432 bytes on
arm64-v8a, 81,628 on armeabi-v7a, and 116,824 on x86_64). The license result
remains Apache/BSD/MIT/MPL-2.0 only, with no GPL/LGPL/AGPL/non-free runtime.
The APK has one RSA-4096 signer and matches the permanent certificate SHA-256
`3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`.
Signing configuration and material remain ignored and untracked.

On Samsung SM-S948B / Android 16, a fresh debug install completed the lawful
12-second sample through Automatic/video_player and the 10-second sample
through Better. A 3458 ms Better source checkpoint survived route disposal;
after a controlled two-second reopen and pause the single Zanka MediaSession
reported 5046 ms. Selecting Fit left that paused position exactly 5046 ms,
then Reset restored Auto/Original. HOME removed the active Zanka session and
return recreated it paused at 695 ms. Exit removed it again. Audio diagnostics
showed paired requests/abandons owned only by `TvMediaBridge` for Zanka. The
episode-1 completion CTA opened episode 2 through Better, and final exit left
no Zanka session. A redacted scan found zero Better-named or media-locator log
lines.

On Television_4K / Android TV API 36 arm64 at 3840x2160, the selector, player,
episode controls, source choice, and Display Mode were D-pad usable. Both
Automatic/video_player and Better played the generated MP4s. Better showed
Replay and Next Episode, navigated to episode 2 without stale state, preserved
an exact 2299 ms checkpoint across exit/reopen, handled +/-10-second seeks,
and returned from HOME paused at 924 ms. Fit, Fill/Crop, Stretch/Fit Parent,
4:3, 16:9, 21:9, and custom 2.39:1 were exercised; Reset restored Auto. Back
closed the display sheet before leaving the player. During playback there was
one Zanka MediaSession and `TvMediaBridge` was the only Zanka focus owner;
after exit the session stack contained zero sessions and focus was abandoned.
A redacted scan found zero Better-named or media-locator log lines.

One long-lived TV debug process stopped reaching Better readiness after
several prior validation cycles; the same final APK worked after an in-place
reinstall created a clean app process, and subsequent playback/teardown passed.
Because Better remains experimental, this is retained as an M19-C stress-test
risk rather than interpreted as production approval. No media capture or
copyrighted validation artifact was retained. Fire physical validation remains
deferred because hardware is unavailable; no Fire certification is claimed.

### M19-B decision boundary

Better Player remains **Experimental/Developer-only** and Automatic remains
`video_player`. M19-B evaluates basic MP4 only. HLS, DASH, audio tracks,
subtitles, wider lifecycle/session certification, and any promotion decision
belong to M19-C. Fire physical validation remains deferred while hardware is
unavailable, and no Fire certification is claimed.

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

At the M19-A checkpoint there was no Better Player adapter, selector, fixture,
or product code beyond that compile regression. The production engine and
Automatic selection remained `video_player`; runtime playback and physical
device approval were deliberately deferred. The M19-B section above describes
the subsequent experimental basic-MP4 integration.

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
level is INFO and controller setup can log the full data-source URL. M19-B now
configures `PlayerLoggerConfiguration` with logging disabled so ephemeral media
locators never enter logs.

### Lifecycle and single-owner preflight

The resolved 1.3.0 aggregate over the 1.2.0 platform bridge permits the M19-B
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

M19-B enforces one active experimental controller because the native event
bridge broadcasts callbacks across active Better controllers. Its bounded
Samsung and Television_4K runs verified notification-free single-session
teardown, HOME/return, and source-specific resume for basic MP4. Subtitle
rendering remains outside this checkpoint and must be verified before any
production approval.

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
