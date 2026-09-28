import 'dart:math';
import 'dart:ui';
import '../systems/touch_zone_transition_controller.dart';

enum GameMode { casual, campaign, chaos }

enum RunState { playing, paused, over, won }

const worlds = [
  'Neon Beginnings',
  'Pixel Panic',
  'Underwater Tap',
  'Cosmic Touch',
  'Lava Fingers',
  'Cyber City',
  'Candy Chaos',
  'Wizard Warp',
  'Alien Arcade',
  'Temple of the Tap God',
];
const milestones = <int, String>{
  100: 'BACKGROUND SHIFT',
  200: 'TAP EXPLOSIONS',
  300: 'FUNNY SOUND MODE',
  400: 'COLOR PULSE',
  500: 'OVERDRIVE',
  600: 'GRAVITY WARP',
  700: 'TROLLVERTISEMENT',
  800: 'FIRE TOUCH',
  900: 'HYPER TAP',
  1000: 'THE FIRST ASCENSION',
  2000: 'WORLD SHIFT',
  3000: 'TAP ASSISTANT',
  4000: 'INVERTED REALITY',
  5000: 'GOLDEN TOUCH',
  6000: 'BEAT TAP',
  7000: 'REALITY DISTORTION',
  8000: 'MEME MAYHEM',
  9000: 'GHOST TAPS',
  10000: 'GOD MODE',
  15000: 'TAP VELOCITY UPGRADE',
  20000: 'ELECTRIC TOUCH',
  30000: 'SYSTEM MELTDOWN',
  40000: 'TAP UNIVERSE',
  50000: 'SECRET DEVELOPER MESSAGE',
  60000: 'INFINITE WORMHOLE',
  75000: 'HALL OF FAME',
  100000: 'TAP GOD',
};

class GameSession {
  GameSession({
    this.mode = GameMode.casual,
    this.stage = 0,
    this.velocityPerk = false,
    int seed = 42,
  }) : random = Random(seed),
       zones = TouchZoneTransitionController(seed: seed, difficulty: stage);
  final String id = DateTime.now().microsecondsSinceEpoch.toString();
  final GameMode mode;
  final int stage;
  final bool velocityPerk;
  final Random random;
  final TouchZoneTransitionController zones;
  RunState state = RunState.playing;
  int rawTaps = 0, score = 0, reviveCount = 0;
  int paletteIndex = 0, worldIndex = 0;
  double lastTapAt = 0;
  final intervals = List<double>.filled(8, 0);
  int intervalCursor = 0;
  bool get steadyBeat {
    final samples = intervals.where((v) => v > 0).toList();
    if (samples.length < 4) return false;
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    return samples.every((v) => (v - mean).abs() < mean * .2);
  }

  double remaining = 1.5, duration = 0, grace = 0, overdrive = 0;
  double width = 400, height = 500, phase = 0;
  bool _arenaConfigured = false;
  Offset get target => zones.active.center;
  double get radius => min(zones.active.width, zones.active.height) / 2;
  final Set<int> fired = {};
  final Map<int, double> ages = {};
  String reason = 'Your finger took a vacation.';
  int get highest => fired.isEmpty ? 0 : fired.reduce(max);
  int get goal => 25 + stage * 5;
  double get tapRate => duration > 0 ? rawTaps / duration : 0;
  int get multiplier => overdrive > 0 ? 2 : 1;
  bool get precision => mode != GameMode.casual;
  bool active(int n, double seconds) =>
      ages.containsKey(n) && ages[n]! < seconds;

  void resize(double w, double h) {
    if (w <= 0 || h <= 0) return;
    final changed = w != width || h != height;
    // Initial layout configures the arena; subsequent changes require Ready.
    if (changed && _arenaConfigured && (rawTaps > 0 || duration > 0)) pause();
    _arenaConfigured = true;
    if (!changed) return;
    width = w;
    height = h;
    zones.resize(Size(w, h));
  }

  bool hit(Offset p) =>
      (Offset.zero & Size(width, height)).contains(p) &&
      (!precision || zones.accepts(p));
  List<int> tap(Offset position) {
    if (state != RunState.playing) return [];
    if (!hit(position)) {
      state = RunState.over;
      reason = 'The glowing zone missed you.';
      return [];
    }
    if (rawTaps > 0 && duration > lastTapAt) {
      intervals[intervalCursor++ % intervals.length] = duration - lastTapAt;
    }
    lastTapAt = duration;
    rawTaps++;
    score += multiplier + (velocityPerk && rawTaps % 10 == 0 ? 1 : 0);
    remaining = 1.5;
    final unlocked = <int>[];
    for (final n in milestones.keys) {
      if (rawTaps >= n && fired.add(n)) {
        ages[n] = 0;
        if (n == 100) paletteIndex = 1 + random.nextInt(4);
        if (n == 2000) worldIndex = 1 + random.nextInt(9);
        unlocked.add(n);
        if (n == 500) overdrive = 10;
      }
    }
    // Evaluate this pointer once against the old geometry, then switch atomically.
    if (precision) {
      if (mode == GameMode.chaos) {
        // Difficulty only influences the next rectangle that has not been shown.
        // Never change an active target or the exact bounds of a visible preview.
        zones.difficulty = min(49, rawTaps ~/ 10);
      }
      zones.acceptedTap(position);
    }
    if (mode == GameMode.campaign && rawTaps >= goal) {
      state = RunState.won;
      reason = 'Stage cleared. Finger promoted.';
    }
    return unlocked;
  }

  void update(double dt) {
    if (state != RunState.playing) return;
    dt = min(dt, remaining + grace);
    duration += dt;
    phase += dt;
    if (precision) zones.update(dt);
    for (final n in ages.keys.toList()) {
      ages[n] = ages[n]! + dt;
    }
    overdrive = max(0, overdrive - dt);
    final graceUsed = min(grace, dt);
    grace -= graceUsed;
    remaining = max(0, remaining - (dt - graceUsed));
    if (remaining <= 0) {
      state = RunState.over;
      return;
    }
  }

  void pause() {
    if (state == RunState.playing) state = RunState.paused;
  }

  void resume() {
    if (state == RunState.paused) state = RunState.playing;
  }

  bool revive({required bool rewarded}) {
    if (!rewarded || state != RunState.over || reviveCount >= 1) return false;
    reviveCount++;
    remaining = 1.5;
    grace = 2;
    state = RunState.paused;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'runId': id,
    'mode': mode.name,
    'rawTaps': rawTaps,
    'score': score,
    'durationMs': (duration * 1000).round(),
    'averageTapsPerSecond': tapRate,
    'reviveCount': reviveCount,
    'highestMilestone': highest,
    'stage': stage,
    'completed': state == RunState.won,
  };
}
