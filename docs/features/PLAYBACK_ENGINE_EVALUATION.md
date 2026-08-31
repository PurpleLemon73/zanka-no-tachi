# M16 Playback Engine Evaluation

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
