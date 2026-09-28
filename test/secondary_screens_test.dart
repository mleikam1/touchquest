import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_quest/game/core/game_session.dart';
import 'package:touch_quest/services/ad_service.dart';
import 'package:touch_quest/services/feedback_service.dart';
import 'package:touch_quest/services/firebase_service.dart';
import 'package:touch_quest/services/save_service.dart';
import 'package:touch_quest/ui/screens/secondary_screens.dart';
import 'package:touch_quest/ui/widgets/arcade_widgets.dart';

Future<void> render(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      theme: arcadeTheme(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pumpAndSettle();
}

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
  test('memory preview changes never touch stored progress', () async {
    SharedPreferences.setMockInitialValues({
      'touchquest.v1': '{"displayName":"Real player","bestRawRun":71}',
    });
    final prefs = await SharedPreferences.getInstance();
    final preview = SaveService.memory({'displayName': 'Preview'});
    await preview.set('displayName', 'Changed preview');
    await preview.clear();
    final production = SaveService(prefs);
    expect(production.choice('displayName', ''), 'Real player');
    expect(production.number('bestRawRun'), 71);
  });

  testWidgets('guest profile edit persists permitted name', (tester) async {
    final save = SaveService.memory();
    final cloud = FirebaseService(save);
    await render(
      tester,
      ProfileScreen(save: save, cloud: cloud, onNavigate: (_) {}),
    );
    await tester.tap(find.text('EDIT'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Orbit Pilot');
    await tester.tap(find.text('SAVE NAME'));
    await tester.pumpAndSettle();
    expect(save.choice('displayName', ''), 'Orbit Pilot');
    expect(find.text('Orbit Pilot'), findsOneWidget);
    expect(find.text('0/${milestones.length}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'badge detail explains raw-run requirement and locked effects cannot equip',
    (tester) async {
      final save = SaveService.memory();
      await render(
        tester,
        ProfileScreen(
          save: save,
          cloud: FirebaseService(save),
          onNavigate: (_) {},
        ),
      );
      await tester.tap(find.byType(BadgeTile).first);
      await tester.pumpAndSettle();
      expect(find.text('1,000 RAW TAPS'), findsOneWidget);
      expect(
        find.textContaining('Boosted score does not count'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EffectTile).last);
      await tester.pump();
      expect(find.text('UNLOCK AT 5,000 RAW TAPS IN ONE RUN'), findsOneWidget);
      expect(find.text('EQUIP EFFECT'), findsNothing);
      expect(save.choice('skin', 'cyan'), 'cyan');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('earned effect preview equips and saves selection', (
    tester,
  ) async {
    final save = SaveService.memory({
      'badges': [5000],
      'reduceMotion': true,
    });
    await render(tester, CollectionScreen(save: save, onNavigate: (_) {}));
    await tester.tap(find.text('Golden Touch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EQUIP EFFECT'));
    await tester.pumpAndSettle();
    expect(save.choice('skin', ''), 'gold');
    expect(find.text('Equipped'), findsOneWidget);
  });

  testWidgets(
    'campaign preserves five stages per world and enforces progression',
    (tester) async {
      final save = SaveService.memory();
      GameMode? launchedMode;
      int? launchedStage;
      await render(
        tester,
        CampaignScreen(
          save: save,
          onNavigate: (_) {},
          onStart: (mode, stage) {
            launchedMode = mode;
            launchedStage = stage;
          },
        ),
      );
      expect(find.text('0/5'), findsOneWidget);
      await tester.tap(find.text('2. Pixel Panic'));
      await tester.pumpAndSettle();
      final lockedStage = tester.widget<ArcadeButton>(
        find.ancestor(
          of: find.text('STAGE 6  ·  50 TAPS'),
          matching: find.byType(ArcadeButton),
        ),
      );
      expect(lockedStage.onPressed, isNull);
      expect(
        find.text('Clear the previous world to unlock these stages.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1. Neon Beginnings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('STAGE 1  ·  25 TAPS'));
      expect(launchedMode, GameMode.campaign);
      expect(launchedStage, 0);
      final secondStage = tester.widget<ArcadeButton>(
        find.ancestor(
          of: find.text('STAGE 2  ·  30 TAPS'),
          matching: find.byType(ArcadeButton),
        ),
      );
      expect(secondStage.onPressed, isNull);
    },
  );

  testWidgets(
    'leaderboard is honest offline and friends have no invented rows',
    (tester) async {
      final save = SaveService.memory();
      await render(
        tester,
        LeaderboardScreen(
          save: save,
          cloud: FirebaseService(save),
          onNavigate: (_) {},
        ),
      );
      expect(find.text('You’re playing offline'), findsOneWidget);
      expect(find.text('TapGod'), findsNothing);
      expect(find.byType(CircleAvatar), findsNothing);
      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();
      expect(find.text('Friends are coming soon'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets('fixture leaderboard remains clearly marked and avatar-free', (
    tester,
  ) async {
    final save = SaveService.memory();
    await render(
      tester,
      LeaderboardScreen(
        save: save,
        cloud: FirebaseService(save),
        onNavigate: (_) {},
        fixture: true,
      ),
    );
    expect(find.text('TapGod'), findsOneWidget);
    expect(find.text('PREVIEW DATA · NOT LIVE RANKINGS'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('settings volume and accessibility changes persist immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final save = SaveService(prefs);
    final audio = FeedbackService(save);
    await render(
      tester,
      SettingsScreen(
        save: save,
        cloud: FirebaseService(save),
        audio: audio,
        ads: WebAdService(),
        onNavigate: (_) {},
      ),
    );
    final music = tester.widget<Slider>(find.byType(Slider).first);
    music.onChanged!(.72);
    await tester.pumpAndSettle();
    expect(save.volume('musicVolume'), .72);
    expect(SaveService(prefs).volume('musicVolume'), .72);
    final haptics = tester.widget<Switch>(find.byType(Switch).first);
    haptics.onChanged!(false);
    final motion = tester.widget<Switch>(find.byType(Switch).at(1));
    motion.onChanged!(true);
    await tester.pumpAndSettle();
    expect(SaveService(prefs).flag('haptics'), isFalse);
    expect(SaveService(prefs).flag('reduceMotion'), isTrue);
    await tester.tap(find.text('Effects Quality'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LOW'));
    await tester.pumpAndSettle();
    expect(SaveService(prefs).choice('quality', 'auto'), 'low');
    await audio.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting guest progress requires explicit confirmation', (
    tester,
  ) async {
    final save = SaveService.memory({'bestRawRun': 123});
    await render(
      tester,
      AccountScreen(
        save: save,
        cloud: FirebaseService(save),
        ads: WebAdService(),
        onNavigate: (_) {},
      ),
    );
    await tester.scrollUntilVisible(find.text('DELETE LOCAL PROGRESS'), 150);
    await tester.tap(find.text('DELETE LOCAL PROGRESS'));
    await tester.pumpAndSettle();
    expect(save.number('bestRawRun'), 123);
    await tester.tap(find.text('KEEP MY PROGRESS'));
    await tester.pumpAndSettle();
    expect(save.number('bestRawRun'), 123);
    await tester.tap(find.text('DELETE LOCAL PROGRESS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE PERMANENTLY'));
    await tester.pumpAndSettle();
    expect(save.number('bestRawRun'), 0);
  });
  for (final viewport in const [
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
    Size(768, 1024),
    Size(1440, 900),
  ]) {
    for (final scale in [1.5, 2.0]) {
      testWidgets(
        'Secondary layouts at ${viewport.width}×${viewport.height} with $scale text',
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final save = SaveService.memory({
            'displayName': 'A longer player name',
            'lifetimeTaps': 128492,
            'bestRawRun': 12847,
            'badges': [1000, 10000],
          });
          final cloud = FirebaseService(save);
          final screens = <Widget>[
            CampaignScreen(save: save, onNavigate: (_) {}, onStart: (_, _) {}),
            ProfileScreen(save: save, cloud: cloud, onNavigate: (_) {}),
            SettingsScreen(
              save: save,
              cloud: cloud,
              audio: FeedbackService(save),
              ads: WebAdService(),
              onNavigate: (_) {},
            ),
            LeaderboardScreen(
              save: save,
              cloud: cloud,
              onNavigate: (_) {},
              fixture: true,
            ),
          ];
          for (final screen in screens) {
            await tester.pumpWidget(
              MaterialApp(
                theme: arcadeTheme(),
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(
                      size: viewport,
                      textScaler: TextScaler.linear(scale),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: screen,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${screen.runtimeType} overflow at $viewport, scale $scale',
            );
          }
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
