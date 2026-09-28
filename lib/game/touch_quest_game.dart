import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextPainter, TextSpan, TextStyle;
import '../services/save_service.dart';
import 'core/game_session.dart';
import 'systems/milestone_director.dart';
import 'worlds/world_definition.dart';

class Spark {
  Offset p = Offset.zero, v = Offset.zero;
  double life = 0, total = 1;
  Color color = const Color(0xff00d9ff);
  bool ring = false, ghost = false;
}

/// Paints only the bounded arena. Flutter owns all input, HUD and modal controls.
class TouchQuestGame extends FlameGame {
  TouchQuestGame(
    this.session,
    this.save,
    this.onFrame, {
    this.frozen = false,
    int seed = 42,
    double fixtureTime = 0,
  }) : rng = Random(seed),
       clock = fixtureTime;
  final GameSession session;
  final SaveService save;
  final void Function() onFrame;
  final bool frozen;
  final pool = List.generate(240, (_) => Spark());
  final Random rng;
  static final _artCache = Images(prefix: 'assets/');
  Image? _background;
  double clock, ghostClock = 0, slowFrames = 0, celebrationClock = 0;
  int cursor = 0;
  late final director = MilestoneDirector(session);
  final Paint ink = Paint();
  static const cyan = Color(0xff00d9ff), magenta = Color(0xffef45ff);
  bool get reduced => save.flag('reduceMotion', false);
  bool get smooth => save.flag('reduceFlashing', true);
  double colorPulseOpacity(double time) =>
      smooth ? .055 : .08 + .04 * sin(time * pi * .6);
  Color get accent {
    final skin = save.choice('skin', 'cyan');
    if (skin == 'gold') return const Color(0xffffd96a);
    if (skin == 'magenta') return magenta;
    if (skin == 'burst') return const Color(0xffffa844);
    if (session.rawTaps >= 5000) return const Color(0xffffd96a);
    if (session.rawTaps >= 800) return const Color(0xffff8054);
    return worldDefinitions[(session.stage ~/ 5).clamp(0, 9)].accent;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // The procedural energy layer remains a usable fallback during asset loading.
    try {
      _background = await _artCache.load('art/backgrounds/gameplay.png');
    } catch (_) {
      _background = null;
    }
  }

