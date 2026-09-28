import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/game/systems/touch_zone_transition_controller.dart';

final oldZone = RRect.fromRectAndRadius(
  const Rect.fromLTWH(40, 290, 180, 110),
  const Radius.circular(18),
);
final nextZone = RRect.fromRectAndRadius(
  const Rect.fromLTWH(120, 100, 180, 100),
  const Radius.circular(18),
);

GameSession fixture({double elapsed = 0}) {
  final session = GameSession(mode: GameMode.chaos);
  session.resize(400, 500);
  session.zones.setFixture(
    active: oldZone,
    next: nextZone,
    previewElapsed: elapsed,
  );
  return session;
}

void main() {
  test('Casual accepts every arena point at all precision/boss milestones', () {
    final session = GameSession();
    for (final count in [60, 160, 500, 25000, 100000]) {
      session.rawTaps = count;
      expect(session.precision, false);
      session.tap(const Offset(1, 1));
      expect(session.rawTaps, count + 1);
      expect(session.state, RunState.playing);
    }
    expect(session.hit(const Offset(-1, 50)), false);
    expect(session.hit(const Offset(100, 501)), false);
  });

  test('Next-only rectangle is invalid before the atomic activation', () {
    final session = fixture();
    session.tap(nextZone.center);
    expect(session.rawTaps, 0);
    expect(session.state, RunState.over);
    expect(session.zones.previewTapsRemaining, 3);
  });

  test('Fast taps wait for 600ms and a further old-area tap', () {
    final session = fixture();
    for (var i = 0; i < 3; i++) {
      session.tap(oldZone.center);
    }
    expect(session.zones.previewReady, true);
    expect(session.zones.active, oldZone);
    session.update(.599);
    session.tap(oldZone.center);
    expect(session.zones.active, oldZone);
    session.update(.001);
    expect(
      session.zones.active,
      oldZone,
      reason: 'Elapsed time alone cannot switch',
    );
    session.tap(oldZone.center);
    expect(session.rawTaps, 5);
    expect(session.zones.active, nextZone);
    expect(session.zones.previous, oldZone);
    expect(session.zones.next, isNull);
    expect(session.remaining, 1.5);
  });

  test('Three accepted old-area taps remain required after 600ms', () {
    final session = fixture();
    session.update(.6);
    session.tap(oldZone.center);
    session.tap(oldZone.center);
    expect(session.zones.active, oldZone);
    expect(session.zones.previewTapsRemaining, 1);
    session.tap(oldZone.center);
    expect(session.rawTaps, 3);
    expect(
      session.zones.active,
      nextZone,
      reason: 'Preview and active use identical bounds',
    );
  });

  test('Handoff accepts old and new for 200ms, then only new', () {
    final session = fixture(elapsed: .6);
    for (var i = 0; i < 3; i++) {
      session.tap(oldZone.center);
    }
    session.tap(oldZone.center);
    session.tap(nextZone.center);
    expect(session.rawTaps, 5);
    session.update(.199);
    expect(session.hit(oldZone.center), true);
    session.update(.001);
    expect(session.hit(oldZone.center), false);
    expect(session.hit(nextZone.center), true);
    expect(session.zones.previous, isNull);
  });

  test('Overlap and grace never double-count a physical input', () {
    final session = fixture(elapsed: .6);
    final overlap = RRect.fromRectAndRadius(
      const Rect.fromLTWH(100, 290, 180, 110),
      const Radius.circular(18),
    );
    session.zones.setFixture(
      active: oldZone,
      next: overlap,
      previewElapsed: .6,
    );
    const point = Offset(150, 340);
    for (var i = 0; i < 4; i++) {
      session.tap(point);
      expect(session.rawTaps, i + 1);
      expect(session.score, i + 1);
    }
  });

  test(
    'Paused wall time neither advances preview nor expires grace or timer',
    () {
      final session = fixture();
      session.update(.2);
      session.pause();
      session.update(20);
      session.tap(oldZone.center);
      expect(session.zones.previewElapsed, .2);
      expect(session.zones.previewTapsRemaining, 3);
      expect(session.remaining, 1.3);
      expect(session.rawTaps, 0);
      session.resume();
      session.update(.4);
      for (var i = 0; i < 3; i++) {
        session.tap(oldZone.center);
      }
      session.pause();
      session.update(20);
      expect(session.zones.graceRemaining, .2);
    },
  );

  test('Fixed rectangles do not drift, shrink or follow the boss', () {
    final session = fixture();
    session.rawTaps = 25000;
    for (var i = 0; i < 10; i++) {
      session.update(.05);
      expect(session.zones.active, oldZone);
      expect(session.zones.next, nextZone);
    }
  });

  test('Resize pauses an active run, bounds geometry and re-arms preview', () {
    final session = fixture(elapsed: .5);
    session.tap(oldZone.center);
    session.resize(320, 380);
    expect(session.state, RunState.paused);
    expect(session.zones.previewElapsed, 0);
    expect(session.zones.previewTapsRemaining, 3);
    expect(session.zones.previous, isNull);
    for (final zone in [session.zones.active, session.zones.next!]) {
      expect(
        zone.outerRect.intersect(const Rect.fromLTWH(0, 0, 320, 380)),
        zone.outerRect,
      );
    }
    final before = session.zones.active;
    session.resize(320, 380);
    expect(session.zones.active, before);
    session.resume();
    session.tap(session.target);
    expect(session.rawTaps, 2);
  });

  test(
    'Initial layout and repeated equal dimensions preserve gallery state',
    () {
      final session = GameSession(mode: GameMode.campaign)..rawTaps = 482;
      session.resize(390, 520);
      session.zones.setFixture(
        active: oldZone,
        next: nextZone,
        previewTapsRemaining: 2,
        previewElapsed: .3,
      );
      session.resize(390, 520);
      expect(session.state, RunState.playing);
      expect(session.zones.active, oldZone);
      expect(session.zones.next, nextZone);
      expect(session.zones.previewTapsRemaining, 2);
    },
  );

  test('Rounded corners use the same RRect hit path as painted geometry', () {
    final controller = TouchZoneTransitionController();
    controller.setFixture(active: oldZone);
    expect(
      controller.accepts(Offset(oldZone.left + 1, oldZone.top + 1)),
      false,
    );
    expect(controller.accepts(oldZone.center), true);
    expect(
      controller.accepts(Offset(oldZone.left - 1, oldZone.center.dy)),
      false,
    );
  });

  test('Old grace-area taps cannot decrement a new preview', () {
    final controller = TouchZoneTransitionController();
    controller.setFixture(
      active: nextZone,
      previous: oldZone,
      next: oldZone,
      graceRemaining: .2,
    );
    controller.acceptedTap(oldZone.center);
    expect(controller.previewTapsRemaining, 3);
  });

  test(
    'Chaos difficulty grows without changing active or visible preview geometry',
    () {
      final session = GameSession(mode: GameMode.chaos, seed: 42);
      session.resize(390, 538);
      session.zones.startPreview();
      final activeBefore = session.zones.active;
      final previewBefore = session.zones.next!;
      session.rawTaps = 300;
      session.tap(session.target);
      expect(session.zones.difficulty, 30);
      expect(session.zones.active, activeBefore);
      expect(session.zones.next, previewBefore);
      session.update(.6);
      session.tap(session.target);
      session.tap(session.target);
      expect(session.zones.active, previewBefore);
      session.zones.startPreview();
      final harderPreview = session.zones.next!;
      expect(harderPreview.width, lessThan(previewBefore.width));
      expect(harderPreview.height, lessThan(previewBefore.height));
      expect(harderPreview.width, greaterThanOrEqualTo(88));
      expect(harderPreview.height, greaterThanOrEqualTo(88));
      expect(session.zones.active, previewBefore);
      session.update(.1);
      expect(session.zones.next, harderPreview);
      expect(session.zones.active, previewBefore);
    },
  );

  test(
    'Chaos future difficulty is capped and Campaign keeps stage difficulty',
    () {
      final chaos = GameSession(mode: GameMode.chaos)..rawTaps = 5000;
      chaos.tap(chaos.target);
      expect(chaos.zones.difficulty, 49);
      final campaign = GameSession(mode: GameMode.campaign, stage: 7)
        ..rawTaps = 30;
      campaign.tap(campaign.target);
      expect(campaign.zones.difficulty, 7);
    },
  );

  test('Seeded generated zones are deterministic', () {
    final a = TouchZoneTransitionController(seed: 7);
    final b = TouchZoneTransitionController(seed: 7);
    for (var step = 0; step < 10; step++) {
      a.startPreview();
      b.startPreview();
      expect(a.next, b.next);
      a.update(.6);
      b.update(.6);
      for (var tap = 0; tap < 3; tap++) {
        a.acceptedTap();
        b.acceptedTap();
      }
    }
  });
}
