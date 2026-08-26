# Live Source Reliability — M12

## Capability truth

Adapter descriptors continue to declare that MangaWorld has a reader resolver
and AnimeWorld has a playback resolver. Installment truth is finer-grained:
`LiveMediaDiagnostics` keeps an in-memory result keyed by the exact provider
binding. A successful binding is ready; a network or parser failure is
temporarily retryable; an observed unsupported delivery is unsupported. An
untested structurally valid binding remains openable so thousands of
installments are not eagerly fetched. Opening it is the capability probe.

Provider-level success never upgrades a different binding. Binding keys are not
shown in diagnostics and no result is canonical identity. Local resolver
capabilities still come only from local files and are unaffected by this live
ledger.

## Bounded recovery

- A live session-open resolver may opt into one automatic fresh resolution after
  `sourceUnavailable`. Parser mismatch, unsupported format, missing local files
  and other errors do not loop.
- A MangaWorld page failure may fetch the chapter document once, rebuild the
  manifest and retry the same logical zero-based page if that index still
  exists. It does not proportionally map or change chapters/bindings.
- If a remote video locator fails while the platform player initializes, the
  screen resolves the same binding once more and rebuilds the controller. A
  successful recovery is named in a short snackbar.
- User-driven Retry is a new bounded attempt. None of these paths rewrite the
  preferred provider, canonical completion, or exact source resume.

Repository tests first persist page/timestamp resume, force the first remote
resolution to fail, recover on exactly the second call, and verify the original
exact resume and canonical progress survive.

## Manga reader resilience

The reader parser uses the final redirected chapter URI and recognizes ordinary
`src`, `data-src`, `data-lazy-src`, and `data-original` first-image attributes.
Its JSON list accepts filename, relative path, and absolute HTTP(S) image refs;
it filters unsupported/control-character entries, preserves first-seen order,
deduplicates exact resolved refs and retains the 500-page safety bound. Images
remain lazy and adjacent prefetch/LRU behavior is unchanged. Requests use the
final chapter document as the ordinary referrer and the transport user agent.

Grouped and ungrouped chapter-list ingestion remains the M11/M0 metadata parser
responsibility and retains dedicated fixtures. A reachable page without valid
reader markers is parser drift, not a network failure.

## Anime playback compatibility

M12 observed direct MP4 across completed/dubbed TV, Movie, OVA, ONA, and ongoing
long-TV samples. The player parser considers all `<video><source>` elements and
selects an explicitly declared `video/mp4`, rather than assuming the first
element is usable. An iframe-only or other declared delivery is a typed
unsupported format. HLS/DASH were not observed and are not newly claimed. The
first-party player, local playback, resume, watched threshold, autoplay-next,
seek/speed/fullscreen and lifecycle flushing remain unchanged.

## Product failure and source switching

Details distinguishes ready sources from temporarily unavailable sources that
can be retried. Reader/player source and installment pickers use the same generic
application view, without provider branches. Error screens translate typed
failures into source unreachable, provider page changed, unsupported device/
format, or missing local file language. They offer Retry and Try another source.

An alternate open uses its exact binding. The failed preference is not rewritten
unless the user explicitly selects another source through the existing open
flow. Canonical read/watched state remains shared; exact pages/timestamps remain
binding-specific, and returning to the original binding restores its own resume.
Home Continue still derives only from canonical progress/completion and opens
canonical Details, where ready local/live alternatives remain visible.

## Diagnostics and cache policy

Adapter Diagnostics reports aggregate live capability state, last success,
last failure, failure class, parser-drift time, observed media MIME type, and
whether a fresh retry recovered. Configuration display is reduced to scheme,
host and optional port. Summaries contain counts/classes only. Full chapter,
image, player and media locators, query values, cookies, CSRF values, tokens,
selectors, stack traces and binding keys are excluded.

Live manifests and per-binding observations are transient memory only. The
existing three-page reader LRU and disposable thumbnail/cover behavior remain
the only relevant bounded caches. No remote media cache, offline mirror, or
manifest persistence was added. Clearing process/cache state cannot change the
Library, completion, progress or source resume, and backup v3 contains no live
session locator.

