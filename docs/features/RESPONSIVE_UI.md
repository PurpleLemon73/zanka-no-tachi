# Responsive UI verification

This is a bounded widget-level verification of the existing Ink & Ember UI,
not physical-device certification. No new layout system or presentation mode
was introduced. TV remains selected semantically, never from viewport size.

## Layout coverage

| Surface group | Representative coverage | Behavioral checks |
| --- | --- | --- |
| Shell, Home, Search, Library | 320–480 logical-pixel phones, 844×390 landscape, 800×1100 and 1280×800 tablets, semantic TV at 960×540, 1280×720 and 1920×1080 | Navigation, selections, loading/error/retry/empty states, pagination, missing art, long titles, remote activation and return focus |
| Manga/Anime Details | Narrow/normal/large phones, landscape, both tablet orientations, semantic TV including 4K physical size with DPR 3 | Editing and keyboard insets, explicit cancellation, source chooser, watched management, modal focus/Back, long metadata |
| Settings, Appearance, About, introduction | Phones, landscape, tablets and semantic TV | Appearance changes, help navigation, local redacted-report copying, all introduction steps; remote introduction starts on Next |
| Local Media | Six phone/tablet layouts with safe-area padding and simulated keyboard | Single import and batch-review cancellation, selection/removal confirmation, no asset removal on Cancel/Back |
| Reader boundary | 320×740, 844×390, 1280×800 at 1.5× text | Settings/Apply, chapter picker and Back; existing 1,002-chapter lazy picker guard |
| Player boundary | 320×740, 844×390 and semantic TV 1280×720 at 1.5× text | Reachable Display Mode/Reset and episode sheets without engine recreation; existing fullscreen, D-pad, completion focus and geometry regressions |

Text scaling ranges from 1.0× to 1.5× across the new surface matrix. Existing
Home/Search/Library and Details cases also cover 2.0× narrow layouts. These are
representative combinations, not a claim that every surface was tested at every
size and font scale.

## Corrections

- Local Media filter/sort dropdowns now have bounded width and variable item
  height. Selection actions wrap below the count instead of consuming the
  entire trailing area of a narrow list tile.
- Local Media uses a safe area and a centered 980-pixel maximum content width,
  consistent with the existing Settings composition. About now respects side
  and bottom safe areas while retaining its existing content-width bound.
- Local removal, attachment and restore confirmations allow growing text to
  scroll. Batch review also scrolls its heading/content when a landscape
  keyboard reduces usable height.
- Single and batch import attachment dropdowns no longer overflow horizontally.
  Review fields own their text-controller lifetimes through `TextFormField`;
  dismissing a dialog no longer disposes an external controller while its exit
  animation or keyboard-inset rebuild still uses it. Reviewed values and import
  semantics are unchanged.
- Introduction Next has deterministic initial focus for remote users.
- The player's decorative seek icon yields height to the enlarged ±10s label.
  Text is not forcibly reduced to fit.

All changes reuse existing Flutter layout/focus primitives and product
components. No reader continuity, player engine, fullscreen ownership,
Display Mode geometry, progress/resume, provider, persistence or native-platform
behavior was changed.

## Automated evidence

134 distinct targeted tests passed:

- 95 tests across `content_visual_test`, `details_visual_test`,
  `details_actions_test`, `product_shell_test`, `settings_visual_test`,
  `media_details_loading_test`, `episode_watch_state_test` and
  `performance/large_library_test`.
- 23 tests in `responsive_surfaces_test`.
- 12 selected `anime_player_screen_test` cases matching
  `responsive player|fullscreen|TV D-pad|TV completion|display geometry`.
- Four selected `manga_reader_widget_test` cases matching
  `responsive reader|chapter picker stays lazy`.

Formatting and analysis of the ten touched Dart files passed. No full repository
suite, release build, live-provider matrix or full physical-device matrix was
run for this verification.

The existing large-library guard passed for 1,000 library records, 5,000 chapters
with two bindings each and 1,000 episodes, within its 15-second ceiling. Existing
lazy widget checks remain active for 1,000-item collections, the 1,002-chapter
picker and large episode-management lists. No eager large-list rendering was
introduced.

The file-picker boundary is stubbed in widget tests. Batch review probes a tiny,
temporary synthetic archive; the test cancels before import or page decoding.
Native picker interaction, decoder behavior and actual device typography are
not certified by these tests.

## Remaining physical checks

1. **Samsung, portrait and landscape:** use normal and increased system font
   sizes. Visit Home, Search, Library and both Details kinds; verify long titles,
   missing covers, loading/retry and Back. Open an editor with the keyboard
   visible, scroll to its actions, then cancel/save. Check the display cutout and
   gesture-navigation edges.
2. **Samsung, Settings and Local Media:** cycle appearance, complete/reopen help,
   and copy diagnostics. Pick lawful single video/CBZ and batch CBZ files; edit
   review text, open the attachment menu, cancel with the keyboard visible, then
   reopen. Select an asset and cancel both removal dialogs; confirm it remains.
3. **Tablet or resizable emulator, both orientations:** repeat Local Media,
   Settings and Details forms; confirm centered readable widths, reachable
   actions and scrolling at increased font scale.
4. **Android TV/Google TV and Fire TV when available, remote only:** traverse
   Home/Search/Library/Settings, activate media, open/close source and editing
   dialogs, and verify visible focus returns to the opener. Reopen introduction
   and use Next/Back without touch. Check native text input and overscan edges.
5. **Reader/player boundary smoke check with lawful content:** open settings and
   chapter/episode pickers at enlarged text; use Display Mode and Reset, then
   Back. Verify playback continues, fullscreen survives episode transitions and
   TV focus returns correctly. No new decoder/format certification is implied.

Physical Fire validation, native picker variations, real-system keyboard/font
behavior, hardware safe areas/overscan and playback decoder reliability remain
explicitly unverified here. Release packaging, build variants and new features
are outside this change.
