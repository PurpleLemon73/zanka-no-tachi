# Canonical Domain Model — M1

## 1. Dependency direction

```text
MangaWorld HTML ─▶ MangaWorld DTO ─▶ MangaWorld mapper ─┐
                                                        ├─▶ canonical domain ─▶ Drift
AnimeWorld HTML ─▶ AnimeWorld DTO ─▶ AnimeWorld mapper ─┘
```

The canonical domain imports no provider parser or DTO. Provider mappers depend
on both their M0 DTO and the canonical domain. Parsing, canonical matching, and
persistence are separate responsibilities.

## 2. Canonical entities and IDs

Strong value types prevent accidental interchange of identities:

- `CanonicalMediaId`
- `CanonicalChapterId`
- `CanonicalEpisodeId`
- `ProviderId`

Canonical IDs are application-owned opaque strings. They are never derived from
a provider URL, MangaWorld numeric ID, AnimeWorld token, or title hash.

`CanonicalMedia` is a sealed base with common display metadata. Its concrete
types are:

- `CanonicalManga`
- `CanonicalAnime`

Manga and anime share identity/title/description/status/genre/cover concepts,
but not an artificial common installment type. `CanonicalChapter` and
`CanonicalEpisode` remain distinct.

## 3. Source bindings

Bindings are explicit and installment-specific:

```text
CanonicalMediaId   ◀── MediaSourceBinding   ──▶ ProviderId + external ID
CanonicalChapterId ◀── ChapterSourceBinding ──▶ ProviderId + external ID
CanonicalEpisodeId ◀── EpisodeSourceBinding ──▶ ProviderId + external ID
```

Each binding stores:

- canonical entity ID;
- provider ID;
- provider-local external ID/token;
- optional provider-relative locator;
- small raw provider metadata map.

Full URLs are not durable identities. Relative locators resolve through M0's
`SourceConfig`, which remains the base-URL authority.

Database uniqueness enforces:

- one canonical entity per `(providerId, externalId)`;
- at most one current binding per `(canonicalId, providerId)`.

Saving a changed provider-local ID atomically replaces the old binding for the
same canonical/provider pair. It cannot take an external ID already bound to a
different canonical entity.

## 4. Chapter numbering

`ChapterNumber` preserves:

- the exact raw label;
- optional integer part;
- optional exact fractional digit string;
- an optional normalized numeric string.

Examples:

| Raw label | Whole | Fraction | Normalized |
|---|---:|---|---|
| `Capitolo 142` | 142 | null | `142` |
| `Capitolo 30.10` | 30 | `10` | `30.10` |
| `Extra estivo` | null | null | null |

The exact label is authoritative. A `double` is not persisted as chapter
identity or exact representation. Numeric ordering compares integer and
fractional value; numerically equivalent forms such as `30.1` and `30.10`
compare equally while retaining distinct raw representations. Specials fall
back to label ordering. Ambiguous equivalent labels must not be silently merged;
matching policy must choose or retain separate canonical chapters.

`volumeLabel` is optional. Missing volume data does not invent an “unvolumed”
volume entity and does not block chapter persistence.

## 5. Anime installments and formats

`EpisodeLabel` retains the raw provider label and an optional parsed numeric
value. This supports numbered episodes and non-standard labels such as
`Special A`. Unknown series totals use:

- `knownEpisodeTotal: null`
- `rawEpisodeTotal: "??"` when that is the observed provider fact.

`AnimeFormat` supports `tv`, `movie`, `ova`, `ona`, `special`, `music`, and
`unknown`. Provider string `Anime` currently maps cautiously to `tv`, while its
raw value remains in binding metadata.

### Airing window is not narrative season

```text
AiringWindow(Autumn, 2003)  ≠  NarrativeSeasonNumber(2)
```

`AiringWindow` represents a release season-of-year and year observed from the
provider. `NarrativeSeasonNumber` is a separate optional concept and is never
inferred from the airing window or a title suffix. M1 mappers do not infer
narrative seasons.

## 6. Provenance

Important normalized text uses `SourcedValue<T>` with `FieldProvenance`:

- primary title;
- alternate titles;
- description;
- genres.

Each value can answer which provider supplied it and can preserve a raw value.
Provider-only facts such as MangaWorld fansub/author/artist or AnimeWorld audio,
subtitle mode, studio, and duration remain binding metadata until a later model
has enough evidence to normalize them safely.