## Exact unsupported cases and risks

- A public AnimeWorld source not explicitly delivered as `video/mp4` is
  unsupported until representative evidence and platform validation justify
  another format.
- An external iframe/player shape is not recursively followed by the player
  parser.
- A MangaWorld chapter with no recognizable first image plus bounded page list,
  more than 500 unique pages, or a refreshed list shorter than the current page
  fails safely.
- Capability observations are in-memory and intentionally age only by a new
  user open; there is no background probing or persistent outage stigma.
- Provider markup and public availability can still change after this evidence
  date. Diagnostics distinguish that drift but cannot guarantee uptime.

## Deterministic physical validation

1. Install the final debug APK on the Samsung Android device and enable network.
2. Search and ingest the four manga matrix titles one at a time. For at least
   three, open Details and a chapter, load several pages, close/reopen to verify
   exact resume, and use previous/next where present. Confirm the ungrouped and
   decimal/oneshot titles have usable lists.
3. Search and ingest at least three anime matrix titles spanning TV, Movie and
   OVA/ONA. Open an episode, start playback, pause/seek, close/reopen to verify
   the exact timestamp, and toggle watched/unwatched once.
4. Where a canonical installment has a local alternate, select it after a live
   failure. Confirm canonical completion stays, the local source starts/resumes
   only at its own exact state, and returning live restores the live resume.
5. Disable network during one live open. Confirm actionable Retry/Try another
   source, unchanged preferred source and unchanged Home Continue. Re-enable
   network and retry once; confirm recovery.
6. Open Settings → Developer → Adapter Diagnostics. Confirm the observed media
   type/times/failure class/recovery flag are present and no locator/token/path
   appears. Clear transient/local diagnostics and confirm Library/progress remain.
7. Force-stop/relaunch. Confirm Library, completion, canonical progress,
   preferences and exact source resumes survive. No screenshots or media should
   be captured or retained as evidence.

## Physical evidence — Samsung Android 16

Final debug APK on SM S948B at 1080×2340:

- Home initially retained the M11 One Piece Digital Colored Comics chapter 1040
  continuation at page 9/12 and Full Metal Panic! (ITA) episode 1 at 0:42.
- Solo Leveling Details exposed 201 chapters. Chapter 198 opened as a 71-page
  MangaWorld session; paged RTL navigation moved 1 → 3 and close/reopen restored
  exactly page 3.
- A device record of +99 Reinforced Wooden Stick predated M11's ungrouped-list
  parser fix and showed zero installments. The new normal Details refresh
  repaired it to 15 chapters without Developer tools. Chapter 15 opened at
  1/179; canonical Previous opened chapter 14 at 1/41.
- 5 cm al secondo identified as a completed Movie with one playable binding.
  Direct MP4 initialized to a 1:02:51 duration; play, pause and +10-second seek
  worked. Close/reopen produced an exact-source 0:40 Details resume (later 0:54
  after continued validation).
- Nekopara OVA identified as completed OVA with one playable binding. Direct MP4
  initialized to 58:03 and played past 0:12. Details later showed 0:29 resume;
  manual watched changed 0/1 to 1/1 without erasing the timestamp.
- With AnimeWorld disabled, Home still showed 5 cm al secondo at 0:54. Details
  retained progress and labeled its episode available to retry. Opening made no
  network request and showed only the non-technical temporary-unreachable copy,
  Retry, and Try another source. AnimeWorld was restored enabled afterward.
- Force-stop/relaunch retained Continue and configuration. Adapter Diagnostics
  showed bounded/redacted local records, sanitized authority only, capability,
  media type, success/failure/parser fields and fresh-retry status. Because the
  binding ledger is intentionally in memory, it correctly showed `neverResolved`
  after that restart.

Validation used accessibility text/runtime state only. No screenshot, chapter
image, video byte, locator, token, cookie, CSRF value, database, or backup was
copied into the repository.
