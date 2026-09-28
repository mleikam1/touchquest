# Architecture

Flutter 3.44.4 / Dart 3.12.2, Flame 1.38.2. Versions are locked in pubspec.lock.

- `lib/game/core/game_session.dart`: deterministic state machine, timer, physical input scoring, safe geometry, 50 campaign stages, progression and reward-gated revive. No service dependency.
- `lib/game/systems/milestone_director.dart`: time-bounded milestone presentation policies.
- `lib/game/systems/touch_zone_transition_controller.dart`: deterministic fixed RRect geometry shared by rendering and hit testing. Three accepted current-area taps and 600ms active time gate a previewed switch; a triggering tap counts once against old geometry before activation, with 200ms old/new grace.
- `lib/game/touch_quest_game.dart`: Flame game-loop adapter, production background illustration, cyan solid active/magenta dashed preview zones, and a fixed 240-slot effect pool. `frozen`, `seed`, and `fixtureTime` provide deterministic gallery rendering. Coordinates remain local to the bounded arena.
- `lib/app/app.dart`: responsive portrait shell, service coordination, navigation, gameplay HUD, and overlays. Wide windows retain a centered portrait game. One live Flame instance per run; screen states do not create new games.
- `lib/ui/`: shared arcade theme/widgets and production secondary screens; gallery fixtures consume the same components.
- `lib/services/save_service.dart`: versioned local JSON via SharedPreferences, run deduplication, settings, monotonic stats and union-based badge merge.
- `lib/services/firebase_service.dart`: optional initialization, anonymous identity, provider linking, private profile sync, aggregate events and unverified run uploads.
- `lib/services/ad_service.dart`: mobile test/production selection, UMP consent, bounded 320×50 banner, observable rewarded loading/availability/outcome state, and capped campaign interstitials. `RewardAdAttempt` requires SDK reward before dismissal for success, deduplicates callbacks, and blocks cancelled/failed results. Web has no provider and reports advertisement unavailable.
- `lib/services/feedback_service.dart`: bounded audio pools, original tone assets, background loop and rate-limited native haptics.
- `firebase/`: ownership rules, ranking index, plausibility inspection and Auth deletion cleanup functions.

## Timing and input

Flutter Listener sends each pointer-down once; holds and pointer movement do not score. Rendering and the inactivity countdown use Flame update(dt). A tap resets 1.5 seconds. A system interruption sets an explicit paused state and stops the engine. Resuming requires an explicit button. Revives preserve the session object and consume a single reward-confirmed allowance, with two seconds of grace after a deliberate Ready/resume action. A rewarded revive returns to paused state.

Casual remains full-arena at every milestone. Campaign/Chaos accept only the current fixed RRect (plus the prior RRect during handoff grace). Preview countdown changes only on accepted current-zone taps; elapsed time alone cannot activate a zone. A resize pauses an already-started run, bounds geometry, and re-arms preview timing/counts.

HUD rebuilds have a 30Hz budget, while the canvas uses display refresh. Particle count never exceeds 240. AUTO reduces new bursts after slow frames. Reduce Motion suppresses particle travel and decorative motion; Reduce Flashing defaults on and uses low-amplitude smooth color changes.

## Persistence and trust

Checkpoints store the delta in real taps; run IDs deduplicate history. A fresh GameSession resets temporary state but retains profile perks. Cloud private stats are not competitive truth. All uploaded runs are unverified; plausibility checking alone does not populate public rankings. A production verified-input/replay system is an explicit extension point.

Local persistence is best-effort on browser/OS termination: checkpoints occur every 50 taps, at milestones, pause and run completion. No promise of surviving abrupt termination between writes. Account linking retains the anonymous UID. Cross-device merge takes maximum counters and unions badges; independent concurrent play does not have an additive event-ledger merge yet.
