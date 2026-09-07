# Anime Player — M6

## M19-B experimental Better Player adapter

Zanka now exposes an Android-only **Better Player (Experimental)** choice under
Settings → Developer for bounded basic-MP4 A/B testing. **Automatic** remains
the recommended default and always resolves to the production `video_player`
adapter. Explicit `video_player` does the same; an explicit Better selection on
a build or platform without the adapter falls back visibly to `video_player`.
Changing the setting affects the next playback session and never recreates an
active player.

The engine preference is device-local, excluded from portable backups, and
preserved on the receiving device during restore. Engine selection does not own
or mutate canonical progress, watched state, exact source-binding resume,
source choice, autoplay, or Display Mode.

The Better adapter imports no package types into player widgets. It exposes the
same engine-neutral state consumed by Player UI v2, accepts basic local or
HTTP(S) MP4 only, applies a bounded exact resume while remaining paused, fences
late native events by generation/session, and force-disposes controllers and
textures idempotently. Audio/subtitle controls stay hidden because this
checkpoint advertises no track capabilities; HLS and DASH are not certified.

Zanka remains the sole owner of controls, display geometry, lifecycle,
MediaSession, and audio focus. Better stock controls, autoplay, lifecycle
handling, auto-disposal, notifications, PiP/background behavior, ASMS track
discovery, and retry UI are disabled. The raw Better texture fills only the
tight frame already computed by Video Display Mode, avoiding a second fit or
aspect transform.

Better Player's upstream INFO logger can reveal complete locators. Every Zanka
Better controller instead uses log level `none`, no caller information, and no
outputs; asynchronous errors and teardown are translated without logging raw
URLs, headers, paths, or exception objects. This must remain the default unless
a future explicitly redacted diagnostic wrapper is implemented.

### M19-B validation

The full 204-test suite, analysis, debug build, signed release/R8 build, and
304 ms large-library guard passed. The signed release is 94,451,450 bytes
(+2.58% over beta.4), resolves Media3 1.9.2 without a forced downgrade, and
retains the permanent RSA-4096 signer. Its only Better-native additions are the
three ABI variants of `libdartjni.so`; no bundled codec runtime was added.

Samsung SM-S948B / Android 16 played the generated MP4 with both Automatic and
Better. Better preserved a 3458 ms binding checkpoint across route disposal;
a controlled two-second reopened run paused at 5046 ms. Fit applied live at the
same 5046 ms and Reset restored Auto. HOME/return resumed the route paused,
exit removed the Zanka session, `TvMediaBridge` alone requested and abandoned
Zanka audio focus, and the completion CTA opened episode 2 through Better.
Television_4K likewise passed D-pad selection, both-engine playback,
Replay/Next Episode, exact 2299 ms reopen, seeks, HOME/return, Back-first sheet
dismissal, and all representative display modes. Both devices produced zero
Better-named or media-locator log lines in redacted checks. A long-lived TV
debug process required an in-place reinstall before one final Better readiness
run; this remains an explicit M19-C stress risk and is one reason the adapter
is not promoted.

## M18 video display modes

Player presentation now owns a complete engine-neutral display policy. Fresh
installs use **Auto / Original**, which waits for the decoder-reported intrinsic
width:height ratio and never guesses from screen dimensions. Fit, Fill / Crop,
Fit Width and Fit Height preserve the selected frame ratio; only the explicit
Stretch / Fit Parent action may distort it. Fit policy and aspect selection are
stored separately.

Available aspect choices are Original, 4:3, 16:9, 16:10, 21:9, 1:1, 3:2 and
5:4. A custom field accepts any finite positive `width:height` pair such as
`2.39:1`, `18:9` or `32:9` and rejects malformed, zero and negative values.
Changes re-layout the existing engine surface live: no engine reopen, seek,
position write, canonical/source reconstruction or resume mutation occurs.
Reset to Auto restores the safe default. The modal is touch and focus/D-pad
accessible, and Back dismisses it before the player route.

The production adapter reports intrinsic aspect ratio through stable
`PlaybackEngineState`; UI code still imports no plugin controller. Display mode
is persisted in the local player settings file but deliberately excluded from
portable backup/restore. Restore retains the receiving device's display mode,
so a television crop/ratio choice is never imposed on an unrelated handset.

### M18 validation

