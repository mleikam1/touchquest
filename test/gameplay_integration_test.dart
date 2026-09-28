import 'dart:convert';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/game/touch_quest_game.dart';
import 'package:touch_quest/services/save_service.dart';
import 'package:touch_quest/ui/overlays/gameplay_hud.dart';
import 'package:touch_quest/ui/preview/ui_fixture_data.dart';

TouchQuestGame currentGame(WidgetTester tester) => tester
    .widget<GameWidget<TouchQuestGame>>(find.byType(GameWidget<TouchQuestGame>))
    .game!;

Future<void> boot(
  WidgetTester tester, {
  String? preview,
  SaveService? save,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    TouchQuestApp(
      save: save ?? SaveService.memory(),
      enableServices: false,
      preview: preview,
    ),
  );
}

void main() {
  testWidgets(
    'Text scaling pauses a started arena and exposes deliberate resume',
    (tester) async {
      await boot(tester);
      await tester.tap(find.text('PLAY'));
      await tester.pump();
      final game = currentGame(tester);
      final arena = find.byKey(const ValueKey('playable-arena'));
      await tester.tap(arena);
      await tester.pump();
      final priorHeight = game.session.height;
      expect(game.session.rawTaps, 1);
      tester.platformDispatcher.textScaleFactorTestValue = 1.25;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();
      await tester.pump();
      expect(game.session.height, isNot(priorHeight));
      expect(game.session.state, RunState.paused);
      expect(game.paused, true);
      expect(find.text('QUEST PAUSED'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final remaining = game.session.remaining;
      await tester.pump(const Duration(seconds: 2));
      expect(game.session.remaining, remaining);
      await tester.tap(find.text('RESUME'));
      await tester.pump();
      expect(currentGame(tester), same(game));
      expect(game.session.state, RunState.playing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Milestone footer and modal surface cannot become arena input', (
    tester,
  ) async {
    await boot(tester);
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    final game = currentGame(tester);
    await tester.tap(find.byKey(const ValueKey('playable-arena')));
    await tester.tap(find.byType(MilestoneCard));
    await tester.tap(find.byKey(const ValueKey('banner-region')));
    await tester.pump();
    expect(game.session.rawTaps, 1);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    await tester.tapAt(const Offset(190, 190));
    await tester.pump();
    expect(game.session.state, RunState.paused);
    expect(game.session.rawTaps, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Gallery input never persists fixture score or progress to device storage',
    (tester) async {
      final original = jsonEncode({
        'bestScore': 11,
        'lifetimeTaps': 22,
        'campaign': 1,
      });
      SharedPreferences.setMockInitialValues({'touchquest.v1': original});
      final prefs = await SharedPreferences.getInstance();
      final fixture = UiFixtureData.createSave();
      final lifetime = fixture.number('lifetimeTaps');
      await boot(tester, preview: '03_transition_warning', save: fixture);
      final game = currentGame(tester);
      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('playable-arena')),
      );
      await tester.tapAt(origin + game.session.target);
      await tester.pump();
      expect(game.session.rawTaps, 483);
      expect(fixture.prefs, isNull);
      expect(fixture.number('lifetimeTaps'), lifetime);
      expect(prefs.getString('touchquest.v1'), original);
      expect(fixture.runs, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
