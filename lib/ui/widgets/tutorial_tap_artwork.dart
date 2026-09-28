import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'arcade_widgets.dart';

/// Decorative onboarding art only. Every gameplay input stays in the arena.
class TutorialTapArtwork extends StatelessWidget {
  const TutorialTapArtwork({super.key, this.size = 300, this.reduced = false});
  final double size;
  final bool reduced;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _TapIllustration(reduced)),
          ),
          Positioned(
            left: size * .40,
            top: size * .41,
            width: size * .50,
            height: size * .58,
            child: Image.asset(
              'assets/art/characters/tutorial_hand.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TapIllustration extends CustomPainter {
  _TapIllustration(this.reduced);
  final bool reduced;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Offset(size.width * .46, size.height * .46), ink = Paint();
    for (var i = 3; i >= 0; i--) {
      final radius = size.width * (.08 + i * .055);
      ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 5 : 2.5
        ..color = (i.isEven ? ArcadeColors.cyan : ArcadeColors.magenta);
      canvas.drawCircle(
        p,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..color = ink.color.withValues(alpha: .48)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(p, radius, ink);
    }
    final random = math.Random(72);
    for (var i = 0; i < (reduced ? 12 : 64); i++) {
      final angle = random.nextDouble() * math.pi * 2,
          radius = size.width * (.22 + random.nextDouble() * .23);
      final start = p + Offset(math.cos(angle), math.sin(angle)) * radius;
      final end =
          start +
          Offset(math.cos(angle), math.sin(angle)) *
              (3 + random.nextDouble() * 10);
      final color = [
        ArcadeColors.cyan,
        ArcadeColors.magenta,
        ArcadeColors.yellow,
        const Color(0xffff683f),
      ][i % 4];
      ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + random.nextDouble() * 1.5
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawLine(start, end, ink);
    }
    ink
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: .9),
          ArcadeColors.magenta.withValues(alpha: .4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p, radius: 18));
    canvas.drawCircle(p, 18, ink);
  }

  @override
  bool shouldRepaint(_TapIllustration oldDelegate) =>
      oldDelegate.reduced != reduced;
}
