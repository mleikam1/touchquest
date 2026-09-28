# Touch Quest visual review

All ten required screens have actual Flutter browser captures and side-by-side comparisons. The implementation follows the supplied board's composition, control hierarchy, and navy/cyan/magenta palette. It is a reconstruction using separate production artwork and real widgets; it is not a pixel-identical reproduction of the illustrated board.

## Current user override

The user has removed all boss hands from the game. Chaos entry now uses original
native abstract neon zone artwork; associated gameplay, audio, badges and the
25,000-tap milestone are removed. This is an intentional override of the source
board, not a remaining fidelity defect. The ordinary tutorial tap pointer and
original robot mascot stay. Supplied reference raster images are archival and
remain unchanged; only refreshed app captures represent the current game.

## Evidence and method

- Final source captures: `screenshots/01_main_menu.png` through `screenshots/10_leaderboards.png`, captured from the running Flutter web app in desktop Google Chrome at a 390 × 844 CSS-pixel viewport with device pixel ratio 1.
- Capture implementation: `scripts/capture_web.cjs`, using Playwright and the actual `flutter-view` at `http://127.0.0.1:8765/?ui=<scenario>`.
- These files supersede the first widget-test captures. Material icon glyphs missing from the initial test renderer were present in the final Chrome captures.
- `browser-errors.json` contains an empty array for the ten final capture runs. This reports browser page errors, not a complete runtime or backend integration test.
- [Rendered app contact sheet](rendered_app_contact_sheet.png) contains only actual app captures; no reference images were substituted for missing screens.
- [Capture manifest](capture_manifest.json) records all ten dimensions, source files, and SHA-256 hashes.
- `scripts/create_ui_review.py` creates the contact sheet, the ten files in `comparisons/`, and [reference measurements](reference_measurements.json). It lists missing captures rather than drawing fake ones. `--strict` returns failure if a required image is missing.
- The reference comparison crops remove approximately 10 pixels on each side, 8 at the top, and 10 at the bottom. The upper reference drawings retain a small part of their black camera notch; that hardware and any extreme-corner frame residue are excluded from the visual assessment. No phone frame or notch is app UI.
- Reference and app proportions are preserved with letterboxing. The source board has inconsistent phone aspect ratios. No numerical image-diff score is used to claim an exact visual match.
- All final comparison images and the rendered contact sheet were visually inspected after the correction pass.

## Corrections verified in the final captures

The logo was widened and its height reduced. Casual onboarding gained a large cyan/magenta concentric burst with colored sparks and a correctly placed tutorial hand. The transition state gained a current-zone hand and clearer labels. Target activation gained a strong magenta border glow and visible hand; the unrelated hand at the lower-right edge was removed. Campaign card density moved closer to five visible worlds. Profile mascot framing, badge/effect spacing, and particle thumbnails were refined. Chaos entry uses atmospheric artwork and a native composition of luminous zone outlines, rings and geometric accents.

## Screen-by-screen assessment

