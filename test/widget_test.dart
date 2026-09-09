import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/services/save_service.dart';

void main() {
  testWidgets('Menu exposes actual modes and accessible navigation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final save = SaveService(await SharedPreferences.getInstance());
    await tester.pumpWidget(TouchQuestApp(save: save));
    expect(find.text('PLAY ENDLESS'), findsOneWidget);
    expect(find.text('CAMPAIGN'), findsOneWidget);
    expect(find.text('CHAOS RUN'), findsOneWidget);
    await tester.tap(find.text('CAMPAIGN'));
    await tester.pump();
    expect(find.text('1. Neon Beginnings'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Holding does not repeat input and banner cannot score', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final save = SaveService(await SharedPreferences.getInstance());
    await tester.pumpWidget(TouchQuestApp(save: save));
    await tester.tap(find.text('PLAY ENDLESS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1 RAW TAPS'), findsOneWidget);
    await gesture.up();
    await tester.tap(find.text('AD SPACE  ·  TAKE A FINGER BREATHER'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1 RAW TAPS'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
