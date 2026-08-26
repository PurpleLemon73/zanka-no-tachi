# M11 Live Media Reconnaissance

Evidence date: 2026-08-25. Requests were deliberately sparse and limited to
the two configured provider authorities, public documents referenced by those
documents, and 2 KiB range checks of the resulting media. No login, CAPTCHA,
anti-bot challenge, access-control bypass, DRM operation, token forgery,
privileged endpoint, or alternate-domain discovery was attempted.

## MangaWorld

### Observed browser chain

1. A configured public manga detail document returns ordinary HTML and public
   chapter anchors under its volume/chapter listing.
2. A selected chapter anchor returns HTTP 200 HTML. The reader document exposes
   the selected chapter object with an ordered `pages` filename array. It also
   renders the first image with the complete public CDN directory.
3. Resolving every filename against that directory produces the page order.
   The sampled chapter contained 41 mixed JPG/PNG filenames.
4. A range request for the first image, with the ordinary chapter referrer,
   returned HTTP 206, `image/jpeg`, and valid JPEG bytes.

The delivery mechanism is therefore public chapter HTML plus direct CDN image
files. No page API, authorization, signed query, cookie-bound image URL, or
obfuscation was required in the observed sample. The chapter token, directory,
filename list, CDN authority, and media URLs remain provider-local ephemeral
facts. Only the existing relative chapter locator is persisted in its source
binding.

### Parser and header boundaries

The manifest parser requires both an ordered public `pages` list and a rendered
chapter image whose directory anchors those filenames. Missing markers,
zero pages, or more than 500 pages are parser/manifest failures. Chapter HTTP
and image HTTP failures are source/page availability failures. Images are lazy;
opening a manifest does not download them. Page requests send the ordinary
chapter `Referer`; no credential header is stored.

Selectors/data paths are fragile because the provider can rename `#reader`,
the serialized `pages` member, or the CDN directory. Minimized fixtures preserve
only these facts. Diagnostics report counts and typed state, never URLs.

## AnimeWorld

### Observed browser chain

1. A configured public series URL redirects to its first public episode page.
   The resulting ordinary HTML contains the episode list, an episode token, a
   page CSRF value, and a session cookie.
2. The provider's referenced public player script issues a same-origin GET to
   `/api/episode/info?id=<episode>&alt=0`, using that normal page session and
   CSRF header. The JSON response returns a relative same-origin player target.
3. That target returns a small public iframe document with HTML
   `<video><source>` metadata.
4. The observed source was a direct HTTPS MP4. A 2 KiB range request with the
   ordinary AnimeWorld referrer returned HTTP 206, `video/mp4`, and a valid ISO
   Base Media prefix.

The delivery mechanism is therefore public episode page/session → public
same-origin JSON → public same-origin iframe → direct MP4. The inspected sample
did not expose HLS, DASH, DRM, Widevine, authentication, or a protected token
exchange. The resolver accepts only declared MP4, HLS, or DASH source types, but
M11 live evidence verifies MP4 only. It does not claim audio or subtitle track
selection.

The page CSRF value and session cookie are ordinary transient browser state.
They exist only inside the bounded in-memory transport. The iframe and media
URLs exist only in the playback manifest. None becomes canonical identity,
binding identity, progress, diagnostics, backup data, or logs.

### Failure taxonomy and uncertainty

Episode/player HTTP failures are availability failures. Missing CSRF, malformed
JSON, absent player target, or absent video source are parser/manifest failures.
A declared media type outside MP4/HLS/DASH is unsupported. CDN lifetime and
whether all catalog entries use direct MP4 remain unproven; every playback
session therefore resolves from the episode page again.

## Evidence minimization

Repository fixtures contain synthetic hosts/tokens and only the structural
markers required by tests. No live CSRF value, cookie, provider media URL,
chapter image, video byte, complete provider HTML, or personal path is stored.

## Capability conclusion

- MangaWorld: `readerCapable` ✅ — public chapter HTML plus direct CDN images.
- AnimeWorld: `playbackCapable` ✅ — public session/JSON/iframe chain resolving
  to a direct MP4 in the verified sample.

These are current compatibility findings, not guarantees that every title or a
future provider revision remains consumable.
