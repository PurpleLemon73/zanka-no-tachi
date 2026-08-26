# M11 Live Provider Media Model

## Architectural placement

```text
chapter/episode source binding (stable provider-local reference)
        │
        ▼ resolve fresh per session
provider document chain + transient session state
        │
        ▼
ephemeral ReaderManifest / PlaybackManifest
        │
        ├─ canonical progress + completion (installment identity)
        └─ exact-source resume (provider + binding external ID)
```

Widgets remain provider-agnostic. Product Details and Home Continue ask the
existing `ReaderRepository`/`PlaybackRepository` for capabilities and sessions.
MangaWorld implements `ReaderSourceResolver`; AnimeWorld implements
`PlaybackSourceResolver`. Provider HTML, JSON, cookies, CSRF handling and media
locator parsing live under `live_media/`, outside product and media widgets.

## Transport

`LiveMediaTransport` is a small injectable GET contract returning status, bytes,
headers and final URI. The production transport has a 15-second bound, an
ordinary browser user agent and an in-memory per-origin cookie jar. It accepts
only call-site-supplied ordinary request headers. Tests replace it with offline
fakes; ordinary tests never access the network.

Transient cookie and CSRF values are not exposed to diagnostics. Closing the
application composition closes the transport and discards them.

## Manga reader resolver

The binding retains its existing relative chapter locator and opaque external
ID. At `open` the resolver uses the current provider configuration, fetches the
chapter document, parses the bounded ordered page manifest, and constructs lazy
`ReaderPage` closures. `displayLocator` is a human label rather than a remote
URL. The three-page reader cache and M10 page-aware tracking remain unchanged.

Changing the configured base authority affects the next resolution through a
registry lookup; it does not rewrite canonical IDs or binding external IDs.
Canonical read completion remains independent from exact MangaWorld page
resume. A source change never maps page indices between bindings.

## Anime playback resolver

The binding retains its relative episode locator and opaque episode token. At
`open` the resolver fetches the public episode page, obtains ordinary transient
session/CSRF state, requests its public JSON target, fetches the returned player
document, and parses its declared source. The resulting network manifest passes
an ordinary referrer through `VideoPlayerController.networkUrl(httpHeaders:)`.

The current player stack consumes direct MP4 and can consume platform-supported
HLS/DASH when truthfully declared, but live M11 evidence is MP4 only. Track lists
remain empty: HTML audio language metadata is not evidence of selectable media
tracks. M10 watched/unwatched, 90% completion, autoplay-next, preferences and
exact-source timestamps are untouched. Switching binding starts from that
binding's resume only.

## Capability and diagnostics

Adapter descriptors declare `readerManifest` for MangaWorld and
`playbackManifest` for AnimeWorld because both were verified through public
bytes. Resolver capability becomes temporarily unavailable when the provider is
disabled or the binding has no locator.

Adapter Diagnostics adds an in-memory media-manifest state:
`neverResolved`, `available`, `networkFailure`, `parserMismatch`, or
`unsupported`, with time and a locator-free summary. Existing provider catalog
reliability remains separate. This makes media parser drift distinguishable
from metadata parser drift and network failure without persisting locators.

## Security and locator hygiene

- Only HTTP(S) provider/media URIs are accepted.
- Page count is bounded to 500.
- Raw media locators, cookies and CSRF values are never written to Drift,
  progress, backup, or local diagnostics.
- Diagnostic summaries contain only stage/type/count, not URLs or tokens.
- No redirects are used for alternate-domain discovery; normal HTTP redirects
  from a requested public resource are transport behavior only.
- No auth/CAPTCHA/anti-bot/DRM bypass or protected token resolution exists.

## Fixture and regression strategy

Minimized fixtures cover MangaWorld reader success/drift and AnimeWorld episode
page, JSON, MP4 player and drift. Tests prove lazy reads, order, headers, typed
failures, no track claims, dynamic base replacement, and locator-free display.
The full M0–M10 suite continues to cover canonical refresh, provider replacement,
source switching, completion, resume, backup, migrations, security and product
flows.

## Known risks for a later milestone

- Provider markup and player chains are inherently drift-prone.
- AnimeWorld may use another lawful format or an unsupported/protected mechanism
  for some episodes; those sessions must fail honestly without capability
  fabrication or fallback endpoint discovery.
- CDN referrer policy and locator lifetime may change.
- `video_player` still exposes no truthful cross-platform embedded track picker.
- Live validation should remain sparse and user-driven; there is no background
  crawling or speculative pre-resolution.
