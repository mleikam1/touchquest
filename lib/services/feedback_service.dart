import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'save_service.dart';

class FeedbackService {
  FeedbackService(this.save);
  final SaveService save;
  final Map<String,AudioPool> pools={};
  bool ready=false;
  int taps=0;
  DateTime lastHaptic=DateTime(2000);
  Future<void> init() async {
    try {for(final n in ['tap','pop','boing','laser','milestone','danger','gameover','revive','electric','boss','fireworks','countdown','menu']) {pools[n]=await FlameAudio.createPool('$n.wav',maxPlayers:4,minPlayers:1);} ready=true;} catch(e) {debugPrint('Audio unavailable: $e');}
  }
  void sound(String name) {if(!save.flag('sfx') || !ready) return; unawaited(pools[name]?.start(volume:.35));}
  void tap(int raw) {taps++; sound(raw>=20000?'electric':raw>=6000?(taps%4==0?'pop':'tap'):raw>=300 && raw<450?['boing','pop','laser'][taps%3]:'tap'); haptic();}
  void haptic({bool strong=false}) {
    if(kIsWeb || !save.flag('haptics') || DateTime.now().difference(lastHaptic).inMilliseconds<65) return;
    lastHaptic=DateTime.now(); final intensity=save.choice('intensity','normal');
    if(intensity=='low') {HapticFeedback.selectionClick();} else if(strong && intensity=='high') {HapticFeedback.heavyImpact();} else if(strong) {HapticFeedback.mediumImpact();} else {HapticFeedback.lightImpact();}
  }
  Future<void> music(bool playing,{bool overdrive=false}) async {
    if(!ready) return;
    try {if(playing && save.flag('music')) {await FlameAudio.bgm.play(overdrive?'overdrive.wav':'music.wav',volume:.12);} else {await FlameAudio.bgm.pause();}} catch(e) {debugPrint('Music unavailable: $e');}
  }
  Future<void> dispose() async {await FlameAudio.bgm.stop(); for(final pool in pools.values) {await pool.dispose();}}
}
