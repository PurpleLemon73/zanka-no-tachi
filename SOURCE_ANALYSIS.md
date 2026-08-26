# Source Analysis — M0 Provider Reconnaissance

Evidence date: 2026-08-25

Scope: public catalog, search, title metadata, and publicly visible
chapter/episode listing metadata. No chapter image payloads, video streams,
authentication, access-control bypass, or anti-bot circumvention was examined.

## Evidence basis

Structural observations were checked against public HTML from:

- MangaWorld home: `https://www.mangaworld.mx/`
- MangaWorld archive/search: `https://www.mangaworld.mx/archive`
- MangaWorld detail samples: numeric title `3693` (ongoing, volumes, decimal
  chapters), numeric title `2050` (multiple volumes), plus completed-title
  listing evidence.
- AnimeWorld archive: `https://www.animeworld.ac/animes`
- AnimeWorld detail samples: token `Ge2kM` (dubbed TV/completed), `44HCI`
  (movie), `amhXs` (ongoing ONA/unknown total), plus OVA and other movie/ONA
  results.

The repository fixtures are manually minimized from these observations. They
retain the relevant element hierarchy, class/attribute names, representative
values, and relative URL shapes while omitting scripts, ads, comments, account
controls, and unrelated page chrome. Tests use only those offline fixtures and
the synthetic `fixture.invalid` hostname.

## 1. MangaWorld structure

### Observed entities and fields

The public pages expose listing items, title details, volume groups, and chapter
rows.

Listing items (`.comics-grid .entry`) expose:

- title and source URL through `.manga-title`;
- cover through `.thumb img`;
- type such as Manga, Manhwa, or Manhua;
- status such as `In corso` or `Finito`;
- author, artist, genres, and a shortened synopsis on archive cards;
- latest chapter in home/latest contexts;
- year in some contexts, but not consistently on every archive card.

Detail pages (`.comic-info`) expose title, cover, genres, author, artist, type,
status, views, release year, fansub, and external metadata links when present.
Synopsis appears in `.comic-description #noidungm` in the observed live page.
Alternate titles were not confirmed as a consistently rendered dedicated field.

### Chapters and volumes

Chapters are grouped by `.volume-element`, with `.volume-name` and
`.volume-chapters .chapter`. The observed live links use `a.chap`, their visible
label is in a child `span`, and display date in `.chap-date`.

Observed numbering includes:

- zero-padded integers (`01`);
- ordinary integers (`49`);
- decimals (`30.1`, `30.2`, `39.5`, `46.5`);
- non-numeric/special labels remain possible and are intentionally represented
  by a raw label with a nullable parsed number.

Volume association is explicit for sampled Manga titles, but not assumed to be
universal. A chapter title distinct from `Capitolo N` was not confirmed on the
live samples; the DTO keeps it optional.

### Identity and URLs

Title URLs have the observed shape `/manga/{numeric-id}/{slug}`. The numeric
segment is stored as `sourceId`; it is not a canonical media ID. Chapter URLs
have an opaque final segment under the title's `/read/` path. Full URLs are
retained as source facts but resolved through configurable `SourceConfig`.

### Pagination and popularity

Archive/search uses a pagination container (`#pagination`) whose content is at
least partly script-assisted. The parser accepts explicit current/total page
attributes in offline evidence, but live pagination extraction remains fragile.

The home page has separate concepts:

- trending chapters;
- latest chapters;
- monthly manga rank;
- read/view count;
- newest additions.

These must not be normalized into one unexplained `popularity` value.

### Optional fields, inconsistencies, and fragile selectors

- Author and artist can be separate even when their values match.
- Fansub and external reference links are optional.
- Year is visible on detail pages but not every listing context.
- “New” can replace a date in latest-chapter presentation.
- Presentation classes (`comic-info`, `volume-element`, `chap`) may change.
- Pagination relies on a comparatively fragile script/UI boundary.
- Publication dates are Italian display strings; timezone and machine-readable
  semantics were not confirmed.

## 2. AnimeWorld structure

### Observed entities and fields

The public pages expose listing items, title details, server group presentation,
and episode links.

Archive items (`.film-list .item`) expose title, source URL, cover, a
`data-jtitle` value, and sometimes a `.dub` badge. The visible title and
`data-jtitle` may differ (localized versus Japanese/alternate title), but in
some samples they are identical.

