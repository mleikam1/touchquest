import 'dart:io';
import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/game/touch_quest_game.dart';
import 'package:touch_quest/ui/preview/ui_fixture_data.dart';

Future<void> loadProductionFonts() async {
  final display = FontLoader('BarlowCondensed')
    ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-ExtraBold.ttf'))
    ..addFont(
      rootBundle.load('assets/fonts/BarlowCondensed-ExtraBoldItalic.ttf'),
    );
  final body = FontLoader('Rajdhani')
    ..addFont(rootBundle.load('assets/fonts/Rajdhani-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Rajdhani-Bold.ttf'));
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([display.load(), body.load(), icons.load()]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadProductionFonts);
  for (final scenario in uiScenarios.keys) {
    testWidgets(
      'Production gallery $scenario renders with bundled fonts',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const key = ValueKey('screenshot');
        final save = UiFixtureData.createSave();
        if (scenario == '06_campaign_map') save.data['campaign'] = 0;
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: TouchQuestApp(
              save: save,
              enableServices: false,
              preview: scenario,
            ),
          ),
        );
        await tester.runAsync(() async {
          final context = tester.element(find.byType(TouchQuestApp));
          for (final asset in [
            'backgrounds/menu.png',
            'backgrounds/gameplay.png',
            'backgrounds/gameover.png',
            'characters/robot.png',
            'characters/tutorial_hand.png',
            'worlds/world_atlas.png',
          ]) {
            await precacheImage(AssetImage('assets/art/$asset'), context);
          }
          for (final element
              in find.byType(GameWidget<TouchQuestGame>).evaluate()) {
            await (element.widget as GameWidget<TouchQuestGame>).game!.loaded;
          }
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(key),
          matchesGoldenFile('goldens/$scenario.png'),
        );
        if (const bool.fromEnvironment('CAPTURE_UI')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(key),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/ui-review/screenshots/$scenario.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        save.dispose();
      },
      tags: const ['golden'],
    );
  }
}
