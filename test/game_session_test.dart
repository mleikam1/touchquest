import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/services/save_service.dart';
import 'package:touch_quest/game/touch_quest_game.dart';

void main() {
  test('Valid pointer down increments raw and score exactly once', () {
    final s = GameSession();
    s.tap(Offset.zero);
    expect(s.rawTaps, 1);
    expect(s.score, 1);
  });
  test('Timeout at 1.5 seconds', () {
    final s = GameSession();
    s.update(1.49);
    expect(s.state, RunState.playing);
    s.update(.011);
    expect(s.state, RunState.over);
  });
  test('Tap resets timer and over-state blocks input', () {
    final s = GameSession();
    s.update(1);
    s.tap(Offset.zero);
    expect(s.remaining, 1.5);
    s.update(1.5);
    s.tap(Offset.zero);
    expect(s.rawTaps, 1);
  });
  test('System pause stops deterministic time', () {
    final s = GameSession();
    s.pause();
    s.update(100);
    expect(s.remaining, 1.5);
    s.resume();
    s.update(.5);
    expect(s.remaining, 1);
  });
  test('Only successful rewarded callback revives preserving score', () {
    final s = GameSession();
    s.tap(Offset.zero);
    s.update(2);
    expect(s.revive(rewarded: false), false);
    expect(s.revive(rewarded: true), true);
    expect(s.score, 1);
    expect(s.rawTaps, 1);
    expect(s.grace, 2);
    s.update(2);
    expect(s.remaining, 1.5);
    s.update(2);
    expect(s.revive(rewarded: true), false);
  });
  test('All milestones fire exactly once without fabricating raw taps', () {
    final s = GameSession();
    final seen = <int>[];
    for (var i = 0; i < 100001; i++) {
      seen.addAll(s.tap(s.target));
    }
    expect(seen, milestones.keys.toList());
    expect(s.rawTaps, 100001);
    expect(s.score, greaterThan(s.rawTaps));
    expect(s.tap(s.target), isEmpty);
  });
  test('New run resets temporary progression', () {
    final s = GameSession();
    for (var i = 0; i < 500; i++) {
      s.tap(s.target);
    }
    final next = GameSession();
    expect(next.fired, isEmpty);
    expect(next.multiplier, 1);
    expect(next.rawTaps, 0);
  });
  test('Campaign accepts target and rejects outside', () {
    final s = GameSession(mode: GameMode.campaign);
    s.tap(s.target);
    expect(s.rawTaps, 1);
    s.tap(Offset.zero);
    expect(s.state, RunState.over);
  });
  test('Campaign stage completes with required physical taps', () {
    final s = GameSession(mode: GameMode.campaign);
    for (var i = 0; i < s.goal; i++) {
      s.tap(s.target);
    }
    expect(s.state, RunState.won);
  });
  test('Targets stay entirely in field, never in banner across stages', () {
    for (var stage = 0; stage < 50; stage++) {
      final s = GameSession(mode: GameMode.campaign, stage: stage);
      s.resize(320, 380);
      for (var i = 0; i < 200; i++) {
        s.moveTarget();
        s.update(.001);
        expect(s.target.dx - s.radius, greaterThanOrEqualTo(0));
        expect(s.target.dx + s.radius, lessThanOrEqualTo(320));
        expect(s.target.dy - s.radius, greaterThanOrEqualTo(0));
        expect(s.target.dy + s.radius, lessThanOrEqualTo(380));
      }
    }
  });
  test(
    'Settings and permanent unlocks persist; account merge preserves guest',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final save = SaveService(prefs);
      await save.set('reduceFlashing', false);
      final s = GameSession();
      for (var i = 0; i < 100; i++) {
        s.tap(s.target);
      }
      await save.record(s, 0);
      await save.merge({
        'bestRawRun': 500,
        'lifetimeTaps': 200,
        'badges': [5000],
      });
      final reloaded = SaveService(prefs);
      expect(reloaded.flag('reduceFlashing'), false);
      expect(reloaded.badges, containsAll([100, 5000]));
      expect(reloaded.number('bestRawRun'), 500);
      expect(reloaded.number('lifetimeTaps'), 200);
    },
  );
  test('Checkpoint adds only new physical taps', () async {
    SharedPreferences.setMockInitialValues({});
    final save = SaveService(await SharedPreferences.getInstance());
    final s = GameSession();
    s.tap(Offset.zero);
    await save.record(s, 0);
    s.tap(Offset.zero);
    await save.record(s, 1);
    expect(save.number('lifetimeTaps'), 2);
  });
  test('Reduce Flashing changes renderer policy immediately', () async {
    SharedPreferences.setMockInitialValues({});
    final save = SaveService(await SharedPreferences.getInstance());
    final game = TouchQuestGame(GameSession(), save, () {});
    expect(game.smooth, true);
    expect(game.colorPulseOpacity(0), game.colorPulseOpacity(.8));
    await save.set('reduceFlashing', false);
    expect(game.smooth, false);
    expect(game.colorPulseOpacity(0), isNot(game.colorPulseOpacity(.8)));
    expect(game.pool.length, 240);
  });
  test('Revive grace consumes only its share of a long update', () {
    final s = GameSession();
    s.update(2);
    s.revive(rewarded: true);
    s.update(2.5);
    expect(s.grace, 0);
    expect(s.remaining, 1);
    expect(s.state, RunState.playing);
  });
}
