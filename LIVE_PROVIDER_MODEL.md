# Live Provider Model — M2

## 1. Provider registry and configuration

`ProviderRegistry` is the only production authority for provider base URLs. A
`ProviderConfig` contains a stable `ProviderId`, display name, configurable base
URL, canonical media kind, and enabled state. The defaults are MangaWorld and
AnimeWorld, but tests replace the entire registry or a single configuration.

Changing a base URL changes only URI resolution. Bindings persist provider ID,
provider-local external ID, and relative locator; no hostname is part of a
canonical ID or binding key. The developer harness allows an absolute HTTP(S)
base URL to be entered manually. There is no alternate-domain discovery.

## 2. Live retrieval boundaries

The implemented direction is:

```text
ProviderRegistry / ProviderConfig
  -> LiveProviderAdapter
  -> ProviderTransport
  -> raw public HTML
  -> M0 parser and provider DTO
  -> M1 mapper
  -> CanonicalIngestionService
  -> CanonicalDatabase
  -> LiveProviderRepository
  -> DeveloperSourcesController
  -> Developer Sources widgets
```

`HttpProviderTransport` uses a clear developer-validation user agent, a
12-second default timeout, normal `package:http` redirect handling, HTTP status
validation in the adapter, and at most one retry for a network exception or a
transient 408/429/5xx response. It is disposable. Tests replace it with bounded
fixture transports and never use live Internet.

Supported public requests are:

| Provider | Catalog | Search | Detail and public installments |
|---|---|---|---|
| MangaWorld | `/archive` | `/archive?keyword=...` | stored relative `/manga/...` locator |
| AnimeWorld | `/animes` | `/search?keyword=...` | stored relative `/play/...` locator |

Only title/detail HTML and the chapter/episode links already supported by M0
are parsed. Chapter images and video playback resources are never requested.

## 3. Health-check behavior

The lightweight catalog check makes one request and reports:

- `available`: successful response with recognized catalog items;
- `unreachable`: timeout, connection, DNS, or other transport failure;
- `unexpectedResponse`: non-2xx HTTP response or invalid configuration;
- `parserMismatch`: reachable 2xx HTML lacks expected structural markers or
  produces no required catalog entries;
- `disabled`: provider disabled without making a network request.

Diagnostics are concise and safe for display. Health checks never search for a
new domain or retry in a loop.

## 4. Ingestion policy

Ingestion first queries the durable media binding by
`(providerId, providerLocalExternalId)`.

- Existing binding: reuse its `CanonicalMediaId`.
- Missing binding: allocate a new app-controlled random/time-based ID.
- Each incoming installment repeats the same lookup against its chapter or
  episode binding and allocates an app-controlled ID only when absent.
- Mapping and persistence then run through the M1 provider mapper and canonical
  repository transaction.

The default ID allocator uses application entropy and a local counter. It does
not contain a provider ID, title, URL, path, token, or hostname. Tests inject a
deterministic allocator.

## 5. Same-provider identity rules

`providerId + externalId` is the only automatic M2 match. Repeated catalog or
detail retrieval alone does not persist anything; detail ingestion creates or
refreshes the binding transactionally. Repeated ingestion reuses canonical
media and installment IDs, so it does not duplicate rows.

Concurrent ingestion of the same previously unseen binding is not yet exposed
by the UI and is a known M3 hardening point. Database uniqueness prevents two
durable bindings with the same provider/external ID, but a future concurrent
job queue should serialize or retry the losing transaction cleanly.

## 6. Cross-provider matching policy

M2 performs no title-based, fuzzy, slug-based, or URL-based cross-provider
merge. Identical titles from MangaWorld and AnimeWorld create separate
canonical entities unless an explicit binding already maps the record.

Future integration points are a reviewed metadata-provider mapping, manual
merge/split workflow, and evidence-backed high-confidence matching. False
negatives are accepted in M2 to avoid destructive false-positive equivalence.

## 7. Metadata and provenance refresh rules

An incoming provider may replace normalized title, description, alternate title,
and genre values that have provenance from that same provider. Existing values
owned by another provenance source are retained. Provider-owned status, cover,
anime format, airing window, and episode totals follow the same ownership check
using the title provenance as the M1 coarse ownership marker.

Raw provider fields and relative locators are refreshed in the source binding.
Library rows and progress rows are never part of an import update.

This is deliberately conservative. M1 does not attach provenance to every
scalar, so scalar precedence is coarse until a richer metadata reconciliation
model is justified.

## 8. Installment refresh rules

Manga chapters preserve raw labels, exact decimal representation, special
labels, optional volume, provider external IDs, and relative locators. Anime
episodes preserve raw/ambiguous labels, provider opaque tokens, and the parent
anime's format, unknown-total, and airing-window context.

Known installment bindings reuse canonical IDs. Newly observed installments
are added. Missing installments are not deleted: temporary provider omission
cannot invalidate a canonical chapter/episode that may own user progress.

