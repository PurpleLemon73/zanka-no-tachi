# Manga Reader — M5

## M18 Manga Reader UI v2

The reader now treats canonical chapter order as an in-session navigation
contract. Previous and Next Chapter are disabled only at real canonical
boundaries; an adjacent chapter that exists but lacks a readable binding stays
visible as an unavailable destination and leaves the current session intact.
Manual Next—including the completion action—opens the next canonical chapter
at page one. It never copies the old chapter's page and does not erase a saved
page belonging to the destination binding. Previous and picker selections use
that binding's own exact resume.

Reaching the final rendered page marks the canonical chapter complete and opens
a completion layer with Previous Chapter, a prominent Next Chapter action, or a
truthful end-of-available-chapters message. The ordered chapter picker is a lazy
list, marks the current and completed chapters, and shows canonical progress for
the active in-progress chapter. It stays provider-agnostic and uses normal
reader source preference/fallback rules.

Volume controls exist only when a canonical chapter or user installment edit
contains a non-empty volume label. Those raw labels provide headings, current
volume, jump-to-volume and previous/next-volume actions. Ungrouped chapters
remain ungrouped; the reader never turns presentation ranges into volumes.
Natural volume ordering and explicit user chapter order are resolved in the
repository before widgets receive the list.

Paged LTR/RTL zoom state is reset on every chapter transition. Vertical mode,
paged mode, pinch/pan, double tap, the page-turn guard, bounded three-page cache,
canonical completion, and exact binding resume remain independent concerns.

### M18 validation

The full automated suite exercises first/middle/last boundaries, decimal and
special labels, explicit order, genuine volumes, unreadable adjacency, manual
Next isolation, completion/end states, a 1,002-chapter lazy picker, fresh picker
progress, and two-pointer zoom reset across a chapter transition.

On Samsung SM-S948B / Android 16, the M18 run covered vertical and paged reading,
Previous/Next, completion Next, the picker, source switching with independent
page resumes, and HOME/return. The final rebuilt APK reconfirmed live picker
state by moving Chapter 1 from 4/4 to 3/4 and observing `Page 3 of 4` immediately
in the canonical picker. The unchanged M13 pinch/pan/double-tap implementation
retains its same-device physical evidence; M18's transition reset is covered by
the real two-pointer widget regression because ADB cannot inject a reliable
multi-pointer gesture on that device.

The bounded Television_4K regression opened a live 15-chapter manga, retained
truthful first/next boundaries, and showed a lazy canonical picker without
invented volume controls. M18 does not claim a TV-specific manga-reader design.

## M13 paged zoom and continuation update

Paged LTR/RTL reading now uses a per-page `InteractiveViewer` with 1×–4× pinch
zoom, pan while zoomed, centered double-tap toggle and an explicit reset action.
PageView navigation is disabled during zoom/pan and the transform resets on page
change. The transform is never persisted, so close/reopen retains the exact
binding-specific logical page and canonical completion remains independent.
Vertical mode deliberately remains on M10 rendered-page tracking.

Details opens the reader through the shared `SmartResumePolicy`: Start selects
the first actionable unread chapter, Resume prefers the binding with its own
exact resume, and Next advances after canonical completion. It never maps page
offsets to another scan.

## 1. Reader session boundary

The product boundary is `CanonicalMediaId` → `CanonicalChapterId` → optional
explicit `ChapterSourceBinding` → `ReaderSessionRequest` → resolver →
`ReaderManifest` → `MangaReaderScreen`. A session owns the canonical media and
chapter, selected source binding, ordered page manifest, exact-source resume,
and application reader preferences. The reader widget imports no live-provider
DTO, parser, registry, or transport type.

## 2. Reader source interface

`ReaderSourceResolver` declares a stable provider ID, reports capability for a
chapter binding, and resolves a request to a provider-neutral manifest.
`ReaderSourceRegistry` is the application composition boundary. An unknown
resolver defaults to `metadataOnly`; future lawful adapters can be registered
without changing reader UI.

## 3. Lawful/local source implementations

M5 implements local image folders and ZIP-based CBZ archives. Folder entries
and archive paths accept JPEG, PNG, WebP, and GIF and use natural,
case-insensitive path ordering (`2` before `10`). Non-image entries are ignored.
Missing folders/files, empty/corrupt archives, and archives with only unsupported
entries fail explicitly.

CBR is not implemented: RAR support would add a heavier and less portable native
dependency. No MangaWorld page resolver or protected-content retrieval exists.

Settings → **Install offline reader sample** creates an idempotent, generated
sample in application support storage. Chapter 1 has a four-page folder source
and a separate two-page alternate scan; chapter 2 is a three-page CBZ. The
sample contains generated pixels, uses no network, and is saved to Library.

