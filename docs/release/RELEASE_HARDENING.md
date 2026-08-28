# M9 Release Hardening

## UX, onboarding and accessibility

First run presents four concise pages covering the product, interchangeable and
metadata-only sources, lawful local CBZ/video support, local state/backup, and
the independent/unofficial position. It can be skipped, persists atomically,
and is reopenable from About. Product navigation becomes a labeled rail at
840px, existing installment/library views remain lazy, long card/search titles
are bounded, and canonical cards expose combined screen-reader descriptions.
Reader/player unknown errors now show actionable generic copy rather than raw
objects. Light/dark/system themes remain one Material 3 system.

## Logging and error strategy

`LocalDiagnostics` records structured debug/info/warning/error entries locally.
It keeps at most 100 records/64 KiB, truncates fields, redacts URLs, query data,
credentials and absolute paths, suppresses debug in release, and serializes no
stack traces or private error messages. Flutter framework and platform/async
uncaught errors add only typed records. About and Developer → Adapter
Diagnostics can inspect/copy/clear; nothing is transmitted automatically.

## Migrations and backup

Drift schema v5 retains incremental migrations. Tests reconstruct representative
v1, v3 and v4 files and prove Library, manga/anime progress, exact-source resumes,
aliases/reconciliation, local assets, adapter config and overrides at v5. Fresh
database/reopen coverage remains in the earlier suite.

Backup format is now v2. v1 remains supported. Both versions are bounded and
validated before a transaction; future/malformed archives fail, restore remains
additive, and absolute cover/binding/enrichment/override locators are omitted.
Local assets restore missing and repairable. Archives are never extracted to an
attacker-controlled path.

## Performance

Product summary and installment availability replaced obvious per-row binding
and progress-label queries with grouped bulk reads. A deterministic test loads
1000 saved media, 5000 two-source chapters and 1000 episodes; the complete
summary/availability read measured **440 ms** during the final full parallel
suite on the development host (295 ms in isolation) and has a
generous 15-second regression ceiling. Lists use builder-based lazy rendering;
search/catalog pagination remains explicit, cursor-bounded and stale-response
safe. Reader cache is bounded and player/import lifecycles retain their M5–M8
tests. This is a regression harness, not a cross-device performance promise.

## Maintenance and security

Settings → Local media can inspect storage/missing assets, refresh state, and
delete only thumbnail cache and orphan `.partial-*`/`.folder-import-*` files.
Tests prove imported bytes, Library and progress survive cleanup and missing
assets are detected. Shared archive safety limits input/expanded/entry sizes and
counts and rejects empty, corrupt, duplicate, absolute, drive-qualified and `..`
paths. Traversal tests cover CBZ import and backup restore with no state mutation.

Repository scans found no embedded credential. Generated lawful MP4 samples are
the only `.mp4` allow-list; databases, backups, CBZs, imported media, local paths,
artifacts and signing material are ignored. This workspace contains no `.git`
directory, so actual tracked history/index could not be audited; initialize or
restore Git and review `git status` before publication.

## Privacy, dependencies, CI and release

There is no telemetry/account/cloud sync. `PRIVACY.md` documents actual local
state, provider requests, imports, backups and diagnostics. Direct packages are
small and purpose-specific: archive, file_picker, html, http, Drift/sqlite,
path/path_provider and first-party video_player. `flutter pub outdated` reported
newer major/incompatible releases but no forced upgrade was taken during release
hardening. Package notices remain available through Flutter's license registry;
review them again whenever dependencies change.

Versioning starts at 0.1.0+1 under MIT. CI pins Flutter 3.47.2 and runs pub get,
format, analyze, tests and debug APK build. Release signing never reuses debug
keys. The RC script emits an APK/checksum for debug testing and fails clearly for
release mode until ignored maintainer signing is configured.

## Legal position and rebranding

Identity, version, description, repository placeholder and disclaimer live in
`AppIdentity`, with matching pubspec/platform metadata. The project is explicitly
independent/unofficial and grants no rights to third-party content. No franchise
art/logo is bundled. A rename must update `AppIdentity`, pubspec, platform names
and package IDs, docs and upgrade/reinstall notes.

## Known limitations and M10+

- Provider availability/parser compatibility cannot be guaranteed offline.
- Release signing and GitHub owner URL require maintainer configuration.
- Data-only backups exclude media payloads by design.
- Embedded audio/subtitle selection and protected provider payload extraction
  remain unsupported.
- A future M10 should focus on community feedback, localization, screenshots,
  platform packaging, instrumentation-based startup profiling and signed beta
  distribution—not source-specific bypasses.

## Deterministic fresh-install smoke test

The M9 RC was installed on a Samsung Android 16 device after clearing only
`dev.zanka.notachi` state. It cold-launched onboarding page 1/4, Skip reached the
empty Home with public discovery, and a force-stop/cold restart returned directly
to Home. The complete reader/player/import/backup paths retain the M5–M8 physical
evidence and pass the full regression suite; repeat all steps below before a
signed public release.

1. Build `tool/build_release_candidate.sh debug`; verify its SHA-256.
2. Uninstall `dev.zanka.notachi`, install the APK, and launch offline.
3. Read/skip onboarding; verify Home, empty Library and Settings/About.
4. Enable network and Search a public title; load exactly one next page; open
   Details/save it. Disable network and verify saved metadata remains.
5. Install the offline reader sample; open chapter 1, advance, close/reopen, and
   verify canonical progress/resume. Switch source and verify no page equivalence
   is assumed.
6. Install the offline player sample; play/seek episode 1, close/reopen, and
   verify resume. Switch encode and verify its timestamp starts independently.
7. Import a lawful real CBZ and video in Local media; read/play both. Rename one
   original/source file as applicable, scan missing assets, then repair it.
8. Edit title/cover metadata; refresh and verify the override survives.
9. Create a data-only backup. Add another Library item, restore the backup, and
   verify restore is non-destructive. Copy the backup to a fresh app install,
   restore, and verify local assets are missing/repairable rather than path-bound.
10. Open Developer → Adapter Diagnostics; verify offline/parser states and copy/
    clear a redacted report. Clear thumbnail/temp cache and verify media/state stay.
11. Force-stop/relaunch. Verify onboarding stays complete and Library, progress,
    preferences, provider config, overrides and repaired sources persist.
