import 'package:flutter/material.dart';
import '../widgets/arcade_widgets.dart';

class ChaosIntroScreen extends StatelessWidget {
  const ChaosIntroScreen({
    super.key,
    required this.onStart,
    required this.onBack,
  });
  final VoidCallback onStart, onBack;
  @override
  Widget build(BuildContext context) => ArcadeBackground(
    asset: 'assets/art/backgrounds/gameplay.png',
    artOpacity: .3,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: FittedBox(
                        child: BeveledTitle(
                          text: 'CHAOS RUN',
                          fontSize: 48,
                          colors: [
                            Color(0xffffff92),
                            Color(0xffffcf32),
                            Color(0xffff9000),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(-23, -12),
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: onBack,
                          icon: const Icon(Icons.chevron_left, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: constraints.maxHeight < 800 ? 280 : 310,
                  width: double.infinity,
                  child: const ExcludeSemantics(
                    child: CustomPaint(painter: _ChaosZoneArtwork()),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Survive\nthe madness...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    color: Color(0xffffb4ff),
                    shadows: [
                      Shadow(color: ArcadeColors.magenta, blurRadius: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 245,
                  child: Column(
                    children: [
                      for (final text in const [
                        'Shifting touch zones',
                        'Ghost taps',
                        'Random events',
                        'Increasing difficulty',
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: ArcadeColors.cyan,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: ArcadeColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ArcadeButton(
                  label: 'START CHAOS',
                  onPressed: onStart,
                  style: ArcadeButtonStyle.primary,
                  height: 62,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Decorative, static touch zones echo the mode's fixed target geometry.
class _ChaosZoneArtwork extends CustomPainter {
  const _ChaosZoneArtwork();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = (size.width / 342).clamp(0.0, 1.0);
    canvas.scale(scale);
    final paint = Paint();
    const glowBounds = Rect.fromLTWH(-160, -140, 320, 280);
    paint.shader = const RadialGradient(
      colors: [Color(0x507938f2), Color(0x1600d9ff), Colors.transparent],
      stops: [0, .5, 1],
    ).createShader(glowBounds);
    canvas.drawOval(glowBounds, paint);
    paint.shader = null;

    // A quiet orbital frame and sparks keep the original arcade atmosphere.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ArcadeColors.violet.withValues(alpha: .4);
    canvas.drawCircle(Offset.zero, 117, paint);
    canvas.drawCircle(Offset.zero, 128, paint);
    for (final (point, color) in const [
      (Offset(-135, -69), ArcadeColors.cyan),
      (Offset(129, 54), ArcadeColors.magenta),
      (Offset(-78, 108), ArcadeColors.yellow),
      (Offset(56, -119), ArcadeColors.cyan),
    ]) {
      paint
        ..strokeWidth = 2
        ..color = color;
      canvas.drawLine(
        point - const Offset(5, 0),
        point + const Offset(5, 0),
        paint,
      );
      canvas.drawLine(
        point - const Offset(0, 5),
        point + const Offset(0, 5),
        paint,
      );
    }

    for (final (rect, color) in const [
      (Rect.fromLTWH(0, -91, 118, 98), ArcadeColors.magenta),
      (Rect.fromLTWH(-117, -30, 172, 125), ArcadeColors.cyan),
    ]) {
      final zone = RRect.fromRectAndRadius(rect, const Radius.circular(22));
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xff081b42);
      canvas.drawRRect(zone, paint);
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = color.withValues(alpha: .18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(zone, paint);
      paint
        ..maskFilter = null
        ..strokeWidth = 2
        ..color = color;
      canvas.drawRRect(zone, paint);
      paint
        ..strokeWidth = 1
        ..color = color.withValues(alpha: .22);
      canvas.drawRRect(zone.deflate(7), paint);
    }

    // A bright bolt is the mode emblem, with no character or encounter implied.
    final bolt = Path()
      ..moveTo(-24, 0)
      ..lineTo(-59, 40)
      ..lineTo(-34, 40)
      ..lineTo(-43, 67)
      ..lineTo(-5, 24)
      ..lineTo(-31, 24)
      ..close();
    paint
      ..style = PaintingStyle.fill
      ..color = ArcadeColors.yellow;
    canvas.drawPath(bolt, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChaosZoneArtwork oldDelegate) => false;
}
