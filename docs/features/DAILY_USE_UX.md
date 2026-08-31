# Daily-Use UX — M13

## M18 navigation parity

Manga Reader UI v2 adds canonical Previous/Next Chapter, completion actions,
a lazy in-reader picker, and genuine-volume navigation while preserving the M13
zoom/page-turn guard and exact binding resume. The player adds device-local,
engine-neutral fit and aspect controls with Auto / Original as the non-stretching
default. See [Manga Reader](MANGA_READER.md) and [Anime Player](ANIME_PLAYER.md).

## Smart Resume

`SmartResumePolicy` is the single application policy for Home and Details. It
combines canonical installment order and completion with current source
capability, media preference, canonical progress and exact binding resume. Its
typed result names Start, Resume, Next, Completed or temporarily unavailable,
the canonical installment, chosen binding and the exact resume belonging only
to that binding.

For manga it produces Start reading, Resume reading, Read next chapter or
Completed. Anime mirrors this with Start watching, Resume episode, Watch next
episode or Completed. A completed installment advances through canonical order
to the next actionable unread/unwatched installment. An unavailable installment
may be skipped for actionability but is neither reordered nor completed. A live
failure never changes preference or canonical state. Offsets are never copied
between scans/encodes.

Details resolves the policy with its full application view and places the CTA
directly below the title/essentials. Home computes the same policy for progress
items and uses its label in Continue. Fully completed media does not appear in
active Continue; temporarily unavailable progress remains visible and safe.

## Compact Details

Manga chapters are presented as collapsed accordion sections. Real volume
labels remain raw and are naturally ordered numerically; M10 explicit order
continues to win. Ungrouped manga uses presentation-only blocks of at most 100
chapters and does not create volumes or identity. The section containing the
Smart Resume target opens automatically. Only one section's chapter rows is in
the lazy sliver at a time.

Rows emphasize label, read/watched/up-next state, capability counts and concise
source attribution. Anime uses dense lazy rows and does not infer narrative
seasons from provider airing labels. Descriptions default to a three-line
preview with accessible Show more/Show less controls. Alternate titles,
creator/studio and genres live in an optional expandable section. Source
availability, progress, repair and Library actions remain visible.

## Appearance

System, Light and Dark remain available. A persisted Material 3 accent adds
Default, Orange, Green, Teal, Blue, Indigo and Purple. Both brightness schemes
come from the centralized `ColorScheme.fromSeed`; no product screen owns an
independent accent. Preference format v2 reads old v1 files safely, preserves
appearance while onboarding changes, and provides an explicit Default choice.

## Paged reader zoom

Paged LTR and RTL modes wrap each logical page in Flutter's native
`InteractiveViewer`: pinch zooms from 1× to 4×, pan is enabled only while
zoomed, and double tap toggles a centered 2.5× zoom. A visible reset control is
also provided. PageView scrolling is disabled while zoomed so a pan cannot turn
the page. Moving to another logical page resets the transform.

Zoom is presentation-only. It never enters progress persistence, cache keys,
completion, or source resume. Tests zoom and pan, attempt a blocked page fling,
reset, turn the page, close and verify the same exact persisted page. Vertical
mode deliberately retains M10 rendered-page-aware tracking without zoom.

## Limits and next work

- Accordion expansion and zoom transforms are session UI state, not persisted.
- Double-tap zoom centers the page rather than the tap coordinate; pinch/pan is
  the precise inspection path.
- Search retains its existing compact status; Library/Home continuation text is
  synchronized, but there is no broad card redesign.
- Player engine, providers, TV/Fire OS/Vega, and unevidenced delivery formats
  are unchanged.

## Physical Samsung validation

The final debug APK was installed over retained state on Samsung SM S948B,
Android 16, 1080×2340. Accessibility/runtime text was used; no screenshot,
chapter artwork, video, database, locator or session artifact was retained.

- Home displayed the shared actions and exact state: Full Metal Panic!
  `Resume episode · 1 · 1:08` and +99 Wooden `Resume reading · Capitolo 01 ·
  Page 3 of 42`. +99 Details produced the same `Resume reading · Page 3 / 42`.
- +99 rendered its current ungrouped range expanded with compact Chapters 1–15
  and concise readable/source state. Its long description started collapsed,
  Show more was reachable, and optional metadata was collapsed separately.
- The lawful local manga opened in paged RTL at page 1/4. Double tap activated
  zoom and exposed Reset page zoom. A horizontal pan kept the logical counter at
  1/4; reset removed the guard, RTL navigation reached 2/4, and close/reopen
  produced `Resume reading · Chapter 1 · Page 2 / 4`. Finishing page 4/4 then
  marked Chapter 1 read and changed Details to `Read next chapter · Chapter 2`
  with 1/2 read.
- The lawful player sample initially produced `Start watching · Episode 1`.
  Episode 1 played to its 0:12 natural end, became 1/2 watched, and Details
  changed to `Watch next episode · Episode 2`. Retained live Full Metal Panic!
  separately proved exact anime Resume.
- System/Light/Dark and all seven accents fit the phone layout. Dark + Teal were
  selected, force-stop/relaunch retained both selected states, and the device
  was restored to System + Default afterward.

Automated multi-pointer coverage supplies the literal pinch gesture: it zooms,
attempts a blocked page fling, resets, changes logical page, closes, and verifies
the exact source resume. The device-driving shell cannot synthesize true
multi-pointer input, so physical automation used the equivalent double-tap zoom
plus pan path and the same native `InteractiveViewer`.
