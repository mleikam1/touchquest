# Reference-matched UI implementation status

Starting commit: `12080316be54bd51fab36bb8a21fb5b1b7f47ef9`.
Original implementation branch: `feature/reference-matched-ui`.
Current follow-up branch: `fix/remove-boss-hands`.

## Current user override

All boss-hand art and associated gameplay/audio/badge references are removed;
the 25,000-tap milestone is no longer in the catalog. Chaos entry uses a native
abstract neon zone hero. The ordinary tutorial pointer and robot mascot remain.
Archived reference images are preserved, with explicit override notes in both
reference READMEs and both saved prompt copies.

## Implemented and reviewed

All ten reference compositions are implemented using production Flutter widgets
and the existing Flame arena. Gameplay, transition warning and target activation
are states of one session. The work includes six separately generated
illustration assets, native abstract Chaos zone artwork, bundled licensed fonts,
vector branding, reusable controls,
world/stage selection, profile editing, badges and effect previews/equip,
settings, account/privacy/legal pages, pause/resume and result overlays.

The complete brief is preserved at `docs/prompts/touch_quest_ui_prompt.txt`.
The UI contract is in `docs/UI_SPEC.md`. Asset sources, dimensions, generation
prompts and licenses are in `assets/art/ASSET_MANIFEST.md`.

- Casual accepts pointer-downs only within the arena and stays full-field.
- Campaign/Chaos use fixed rounded rectangles. A preview requires three accepted
  current-area taps and 600ms active time, then activates on a valid old-area tap.
  Rendering and hit tests use identical geometry. Handoff accepts old/new for 200ms. Chaos shrinks only newly generated future
  zones as raw taps rise; active and visible preview geometry remain fixed.
- Raw taps, boosted score, milestones, duration and average tap rate remain separate.
- Resizing/system interruptions pause the existing session. An explicit Resume
  action restarts it. Rewarded revive preserves the same game/session and stays
  paused until Ready. Retry creates one new instance.
- HUD, milestone footer and fixed 320×50 banner are separate from input/effects.
  Native banner content is unmounted beneath pause/results overlays while its
  reserved geometry stays stable; gameplay controls never cover a live ad.
- Reduced motion/flashing and effects quality change live rendering. Haptics are
  rate limited with a web fallback; music/SFX sliders apply and persist immediately.
- The remaining 27-milestone catalog through 100,000 and 50-stage campaign are retained.
- No reference screenshot is in the production asset bundle. No avatar or avatar
  placeholder is rendered in leaderboard rows.

## Visual evidence

`docs/ui-review/screenshots/01_main_menu.png` through `10_leaderboards.png` are
actual Chrome captures of the running Flutter debug app. The corresponding
side-by-side files compare frame-trimmed supplied references to these renders.
`docs/ui-review/rendered_app_contact_sheet.png` contains all ten app captures.
`docs/ui-review/UI_REVIEW.md` records remaining differences screen by screen.

`docs/ui-review/recordings/preview-switch-active.webm` records real pointer input:
a seeded Campaign run starts, previews, switches twice and accepts 17 taps before
an explicit pause. It uses isolated gallery memory state and production gameplay.
It does not replay fabricated scores or simulate an ad reward.

## Services actually exercised and remaining contracts

| Area | Implemented connection | Verification / external limitation |
| --- | --- | --- |
| Local profile/progression/settings | Existing SharedPreferences service; memory-only test adapter | Persistence, deduplication, editing, settings and gallery isolation tested |
| Firebase | Existing optional Firebase init, auth, private sync and unverified run submission retained | No credentials supplied; no live project connection or deployment claimed |
| Google/Facebook | Existing provider-link/sign-in/sign-out/account deletion flows preserved in Account | Provider credentials, consent and server deletion cleanup still require owner configuration |
| Profile editing | Validated display-name method in FirebaseService with local-first guest save | Auth update path compiled; cross-device provider behavior not tested |
| Rankings | Existing category/value verified leaderboard read contract | Raw run, score, campaign and Hall are distinguished; existing contract is cross-mode. Mode-specific categories require backend work. Friends has no source and is Coming Soon |
| Advertising | Existing web/mobile adapters; observable loading/ready/showing/cancelled/failed/rewarded state | Web is truthfully unavailable. SDK callback reducer tests cover reward+dismissal ordering, duplicates and failure. Native AdMob impressions/rewards were not exercised |
| Legal | Existing in-app Privacy/Terms documents preserved and labeled drafts | Owner/contact/date/retention/age/legal review requirements remain unresolved; no invented policy details |

There are no production score/unlock writes from the gallery. Firebase refuses
memory stores; gallery never initializes analytics or ads. `?ui=...` is ignored
in release. A release-browser guard test checks that a leaderboard fixture URL
opens the production menu without fixture names.

## Run and inspect

Use Flutter 3.44.4 / Dart 3.12.2 (same locked dependencies as the starting repo):

```sh
flutter pub get
flutter run -d chrome
# Developer gallery in a debug web build:
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8765
# Open http://127.0.0.1:8765/?ui=gallery
# Individual capture example: http://127.0.0.1:8765/?ui=03_transition_warning
```

The gallery is web-query driven and debug only. Use the source scenario keys in
`lib/ui/preview/ui_fixture_data.dart`. Profile fixtures are not live account data;
fixture leaderboards are visibly labeled. Normal guest navigation uses real saves.

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
node --test firebase/functions/validation.test.js
flutter build web --no-pub
flutter build apk --debug --no-pub
flutter build ios --simulator --debug --no-pub
```

Do not run Flutter package regeneration concurrently with an iOS SPM build.
Final local validation passed formatting, zero-issue analysis, 134 Flutter tests,
four backend tests, and web/Android debug/iOS simulator builds.
Builds and verification details are in `docs/ui-review/VALIDATION.md`; command
output is preserved alongside that file. No production deployment, force-push,
physical-device install, store signing, or native ad impression is part of this
validation.
