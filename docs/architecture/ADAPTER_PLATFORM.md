# Adapter Platform

## 1. Descriptor and capability model

`AdapterId` is a stable integration identifier, never a canonical media ID. An
`AdapterDescriptor` declares display name, manga/anime scope, local status and
an explicit set of `AdapterCapability` values. The current vocabulary covers
catalog, search, details, chapter/episode metadata, reader/playback manifests,
cover assets, enrichment and pagination. Absence means unsupported; widgets do
not guess capability from provider names or URLs.

MangaWorld and AnimeWorld are metadata adapters. They do not declare reader or
playback manifests. Imported CBZ and video adapters declare the corresponding
local payload capability. This preserves the M5/M6 metadata-only boundary.

## 2. Registration lifecycle

`AdapterRegistry` is the authoritative capability view. Core descriptors cover
the two public metadata sources, production local imports and deterministic
sample sources. Live implementations are registered through
`LiveAdapterSdkBridge`; future lawful adapters can be supplied as additional
`AdapterRegistration` values at composition without changing product widgets
or canonical persistence.

Registration fails when a declared catalog/search/details/enrichment capability
lacks its component or an implementation is present without a declaration.
Application startup also checks reader/playback resolver IDs against descriptor
capabilities. Existing specialized resolver registries remain because they own
M5/M6 session mechanics, but they cannot silently disagree with the central
view.

## 3. SDK contracts

The SDK deliberately uses small interfaces: `CatalogAdapter`, `SearchAdapter`,
`DetailsAdapter`, `InstallmentMetadataAdapter`, `MetadataEnrichmentAdapter`,
`ReaderManifestAdapter`, `PlaybackManifestAdapter`, `ReaderBindingAdapter` and
`PlaybackBindingAdapter`. Every component exposes a descriptor. Catalog/search
return source listings and opaque page state; details return provider DTO
results for canonical ingestion. Reader/player contracts remain provider-neutral
session manifests defined by M5/M6.

An adapter must keep HTTP, parsing and provider mechanics behind these
interfaces. It must not write canonical identity directly from a hostname or
physical path.

## 4. Pagination

`PaginationCursor` is opaque to application/UI code. `PageRequest` accepts a
single cursor and a bounded page size (1–50). Existing bridges translate the
cursor to the provider's page parameter and return `PageResult` with `hasMore`
and at most one next cursor.

Search and Home hold one cursor per adapter. “Load more” performs one page per
explicit tap; there is no background traversal or bulk crawling. Results are
deduplicated by confirmed canonical ID, otherwise by exact adapter/external ID.
Search generations prevent an older initial or next-page response from replacing
or appending to a newer query.

## 5. Persisted configuration

Schema v5 stores enabled state, absolute HTTP(S) base URL, stable ordering and
update time. Invalid or relative URLs are rejected before mutation. The runtime
registry loads persisted values on application/controller initialization.
Changing hostname only changes adapter configuration; canonical media IDs,
source binding external IDs, Library state and progress are untouched.

Safe configuration is included in data-only backup. Restore is non-destructive:
current configuration wins and only missing configuration is imported. Secrets
are neither modeled nor exported.

## 6. Reliability history

Explicit health checks persist `lastCheckedAt`, `lastSuccessAt`,
`lastFailureAt`, consecutive failures, `lastParserMismatchAt` and the last
diagnostic. Success resets the consecutive count. Parser drift therefore remains
distinguishable from transport/HTTP failure after restart. Zanka does not poll
in the background; checks are user-driven.

## 7. Enrichment pipeline

Enrichment attaches to an already selected canonical media ID and persists one
contribution per enrichment adapter. The payload may contribute title,
alternate titles, description, cover and genres while retaining `AdapterId`
provenance. It never creates, changes or merges source bindings.

M8 proves the entire path with `DeterministicEnrichmentAdapter`. It is offline,
repeatable and requires an explicitly reviewed attachment. This avoids adding a
network dependency or silently matching titles. Multiple adapters may coexist;
the current effective projection selects them deterministically by adapter ID.

## 8. Covers and thumbnails

Provider covers remain source evidence. Enrichment covers retain enrichment
provenance in their persisted contribution; local/user covers belong to the
override layer. `CoverArt` handles HTTP(S), absolute local paths and `file:` URIs
with a non-failing placeholder.