Tradeoff: provenance is not attached to every scalar. Status, format, airing
window, and episode totals retain raw source forms in binding metadata while
their supported canonical form is stored on media. This avoids a provenance
graph disproportionate to M1 while preserving the path back to evidence.

## 7. Library and progress

`CanonicalLibraryEntry` references only `CanonicalMediaId` and stores:

- saved and favorite flags;
- evolvable canonical library status;
- created and updated timestamps.

`CanonicalMangaProgress` references canonical media/chapter IDs plus page index,
optional total pages, and update time.

`CanonicalAnimeProgress` references canonical media/episode IDs plus playback
position, optional duration, and update time.

No progress object contains provider IDs, provider tokens, provider URLs, image
URLs, or stream URLs. Persistence validates that the installment belongs to the
same canonical media before accepting progress.

## 8. Drift persistence

The M1 `CanonicalDatabase` is separate from the legacy prototype database and
starts at schema version 1. Foreign keys are enabled before opening.

Tables:

- canonical media records;
- canonical chapter records;
- canonical episode records;
- media/chapter/episode source bindings;
- canonical library records;
- canonical manga progress records;
- canonical anime progress records.

Normalized title/description provenance has dedicated columns. Lists of sourced
alternate titles and genres are stored as version-1 JSON payloads. This is a
known early-schema compromise; M2 may normalize them into child tables if query
requirements justify it.

Non-negative progress positions have database `CHECK` constraints. Media-kind
and installment ownership checks are enforced by the write API in addition to
foreign keys.

Future schema changes must increment `schemaVersion` and add explicit Drift
migrations. Tests use only in-memory or temporary file databases.

## 9. Mapping boundaries

`MangaWorldCanonicalMapper` and `AnimeWorldCanonicalMapper` transform M0 title
DTOs into import bundles containing:

- canonical media;
- canonical installments;
- media binding;
- installment bindings.

The caller supplies the canonical media ID and an installment-ID allocator or
matching function. This is deliberate: a mapper cannot prove that differently
named/provider-local records describe the same work or installment.

`CanonicalRepository` persists each import bundle transactionally. No HTML
parsing occurs in entities, mappers, or persistence.

## 10. Provider replacement behavior

```text
Before:
Provider A binding ─▶ Canonical chapter 142 ◀─ progress(page 17)

Delete Provider A bindings:
                       Canonical chapter 142 ◀─ progress(page 17)

After:
Provider B binding ─▶ Canonical chapter 142 ◀─ progress(page 17)
```

Provider-binding deletion never cascades into canonical entities, library, or
progress. Tests cover manga and anime replacement using entirely different
provider-local IDs and verify state both immediately and after closing/reopening
the database.

## 11. Rejected designs

- Provider URL or external ID as canonical primary key: breaks replacement.
- Title hash as canonical ID: spelling/localization collisions and changes are
  unresolved by M0 evidence.
- One generic installment model: erases manga volume/chapter versus anime
  episode semantics.
- `double`-only chapter number: loses special labels and exact decimals.
- Airing season as franchise season: contradicts AnimeWorld evidence.
- Cascading canonical deletion when a provider is removed: destroys user state.
- Automatic cross-provider merge in mappers: hides matching uncertainty.

## 12. Known compromises and unresolved M1 questions

- Canonical ID generation and cross-provider matching policy are intentionally
  left to M2; M1 requires explicit caller decisions.
- A source cover locator may become stale. It is display metadata, never
  identity, and a future asset/provenance model may replace the scalar.
- Status normalization is deliberately small and stores unrecognized values as
  `unknown` with raw source metadata retained.
- Episode numeric parsing uses `double` only as an optional convenience value;
  the raw label remains authoritative. If decimal anime episodes become a key
  ordering requirement, adopt the exact chapter-style representation.
- JSON sourced-value lists need explicit migration if they become independently
  searchable.
- Canonical merge/split operations are not implemented. They require careful
  transactional progress and binding reassignment semantics.

## 13. Expected M2 integration points

- canonical ID generator;
- explicit matching/reconciliation service with confidence and user review;
- metadata-provider bindings (for example AniList) without making them content
  source identity;
- repository query/watch interfaces for UI state;
- source registry mapping `ProviderId` to current `SourceConfig`;
- canonical merge/split workflow;
- migration from or removal of the legacy prototype domain/database;
- local CBZ/CBR and video bindings with no network URL;
- richer credits, assets, tags, and popularity observations if product queries
  require them.
