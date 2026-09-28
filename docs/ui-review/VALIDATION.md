# Validation environment and evidence

Date: 2026-09-28. Host: macOS 15.7.4 / Apple silicon. Flutter 3.44.4 stable,
framework ad70ec4617, Dart 3.12.2, Flame 1.38.2. Xcode 26.3 (17C529).
Browser: Google Chrome 153.0.8010.54, running the actual Flutter web app.
`pubspec.lock` remains unchanged from the starting commit.

## Commands

| Command | Result |
| --- | --- |
| `flutter analyze --no-pub` | Passed, zero issues; `analyze.log` |
| `flutter test --no-pub` | Passed 132 tests, including all 10 golden comparisons; `flutter-tests.log` |
| `node --test firebase/functions/validation.test.js` | Passed 4 backend tests; `backend-tests.log` |
| `flutter build web --no-pub` | Passed; `web-build.log` |
| `flutter build apk --debug --no-pub` | Passed; `android-build.log` |
| `flutter build ios --simulator --debug --no-pub` | Passed; `ios-build.log`. Initial SPM deployment mismatch preserved separately |

## Deterministic visual tests

`test/ui_gallery_test.dart` loads Barlow Condensed, Rajdhani and MaterialIcons
from production assets, uses 390×844 at DPR 1, isolated memory state, seeded Flame
randomness and frozen animation timestamps. Reference review precedes acceptance
of the 10 golden baselines in `test/goldens/`. Updating baselines is not proof of
matching the supplied design. Review `UI_REVIEW.md` and the comparison images.

The responsive suites cover 360×800,390×844,430×932,768×1024 and 1440×900, including
1.5×/2× text where relevant. These are layout checks under Flutter's test engine;
they do not claim physical device haptic/ad/performance testing.

Behavioral tests cover exact-once pointer input, UI/ad separation, all milestones,
pause/resume, resize/re-arm, old-geometry activation, preview bounds and timing,
handoff expiry/overlap, saved stats/settings, profile/effect interactions, ad
callback ordering, retry identity, and fixture isolation. Backend tests retain
existing score plausibility/security contract checks.

## Browser evidence and reproduction

`scripts/capture_web.cjs` captures every gallery scenario in Chrome at 390×844.
`scripts/record_transition.cjs` records a real seeded Campaign run with genuine
mouse pointer-downs, followed by an explicit pause. Both use an externally
installed Playwright via `NODE_PATH`; it is not a production dependency.

Example from a tooling directory outside the repository:

```sh
npm install --prefix ../browser-qa playwright@1.58.2
../browser-qa/node_modules/.bin/playwright install ffmpeg
NODE_PATH=../browser-qa/node_modules node scripts/capture_web.cjs
NODE_PATH=../browser-qa/node_modules node scripts/record_transition.cjs
python3 scripts/create_ui_review.py --strict
```

Set `CHROME_PATH` for a Chrome executable in a different location. Pillow is
required for comparison/contact-sheet generation. Those sheets use captured
pixels; the script does not manufacture app screens. `browser-errors.json`
records browser page exceptions. `release-guard.json` records the release URL
fixture-isolation check.

## Platform and service limits

Android debug APK is at `build/app/outputs/flutter-apk/app-debug.apk`.
No physical iOS/Android installation, signing, store upload, native haptic
quality, real AdMob impression, provider sign-in, or Firebase server connection
was verified. Runtime play and the transition recording were tested on web.
The configured iOS minimum is 15.0, matching the locked Firebase SDK requirement.

CI keeps normal analysis/behavior/build checks on Ubuntu and runs the `golden`
tag on macOS 15 with the same Flutter version. The authored baselines use macOS;
rebaseline only after visual review when changing engine, platform or fonts.
The native iOS build succeeded after explicitly aligning Runner and framework
metadata to the existing 15.0 deployment floor. The first failure log records a
regenerated ephemeral SPM package at 13.0; final successful output is retained.