| Screen | What matches | Intentional changes and remaining differences |
|---|---|---|
| [01 Main menu](comparisons/01_main_menu_comparison.png) | Illustrated blue/purple clouds, floating islands, large two-line cyan/yellow logo, yellow primary button, five dark secondary controls, four purposeful shortcuts. | The recreated logo has different glyph shapes, a flatter bevel, and less diagonal slant. Generated scenery is more detailed than the simpler painted board. The shortcut row sits slightly higher with more bottom breathing room. These remain visible artwork/proportion differences. |
| [02 Casual gameplay](comparisons/02_casual_gameplay_comparison.png) | Score/best/pause HUD, luminous timer, dark arena, onboarding hand and energetic circular burst, milestone card, separated banner area. | Full timer at 1.5 seconds corrects the inconsistent board example. The banner is an actual centered 320 × 50 preview slot rather than a full-width painted rectangle. The burst uses cleaner geometric rings, and the arena has darker rocky detail and less diffuse blue bloom. Utility typography and milestone icon are different. |
| [03 Transition warning](comparisons/03_transition_warning_comparison.png) | Dashed magenta future box, solid cyan current box, connecting arrow, visible tutorial cursor, persistent HUD/footer. | Explicit `IN 2 TAPS` and `NEXT AREA` text clarify behavior. The next milestone uses the established catalog. Boxes are somewhat wider than the board, the arrow is finer, and current-zone fingertip ripples are less pronounced. The geometry is stationary; the screenshot represents a state of the same game. |
| [04 Target mode](comparisons/04_target_mode_comparison.png) | Magenta activation box, bright outline, tap label, tutorial hand, central sparks, preserved HUD/footer. | The activation burst is narrower and more geometric than the broad multicolor painted explosion. The board's long curved trail below the target is absent. That decorative omission does not imply target movement: active geometry switches discretely and later settles to cyan. |
| [05 Game over](comparisons/05_game_over_comparison.png) | Red storm atmosphere, warm two-line title, aligned statistic panel, reaction panel, green revive/blue retry/dark menu hierarchy. | Lightning is more detailed and luminous. The title is narrower and has a simpler bevel. Labels and values come from the run model; the average of 2,847 taps over 86 seconds is 33.1, and revives reflect the fixture rather than copying the board's inconsistent values. Panels and buttons have lighter edge treatment. |
| [06 Campaign map](comparisons/06_campaign_map_comparison.png) | Compact header, first five themes in the supplied order, illustrated square thumbnails, dark cards, progress/locks, fixed navigation. | Generated thumbnails are independent high-resolution art with different internal compositions. Five cards are fully visible with a small glimpse of the sixth. Progress is 0/5 because the existing catalog has five stages per world; the board's sample 0/30 is not fabricated. Borders have less layered bevel. |
| [07 Chaos entry](comparisons/07_chaos_entry_comparison.png) | Warm title, original abstract neon zone hero, floating shapes, background depth, pink two-line subtitle, feature list, yellow start button. | The source board's creature is superseded by the user's removal request. Static native cyan/magenta rounded zones, rings, sparks and a yellow bolt replace it intentionally. Feature wording retains `Shifting touch zones` and `Ghost taps`; no character encounter is promised. The palette and button hierarchy still follow the board. |
| [08 Profile](comparisons/08_profile_comparison.png) | Robot tile, name/title/edit action, two-by-two stats, gold badges and locked tiles, four particle thumbnails, fixed navigation. | Original mascot design is intentionally different. The three pinned badges are 1K, 10K and 100K; the removed 25K collection item is absent. Badge medallions are simpler than the ornate board art, effects are live painter previews, and card edges glow less strongly. `VIEW ALL` actions and the equipped checkmark expose useful collection behavior. There is somewhat more space above navigation. Catalog totals and title use the fixture/model. |
| [09 Settings](comparisons/09_settings_comparison.png) | Compact header, two bordered dark groups, cyan sliders, green haptics toggle, accessibility controls, account/legal rows and fixed navigation. | Settings controls are crisper and less heavily beveled than the painted board. The lower gap above navigation is larger. Notifications are honestly labeled `Coming Soon`; no fake enabled switch is shown. The layout remains recognizably the same grouping and order. |
| [10 Leaderboards](comparisons/10_leaderboards_comparison.png) | Header, three segmented tabs, ten compact ranked rows, right-aligned scores, cyan current-player row and warm score accent, fixed navigation. | Player avatars are deliberately removed without reserving an empty avatar column. The first three ranks use colored digits rather than metallic discs. Metric/assistance labels and `PREVIEW DATA · NOT LIVE RANKINGS` prevent fixtures being mistaken for production standings. The tab bevel and row glow are restrained compared with the board. |

## Palette samples

Non-text interior reference samples yielded near-black navy `#000825`, navigation navy `#001435`, dark panel `#021940`, lit cyan slider `#40EEFF`, green toggle `#17E663`, and primary-button yellow/orange `#FDC528` / `#FEAF18`. These are median raster patch values, not recovered original design tokens. Sample coordinates and method are recorded in `reference_measurements.json`.

## Motion evidence and limitations

[Preview → switch → active tapping recording](recordings/preview-switch-active.webm) and its associated stills are saved in `recordings/`. The recording is an actual browser session using the playable campaign route, rather than a generated animation. The screenshot comparisons assess appearance; fixed-zone geometry, grace timing, counting, input exclusion, and accessibility behavior are separately covered by implementation tests and validation logs.

The displayed screenshots are developer gallery fixtures. They demonstrate UI rendering, not successful authentication, live ranked data, ad reward delivery, native device interaction, or production Firebase deployment. Platform build results and service limitations are documented separately. Artwork texture, title bevels, the target burst, and some panel/navigation density remain the main visual differences from the reference.

The locked Firebase iOS packages require iOS 15.0. The project already inherited that floor, and it is now explicit for Runner Debug/Profile/Release and `AppFrameworkInfo.plist`. The first simulator build encountered an ephemeral Swift package still declaring iOS 13.0; its failure is retained in `ios-build-initial-failure.log`. The serialized `flutter build ios --simulator --debug --no-pub` rerun generated a 15.0 package and built `Runner.app` successfully (`ios-build.log`; elapsed time is recorded in the log). Android `flutter build apk --debug` also passed (`android-build.log`). No dependency locks were changed and no physical device was signed, deployed, or tested. This matches [Flutter's guidance on Swift package minimum platform versions](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-use-a-swift-package-manager-flutter-plugin-that-requires-a-higher-os-version).

## Reproduce the comparison artifacts

After capturing fresh browser screenshots, from the repository root:

```sh
python3 scripts/create_ui_review.py --strict
```

The script requires Pillow. The environment used for this review provided it at `/Users/MattLeikam/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3`.

Do not treat regenerated golden images as proof of reference fidelity. Goldens protect the reviewed reconstruction from later regressions; the supplied reference and these side-by-side comparisons remain the evidence for visual fidelity.
