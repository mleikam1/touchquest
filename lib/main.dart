import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'services/save_service.dart';
import 'ui/preview/ui_fixture_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No fixture repositories, ads or cloud calls can enter release navigation.
  final scenario = kReleaseMode ? null : Uri.base.queryParameters['ui'];
  final preview =
      scenario != null &&
      (uiScenarios.containsKey(scenario) || scenario == 'gallery');
  final save = preview
      ? UiFixtureData.createSave()
      : SaveService(await SharedPreferences.getInstance());
  runApp(TouchQuestApp(save: save, preview: preview ? scenario : null));
}
