# Touch Quest reference implementation

Source: `docs/prompts/touch_quest_ui_prompt.txt` (the complete user brief). Starting
commit: `12080316be54bd51fab36bb8a21fb5b1b7f47ef9`. Working branch:
`feature/reference-matched-ui`. The prior local checkout is untouched.

## Visual source

The supplied master and all ten individual PNG crops were found in
`Touch_Quest_UI_Reference_Pack/design/reference/` and copied without resampling to
`design/reference/`. These are comparison material only. Their phone frames,
camera cutouts, headings and poster footer are excluded from app UI.

Reconstruct a portrait 390×844 composition, allowing natural scrolling and text
scaling. On wide displays center a portrait surface in an atmospheric surround.
Use separately generated illustration assets and live Flutter widgets, never a
screenshot behind invisible controls. Flutter owns navigation, HUD, accessibility,
dialogs and menus; Flame owns the bounded arena, zones, rings and particles.

## Shared treatment

Near-black navy #050A24; panel #071B3B with #0D2D59 highlights; cyan #00D9FF;
magenta #F13CFF; violet #7938F2; yellow #FFE13B; orange #FF9A00; reward green
#00EE69; white #F5F7FF; muted #A8BCD8. Refine during visual QA.
Bundled SIL OFL Barlow Condensed ExtraBold/Italic display lettering and Rajdhani
SemiBold/Bold utility text. Luminous thin borders, shaded rounded panels, beveled
gradient controls. Yellow PLAY/START CHAOS, blue retry, green rewarded revive.

## Screen composition

1. Menu: illustrated floating islands/clouds, cyan TOUCH and warm QUEST logo,
   tagline, PLAY, Campaign, Chaos Run, Leaderboard, Profile, Settings, four shortcuts.
2–4. One gameplay screen: score/best/pause HUD; 1.5-second meter; bounded arena;
   milestone card from raw taps; separated fixed 320×50 banner. Casual remains
   full arena. Campaign/Chaos use the same fixed-zone state machine.
5. Results: red lightning, warm GAME OVER title, six real statistics, reaction,
   green reward action, blue retry, navy main menu.
6. Campaign: illustrated world cards in established order, persisted stage locks,
   progress and matching stage selector. Catalog has five stages per world;
   display this actual denominator instead of the board's illustrative 30.
7. Chaos: warm title, large spectral hand, feature list, yellow launch button.
8. Profile: robot mascot, editable name, 2×2 real stats, badges, effect previews.
9. Settings: persistent volume/accessibility/quality controls plus account/legal.
10. Rankings: Global/Friends/Hall of Fame, metrics distinguishable, no avatars or
    empty avatar column. Production offline/empty states must be truthful.

## Input and time invariants

Pointer-down is handled exactly once, only within arena bounds. Target geometry
is shared between rendering/hit testing. Preview exact next rounded rectangle
for three accepted taps and at least 600ms of active game time. When both are
satisfied, count the triggering tap once on old geometry then switch atomically.
Accept old/new for configurable 200ms grace. No target position/size tweens.
Resize pauses and rearms geometry. Pauses and system interruptions stop time.
Revive restores the existing run only after reward and ad dismissal, then waits
for an explicit ready action. Existing milestones through 100,000 are retained.

## Trust and verification

Existing local persistence, cloud validation, auth and platform ad adapters are
retained. Gallery runs in debug only with memory repositories, fixed state/time,
seeded effects and no analytics/ads/cloud initialization. It uses production
components. Screenshots and goldens document actual Flutter rendering, not proof
of pixel-identical reconstruction. All remaining artwork/service gaps belong in
`docs/UI_IMPLEMENTATION_STATUS.md` and `docs/ui-review/UI_REVIEW.md`.
