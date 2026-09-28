import 'package:flutter/foundation.dart';
import '../../services/save_service.dart';

/// Debug-only repositories: no SharedPreferences handle and no cloud initialization.
abstract final class UiFixtureData {
  static SaveService createSave() {
    if (kReleaseMode) {
      throw StateError('UI fixtures are unavailable in release.');
    }
    return SaveService.memory({
      'displayName': 'TapMaster',
      'lifetimeTaps': 128492,
      'bestRawRun': 12847,
      'bestScore': 3482,
      'campaign': 15,
      'badges': [
        100,
        200,
        300,
        400,
        500,
        600,
        700,
        800,
        900,
        1000,
        2000,
        3000,
        4000,
        5000,
        6000,
        7000,
        8000,
        10000,
      ],
      'musicVolume': .35,
      'sfxVolume': .35,
      'reduceMotion': false,
      'reduceFlashing': false,
      'quality': 'high',
      'haptics': true,
    });
  }
}

const uiScenarios = <String, String>{
  '01_main_menu': 'Main menu',
  '02_casual_gameplay': 'Casual gameplay',
  '03_transition_warning': 'Next area preview',
  '04_target_mode': 'Target activation',
  '05_game_over': 'Game over',
  '06_campaign_map': 'Campaign',
  '07_chaos_entry': 'Chaos entry',
  '08_profile': 'Profile',
  '09_settings': 'Settings',
  '10_leaderboards': 'Leaderboards',
};
