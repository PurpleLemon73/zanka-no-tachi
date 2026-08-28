# Manga Reader — M5

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

The screen provides a page counter, chapter label, source label, tap-to-toggle
controls, normal close/back, source picker, reader settings, chapter picker,
and previous/next chapter controls.

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
resume. A different binding without resume always starts at page one. The UI
states that scan page equivalence is not assumed. M5 offers no automatic or
proportional position mapping.

Media preference is considered only among reader-capable bindings for that
chapter. An unavailable or metadata-only preferred provider is skipped rather
than treated as readable.

## 9. Canonical chapter navigation

Previous, next, and picker ordering comes from canonical chapters. Numeric and
exact decimal chapter numbers sort numerically; special chapters follow numeric
chapters in deterministic label order. A destination with no reader-capable
binding is explained and not silently skipped.

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
- Vertical progress estimates the visible page from scroll fraction because M5
  does not add an item-position tracking dependency.
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
