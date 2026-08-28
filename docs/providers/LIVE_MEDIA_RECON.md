# M11 Live Media Reconnaissance

## M12 representative follow-up — 2026-08-26

Sparse follow-up expanded MangaWorld reader evidence to four titles with sampled
manifests of 18, 64, 26, and 179 pages, covering grouped/ungrouped lists, a
completed title, ongoing/very-long catalogs, decimal chapters and an observed
oneshot label. The same first-image plus ordered JSON-list contract held. No
naturally different CDN authority was encountered.

AnimeWorld follow-up inspected five player documents spanning completed dubbed
TV, Movie, OVA, ONA and ongoing long TV. Every sample declared direct MP4. No
HLS, DASH, alternate iframe delivery, or reliable selectable track was observed.
Consequently M12 narrows supported live delivery to verified MP4 and classifies
other/iframe shapes as unsupported until evidence changes.

Evidence date: 2026-08-25/26. Requests were sparse and limited to configured
provider authorities, public documents referenced by them, and 2 KiB range
checks of resulting media. No login, CAPTCHA, anti-bot challenge, access-control
bypass, DRM operation, token forgery, privileged endpoint, or alternate-domain
discovery was attempted.

## MangaWorld

### Delivery found

1. Public manga detail HTML exposes ordinary chapter anchors.
2. A chapter anchor returns HTTP 200 HTML containing the selected chapter's
   ordered `pages` filename array and a rendered first image whose URL supplies
   the public CDN directory.
3. Resolving the filenames against that directory produces page order. The
   reconnaissance sample contained 41 mixed JPG/PNG filenames.
4. A 2 KiB first-image range request with the ordinary chapter referrer returned
   HTTP 206, `image/jpeg`, and valid JPEG bytes.

The mechanism is public chapter HTML plus direct CDN image files. No page API,
authorization, signed query, cookie-bound image, or obfuscation was required in
the observed samples. Chapter token, CDN authority, paths and image URLs remain
provider-local ephemeral facts. Only the pre-existing relative chapter locator
is persisted in its source binding.

Current detail markup has both explicit `.volume-element` groups and ungrouped
`.chapters-wrapper .chapter` rows. Physical validation exposed the ungrouped
variant after the first pass; the metadata parser now supports it while leaving
`volumeLabel` null rather than inventing a volume.

### Resolver and failure boundary

The resolver requires an ordered public `pages` list and rendered chapter image
directory. Zero pages, missing markers, or over 500 pages are manifest/parser
failures. Chapter HTTP and image HTTP failures are availability/page failures.
Images are lazy: resolving a session does not download all pages. Image requests
send the ordinary chapter `Referer`; no credential header is stored.

## AnimeWorld

### Delivery found

1. A public series URL redirects to a public episode page containing episode
   tokens, a page CSRF value, and an ordinary session cookie.
2. The provider's public player script calls same-origin
   `/api/episode/info?id=<episode>&alt=0` with that page session/CSRF header.
3. JSON returns a relative same-origin player target.
4. The player document contains HTML `<video><source>`. The observed source was
   a direct HTTPS MP4. A 2 KiB range request with an ordinary referrer returned
   HTTP 206, `video/mp4`, and a valid ISO Base Media prefix.

The mechanism is public episode page/session → same-origin JSON → same-origin
player document → direct MP4. The inspected samples exposed no HLS, DASH, DRM,
Widevine, login, or protected token exchange. The resolver accepts declared
MP4/HLS/DASH types, but live M11 evidence verifies MP4 only. It claims no
selectable audio or subtitle tracks.

CSRF, cookies, iframe target and media locator are transient in-memory session
facts. They never become canonical identity, binding identity, progress,
diagnostics, backup data, or logs. Each playback session resolves fresh.

## Fixtures and drift

Fixtures use synthetic hosts/tokens and preserve only success/drift markers.
No live cookie, CSRF value, provider locator, image, video byte, full provider
HTML, or personal path is stored. Network/unavailable, parser mismatch and
unsupported media are separate typed outcomes. CDN policy, locator lifetime and
whether every episode uses direct MP4 remain open uncertainties.

## Physical Android evidence

On a Samsung SM-S948B running Android 16, a fresh debug build completed live
Search/Details. AnimeWorld `Full Metal Panic! (ITA)` showed 24 episodes with one
playable source; episode 1 resolved and rendered video. MangaWorld
`One Piece - Digital Colored Comics` ingested 1,076 chapters with one readable
source; chapter 1040 opened as `1 / 12 · MangaWorld`. Validation stopped after
initialization. No reader screenshot was retained because that would copy
chapter artwork into a local artifact.

## Conclusion

- MangaWorld: `readerCapable` ✅ — public chapter HTML + direct CDN images.
- AnimeWorld: `playbackCapable` ✅ — public session/JSON/player chain + direct
  MP4 in the verified samples.

These are current compatibility findings, not promises that every title or a
future provider revision remains consumable.
