# M11 Live Provider Media Model

## M12 reliability extension

M12 adds transient exact-binding observations on top of descriptor capability,
one opt-in fresh resolver retry, one MangaWorld same-page manifest refresh, and
one remote player-initialization refresh. The canonical/source-binding/session
boundaries are unchanged. Details and media screens consume generic ready versus
retryable availability and actionable typed errors; no provider branch entered
normal widgets.

MangaWorld parsing now handles common lazy attributes, absolute/relative JSON
page refs, deduplication, malformed refs and redirect-final referrers. AnimeWorld
selects verified MP4 across multiple source elements and rejects unevidenced
delivery formats. Adapter Diagnostics exposes only aggregate sanitized timing,
failure class, media type and retry outcome. `LIVE_RELIABILITY.md` is the M12
policy authority and `LIVE_COMPATIBILITY_MATRIX.md` records the evidence.

## Dependency and state boundary

```text
chapter/episode source binding
        │ resolve fresh with current ProviderConfig
        ▼
public provider document chain + transient session state
        ▼
ephemeral ReaderManifest / PlaybackManifest
        ├─ canonical progress + completion
        └─ exact-source page/timestamp resume
```

Product widgets remain provider-agnostic. Details and Home Continue use the
existing `ReaderRepository`/`PlaybackRepository`. MangaWorld implements
`ReaderSourceResolver`; AnimeWorld implements `PlaybackSourceResolver`.
Provider HTML/JSON/cookies/CSRF/media parsing lives under `live_media/`.

## Transport

`LiveMediaTransport` is an injectable bounded GET contract returning status,
bytes, headers and final URI. Production uses a 15-second timeout, ordinary
browser user agent, normal redirects, and an in-memory per-origin cookie jar.
Only ordinary call-site headers are supported. Offline fakes back all tests.
Closing app composition closes the transport and discards session state.

## MangaWorld resolver

The binding retains its relative chapter locator and opaque external ID. On
open, the resolver reads current provider configuration, fetches chapter HTML,
parses a maximum of 500 ordered pages, and creates lazy page closures. Reader
display locators are human labels, not URLs. Changing base authority affects the
next resolution without changing canonical/binding IDs. Canonical completion
and exact MangaWorld page resume remain separate; source switching maps no page.

The metadata parser supports both grouped volumes and current ungrouped chapter
wrappers. Ungrouped rows retain a null volume. This physical-test discovery is
covered by a minimized fixture.

## AnimeWorld resolver

The binding retains its relative episode locator/token. On open, the resolver
fetches the episode page, uses its ordinary transient session/CSRF state for the
public JSON request, fetches the returned player document, and parses its
declared media source. Network manifests pass an ordinary referrer through
`VideoPlayerController.networkUrl(httpHeaders:)`.

Live evidence is direct MP4. HLS/DASH are accepted only when truthfully declared
and supported by the target platform. Track lists stay empty because metadata
language is not proof of selectable media tracks. Watched/unwatched, 90%
completion, autoplay-next, preferences and exact-source timestamp resume remain
the unchanged M10 implementation.

## Capability and diagnostics

Descriptors declare MangaWorld `readerManifest` and AnimeWorld
`playbackManifest`. Disabled providers or locator-less bindings are temporarily
unavailable. Adapter Diagnostics adds an in-memory media-manifest state:
`neverResolved`, `available`, `networkFailure`, `parserMismatch`, or
`unsupported`, with time and a locator-free summary. Catalog parser reliability
remains separate.

## Locator hygiene and safety

- Only HTTP(S) media locators are accepted.
- Cookies, CSRF and resolved media URLs remain in memory.
- No locator is written to canonical identity, progress, backup or diagnostics.
- Summaries store only stage/type/count, never URL/token values.
- No automatic domain discovery, background crawling, auth/CAPTCHA/anti-bot
  bypass, protected token resolution, or DRM handling exists.

## Verification and remaining risks

Offline fixtures prove page order/laziness, ordinary headers, typed drift and
network outcomes, public MP4 parsing, no track claims, and dynamic base
replacement. The M0–M10 suite continues to prove canonical refresh/replacement,
completion, source resume, backup/migration/security and product behavior.

Provider markup, CDN referrer policy and media chain can drift. Some AnimeWorld
episodes may expose a different lawful format or an unsupported/protected
mechanism; those sessions must fail honestly without endpoint discovery or
capability fabrication. The current player still has no truthful cross-platform
track picker.