On Samsung SM-S948B / Android 16, the final debug APK opened the touch sheet with
Auto / Original selected, applied Fill / Crop and 21:9 live, accepted `2.39:1`
through the text IME, dismissed the sheet with Back before leaving playback,
and restored Auto / Original with Reset. On Television_4K, D-pad focus moved
from Play through Episodes and Source to Display mode, activated the sheet,
selected Fill / Crop, and returned to the same paused `2:24 / 23:40` session.
Reset to Auto was then confirmed selected. The widget suite independently proves
one engine/open, no seek, unchanged position, no progress write, real overflow
geometry, invalid-input handling, and Back-first dismissal.

## Player UI v2 (M17)

The presentation now depends on `PlaybackEngine`, never a plugin controller.
The production adapter owns every `video_player` object and translates plugin
state into stable phase, buffering, position, duration, rate, error, track, and
capability models. Canonical ordering, source choice, completion, exact source
resume, autoplay, lifecycle, and diagnostics remain outside the engine.

The overlay provides Play/Pause, previous/next canonical episode, ±10 seconds,
touch timeline seeking, current/total time, episode picker, source, bounded speed
choices, and fullscreen. The picker renders lazily, identifies the current
episode, and shows watched state. Manual Next begins at 0:00 without deleting a
stored source resume; normal Resume and picker navigation retain it.

Natural completion shows Replay and a prominent Next Episode action; on TV,
Next has default focus. End-of-available content is stated truthfully. Audio and
subtitle actions render only when an engine reports both the capability and real
tracks. Production `video_player` reports neither, so no fake selectors appear.

`PlaybackEngineRegistry` supports Automatic, approved `video_player`, and the
optional Better Player experimental builder. Automatic always chooses the
approved production adapter. An unavailable experimental builder falls back to
`video_player` with a bounded explanation. The selector remains in Developer
settings rather than normal playback UI.

## M14 television controls

Android television presentation reuses the M6 player/session architecture and
the M17 engine contract. Select toggles playback; with the overlay visible,
Left/Right move focus between controls, while Rewind/Fast-forward seek by the
saved step. When the overlay is hidden, Left/Right reveal it and seek. Up/Down
reveal or move through the control rows, and Back hides controls before leaving.
A framework Android MediaSession mirrors metadata, duration and exact position,
while audio focus is requested only when play begins. HOME/onStop pauses, flushes
canonical and binding-specific progress, abandons focus and releases native
playback state; return is paused at the exact timestamp. See [TV experience](../tv/TV_EXPERIENCE.md)
for the complete lifecycle and validation.

## 1. Playback session boundary

The product boundary is `CanonicalMediaId` → `CanonicalEpisodeId` → optional
explicit `EpisodeSourceBinding` → `PlaybackSessionRequest` → resolver →
`PlaybackManifest` → `AnimePlayerScreen`. A session owns canonical identity,
the selected source binding, a playable URI, exact-source resume, track facts,
and application preferences. The UI imports no provider parser, DTO, registry,
or HTTP transport.

## 2. Source resolver interface

`PlaybackSourceResolver` declares a stable provider ID, reports capability for
an episode binding, and resolves a provider-neutral manifest.
`PlaybackSourceRegistry` is the composition boundary. Unknown providers default
to `metadataOnly`; a future lawful adapter can be registered without changing
the player.

## 3. Local/lawful source implementations

M6 implements file-backed MP4, WebM, MKV, and MOV manifest resolution, subject
to the platform decoder's codec support. The deterministic sample uses broadly
supported H.264 video, AAC audio, and MP4 containers. It contains generated test
patterns and tones only.

Settings → **Install offline player sample** copies three bundled files into
application support storage and idempotently installs one two-episode canonical
anime. Episode 1 has 12-second primary and 8-second alternate encodes; episode 2
has one 10-second encode. No provider network or protected content is involved.

## 4. Playback capability model

Capabilities are `metadataOnly`, `playbackCapable`,
`temporarilyUnavailable`, and `unsupported`. Capability belongs to a registered
resolver and verified installment, not merely to canonical availability.

## 5. Player UI/control architecture

The production path uses first-party `video_player` 2.14.0, the stable release
selected with Flutter 3.47.2/Dart 3.13.2. The original `better_player: 1.3.0`
is packaged as an explicit Android-only experimental basic-MP4 adapter; it is
not an automatic or production replacement. Both supply only the decoder and
texture behind `PlaybackEngine`. On Android, Zanka's native MediaSession bridge
is the single audio-focus owner and both adapters are configured not to request
competing focus. Zanka owns play/pause, scrubber, elapsed/duration, ±10-second
seeks, double-tap seek, buffering indicator, retry,
source/episode/settings sheets, previous/next, and immersive fullscreen
controls. Controls auto-hide after three seconds of playback and return on tap.

