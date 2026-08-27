# Anime Player — M6

## M14 television controls

Android television presentation reuses the M6 player/session architecture and
`video_player`. Select toggles playback, Left/Right seek by the saved step,
Up/Down reveal five-second controls, media keys map to their matching actions,
and Back hides controls before leaving. A framework Android MediaSession mirrors
metadata, duration and exact position, while audio focus is requested only when
play begins. HOME/onStop pauses, flushes canonical and binding-specific progress,
abandons focus and releases native playback state; return is paused at the exact
timestamp. See `TV_EXPERIENCE.md` for the complete lifecycle and validation.

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
resolver, not to canonical availability. AnimeWorld remains metadata-only and
never exposes a fake Watch action.

## 5. Player UI/control architecture

The app uses first-party `video_player` 2.10.1, the newest release compatible
with Flutter 3.35.4/Dart 3.9.2. It supplies the platform decoder and texture;
Zanka owns play/pause, scrubber, elapsed/duration, ±10-second seeks, double-tap
seek, buffering indicator, retry, source/episode/settings sheets, previous/next,
and immersive fullscreen controls. Controls auto-hide after three seconds of
playback and return on tap.

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
track and no subtitle track. `video_player` 2.10.1 does not expose reliable
platform audio/subtitle track selection, so the UI truthfully shows Default
audio and Subtitles Off; external subtitle loading is deferred.

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
