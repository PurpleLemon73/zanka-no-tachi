# M10 Product Maturity

## M14 television presentation

Zanka now composes a semantic Android TV/Google TV/Fire OS presentation from the
same product controller and canonical repositories. It adds a 10-foot Home,
remote Search/Library/Settings, landscape Anime Details and remote-first player
without changing phone/tablet flows or creating TV persistence. Shared Smart
Resume and source-specific timestamps remain the authority. Fire OS physical
hardware validation remains an explicit release gap.

## Editing and identity

Imported chapters and episodes can be edited from Details by holding an
installment. Chapter edits support a reviewed label, standard/decimal/special/
extra/oneshot classification, volume, explicit order, and local source label.
Episode edits support a label, optional number, standard/movie/OVA/ONA/special
classification, semantically optional narrative season, explicit order, and
local source label.

Edits are schema-v6 user overlays. They do not rewrite provider observations,
canonical media/installment IDs, or source bindings. Canonical progress and the
exact per-binding page/timestamp resume therefore survive an edit. Removing a
local source remains a separate confirmed action; it never removes Library
state, canonical metadata, or progress.

## Metadata override lifecycle

Details supports title, alternate titles, description, cover locator,
genres/tags, status, locally meaningful anime format, and freeform creator or
studio. User values have `user-override` provenance and remain above enrichment
and provider values during refresh. The undo menu clears one field; the editor
can clear all fields after confirmation. A cleared field immediately falls back
to enrichment and then provider data. Details labels the displayed title as
Your edit, Enrichment, or Source metadata.

## Local Media and import UX

Settings → Local media now provides search by file or linked title; manga,
video, available, and repair-needed filters; title, size, recent, and missing
sorting; human sizes; storage totals; linked Details navigation; long-press
multi-selection; reviewed attach-to-another-installment; safe bulk source
removal; repair; explicit source removal vs
physical deletion; and regenerable-cache/orphan-partial cleanup.

Single import retains reviewed attachment and makes an app-owned staged copy.
Batch import is naturally ordered, probed before commit, label-editable, and
warns about already-imported or repeated filenames. Each import transaction
registers only after its copy is complete; partial staging files are cleaned.
Successful earlier batch items remain valid if a later independent item fails.

## Reader tracking and completion

Vertical mode no longer maps a scroll fraction to a page. It compares actual
rendered page positions with the viewport and changes the logical page only
when the centered visible page changes. Opening, mode changes, lifecycle flush,
and ordinary layout changes preserve that logical page where it is rendered.
Writes retain the 300 ms meaningful-change debounce and lifecycle flush. Paged
LTR/RTL, fit controls, page counter, source selection, chapter picker,
previous/next, bounded three-page cache, and retry remain available.

Reaching the final page marks the canonical chapter read. Details shows read
counts and permits Mark Read/Mark Unread. Completion is its own record; marking
unread never clears exact source resume. Home Continue omits a currently
completed chapter and sorts remaining entries by recent progress.

## Player, watched state, and autoplay

The player retains scrubbing, double-tap seek, configurable seek step,
fullscreen/orientation handling, playback speed, episode picker,
previous/next, source selection, buffering state, retry, bounded position
writes, and lifecycle flush. An episode becomes watched at 90% of known
duration or natural end. Details supports Mark Watched/Mark Unwatched and shows
watched counts. Exact source timestamp resume remains intact in either state.

Autoplay-next is a persisted toggle. It runs only after a natural end, selects
the canonical next episode, and proceeds only when that exact next installment
has a playback-capable binding. It does not skip metadata-only or unplayable
episodes.

## Audio and subtitle truthfulness

The current first-party `video_player` stack does not expose reliable embedded
audio/subtitle selection or cross-platform external SRT/WebVTT rendering.
Manifests therefore advertise no selectable tracks, and the player explicitly
says it uses the file's default audio with subtitles unavailable. Preferred
language fields remain inert domain preparation, not claimed capability. M10
does not fake controls. A future player-stack change must first prove Android,
iOS, and desktop behavior with lawful fixtures.

## Probing, covers, and thumbnails

CBZ probing reports page count and image formats. First-page CBZ covers use the
existing bounded, regenerable 64-entry cache, can be overridden by the user,
regenerate after repair, and degrade to the standard placeholder.

Video probing first records container and size, then opportunistically asks the
same platform decoder used for playback for duration and resolution. Probe
failure does not block import. The current stack does not reliably expose codec
names, audio/subtitle stream counts, or frame extraction on every target, so
those fields and video thumbnails are not fabricated. Adding a heavy native
probe/thumbnail dependency was rejected for M10 until its platform/release cost
can be evaluated with physical fixtures.

## Home, Search, Library, and Details

Home has completion-aware Continue Reading/Watching sorted by recent progress,
Recently Added, and source-failure-tolerant Discover Manga/Anime. Search keeps
query/kind state across Details navigation, persists 12 recent searches with a
clear action, retains bounded user-driven load-more, displays source
availability, and preserves canonical deduplication without title-only merge.
Library remains offline-first, with grid/list, kind/favorite/status filters,
sorting, progress text, source counts, and a Needs repair badge. Details adds
completion summaries/actions, installment editing, truthful readable/playable
availability, metadata provenance, and normal repair actions.