## 6. Canonical vs source-specific progress

`CanonicalAnimeProgress` remains the Home/Details continuity record and points
to canonical media and episode. `AnimeSourcePlaybackResume` is the exact resume
authority keyed by `(providerId, episodeExternalId)` and validated against that
binding. Both are written in one transaction, bounded at five-second intervals,
and flushed on background and exit. Positions clamp to the observed duration.

Schema version 3 adds the source-resume table. Reviewed merge moves it with its
episode binding; safe undo restores it, and reconciliation fingerprints detect
post-merge resume changes.

## 7. Source switching semantics

Reopening the same binding seeks to its exact saved timestamp. Switching to a
binding with its own resume uses that resume. A different binding without resume
starts at `0:00`, even if canonical progress exists. The source sheet explicitly
states that encodes may differ. M6 deliberately offers no silent proportional or
approximate mapping.

## 8. Audio/subtitle track model

Manifests expose independent `PlaybackTrack` lists for audio and subtitles,
including stable session IDs, labels, and optional language. Preferences reserve
preferred audio/subtitle languages. The local sample declares its default audio
track and no subtitle track. The production `video_player` adapter does not
claim reliable platform audio/subtitle selection. The M19-B Better adapter also
reports those capabilities as unsupported until later certification, so neither
path presents a fake selector. External subtitle loading remains deferred unless
a future approved engine truthfully reports that capability.

## 9. Episode navigation

Ordering comes only from canonical episodes: numeric episodes first in numeric
order, then non-numeric labels deterministically. Previous, next, and the picker
do not infer source order or silently skip an episode lacking playable bindings;
unplayable destinations are disabled.

## 10. Lifecycle/resource management

Inactive, paused, and detached lifecycle states pause playback and flush
progress. Leaving the player flushes again, removes listeners, cancels timers,
disposes the platform controller, and restores orientation/system UI after
fullscreen. Replacing a source or episode closes the old controller before the
new session owns a decoder.

## 11. Buffering/cache policy

The player surfaces the backend buffering state and decoder failures separately
from resolver/file failures. Retry rebuilds the session/controller. Local files
play directly from application support storage; M6 creates no duplicate media
cache, download manager, protected offline store, or network buffering policy.

## 12. Product integration

Product Details aggregates `PlaybackEpisodeAvailability`. A playable episode
shows its source count and opens `/player/{mediaId}/{episodeId}`; metadata-only
episodes retain an explanatory unavailable sheet. Closing the player reloads
canonical details and the product controller, so Home Continue reflects the
episode and timestamp. The sample is saved to Library and remains usable with
both live providers disabled.

## 13. Known limitations

- Codec/container support follows each platform's `video_player` backend; the
  deterministic Android proof uses H.264/AAC MP4.
- Better Player remains Developer-only, Android-only, and basic-MP4-only in
  M19-B. HLS, DASH, audio/subtitle tracks, and broader production certification
  are deferred to M19-C.
- Track enumeration is manifest-level; this plugin version cannot reliably
  switch embedded audio/subtitle streams across platforms.
- External WebVTT/SRT selection, picture-in-picture, casting, lock controls,
  HLS policy, and completion badges are deferred.
- Autoplay, speed, and language preferences persist. Seek step has a persisted
  model but no Settings editor yet; the control uses its stored/default value.
- A completed short sample remains at its end on exact reopen; seeking backward
  restarts it. A future completion policy may intentionally reset finished media.

## 14. M7+ integration points

M7 import/download management should add a document picker, app-owned copy vs
external-reference policy, storage accounting, missing-file repair, removal,
and background preparation without changing playback sessions. Future lawful
adapters must register capability, return expiring resources only inside a
session, translate failures, expose tracks honestly, and never make a stream URL
or provider token canonical identity. HLS support should be added only with
bounded refresh/cache behavior and explicit lawful-source evidence.

## M16/M17 decision and M19 experiment

M16 compared an isolated `media_kit` spike with the production path using
original local fixtures. M17 retained the durable engine contract and Player UI
v2 but rejected that runtime from the package: its Television_4K exact-reopen
and HLS/DASH gates failed, it had no single-owner MediaSession integration, it
materially increased APK size, and its LGPL package was incomplete. The
production `VideoPlayerPlaybackEngine` remains the approved adapter and the
Automatic default. M19-B adds original Better Player 1.3.0 only as an explicit
Developer experiment for basic MP4; it has not reversed the M17 production
decision or completed segmented-format/track certification. See
[Playback Engine Evaluation](PLAYBACK_ENGINE_EVALUATION.md).
