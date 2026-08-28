# Live Compatibility Matrix — M12

Evidence date: 2026-08-26. Requests were sparse, user-driven equivalents against
only the configured provider authorities. Temporary HTML/cookies stayed in the
system temporary directory and are not repository artifacts. No chapter image,
video, screenshot, cookie, CSRF value, or session locator is retained here.

## MangaWorld

| Representative title | Metadata shape | Reader sample | Result |
|---|---|---:|---|
| One Piece Digital Colored Comics | popular, ongoing, grouped volumes, very long list, oneshot label | 18 pages | ordered public image manifest resolved |
| Solo Leveling | completed, grouped volumes, long chapter session | 64 pages | ordered public image manifest resolved |
| MAD | ongoing, grouped volumes, decimal chapters including `.5` labels | 26 pages | ordered mixed JPEG/PNG manifest resolved |
| +99 Reinforced Wooden Stick | dropped, current ungrouped `.chapters-wrapper` list | 179 pages | ordered public image manifest resolved |

The naturally sampled documents used the same public reader contract: a first
rendered image reference plus an ordered JSON page list. Absolute and relative
references, lazy attributes, duplicate/malformed entries, redirects and a moved
page manifest are covered by minimized synthetic regression markup derived from
the observed contract. No alternate CDN authority was naturally encountered,
so M12 does not claim one; authority changes remain session data and the parser
accepts an ordinary absolute HTTP(S) page reference.

## AnimeWorld

| Representative title | Content shape | Episode/list sample | Delivery |
|---|---|---|---|
| Full Metal Panic! (ITA) | completed dubbed TV, 24 episodes | episode from series | direct MP4 |
| 5 cm al secondo | subtitled Movie, one installment | sole episode | direct MP4 |
| Nekopara OVA | subtitled OVA, one installment | sole episode | direct MP4 |
| Devilman Crybaby | subtitled ONA, 10 episodes | episode from series | direct MP4 |
| One Piece (SUB ITA) | ongoing TV, very long list (over 1,100 visible episode links) | one episode | direct MP4 |

All five representative player documents used the M11 delivery chain: public
episode page/session → same-origin episode-info JSON → same-origin player
document → direct `video/mp4`. No HLS or DASH manifest was naturally observed.
The current player therefore supports the evidenced direct MP4 path and returns
a typed unsupported-format result for an unverified source/iframe delivery.
There was no basis for replacing `video_player` or claiming selectable tracks.

## Coverage limits

- Special/non-numeric MangaWorld reader payloads were represented by an
  observed oneshot label; arbitrary editorial labels remain metadata, not a
  page-order contract.
- AnimeWorld irregular per-episode labels were not found in this sparse sample.
- Availability is an observation, not a permanent promise. A binding is checked
  when opened and can move between ready, temporarily unavailable, parser
  mismatch and unsupported without changing canonical identity or progress.
- Physical Android evidence is recorded in [Live reliability](LIVE_RELIABILITY.md);
  this matrix contains no visual/media artifact.

## Physical matrix confirmation

Samsung SM S948B / Android 16 confirmed three titles per provider in the final
product path: One Piece Digital Colored Comics, Solo Leveling and +99 Reinforced
Wooden Stick for manga; Full Metal Panic! (ITA), 5 cm al secondo and Nekopara
OVA for anime. Exact counters/durations and resume evidence are recorded below
in `LIVE_RELIABILITY.md`.
