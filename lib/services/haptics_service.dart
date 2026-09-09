import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'save_service.dart';

class HapticsService {
  HapticsService(this.save);
  final SaveService save;
  DateTime last = DateTime(2000);
  final List<Timer> pending = [];
  void pulse({bool strong = false}) {
    if (kIsWeb ||
        !save.flag('haptics') ||
        DateTime.now().difference(last).inMilliseconds < 65) {
      return;
    }
    last = DateTime.now();
    final intensity = save.choice('intensity', 'normal');
    if (intensity == 'low') {
      HapticFeedback.selectionClick();
    } else if (strong && intensity == 'high') {
      HapticFeedback.heavyImpact();
    } else if (strong) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void celebrate(int threshold) {
    cancel();
    pulse(strong: true);
    final count = [1000, 10000, 100000].contains(threshold) ? 3 : 2;
    for (var i = 1; i < count; i++) {
      pending.add(
        Timer(
          Duration(milliseconds: 110 * i),
          () => pulse(strong: i == count - 1),
        ),
      );
    }
  }

  void cancel() {
    for (final timer in pending) {
      timer.cancel();
    }
    pending.clear();
  }
}
