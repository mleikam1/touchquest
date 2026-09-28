import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/services/save_service.dart';
import 'package:touch_quest/services/ad_service.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/game/touch_quest_game.dart';

TouchQuestGame game(WidgetTester tester) =>
    (tester.widget(find.byType(GameWidget<TouchQuestGame>))
            as GameWidget<TouchQuestGame>)
        .game!;
Future<void> boot(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    TouchQuestApp(save: SaveService.memory(), enableServices: false),
  );
}

void main() {
  testWidgets('Menu starts guest play and named destinations', (tester) async {
    await boot(tester);
    for (final label in [
      'PLAY',
      'CAMPAIGN',
      'CHAOS RUN',
      'LEADERBOARD',
      'PROFILE',
      'SETTINGS',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('CAMPAIGN'));
    await tester.pump();
    expect(find.text('1. Neon Beginnings'), findsOneWidget);
    await tester.tap(find.text('1. Neon Beginnings'));
    await tester.pump();
    await tester.tap(find.text('STAGE 1  ·  25 TAPS'));
    await tester.pump();
    expect(game(tester).session.mode, GameMode.campaign);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Holding and HUD/banner pointers cannot duplicate or score taps',
    (tester) async {
      await boot(tester);
      await tester.tap(find.text('PLAY'));
      await tester.pump();
      final run = game(tester);
      final arena = find.byKey(const ValueKey('playable-arena'));
      final gesture = await tester.startGesture(tester.getCenter(arena));
      await tester.pump(const Duration(milliseconds: 100));
      expect(run.session.rawTaps, 1);
      await gesture.moveBy(const Offset(20, 20));
      await tester.pump(const Duration(milliseconds: 100));
      expect(run.session.rawTaps, 1);
      await gesture.up();
      await tester.tapAt(
        tester.getCenter(find.byKey(const ValueKey('gameplay-hud'))),
      );
      await tester.tapAt(
        tester.getCenter(find.byKey(const ValueKey('banner-region'))),
      );
      await tester.pump();
      expect(run.session.rawTaps, 1);
      await tester.tap(find.byTooltip('Pause'));
      await tester.pump();
      expect(find.byType(AdPlaceholder), findsNothing);
      final remaining = run.session.remaining;
      await tester.pump(const Duration(seconds: 2));
      expect(run.session.state, RunState.paused);
      expect(run.session.remaining, remaining);
      await tester.tap(find.text('RESUME'));
      await tester.pump();
      expect(identical(game(tester), run), isTrue);
      expect(run.session.state, RunState.playing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Retry creates exactly one new session after game over', (
    tester,
  ) async {
    await boot(tester);
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    final first = game(tester);
    first.session.update(1.5);
    first.onFrame();
    await tester.pump();
    expect(find.text('TRY AGAIN'), findsOneWidget);
    await tester.tap(find.text('TRY AGAIN'));
    await tester.pump();
    await tester.pump();
    expect(identical(game(tester), first), isFalse);
    expect(game(tester).session.rawTaps, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