## 4. Reader-capable capability model

Capabilities are `metadataOnly`, `readerCapable`, `temporarilyUnavailable`, and
`unsupported`. Capability belongs to the registered reader adapter, not to
canonical chapter identity. Existing production metadata bindings are
`metadataOnly` by default. Product Details displays their source metadata but
does not present a working Read action. Only a binding accepted by a registered
resolver can create a session.

## 5. Page manifest structure

Each `ReaderPage` has session-level ID, zero-based ordered index, opaque display
locator, lazy byte loader, optional dimensions, and optional spread flag. The
locator is never canonical identity. A manifest is rejected if empty or if page
indexes are not contiguous from zero.

## 6. Reader modes and settings

The reader supports continuous vertical and page-by-page modes. Paged mode can
be LTR or RTL. Image fit can be width or contain. Preferences are application
owned and persist in `reader-settings.json` under application support storage;
corrupt/missing settings safely fall back to vertical/LTR/fit-width.

The screen provides a page counter, edited/canonical chapter label, truthful
volume label when one exists, source label, tap-to-toggle controls, normal
close/back, source picker, reader settings, lazy chapter picker, completion
actions, and boundary-aware previous/next chapter controls.

## 7. Canonical versus source-specific progress

`CanonicalMangaProgress` identifies the current canonical media/chapter and
feeds Home/Details continuity. Its legacy page/count fields are updated for the
active session but are never used to map pages to another scan.

`MangaSourcePageResume` is the exact resume authority. It is keyed by provider
and chapter external ID and validated against that binding. It stores page index
and observed page count. Both records are written transactionally on meaningful
page changes and reader close/lifecycle flush.

## 8. Source-switch semantics

Reopening the same binding resumes its saved page, clamped if that source's
manifest became shorter. Switching to a binding with its own resume uses that
resume. A different binding without resume always starts at page one. Manual
Next is a deliberate page-one presentation override and does not consume or
copy a stored destination resume. The UI states that scan page equivalence is
not assumed. There is no automatic or proportional position mapping.

Media preference is considered only among reader-capable bindings for that
chapter. An unavailable or metadata-only preferred provider is skipped rather
than treated as readable.

## 9. Canonical chapter navigation

Previous, next, picker, completion and volume navigation all consume the same
repository-ordered canonical list. Explicit user order wins; genuine volume
labels sort naturally; numeric and exact decimal chapter numbers sort
numerically; special/raw labels remain deterministic. A destination with no
reader-capable binding is explained and never silently skipped.

## 10. Cache and prefetch strategy

`ReaderPageCache` is an LRU of three page futures. It prefetches only the
immediately previous and next pages, evicts distant pages, and can remove a
failed page for explicit retry. Local folder bytes are read lazily. CBZ central
directory enumeration does not retain the entire archive; the selected entry is
decoded from a newly opened file stream on demand.

## 11. Error and lifecycle behavior

Reader errors distinguish source unavailable, invalid manifest, page
unavailable, unsupported format, and missing local file. Session errors provide
a full-screen retry. Individual page loader failures provide per-page retry and
do not crash or discard progress.

Position writes are debounced to 300 ms and flushed on close and inactive,
paused, or detached lifecycle states. Existing canonical/library data remains
available if a reader source fails. Local sessions require no provider network.

## 12. Product integration

Product Details aggregates reader availability through `ReaderRepository`.
Readable chapters open `/reader/{mediaId}/{chapterId}`. Metadata-only chapters
retain a useful unavailable sheet with source names and scan-equivalence
warning. Settings installs and immediately opens the deterministic sample. Home
Continue reflects persisted canonical progress after the product state refreshes.

## 13. Known limitations

- Folder/CBZ paths are installed by the deterministic sample; a general system
  document picker and user-managed import/removal workflow are deferred.
- CBR/RAR is unsupported.
- Very large CBZ pages are decoded one at a time, but the archive entry decoder
  may still allocate the full uncompressed selected page.
- Vertical progress tracks the rendered page nearest the viewport center; it
  does not infer an exact page from a global scroll fraction.
- Spread metadata and image dimensions are available in the model but are not
  inferred from local images.
- Exact progress survives source replacement only when the binding identity is
  retained/migrated; new scans deliberately start independently.

## 14. M6/M7 integration points

M6 anime playback should mirror the session/resolver/capability boundary but
treat cross-encode timestamps as approximate and user-confirmed. It should not
reuse manga page semantics.

Future lawful manga adapters should register a resolver, declare capability,
return lazy stable-session pages, translate typed failures, and avoid making
provider URLs canonical. M7 import/download work can add a document picker,
copy ownership policy, storage accounting, removal, and background preparation
without changing reader UI or canonical progress.
