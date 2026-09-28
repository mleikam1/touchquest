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
        final pool = await FlameAudio.createPool(
          '$n.wav',
          maxPlayers: 4,
          minPlayers: 1,
        );
        if (disposed) {
          await pool.dispose();
          return;
        }
        pools[n] = pool;
      }
      ready = true;
    } catch (e) {
      debugPrint('Audio unavailable: $e');
    }
  }

  void sound(String name) {
    if (disposed || !save.flag('sfx') || !ready) return;
    unawaited(pools[name]?.start(volume: save.volume('sfxVolume')));
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
    if (!ready || disposed) return;
    try {
      if (playing && save.flag('music')) {
        await FlameAudio.bgm.play(
          overdrive ? 'overdrive.wav' : 'music.wav',
          volume: save.volume('musicVolume', .12),
        );
      } else {
        await FlameAudio.bgm.pause();
      }
    } catch (e) {
      debugPrint('Music unavailable: $e');
    }
  }

  Future<void> updateVolume(String key, double value) async {
    await save.set(key, value.clamp(0.0, 1.0));
    await save.set(key == 'musicVolume' ? 'music' : 'sfx', value > 0);
    if (key == 'musicVolume' && ready && !disposed) {
      await FlameAudio.bgm.audioPlayer.setVolume(save.volume(key, .12));
    }
  }

  Future<void> dispose() async {
    disposed = true;
    haptics.cancel();
    if (ready) await FlameAudio.bgm.stop();
    final activePools = pools.values.toList();
    pools.clear();
    ready = false;
    for (final pool in activePools) {
      await pool.dispose();
    }
  }
}