Detail pages expose:

- title at `#anime-title` with `data-jtitle`;
- cover at `#thumbnail-watch img`;
- metadata as `dl.meta` `dt`/`dd` pairs;
- category/format, audio, release date, airing-season label, studio, genres,
  score, duration, episode total, status, and views;
- synopsis in `.widget.info .desc`;
- episodes in `.servers .episodes a`, including source-local episode token and
  numeric display attributes.

### Episode and season representation

Episode links append an opaque token to the series URL and carry numeric
attributes such as `data-episode-num`. Large lists are split into UI ranges
(for example `1 - 50`, `51`), not separate canonical seasons.

`Stagione: Autunno 2003` is an airing window (season + year). It is not evidence
of a franchise season entity. Franchise sequels commonly appear as separate
catalog titles (often with `2`, `3`, or “2nd Season” in title metadata).

Unknown episode totals are rendered as `??`; the parser preserves that raw
label and returns a null numeric total. Movies typically report one episode,
while duration may use an hour-form label such as `1h e 02 min`.

### Formats

Observed categories include Anime (TV-like series), Movie, OVA, ONA, Special,
and Music in navigation/filtering. Detail evidence was checked across Anime,
Movie, OVA, and ONA. Category remains a raw source string because exact mapping
of `Anime` to TV is not guaranteed by the label alone.

### Dubbing, subtitles, and audio

These are related but distinct source facts:

- `.dub` is a catalog badge;
- `Audio` is a detail language such as `Italiano` or `Giapponese`;
- archive filters separately expose `Subbato`/`Doppiato` and audio languages;
- `(ITA)` is often part of a displayed title, but must not be the only language
  signal.

No reliable per-episode subtitle-language matrix was observed. The DTO keeps
subtitle mode optional and does not infer it from title text.

### Identity, pagination, and ranking

Series URLs have the shape `/play/{slug}.{opaque-series-token}`. Episode URLs
append an opaque episode token. Tokens are suitable only for provider bindings.

The archive visibly reports `pagina 1 di 101` and exposes previous/next
navigation. Top lists are period-specific (day/week/month) and show rank, views,
and score separately. These values have distinct semantics.

### Optional fields, inconsistencies, and fragile selectors

- Studio may be `Sconosciuto` or absent.
- Episode total may be `??`.
- `data-jtitle` may equal the visible title and is therefore only a candidate
  alternate title.
- Some film evidence omitted a season/studio value.
- Duration syntax differs for series and movies.
- Detail information is duplicated between compact summary and full metadata;
  parsing is scoped to the full `.widget.info` block.
- CSS classes and opaque tokens are provider implementation details.

## 3. Cross-source comparison

| Concept | MangaWorld evidence | AnimeWorld evidence | Canonical implication |
|---|---|---|---|
| Identity | Numeric title ID in `/manga/` URL | Opaque token in `/play/` URL | Separate provider binding from canonical ID |
| Title | Visible title | Visible/localized title | Common display-title concept |
| Alternative titles | Not consistently confirmed | `data-jtitle`, sometimes identical | Optional labeled title variants, preserve provenance |
| Cover | CDN/resource URL | Image resource URL | Ephemeral source asset reference |
| Description | Detail synopsis | Detail synopsis | Common optional synopsis with provenance |
| Status | `In corso`, `Finito` | `In corso`, `Finito`, filters add unreleased/dropped | Raw source status plus cautious mapping |
| Format/type | Manga/Manhwa/Manhua/etc. | Anime/Movie/OVA/ONA/etc. | Separate manga publication type and anime format vocabularies |
| Genres | Genre links | Genre links | Shared tag concept possible; vocabularies remain source-labeled |
| Authors/studio | Author and artist | Studio | Separate credits, not one `creator` scalar |
| Chapters/episodes | Chapter label/number/date | Episode label/number/token | Distinct child entities and progress units |
| Volumes/seasons | Explicit volume groups | Airing season label; sequels often separate titles | Never equate volume and season |
| Progress unit | Chapter then page (page not inspected in M0) | Episode then playback position (stream not inspected) | Media-kind-specific progress |
| Dates | Italian chapter/release display strings | Release display date and airing window | Raw label plus optional parsed date later |
| Ranking/popularity | Monthly rank and read counts | Period rank, views, score | Typed metrics with period/source, not one score |
| Provider binding | Numeric ID + URL | Opaque series token + URL | Dedicated `SourceBinding` |
| Source URL | Title/chapter URLs | Series/episode URLs | Config-relative locator; never canonical identity |

