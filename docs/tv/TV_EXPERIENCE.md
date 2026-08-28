# Android TV, Google TV and Fire OS experience

## Architecture

M14 is a presentation layer inside the same application and canonical core. The
Android host reports `tv` only when `UiModeManager` identifies television mode
or the device exposes the Leanback feature. Screen width and aspect ratio never
select TV. Non-TV devices continue through the existing phone/tablet shell.

The TV shell uses the same `ProductController`, `ProductRepository`,
`SmartResumePolicy`, reader/player repositories, source registries, canonical
IDs, preferences and progress tables. There is no TV database, provider, or
permanent fork.

## Packaging

The Android manifest retains the ordinary launcher and adds:

- an independent `LEANBACK_LAUNCHER` intent;
- optional `android.software.leanback` support;
- `android.hardware.touchscreen` with `required=false`;
- a 320×180 first-party TV banner with safe inset branding.

Leanback is optional so the same APK remains installable on phones and tablets.
The implementation uses Flutter and Android framework APIs only; core Fire OS
use does not require Google Play Services.

## Ten-foot shell and focus

TV Home provides a large hero or focused empty-state Browse action, followed by
lazy horizontal Continue, Anime Library, Discover Anime and secondary Manga
rails. Search transfers focus from the IME directly to the first result after
submission. Library provides All/Anime/Manga filters, A–Z sorting, repair state,
and a lazy grid. Settings keeps appearance, About and Developer tools usable by
remote.

`TvFocusable` centralizes the 140 ms scale, high-contrast three-pixel accent
outline, elevated surface, semantics and scroll-into-view behavior. Details has
a dedicated landscape hierarchy: artwork and essentials, focused shared Smart
Resume action, Library action, source truth, then lazy episode/chapter rails.
Anime is primary; manga remains bounded and usable rather than receiving a
television reader redesign.

## Remote player

The player remains provider-agnostic and continues to use `video_player`.

| Remote input | Behavior |
| --- | --- |
| Select / Enter / Play-Pause | Play or pause |
| Left / Rewind | Seek backward by the persisted step |
| Right / Fast-forward | Seek forward by the persisted step |
| Up / Down | Reveal controls and context |
| Back | Hide controls first, exit fullscreen second, then leave player |
| HOME | System-owned; pause, exact-position flush and native release via lifecycle |

Controls remain visible for five seconds on TV and use a larger central action.
Episode/source/settings/previous/next remain available without touch. Source
switching retains M6 semantics: canonical completion is shared, while exact
timestamps remain binding-specific.

## MediaSession, audio focus and lifecycle

The Android bridge uses framework `MediaSession`, `PlaybackState`,
`MediaMetadata` and `AudioFocusRequest` so it adds no Google/Media3 dependency.
The session is active before user playback, advertises play/pause/seek actions,
accepts media buttons, and mirrors current position/duration. Playback requests
audio focus immediately before `play`; loss pauses, and focus is abandoned when
the player stops.

Flutter pauses and flushes on inactive/paused/detached. Android `onStop` also
pauses, abandons focus and releases the session. Return recreates the session in
a paused state at the exact live controller position and never auto-plays.
Background playback is intentionally not offered.

The design follows current official guidance for [TV app packaging and
hardware](https://developer.android.com/training/tv/get-started/create),
[D-pad navigation](https://developer.android.com/training/tv/get-started/navigation),
[TV playback controls](https://developer.android.com/training/tv/playback/controls),
[audio focus](https://developer.android.com/media/optimize/audio-focus), and
[Fire TV multimedia lifecycle/audio behavior](https://developer.amazon.com/docs/fire-tv/multimedia-app-requirements.html).

## Validation evidence

- M15 beta revalidation installed the single adaptive debug APK through the
  Leanback launcher on an Android TV API 36 ARM64 `Television 4K` AVD. At
  3840×2160 the TV Home rendered with Browse Anime deterministically focused.
  The emulator required Vulkan to be disabled/software rendering on this host;
  that is an emulator graphics setting, not an application fallback.

- Google TV API 36 ARM64 AVD, 1920×1080: the installed APK resolved both normal
  and Leanback launchers. A Leanback cold launch showed the TV shell with Browse
  Anime focused. D-pad Select opened Search; submitting `Nekopara` moved focus
  directly to its first live result.
- The selected AnimeWorld result ingested canonically, opened dedicated Details
  with `Start watching` focused, and exposed 12 episodes. Smart Resume opened
  live episode 1 through the existing resolver as a direct MP4 with a 21:45
  duration.
- D-pad Up revealed controls, Select played, and Right sought to 0:10. HOME
  removed the active Zanka MediaSession. Returning brought the existing player
  task forward, paused, at exactly 0:10; the platform session was recreated with
  the same 10000 ms position in `PlaybackState`.
- The final APK installed successfully over retained data on Samsung SM S948B /
  Android 16. Its read-only platform state reported no Leanback feature and
  normal UI mode `0x21`, proving semantic selection remains mobile. The device
  was locked, so no claim is made for a new visual pass; the unchanged mobile
  shell is covered by the complete widget suite, including the explicit TV/non-TV
  composition regression. An existing Pixel AVD could not install because its
  data partition was full; no user data was deleted to force the check.
- No copyrighted video, image, screenshot or hierarchy is retained. Temporary
  `/sdcard/zanka_tv.xml` and `/sdcard/zanka_phone.xml` were deleted after
  validation.

Final verification: `dart format .` made no changes; `flutter analyze` found no
issues; all 156 tests passed; the 1,000-item large-library guard completed in
447 ms; and `flutter build apk --debug` succeeded.

Physical Fire TV / Fire OS hardware was not attached, so device-specific runtime
validation is outstanding. Compatibility is supported by the optional Leanback
manifest, touch-free UI, framework-only media integration, HOME/onStop handling,
and absence of Google Play Services—not claimed as physical evidence.

## Known limitations

- No background playback or home-screen recommendations/channels.
- No TV manga reader redesign; Details and reader entry remain bounded.
- Fire OS physical verification and manufacturer-specific remote variations
  remain necessary before a public TV release.
- Vega OS is out of scope.
