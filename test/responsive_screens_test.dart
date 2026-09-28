import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/game/touch_quest_game.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/services/save_service.dart';
import 'package:touch_quest/ui/preview/ui_fixture_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'Rajdhani': 'assets/fonts/Rajdhani-SemiBold.ttf',
      'BarlowCondensed': 'assets/fonts/BarlowCondensed-ExtraBold.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
  });
  for (final viewport in const [
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
    Size(768, 1024),
    Size(1440, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      for (final scenario in const [
        '01_main_menu',
        '02_casual_gameplay',
        '03_transition_warning',
        '04_target_mode',
        '05_game_over',
        '07_chaos_entry',
      ]) {
        testWidgets(
          '$scenario at ${viewport.width}×${viewport.height}, text $scale',
          (tester) async {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final save = UiFixtureData.createSave();
            await tester.pumpWidget(
              TouchQuestApp(
                save: save,
                enableServices: false,
                preview: scenario,
              ),
            );
            await tester.runAsync(() async {
              for (final element
                  in find.byType(GameWidget<TouchQuestGame>).evaluate()) {
                await (element.widget as GameWidget<TouchQuestGame>)
                    .game!
                    .loaded;
              }
            });
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 16));
            expect(tester.takeException(), isNull);
            final arena = find.byKey(const ValueKey('playable-arena'));
            if (arena.evaluate().isNotEmpty) {
              final bounds = tester.getRect(arena);
              expect(bounds.width, greaterThanOrEqualTo(300));
              expect(bounds.height, greaterThanOrEqualTo(150));
              for (final element
                  in find.byType(GameWidget<TouchQuestGame>).evaluate()) {
                final game =
                    (element.widget as GameWidget<TouchQuestGame>).game!;
                final region = Offset.zero & bounds.size;
                if (game.session.precision) {
                  expect(
                    region.contains(
                      game.session.zones.active.outerRect.topLeft,
                    ),
                    isTrue,
                  );
                  expect(
                    region.contains(
                      game.session.zones.active.outerRect.bottomRight -
                          const Offset(.01, .01),
                    ),
                    isTrue,
                  );
                }
              }
            }
            await tester.pumpWidget(const SizedBox());
            await tester.pump();
            save.dispose();
          },
        );
      }
    }
  }
  testWidgets('App interruption pauses the live run until deliberate resume', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final save = SaveService.memory();
    await tester.pumpWidget(TouchQuestApp(save: save, enableServices: false));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    final game = tester
        .widget<GameWidget<TouchQuestGame>>(
          find.byType(GameWidget<TouchQuestGame>),
        )
        .game!;
    await tester.runAsync(() => game.loaded);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('playable-arena')));
    await tester.pump(const Duration(milliseconds: 100));
    final before = game.session.rawTaps;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    final time = game.session.remaining;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    expect(game.session.state, RunState.paused);
    expect(game.session.remaining, time);
    final point =
        tester.getTopLeft(find.byKey(const ValueKey('playable-arena'))) +
        const Offset(8, 8);
    await tester.tapAt(point);
    expect(game.session.rawTaps, before);
    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(game.session.state, RunState.playing);
    expect(
      identical(
        tester
            .widget<GameWidget<TouchQuestGame>>(
              find.byType(GameWidget<TouchQuestGame>),
            )
            .game,
        game,
      ),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    save.dispose();
  });
}
