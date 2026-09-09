import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_quest/app/app.dart';
import 'package:touch_quest/services/save_service.dart';
void main() {
 testWidgets('Menu exposes actual modes and accessible navigation',(tester) async {
  SharedPreferences.setMockInitialValues({});
  final save=SaveService(await SharedPreferences.getInstance());
  await tester.pumpWidget(TouchQuestApp(save:save));
  expect(find.text('PLAY ENDLESS'),findsOneWidget);
  expect(find.text('CAMPAIGN'),findsOneWidget);
  expect(find.text('CHAOS RUN'),findsOneWidget);
  await tester.tap(find.text('CAMPAIGN')); await tester.pump();
  expect(find.text('1. Neon Beginnings'),findsOneWidget);
  await tester.pumpWidget(const SizedBox());
 });
}
