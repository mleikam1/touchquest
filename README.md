# TOUCH QUEST

**TAP. SURVIVE. ASCEND.** An original Flutter + Flame arcade game for Android, iOS and Web. Each physical pointer-down counts once. Stop for 1.5 seconds and your finger's quest is over.

## Play

Use Flutter **3.44.4 stable** and Dart **3.12.2**.

```sh
flutter pub get
flutter run -d chrome
```

- **Casual / PLAY:** every point in the bounded arena stays valid for the entire run. HUD, milestone footer, and ads never score.
- **Campaign:** 50 stages across ten worlds; tap fixed rounded touch zones, preview exact upcoming bounds, clear the tap goal, and unlock the next stage.
- **Chaos:** fixed touch zones, previewed discrete switches, visual ghost rings, and abstract neon zone effects. Accepted hit areas never drift, bounce, or chase.

Layered production illustration and neon Canvas art, exact-location rings, bounded particles, procedural sound effects and music, mobile haptics, 27 milestones through 100,000 taps, guest persistence, cosmetics, accessibility preferences, share-sheet results and optional cloud/ad integrations are included.

## Validate and build

```sh
dart format .
flutter analyze
flutter test
node --test firebase/functions/validation.test.js
flutter build web
flutter build apk --debug
flutter build ios --no-codesign
```

To inspect isolated deterministic production UI fixtures in debug mode:

```sh
flutter run -d chrome --web-port=8080
```

Open [the local UI gallery](http://localhost:8080/?ui=gallery) in that debug build. The gallery uses in-memory progress, unavailable ads, frozen Flame clocks, seeded randomness, and the same production components. It does not initialize Firebase or write fixture scores to profiles. Release navigation never exposes it.

The static web output is `build/web`; serve it over HTTP. Android APK output is `build/app/outputs/flutter-apk/app-debug.apk`. iOS requires Xcode; unsigned builds do not install on physical devices without signing.

## Services

The app starts as a guest without any cloud configuration. See [Firebase setup](docs/FIREBASE_SETUP.md) and [advertising setup](docs/ADS_SETUP.md). Copy `config/example.json` to an ignored platform-specific file and pass `--dart-define-from-file=...`. No production IDs or secrets are invented. Google/Facebook sign-in need your provider setup. Public rankings never masquerade local submissions as verified scores.

## Project guide

- [Architecture and performance](docs/ARCHITECTURE.md)
- [Milestone implementation matrix](docs/MILESTONES.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Privacy policy draft](docs/PRIVACY_POLICY.md)
- [Terms draft](docs/TERMS_OF_SERVICE.md)
- [Build validation](docs/VALIDATION.md)

Game logic lives in `lib/game/core`, Flame presentation in `lib/game/touch_quest_game.dart`, Flutter screens in `lib/app`, and platform integrations in `lib/services`. Milestone keys are physical tap thresholds; each fires once per session and persists a permanent achievement. The 500-tap multiplier changes bonus score only. The 15,000-tap perk adds one bonus point every ten future raw taps.

This is a playable v1, not a store-ready online service. Credential-backed sign-in/ads, trusted rankings, privacy review and real-device performance validation remain release requirements. All game sounds are original generated tones. Flutter/Material icons and dependency licenses remain under their respective upstream licenses.