## 4. Proposed canonical concepts for M1

The minimum evidence-supported direction is:

- `CanonicalMedia`: application-owned identity, primary display metadata, media
  kind, and provenance-aware title variants.
- `Manga` and `Anime`: kind-specific extensions rather than a forced shared
  installment model.
- `SourceBinding`: canonical ID, provider ID, provider-local media ID, current
  locator, last-observed time, and optional raw source facts.
- `MediaCredit`: role + name, accommodating manga author/artist and anime studio
  without flattening their semantics.
- `SourceTag`: source label and optional later canonical tag mapping.
- `Volume` and `Chapter`: volume optional; chapter retains raw label, optional
  decimal number, optional title/date, and source binding/locator.
- `Episode`: raw label, optional decimal/integer number, optional title/date,
  and source binding/locator.
- `AiringWindow`: optional season-of-year + year metadata. Do not call it a
  franchise `Season` without stronger evidence.
- `LibraryEntry`: application-owned relation to canonical media.
- `MangaProgress`: canonical media/chapter reference and page position.
- `AnimeProgress`: canonical media/episode reference and playback position.
- `PopularityObservation`: provider, metric kind, optional period, value, rank,
  and observation time.

Canonical records should not contain fields named `mangaworldId` or
`animeworldId`. Provider-local identities belong in bindings.

## 5. Mapping risks

- Title matching cannot establish canonical identity reliably; localized,
  Japanese, romanized, suffix-bearing, and franchise-season titles differ.
- Manga `status` and AnimeWorld status vocabularies overlap textually but may
  differ operationally.
- Manga decimal chapter numbers should not use binary floating point as a
  durable canonical key. Preserve the raw label and use a decimal/string-based
  sortable representation later.
- “Special” chapter/episode labels may not have numeric semantics.
- Explicit MangaWorld volumes may be absent or incomplete.
- AnimeWorld airing season is not a franchise season.
- `DUB`, subtitle mode, audio language, and `(ITA)` are not interchangeable.
- Scores, view counts, and ranks differ by metric and observation period.
- Display dates lack confirmed timezone/ISO semantics.
- Provider cover and resource URLs can change independently of source IDs.
- A source-local ID can disappear or be reassigned; bindings need observation
  history and should not become canonical identity.

## 6. Future-provider compatibility

- Another manga source fits through its own DTO/parser and bindings; it may add
  official volume/chapter IDs or different numbering without changing the
  MangaWorld DTO.
- Another anime source can expose real franchise seasons, episode titles,
  multiple audio tracks, or per-episode subtitles without forcing those facts
  into AnimeWorld's DTO.
- Local CBZ/CBR fits as another binding type with file identity, optional volume
  and chapter metadata, and page-based progress; it has no source URL.
- Local video fits with file identity, duration, optional episode mapping, and
  playback progress; it has no provider stream locator.
- Legal public APIs can supply typed identifiers and dates through their own
  DTOs and mappers.
- AniList or another metadata provider should be a separate metadata binding,
  not assumed equivalent to a content source or treated as infallible identity.

## Unresolved uncertainties

1. MangaWorld alternate-title markup was not confirmed across enough detail
   samples.
2. MangaWorld chapter titles distinct from chapter labels were not confirmed.
3. MangaWorld live archive pagination values are script-assisted; exact request
   and terminal-page behavior needs a future bounded check.
4. Volume coverage may be editorially incomplete; absence cannot yet mean
   “unvolumed” canonically.
5. AnimeWorld `data-jtitle` is sometimes identical to the visible title; its
   exact language/romanization contract is unknown.
6. AnimeWorld subtitle metadata was visible as archive filtering semantics but
   was not confirmed as a stable per-title/per-episode detail field.
7. No reliable per-episode release date/title field was confirmed on sampled
   AnimeWorld pages.
8. Whether opaque provider tokens remain stable across domain migrations is
   unknown.
9. Status, score, views, and rank update cadence is unknown for both sources.
10. Date timezone and normalization rules remain unconfirmed.

These uncertainties are intentionally nullable/raw in M0 DTOs and do not block
the evidence-supported parser contracts.
