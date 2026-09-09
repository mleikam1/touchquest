import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/core/game_session.dart';

class SaveService extends ChangeNotifier {
  SaveService(this.prefs) {
    data =
        jsonDecode(prefs.getString('touchquest.v1') ?? '{}')
            as Map<String, dynamic>;
  }
  final SharedPreferences prefs;
  late Map<String, dynamic> data;
  bool flag(String key, [bool fallback = true]) =>
      data[key] as bool? ?? fallback;
  String choice(String key, String fallback) =>
      data[key] as String? ?? fallback;
  int number(String key) => (data[key] as num?)?.toInt() ?? 0;
  List<int> get badges => (data['badges'] as List? ?? []).cast<int>();
  List<Map<String, dynamic>> get runs => (data['runs'] as List? ?? [])
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  Future<void> set(String key, dynamic value) async {
    data[key] = value;
    notifyListeners();
    await persist();
  }

  Future<void> persist() async {
    await prefs.setString('touchquest.v1', jsonEncode(data));
  }

  Future<void> record(GameSession s, int alreadySaved) async {
    data['lifetimeTaps'] =
        number('lifetimeTaps') + max(0, s.rawTaps - alreadySaved);
    data['bestRawRun'] = max(number('bestRawRun'), s.rawTaps);
    data['bestScore'] = max(number('bestScore'), s.score);
    data['badges'] = {...badges, ...s.fired}.toList()..sort();
    if (s.state == RunState.won) {
      data['campaign'] = max(number('campaign'), s.stage + 1);
    }
    final list = runs;
    final result = {...s.toJson(), 'runId': s.id};
    final existing = list.indexWhere((r) => r['runId'] == s.id);
    if (existing >= 0) {
      list[existing] = result;
    } else {
      list.insert(0, result);
    }
    data['runs'] = list.take(30).toList();
    notifyListeners();
    await persist();
  }

  Future<void> merge(Map<String, dynamic> remote) async {
    for (final k in ['lifetimeTaps', 'bestRawRun', 'bestScore', 'campaign']) {
      data[k] = max(number(k), (remote[k] as num?)?.toInt() ?? 0);
    }
    data['badges'] = {
      ...badges,
      ...(remote['badges'] as List? ?? []).cast<int>(),
    }.toList()..sort();
    notifyListeners();
    await persist();
  }

  Future<void> clear() async {
    data = {};
    notifyListeners();
    await persist();
  }
}