No manga page list, image asset, playback page, stream URL, or protected payload
is resolved during ingestion.

## 9. Parser drift detection

Retrieval and parsing are separate failure boundaries. A non-2xx response is an
HTTP failure. A 2xx response that lacks MangaWorld `comics-grid` or detail
`comic-info` evidence, or AnimeWorld `film-list` or detail information evidence,
becomes `ProviderParserException`/`parserMismatch`.

Search may legitimately return a structurally valid empty listing. Catalog and
health pages require recognized items. Offline tests cover reachable but
incompatible HTML independently from timeout and HTTP failures.

## 10. Error taxonomy

- `ProviderNetworkException`: timeout/connection/transport failure;
- `ProviderHttpException`: non-success status with status code;
- `ProviderParserException`: reachable HTML incompatible with expected parser
  structure;
- `ProviderConfigurationException`: invalid retrieval configuration;
- `ProviderDisabledException`: action attempted for a disabled provider.

These are application-layer errors. The canonical domain imports none of them
and remains unaware of HTTP and parser implementation details.

## 11. Developer validation UI

The running application is intentionally the temporary `Developer Sources`
screen, not a final product UI. It provides:

- provider name, kind, enabled switch, base URL editor, health state, diagnostic,
  `Check`, and `Catalog` actions;
- provider-selectable public search;
- result selection that retrieves detail HTML and ingests it;
- canonical ID, provider/local ID, kind/format, status, public cover locator,
  title provenance, chapter/episode counts, and binding inspection;
- persisted canonical media reload after navigating away or restarting.

Widgets call only `DeveloperSourcesController`, which calls
`LiveProviderRepository`. They do not import provider parsers or issue Drift
queries.

## 12. Base-URL replacement behavior

The automated scenario ingests from Base URL A, replaces only the registry
configuration with Base URL B, and ingests the same provider/local item again.
The transport observes the new hostname while persistence retains the original
canonical media ID, installment IDs, relative binding, and single media row.

The same behavior is manually testable by editing the base URL in the provider
panel and selecting `Apply URL`. This is configuration, not canonical identity
migration.

## 13. Legacy prototype decision

Decision: retire it from production and keep it temporarily as isolated
historical evidence.

The old `AppDatabase`, raw-string `lib/domain/models.dart`, `AppController`, and
mock provider interfaces are no longer imported by `main.dart` or the M2
application path. Production opens only M1's `CanonicalDatabase` at
`zanka-canonical.sqlite`. The old files and their restart test remain in the
repository to avoid silently deleting prototype evidence, but they must receive
no new features and are not a competing runtime authority.

A later milestone may delete them or provide an explicit one-time migration if
real pre-M0 user data must be retained.

## 14. Known risks for M3

- Serialize/retry concurrent first ingestion of the same unseen binding.
- Persist developer-edited provider configuration if it becomes user-facing;
  M2 configuration replacement is runtime-only.
- Add explicit last-observed/staleness data instead of retaining omitted
  installments indefinitely without visibility.
- Design reviewed canonical merge/split and metadata-provider matching.
- Refine scalar provenance beyond title-owned precedence.
- Decide whether sourced list JSON should become normalized query tables.
- Add pagination/query models beyond the first public result page.
- Validate/detail parser drift against additional live samples without bulk
  crawling.
- Remove or migrate the isolated legacy prototype files.

## Manual validation procedure

1. Run `flutter run` on Android, iOS, macOS, Linux, or Windows with Internet
   access. The app opens directly on `Developer Sources`.
2. Confirm both provider panels show their configured URLs and are enabled.
3. Select `Check` once for each provider. Expect `available`; otherwise read the
   distinction between unreachable, unexpected response, and parser mismatch.
4. Select MangaWorld, search for `MAD`, and tap a result. Confirm the inspection
   shows a canonical ID, `mangaworld` binding/local ID, provenance, and chapters.
5. Note the canonical ID. Tap the same search result again. Confirm the message
   says it refreshed without duplication and the persisted list still contains
   one row with the same ID.
6. Select AnimeWorld, search for `Fullmetal Alchemist`, tap a result, and confirm
   format/status, `animeworld` binding/local token, provenance, and episode count.
7. Leave the app screen or terminate/relaunch the app. Under `Persisted canonical
   media`, use the reload button and confirm both items remain inspectable.
8. For a known lawful replacement host, edit only the provider's base URL and
   select `Apply URL`, then repeat search/ingestion. Confirm the canonical ID and
   persisted row do not change. Do not guess or discover alternate domains.
9. To validate error display safely, disable a provider and confirm its network
   actions are disabled, then re-enable it. A deliberately invalid developer URL
   may be used to observe `unreachable`, but avoid repeated checks.
10. Do not navigate into reader/playback payloads; M2 validates only public
    catalog, search, detail, and visible installment metadata.
