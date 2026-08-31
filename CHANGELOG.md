# Changelog

This project follows Semantic Versioning.

## [Unreleased]

## [0.2.0-beta.3] - 2026-08-31

- Added Player UI v2 with Previous/Next Episode, Replay, completion actions,
  a lazy in-player episode picker, timeline scrubbing, and ±10-second seeking.
- Added TV-first D-pad player navigation alongside mobile touch adaptation,
  while preserving exact source-specific resume and canonical completion.
- Introduced an engine-neutral player contract internally; `video_player`
  remains the sole production engine.
- Removed the rejected experimental `media_kit` runtime, probe, fixtures, and
  generated registrations from the production dependency graph and APK.
- Verified normal in-place Android upgrade continuity from beta.2 with Zanka's
  permanent production signing identity.

## [0.2.0-beta.2] - 2026-08-28

- Established Zanka's permanent production Android signing identity and a
  fail-closed release pipeline that verifies package, version, APK signature,
  signer certificate and checksums.
- Migrated to Flutter 3.47.2, Dart 3.13.2, Gradle 9.3.1, AGP 9.1.0 and Kotlin
  2.4.0 while preserving the Android TV/MediaSession integration.
- Hid source/adapter diagnostics behind an intentional Developer Mode gesture
  so a fresh install presents only normal product flows.
- Verified beta.1 backup compatibility for the required
  backup → uninstall → beta.2 install → restore signing migration.
- Physical Fire TV validation remains deferred; compatibility is not a Fire TV
  certification claim.

## [0.2.0-beta.1] - 2026-08-27

- Added one adaptive Android experience spanning phone/tablet and a dedicated
  D-pad-first Android TV, Google TV, and Fire TV-compatible shell.
- Added live MangaWorld reading and AnimeWorld playback for verified ordinary
  public delivery paths, with per-installment capability and bounded retry.
- Added Smart Start/Resume/Next, exact page/timestamp resume, reader zoom,
  completion controls, player autoplay, and durable multi-source switching.
- Added canonical local imports, repair, safe removal, storage maintenance, and
  versioned non-destructive backup/restore.
- Added original Ashen Blade and Nova Pulse showcase media, safe product
  screenshots, public installation/release docs, and repository hygiene.
- Physical Samsung Android 16 and prior Google TV API 36 emulator validation
  are complete. Physical Fire TV validation and production signing remain
  outstanding.

- Hardened live MangaWorld reading and AnimeWorld direct-MP4 playback across a
  representative compatibility matrix with per-installment truth, one bounded
  fresh-manifest retry, actionable source failure/switch UX, sanitized media
  diagnostics, and normal Details metadata refresh.
- Added stable-ID post-import chapter/episode editing and reversible expanded
  metadata overrides.
- Added rendered-page reader resume, read/unread, watched/unwatched, and safe
  natural-end autoplay-next.
- Matured Local Media, import warnings, normal Details repair, completion-aware
  Home/Library, persisted recent search, optional video probing, and backup v3.
- Kept unsupported audio/subtitle switching and video thumbnails explicitly
  unavailable rather than advertising unreliable capabilities.

## [0.1.0] - 2026-08-25

- Added canonical multi-source identity, durable Library/progress and reviewed merge/split recovery.
- Added Home, bounded Search, Library, Details, local manga reader and local anime player.
- Added imports, repair/removal, portable backup/restore, adapter SDK and metadata enrichment.
- Added onboarding, accessibility/responsive polish, local diagnostics, migration/security tests and release tooling.