  @override
  Color backgroundColor() => const Color(0xff050a24);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final wasPlaying = session.state == RunState.playing;
    session.resize(size.x, size.y);
    if (wasPlaying && session.state == RunState.paused) {
      pauseEngine();
      // Resize runs during layout. Notify Flutter after that frame's build so
      // accessibility-driven arena changes can show the deliberate-resume UI.
      scheduleMicrotask(onFrame);
    }
  }

  void burst(Offset at, {bool celebrate = false}) {
    final low =
        save.choice('quality', 'auto') == 'low' ||
        (save.choice('quality', 'auto') == 'auto' && slowFrames > 20);
    final count = reduced
        ? 3
        : low
        ? 8
        : celebrate
        ? 72
        : director.hyper
        ? 32
        : session.rawTaps >= 200
        ? 22
        : 12;
    for (var i = 0; i < count; i++) {
      final s = pool[cursor++ % pool.length];
      final angle = rng.nextDouble() * pi * 2;
      s.p = at;
      s.ring = i < 2;
      s.v = s.ring
          ? Offset.zero
          : Offset(cos(angle), sin(angle)) *
                (45 + rng.nextDouble() * (celebrate ? 250 : 170));
      s.total = s.life = celebrate ? .8 : .45;
      s.ghost = false;
      s.color = i % 5 == 0
          ? const Color(0xffffc63e)
          : i.isEven
          ? magenta
          : accent;
    }
  }

  @override
  void update(double dt) {
    if (frozen) return;
    super.update(dt);
    if (session.state != RunState.playing) return;
    clock += dt;
    slowFrames = (slowFrames + (dt > .025 ? 1 : -.1)).clamp(0, 100);
    session.update(dt);
    _advanceEffects(dt);
    if (session.rawTaps >= 9000 ||
        (session.mode == GameMode.chaos && session.rawTaps > 70)) {
      ghostClock += dt;
      if (ghostClock > 1.4) {
        ghostClock = 0;
        final s = pool[cursor++ % pool.length];
        s.p = Offset(rng.nextDouble() * size.x, rng.nextDouble() * size.y);
        s.life = s.total = .45;
        s.ring = s.ghost = true;
        s.color = const Color(0xff687897);
        s.v = Offset.zero;
      }
    }
    if (director.tapGod ||
        session.active(1000, 3) ||
        session.active(10000, 4)) {
      celebrationClock += dt;
      if (celebrationClock > .5 && !reduced) {
        celebrationClock = 0;
        burst(
          Offset(rng.nextDouble() * size.x, rng.nextDouble() * size.y * .6),
          celebrate: true,
        );
      }
    }
    onFrame();
  }

  /// Advances already-created effects for a frozen gallery shot only. It never
  /// changes the game timer, accepted tap count, transition clock, or callbacks.
  /// Call once with the desired burst age after constructing the fixture burst.
  void previewEffectsAt(double age) {
    assert(frozen, 'Effect time overrides belong only to frozen previews.');
    if (!age.isFinite || age < 0) throw ArgumentError.value(age, 'age');
    _advanceEffects(age);
  }

  void _advanceEffects(double dt) {
    for (final s in pool) {
      if (s.life <= 0) continue;
      s.life -= dt;
      if (!reduced && !s.ring) {
        if (session.rawTaps >= 600) {
          final pull = Offset(size.x / 2, size.y / 2) - s.p;
          s.v += Offset(-pull.dy, pull.dx) * dt * .4;
        }
        s.p += s.v * dt;
      }
    }
  }

  void label(
    Canvas c,
    String text,
    Offset center, {
    double fontSize = 15,
    Color color = const Color(0xfff5f7ff),
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'BarlowCondensed',
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
          shadows: [Shadow(color: color.withValues(alpha: .4), blurRadius: 9)],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: max(1, maxWidth ?? size.x - 36));
    painter.paint(c, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;
    final bounds = Offset.zero & size.toSize();
    final t = reduced ? 0.0 : clock;
    canvas.save();
    canvas.clipRect(bounds);
    _drawAtmosphere(canvas, bounds, t);
    _drawMilestoneAtmosphere(canvas, bounds, t);
    if (session.precision) _drawZones(canvas);
    for (final s in pool) {
      if (s.life <= 0) continue;
      final progress = (s.life / s.total).clamp(0.0, 1.0);
      final radius = reduced
          ? 12.0
          : 7 + (1 - progress) * (director.hyper ? 95 : 65);
      ink
        ..shader = null
        ..color = s.color.withValues(alpha: progress * (s.ghost ? .35 : .95))
        ..strokeWidth = s.ring ? 2.2 : 1.5
        ..style = s.ring ? PaintingStyle.stroke : PaintingStyle.fill;
      if (s.ring) {
        canvas.drawCircle(s.p, radius, ink);
        ink.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(s.p, radius, ink);
        ink.maskFilter = null;
      } else {
        canvas.drawCircle(s.p, 1.2 + progress * 1.9, ink);
        if (!reduced) canvas.drawLine(s.p, s.p - s.v * .035, ink);
      }
      if (session.rawTaps >= 7000 && s.ring && !reduced) {
        ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = s.color.withValues(alpha: progress * .15);
        canvas.drawOval(
          Rect.fromCenter(
            center: s.p,
            width: radius * 2.2,
            height: radius * .7,
          ),
          ink,
        );
      }
      if (director.electric && !s.ring) {
        canvas.drawLine(s.p, s.p + Offset(8 * sin(s.p.dy), -10), ink);
      }
    }
    ink.style = PaintingStyle.fill;
    // Secondary milestone copy stays in the bottom margin, clear of zone labels.
    if (director.message.isNotEmpty) {
      label(
        canvas,
        director.message,
        Offset(size.x / 2, size.y - 18),
        fontSize: 10,
        color: accent,
      );
    }
    if (session.rawTaps >= 3000 && director.message.isEmpty) {
      label(
        canvas,
        session.remaining < .6
            ? 'THAT WAS CLOSE. KEEP TAPPING!'
            : session.tapRate > 6
            ? 'FINGER OVERTIME APPROVED.'
            : 'YOU CAN STOP. PROBABLY.',
        Offset(size.x / 2, size.y - 17),
        fontSize: 10,
        color: accent,
      );
    }
    if (session.rawTaps >= 6000) {
      for (var i = 0; i < 12; i++) {
        final height = reduced
            ? 7.0
            : 5 + (sin(t * max(1, session.tapRate) + i) + 1) * 6;
        ink
          ..style = PaintingStyle.fill
          ..color = accent.withValues(alpha: .3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.x / 2 - 46 + i * 8,
              size.y - 38 - height,
              4,
              height,
            ),
            const Radius.circular(2),
          ),
          ink,
        );
      }
      if (session.steadyBeat) {
        label(
          canvas,
          'PERFECT GROOVE',
          Offset(size.x / 2, size.y - 68),
          fontSize: 10,
          color: accent,
        );
      }
    }
    canvas.restore();
  }

  void _drawAtmosphere(Canvas c, Rect bounds, double t) {
    final center = Offset(size.x * .5, size.y * .52);
    ink
      ..style = PaintingStyle.fill
      ..shader = Gradient.radial(
        center,
        size.y * .9,
        const [Color(0xff103d83), Color(0xff111443), Color(0xff050a24)],
        [.0, .47, 1],
      );
    c.drawRect(bounds, ink);
    ink.shader = null;
    final art = _background;
    if (art != null) {
      final scale = max(bounds.width / art.width, bounds.height / art.height);
      final source = Rect.fromCenter(
        center: Offset(art.width / 2, art.height / 2),
        width: bounds.width / scale,
        height: bounds.height / scale,
      );
      c.drawImageRect(
        art,
        source,
        bounds,
        Paint()..color = const Color(0xddffffff),
      );
      c.drawRect(bounds, Paint()..color = const Color(0x28050a24));
    }
    if (session.rawTaps >= 100 || session.mode == GameMode.campaign) {
      final index = session.mode == GameMode.campaign
          ? session.stage ~/ 5
          : (session.paletteIndex +
                    session.worldIndex +
                    (session.rawTaps >= 40000 ? session.tapRate.floor() : 0)) %
                worldDefinitions.length;
      ink.color = worldDefinitions[index.clamp(0, 9)].color.withValues(
        alpha: .20,
      );
      c.drawRect(bounds, ink);
    }
    // Long irregular electric filaments bring blue/purple depth behind the UI.
    for (var i = 0; i < 28; i++) {
      final angle = i * 2.39996;
      final unit = Offset(cos(angle), sin(angle));
      final distance = 60 + (i * 43) % 170;
      final start = center + unit * distance.toDouble();
      final end = center + unit * (distance + 100 + i % 4 * 27).toDouble();
      ink
        ..strokeWidth = i % 5 == 0 ? 1.3 : .65
        ..color = (i % 3 == 0 ? magenta : cyan).withValues(
          alpha: art == null ? .16 : .10,
        );
      c.drawLine(start, end, ink);
    }
    for (var i = 0; i < 44; i++) {
      final p = Offset(
        (i * 97.0 + 19) % size.x,
        (i * 151.0 + t * (2 + i % 3)) % size.y,
      );
      ink.color = (i % 4 == 0 ? magenta : cyan).withValues(
        alpha: .18 + (i % 3) * .08,
      );
      c.drawCircle(p, i % 5 == 0 ? 1.6 : .75, ink);
    }
  }

  void _drawZones(Canvas c) {
    final zones = session.zones;
    final next = zones.next;
    final previous = zones.previous;
    if (previous != null && zones.graceRemaining > 0) {
      _zone(
        c,
        previous,
        cyan,
        opacity: (zones.graceRemaining / max(.001, zones.handoffDuration)) * .5,
      );
    }
    if (next != null) {
      final count = zones.previewTapsRemaining;
      label(
        c,
        count == 0
            ? 'NEXT AREA READY'
            : 'NEXT TAP AREA\nIN $count ${count == 1 ? 'TAP' : 'TAPS'}',
        Offset(size.x / 2, 36),
        fontSize: 30,
        color: const Color(0xffffccff),
      );
      _zone(c, next, magenta, dashed: true);
      label(
        c,
        'NEXT AREA',
        next.center,
        fontSize: 16,
        color: const Color(0xffffb7ff),
        maxWidth: next.width - 12,
      );
      final from = zones.active.center;
      final to = next.center;
      final delta = to - from;
      final direction = delta / max(1, delta.distance);
      final gapStart = from + direction * (zones.active.height / 2 + 22);
      final gapEnd = to - direction * (next.height / 2 + 17);
      if ((gapEnd - gapStart).distance > 12 &&
          (gapEnd - gapStart).dx * direction.dx +
                  (gapEnd - gapStart).dy * direction.dy >
              0) {
        ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xfffb80c6);
        c.drawLine(gapStart, gapEnd, ink);
        final normal = Offset(-direction.dy, direction.dx);
        c.drawLine(gapEnd, gapEnd - direction * 9 + normal * 5, ink);
        c.drawLine(gapEnd, gapEnd - direction * 9 - normal * 5, ink);
      }
    }
    final activation = (1 - zones.activationAge / .18).clamp(0.0, 1.0);
    // Hold the vivid magenta activation for 120ms, then settle into cyan.
    final magentaWeight = ((.18 - zones.activationAge) / .06).clamp(0.0, 1.0);
    final activeColor = Color.lerp(cyan, magenta, magentaWeight)!;
    _zone(c, zones.active, activeColor, activation: activation);
    final above = zones.active.top - 22;
    label(
      c,
      next == null ? 'TAP HERE!' : 'CURRENT AREA',
      Offset(zones.active.center.dx, max(next == null ? 24 : 86, above)),
      fontSize: next == null ? 28 : 22,
      color: next == null ? const Color(0xfff9e4ff) : const Color(0xff7ffff2),
    );
    if (activation > 0) {
      final metric = (Path()..addRRect(zones.active)).computeMetrics().first;
      for (var i = 0; i < 28; i++) {
        final tangent = metric.getTangentForOffset(metric.length * i / 28)!;
        final p = tangent.position;
        final direction = Offset(tangent.vector.dy, -tangent.vector.dx);
        // Keep the title above the rectangle free of decorative sparks.
        if (p.dy < zones.active.top + 2 &&
            (p.dx - zones.active.center.dx).abs() < zones.active.width * .35) {
          continue;
        }
        ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = i % 3 == 0 ? 2.8 : 1.8
          ..color = (i % 4 == 0 ? cyan : magenta).withValues(
            alpha: min(1, activation * 1.6),
          );
        c.drawLine(p + direction * 7, p + direction * (15 + i % 4 * 4), ink);
      }
    }
  }

  void _zone(
    Canvas c,
    RRect zone,
    Color color, {
    bool dashed = false,
    double opacity = 1,
    double activation = 0,
  }) {
    ink
      ..shader = null
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: (dashed ? .08 : .075) * opacity);
    c.drawRRect(zone, ink);
    if (activation > 0) {
      ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..color = magenta.withValues(
          alpha: .8 * opacity * min(1, activation * 2.4),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      c.drawRRect(zone, ink);
      ink
        ..strokeWidth = 6
        ..color = magenta.withValues(
          alpha: .9 * opacity * min(1, activation * 2.4),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      c.drawRRect(zone, ink);
      ink.maskFilter = null;
    }
    ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = dashed
          ? 2
          : activation > 0
          ? 4
          : 2.8
      ..color = color.withValues(alpha: .45 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 + activation * 3);
    c.drawRRect(zone, ink);
    ink
      ..maskFilter = null
      ..color = color.withValues(alpha: opacity);
    if (dashed) {
      final path = Path()..addRRect(zone);
      for (final metric in path.computeMetrics()) {
        for (double start = 0; start < metric.length; start += 17) {
          c.drawPath(
            metric.extractPath(start, min(start + 10, metric.length)),
            ink,
          );
        }
      }
    } else {
      c.drawRRect(zone, ink);
      ink
        ..strokeWidth = .8
        ..color = const Color(0xffeeffff).withValues(alpha: opacity * .8);
      c.drawRRect(zone, ink);
    }
    ink.style = PaintingStyle.fill;
  }

  void _drawMilestoneAtmosphere(Canvas c, Rect bounds, double t) {
    if (session.active(100, 3) || director.colorPulse || director.inverted) {
      ink
        ..style = PaintingStyle.fill
        ..color = (director.inverted ? magenta : accent).withValues(
          alpha: colorPulseOpacity(t),
        );
      c.drawRect(bounds, ink);
    }
    if (director.wormhole || director.god) {
      ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent.withValues(alpha: .09);
      for (var i = 0; i < 9; i++) {
        c.drawOval(
          Rect.fromCenter(
            center: Offset(size.x / 2, size.y * .55),
            width: 30 + i * 35,
            height: 20 + i * 27 + (reduced ? 0 : sin(t + i) * 5),
          ),
          ink,
        );
      }
    }
    if (director.meltdown) {
      ink
        ..style = PaintingStyle.fill
        ..color = accent.withValues(alpha: .05);
      for (double y = 0; y < size.y; y += 9) {
        c.drawRect(Rect.fromLTWH(0, y, size.x, 1), ink);
      }
    }
    if (director.hyper && !reduced) {
      ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(
          alpha: smooth ? .16 : .16 + .025 * sin(t * 2),
        );
      c.drawRect(bounds.deflate(2), ink);
    }
    ink.style = PaintingStyle.fill;
  }
}
