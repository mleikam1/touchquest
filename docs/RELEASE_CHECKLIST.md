# Release checklist

## Local validation
- [x] Installed stable Flutter/Dart inspected and versions locked.
- [x] Pure game tests cover timer, physical taps, pause, revive, all thresholds, safe target placement, campaign, settings and guest merge.
- [x] Flutter menu navigation widget test.
- [x] Server plausibility unit tests.
- [x] Working web build and browser menu/tap/timeout smoke test.
- [x] Android debug APK built locally.
- [x] Unsigned iOS build completed with iOS 15 minimum; see VALIDATION.md.
- [ ] Real Android/iPhone haptic, audio, low-end GPU and thermal soak tests (60 FPS is a target, not a measured claim).
- [ ] Test pointer multi-touch, app interruptions, consent ads and rotation on physical devices.

## External service setup
- [ ] Firebase project/app options, anonymous auth, OAuth provider IDs, platform URL schemes/key hashes.
- [ ] Deploy and emulator-test Firestore rules, indexes and functions.
- [ ] Validate anonymous linking and recent-login account deletion against real accounts.
- [ ] Implement a trusted competitive verification service before publishing ranked runs.
- [ ] Configure production AdMob app/unit IDs, UMP messages, child/age treatment, app-ads.txt and store declarations.
- [ ] Verify ad consent privacy options, reward earned/dismissed/failed flows and campaign frequency cap on real devices.
- [ ] Configure web provider bridge if web monetization is desired.

## Product/legal/store
- [ ] Complete owner, support, effective date, retention and jurisdiction placeholders; obtain legal review.
- [ ] Complete platform privacy/data-safety declarations for configured services.
- [ ] App signing, provisioning, store listing, icons/screenshots and production URLs.
- [ ] Validate accessibility with assistive technology and larger text settings.
- [ ] Optional polish expansion: additional original music layers and abstract neon effects.

No credentials, hosted backend or signed store release were supplied by this task.
