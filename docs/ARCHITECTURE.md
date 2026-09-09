# Architecture

Flutter 3.44.4 / Dart 3.12.2, Flame 1.38.2. Versions are locked in pubspec.lock.

- `lib/game/core/game_session.dart`: deterministic state machine, timer, physical input scoring, safe geometry, 50 campaign stages, progression and reward-gated revive. No service dependency.
- `lib/game/systems/milestone_director.dart`: time-bounded milestone presentation policies.
- `lib/game/touch_quest_game.dart`: Flame game-loop adapter and original Canvas art; fixed 240-slot reusable effect pool. Render and input coordinates share a field-local coordinate space. The Flame camera API is not needed.
- `lib/app/app.dart`: responsive 560px arcade shell, menu, HUD, gameplay overlay, campaign map, settings, profile, rankings, cosmetics and legal screens. One live game object per run.
- `lib/services/save_service.dart`: versioned local JSON via SharedPreferences, run deduplication, settings, monotonic stats and union-based badge merge.
- `lib/services/firebase_service.dart`: optional initialization, anonymous identity, provider linking, private profile sync, aggregate events and unverified run uploads.
- `lib/services/ad_service.dart`: mobile test/production selection, UMP consent, banner, rewarded callbacks and capped campaign interstitials. Web defaults to no provider.
- `lib/services/feedback_service.dart`: bounded audio pools, original tone assets, background loop and rate-limited native haptics.
- `firebase/`: ownership rules, ranking index, plausibility inspection and Auth deletion cleanup functions.

## Timing and input

Flutter Listener sends each pointer-down once; holds and pointer movement do not score. Rendering and the inactivity countdown use Flame update(dt). A tap resets 1.5 seconds. A system interruption sets an explicit paused state and stops the engine. Resuming requires an explicit button. Revives preserve the session object and consume a single reward-confirmed allowance, with two seconds of grace.

HUD rebuilds have a 30Hz budget, while the canvas uses display refresh. Particle count never exceeds 240. AUTO reduces new bursts after slow frames. Reduce Motion suppresses particle travel and decorative motion; Reduce Flashing defaults on and uses low-amplitude smooth color changes.

## Persistence and trust

Checkpoints store the delta in real taps; run IDs deduplicate history. A fresh GameSession resets temporary state but retains profile perks. Cloud private stats are not competitive truth. All uploaded runs are unverified; plausibility checking alone does not populate public rankings. A production verified-input/replay system is an explicit extension point.

Local persistence is best-effort on browser/OS termination: checkpoints occur every 50 taps, at milestones, pause and run completion. No promise of surviving abrupt termination between writes. Account linking retains the anonymous UID. Cross-device merge takes maximum counters and unions badges; independent concurrent play does not have an additive event-ledger merge yet.
