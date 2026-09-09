import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'save_service.dart';
import 'haptics_service.dart';

class FeedbackService {
  FeedbackService(this.save);
  final SaveService save;
  final Map<String, AudioPool> pools = {};
  bool ready = false, disposed = false;
  int taps = 0;
  late final haptics = HapticsService(save);
  Future<void> init() async {
    try {
      for (final n in [
        'tap',
        'pop',
        'boing',
        'laser',
        'milestone',
        'danger',
        'gameover',
        'revive',
        'electric',
        'boss',
        'fireworks',
        'countdown',
        'menu',
      ]) {
        if (disposed) return;
        pools[n] = await FlameAudio.createPool(
          '$n.wav',
          maxPlayers: 4,
          minPlayers: 1,
        );
        if (disposed) {
          await pools[n]!.dispose();
          return;
        }
      }
      ready = true;
    } catch (e) {
      debugPrint('Audio unavailable: $e');
    }
  }

  void sound(String name) {
    if (!save.flag('sfx') || !ready) return;
    unawaited(pools[name]?.start(volume: .35));
  }

  void tap(int raw, {bool funny = false}) {
    taps++;
    sound(
      raw >= 20000
          ? 'electric'
          : raw >= 6000
          ? (taps % 4 == 0 ? 'pop' : 'tap')
          : funny
          ? ['boing', 'pop', 'laser'][taps % 3]
          : 'tap',
    );
    haptic();
  }

  void haptic({bool strong = false}) => haptics.pulse(strong: strong);
  void celebration(int n) {
    haptics.celebrate(n);
    sound([1000, 10000, 100000].contains(n) ? 'fireworks' : 'milestone');
  }

  Future<void> music(bool playing, {bool overdrive = false}) async {
    if (!ready) return;
    try {
      if (playing && save.flag('music')) {
        await FlameAudio.bgm.play(
          overdrive ? 'overdrive.wav' : 'music.wav',
          volume: .12,
        );
      } else {
        await FlameAudio.bgm.pause();
      }
    } catch (e) {
      debugPrint('Music unavailable: $e');
    }
  }

  Future<void> dispose() async {
    disposed = true;
    haptics.cancel();
    await FlameAudio.bgm.stop();
    for (final pool in pools.values) {
      await pool.dispose();
    }
  }
}