For CBZ batches, the naturally first supported image becomes the local cover.
`LocalThumbnailService` caches the extracted bytes in `thumbnail-cache`, updates
cache recency, caps entries (64 by default), and can clear/regenerate the cache.
The cache sits outside managed assets and is excluded from data-only backup.
Video thumbnail generation is not attempted because the current portable player
API does not expose deterministic frame extraction on every target platform.

## 9. Metadata override rules

The effective priority is:

1. explicit user override (`user-override` provenance);
2. reviewed enrichment contribution;
3. canonical provider evidence.

Users can edit display title, alternate titles, cover locator and genres/tags
from Details. Overrides are separate schema-v5 rows, so provider ingestion and
refresh cannot overwrite them. Empty override lists fall back to enrichment or
source evidence. Batch installment labels are reviewed and editable before
commit; imported installment rows retain those labels independently of names.

## 10. Batch import

Settings → Local media supports multi-select CBZ and video batches. Preview
deduplicates paths, applies natural filename ordering and displays cheap probe
results. The user must review a canonical title, choose create-versus-attach,
and may edit every chapter/episode label before committing.

Commit reuses M7's validated app-owned copy workflow. The first file creates (or
uses) the reviewed canonical media; subsequent files attach through the same
canonical/source-binding APIs. Filenames and paths are never canonical identity.

## 11. Probing

CBZ probing validates ZIP structure and reports supported page count and image
formats. It intentionally does not decode every page or scan recursively. Video
probing reports supported container and file size—the reliably portable values
available without invoking platform-specific/native command-line tools.
Duration, dimensions and codec are nullable and currently unavailable; playback
itself obtains duration from the M6 player after opening.

## 12. Diagnostics

Settings → Developer → Adapter Diagnostics takes one bounded database/registry
snapshot. It lists every registered adapter, explicit capabilities, media scope,
persisted enabled/base URL configuration, pagination support, last check,
failure count, parser mismatch time and last error. It performs no crawl and no
automatic network check.

## 13. Error model

SDK consumers receive typed `AdapterConfigurationError`, `AdapterNetworkError`,
`AdapterHttpError`, `AdapterParseError`, `AdapterRateLimitError`,
`AdapterUnsupportedCapability`, `AdapterUnavailable` and
`AdapterEnrichmentConflict`. Live bridges translate legacy provider exceptions
and preserve the underlying cause where useful. Product surfaces use stable,
non-technical messages; diagnostics retain detailed state.

## 14. Adding a new lawful adapter

1. Choose a stable `AdapterId` unrelated to a hostname.
2. Declare the smallest truthful descriptor capability set.
3. Implement only the matching small SDK interfaces.
4. Register the components in application composition (an additional
   registration is sufficient for catalog/search/details/enrichment).
5. If it supplies reader/playback payloads, add a resolver through the existing
   M5/M6 abstraction and declare that exact capability.
6. Use canonical ingestion/source bindings; never infer equality from title.
7. Add offline fixture/fake tests for contracts, errors and pagination.

Product Search/Home/Details query the registry generically, so no provider branch
is required in those widgets. Canonical tables remain unchanged.

## 15. Known limitations

- Public pagination markup may drift; drift is a parse failure, not a network
  failure.
- Page size is a safety bound in the SDK but current sites control actual result
  count.
- Enrichment source choice is deterministic, not a user-editable priority list.
- Local batch picking is multi-file; recursive directory import is intentionally
  not implemented.
- Post-import installment relabeling is not yet exposed; labels are corrected in
  the reviewed pre-commit preview.
- Portable video duration/resolution/codec probing and video frame thumbnails
  need a future cross-platform media-inspection abstraction.
- Absolute local cover overrides are intentionally stripped from portable
  backup and must be reassigned on the destination device.

No protected chapter/video extraction, token resolution, DRM/access-control
bypass, anti-bot behavior, automatic domain discovery or unattended crawl is
implemented.

## 16. M9+ integration points

M9 can add a reviewed public enrichment source, configurable enrichment
priority/conflict review, richer creator/date/format fields, platform media
probing, post-import installment editing, directory batch plans, and optional
full-media encrypted backup. These should extend SDK capabilities and projection
policies rather than add provider branches to product, reader or player UI.
