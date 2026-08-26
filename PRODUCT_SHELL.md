# Product Shell — M4

## 1. Navigation structure

The root `ProductShell` launches on Home and retains four destinations in an
`IndexedStack`: Home, Search, Library, and Settings. This preserves tab and
scroll state without recreating long-lived services. Canonical details use a
pushed route named `/media/{canonicalId}` with normal back behavior. The M2/M3
diagnostic harness is a pushed `/settings/developer` route and is never a root
tab or launch screen.

## 2. UI architecture and state management

The dependency direction is:

```text
product widget
  → ProductController
  → ProductRepository
  → LiveProviderRepository / canonical availability APIs
  → CanonicalDatabase or configured provider adapters
```

`ProductRepository` creates source-agnostic summary, detail, search, discovery,
library, progress, and availability view models. Widgets never import Drift,
provider DTOs/parsers, or HTTP transports. One `ProductController` lives for the
application lifetime and uses `ChangeNotifier`, consistent with the existing
developer controller. User mutations explicitly refresh shared local state;
provider loading and failures are held separately.

The existing `LiveProviderRepository`, provider registry, ingestion service,
canonical database, reconciliation service, and preferred-source APIs remain
the only authorities. M4 introduces no parallel persistence or matching logic.

## 3. Home data semantics

- **Continue** comes only from canonical manga/anime progress. It displays the
  persisted chapter/episode label and page or playback position.
- **Your Library** is a shortcut into locally saved canonical records.
- **On this device** means already persisted/ingested locally. It does not claim
  observation recency because M1–M3 store no media observation timestamp.
- **Discover Manga** and **Discover Anime** are current first-page provider
  catalog results. They make no popularity, trending, or quality claim.

Provider discovery runs independently of local loading. Pull-to-refresh reloads
both. A failed catalog shows a concise source-availability message while local
sections remain functional.

## 4. Search behavior

Search has one query field and independently selectable manga/anime scopes. It
queries every enabled provider in scope concurrently. Input is debounced by 350
milliseconds; keyboard submission runs immediately. Each request generation is
tagged, and a late response is discarded when the query or scope has changed.

Known `(providerId, externalId)` bindings resolve to canonical IDs. Results with
the same resolved canonical ID combine into one card with multiple sources.
Unseen provider results remain distinct—even when titles match—until M3 review
confirms identity. Opening an unseen result retrieves public detail metadata and
ingests through the existing idempotent service; opening a known result uses its
local canonical detail.

Failures are collected per provider. Successful results remain visible when
another provider is offline or parser-incompatible. Normal UI translates the
provider taxonomy into concise messages and never exposes stack traces.

## 5. Library behavior

Library reads only canonical persistence and works with every provider offline.
It supports all saved records, manga/anime kind filters, favorites, every
`CanonicalLibraryStatus`, title sort, and persisted updated-time sort. Empty
states explain how to add content or adjust filters.

Add/remove, favorite, and status changes persist immediately. Removing means
`isSaved = false`; it does not delete canonical media, source bindings, or
progress. Creation/update timestamps remain durable across restart. Product
repository tests reopen a file database offline and verify saved/favorite/status
and source preference state.

## 6. Media Details behavior

The shared details screen renders canonical title, alternate titles,
description, kind/status, genres, cover, library controls, and source summary.

Manga details show exact raw chapter labels, optional volume labels, canonical
progress, and all bindings per chapter. Anime details show format, airing window,
known narrative season only when present, canonical progress, and all bindings
per episode. Provider-specific studios/credits remain raw binding metadata in
the current domain and are not presented as invented canonical facts.

Chapter/episode taps preserve the selected canonical installment and show a
future reader/player sheet. No page list, image payload, stream, or playback URL
is requested.

## 7. Source-selection UI

Media details display one choice chip per media source binding. Selecting one
persists `PreferredMediaSource` for that canonical media. Chapter/episode rows
show every binding, making missing/fallback coverage visible under one canonical
work. If no preference exists, the UI asks the user to choose rather than
pretending a source is canonical. If a stored preference has become unavailable,
the UI names that condition and offers the remaining sources.

Manga placeholders state that pages can differ between scans. Anime placeholders
state that playback positions can be approximate between encodes. M4 never
asserts scan or timestamp equivalence.

## 8. Offline and provider-failure behavior

Home local sections, Library, and persisted Details load from canonical storage
before and independently from discovery. Search records failure per provider,
keeps partial successes, and distinguishes source incompatibility from temporary
unreachability in friendly language. Retry is available for discovery.

Remote covers have a fixed-size loading state and an error placeholder, so a
broken image cannot remove controls or change canonical identity. Missing
installments and missing source bindings have explicit empty states.

## 9. Developer-tool relocation

Settings → Developer opens the complete existing Developer Sources screen. It
retains health/error classification, base-URL editing, catalog/search/detail
ingestion, canonical inspection, reconciliation evidence, synthetic M3 seed,
reviewed merge, alias inspection, and undo. Those controls are absent from
Home, Search, Library, and normal Details.

## 10. Accessibility and performance decisions

- Material navigation, buttons, chips, tooltips, and semantic cover labels
  provide keyboard/screen-reader meaning and adequate tap targets.
- Text does not encode critical state by color alone; source/library states use
  labels and icons.
- Search supports keyboard submission and clear controls.
- Product and installment collections use lazy horizontal lists or slivers.
- Stable tab state avoids duplicate provider requests during ordinary rebuilds.
- Search debounce and generation checks prevent request storms and stale UI.
- Covers reserve dimensions during loading/error to avoid layout jumps.
- Empty, loading, partial-error, no-progress, and no-installment states are
  explicit rather than blank.

## 11. Known UX limitations

- Discovery is first-page provider catalog data; pagination and observation
  timestamps are not yet modeled.
- Global fallback order is deterministic but not yet user-reorderable or
  persisted as a settings record. Per-media preference is fully persisted.
- The product controller refreshes local aggregates after its own mutations and
  on Library navigation; a future cross-process/cloud writer will need database
  watch streams.
- Search does not perform reviewed cross-provider matching. Legitimate but
  unmerged duplicates may appear separately, by design.
- Provider names are derived from configured display names where available and
  readable IDs for synthetic/unregistered bindings.
- Historical merge audits are not a normal-product feature; Developer supports
  the latest in-session safe undo workflow.
- Credits such as studio/author remain provider raw metadata pending a canonical
  credit model.

## 12. M5/M6 integration points

### M5 manga reader

- Accept `CanonicalMediaId`, `CanonicalChapterId`, and an explicitly selected
  `ChapterSourceBinding` from the M4 chapter sheet.
- Resolve reader payloads behind a new application service, never in widgets.
- Resume from `MangaSourcePageResume` only for the exact source binding; fall
  back to canonical chapter continuity when switching scans.
- Preserve the M4 source-choice and unavailable-preference UX.

### M6 anime player

- Accept `CanonicalMediaId`, `CanonicalEpisodeId`, and an explicitly selected
  `EpisodeSourceBinding` from the M4 episode sheet.
- Resolve lawful playback behind a player application service and keep provider
  extraction outside widgets.
- Offer canonical playback position as an approximate cross-encode resume and
  validate duration/cut differences before seeking.
- Keep format/narrative-season uncertainty and provider failure explicit.
