# M16 Playback Engine Evaluation

## Decision

`video_player` remains Zanka's production playback engine. The M16
`media_kit` work is an isolated evaluation target and is not wired into
`AnimePlayerScreen`, Smart Resume, source resolution, canonical progress,
watched state, autoplay, or the Android MediaSession bridge.

The spike demonstrates materially better track APIs, but it does not clear the
migration rule. On Television_4K the generated MP4 played and exposed two audio
tracks plus an external subtitle, while the local HLS/DASH fixtures did not
advance and reopening at an exact timestamp did not retain that timestamp. The
recommendation is **do not migrate in M17 without a focused reliability
investigation**.

## Boundary and lawful probe

`PlaybackEngine` defines open, play/pause, seek, speed, track discovery,
selection, external subtitles, state streams, and disposal. Production defaults
to `PlaybackEngineKind.videoPlayer`; the experimental kind requires explicit
injection or `ZANKA_EXPERIMENTAL_MEDIA_KIT=true`. `MediaKitPlaybackEngine` is
used only by `lib/m16_playback_probe.dart`. Product widgets still instantiate
the proven `video_player` controller.

Debug builds use package suffix `.debug`, so the probe can coexist with the
permanently signed public app without replacing its data or signing identity.

The probe uses a 12-second original color/test-pattern video with two generated
tones, an original SRT file, and locally segmented HLS/DASH forms. No provider
or copyrighted media is retained. Build it with:

```bash
flutter build apk --debug --target lib/m16_playback_probe.dart
```

It copies fixtures to its private temporary directory and logs only
format/result/count/timestamp facts—never media locators.

## Licensing audit

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

No GPL or non-free runtime was enabled. Any production migration must ship the
applicable notices and satisfy LGPL relinking or corresponding-source duties for
the exact native build. That compliance packaging does not exist today and is
another reason the spike cannot become production automatically.

## Comparison evidence

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

## Recommendation

Do not migrate automatically. The Samsung result proves material track and
format advantages, but the mandatory TV result still fails exact reopen and
segmented playback. If revisited, first explain those TV failures, implement
the existing single-owner
MediaSession/audio-focus contract, add release-grade LGPL compliance, and repeat
the complete Samsung and TV matrix. Only then consider product injection.

The Phase B commit intentionally carries the experimental packages and lawful
fixtures so the result is reproducible. If M17 does not approve migration, they
must be removed before the next production release; otherwise an unused native
runtime and its size/license obligations would enter that artifact.