## Repair, backup, and lifecycle

When startup or a Local Media scan finds a missing managed file, Library and
Details retain the item. Details offers Repair, explains that identity/progress/
resume remain, validates the replacement, stages it, and refreshes immediately.
No missing file is silently deleted.

Data-only backup is now format v3 and includes installment edit overlays,
completion records, expanded metadata overrides, reader/player preferences,
and the previous canonical state. Restore remains validated, transactional,
non-destructive, traversal-bounded, and compatible with v1/v2. Local bytes and
thumbnail caches remain excluded. Full-media backup was not added: multi-GB
archives need streaming ZIP creation, free-space guarantees, cancellation, and
collision-safe streaming restore beyond the current in-memory archive package.

Reader/player pause or inactive transitions flush state. Database reopen,
v5→v6 migration, mode/layout changes, source missing on reopen, provider disable,
and force-relaunch persistence are covered by repository/widget/migration tests
and the deterministic device procedure below.

## Large-library findings

The synthetic regression still uses 1,000 media, 5,000 manga chapters, 1,000
anime episodes, multi-source bindings, and representative user state. The full
persisted Library/availability read completed in 439 ms on this development
machine during final M10 verification. Completion and missing-local aggregation
are bulk reads; installment lists remain lazily rendered. No new per-media query
was added to the Library path.

## Remaining product gaps and M11 recommendation

- Video thumbnails and stream/track discovery await a deliberately selected,
  proven native media stack.
- External SRT/WebVTT and embedded track selection remain unavailable rather
  than misleading.
- Batch import cancellation and a resumable full-media backup require streaming
  job infrastructure.
- Reviewed local installment reattachment rejects cross-media and occupied
  targets, moves only the selected binding/exact-source resume, and leaves
  canonical progress untouched.
- Paged zoom/pan and optional spread mode remain candidates after gesture and
  memory testing on physical devices.

M11 should focus on a measured media-engine evaluation plus cancellable
background import/backup jobs, not provider extraction or distribution work.

## Deterministic physical-device validation

1. Fresh-install the debug APK and complete onboarding.
2. Open Settings → Local media; batch-select three lawful CBZ files. Review the
   natural order, change one label, import, then open the linked manga.
3. Hold a chapter; change it to decimal/special, set volume/order/source label,
   close Details, reopen it, and verify the same item is edited.
4. Edit title, description, cover, tags, status, and creator. Reset title only,
   verify fallback, then clear all edits and confirm Library state remains.
5. Open the chapter vertically, scroll until page N is centered, background the
   app, rotate, return, close, and reopen. Verify page N and the counter.
6. Reach the final page; verify Read in Details. Mark Unread, reopen, and verify
   exact page resume remains.
7. Batch-import three lawful MP4/WebM/MKV/MOV episodes. Review/change labels,
   then hold an episode in Details and set number/type/order.
8. Play episode 1, seek, background/foreground, close/reopen, and verify resume.
   Seek beyond 90%; verify Watched, mark Unwatched, and verify resume remains.
9. Enable Play next episode automatically. Let episode 1 end naturally and
   verify episode 2 opens. Remove episode 2's source and repeat; verify playback
   stops without skipping.
10. Open player settings and verify no selectable audio/subtitle controls are
    claimed for the local fixture; the limitation text is visible.
11. Rename one managed local file outside Zanka, force-stop/relaunch, open its
    Details, choose Repair, select an equivalent lawful replacement, confirm,
    and verify identity/progress/resume.
12. Use Local Media search, each filter and sort, long-select two sources, and
    cancel then confirm safe bulk removal. Verify physical-delete wording on a
    separate single source.
13. Submit two searches, open/back from Details, verify query/results remain,
    relaunch and use a recent-search chip, then clear history.
14. Exercise Home Continue and Library grid/list/filter/sort offline with both
    completed and incomplete items and a missing source badge.
15. Create a v3 data-only backup, add/edit progress, restore it, and verify the
    merge is non-destructive and local files are reported as excluded.
16. Load the synthetic large-library fixture in a debug/profile run; scroll Home,
    Library, and a 5,000-chapter Details list while watching for long stalls.
17. Force-stop and relaunch once more; verify edits, completion, preferences,
    recent searches, progress, and exact source resumes remain.
# M13 daily-use refinement

Home and Details now share `SmartResumePolicy`, producing consistent Start,
Resume, Next and Completed behavior from canonical completion and exact-binding
resume. Details prioritizes that action, collapses descriptions and optional
metadata, naturally orders volume labels, and keeps large manga/anime lists
compact and lazy. Ungrouped chapter ranges remain presentation-only.

Appearance now persists System/Light/Dark plus a curated Material 3 accent.
Paged manga reading adds guarded pinch zoom/pan and double-tap/reset without
changing logical page, completion or source-specific resume. Vertical mode
retains the rendered-page-aware M10 implementation. Player engine, live-source
reliability, local repair, backup and canonical editing semantics are unchanged.
