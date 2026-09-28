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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        left: 0,
                        top: 150,
                        child: Icon(
                          Icons.star_border_rounded,
                          size: 50,
                          color: ArcadeColors.magenta,
                          shadows: [
                            Shadow(color: ArcadeColors.magenta, blurRadius: 22),
                          ],
                        ),
                      ),
                      const Positioned(
                        right: 8,
                        bottom: 0,
                        child: Icon(
                          Icons.hexagon_outlined,
                          size: 28,
                          color: Color(0xffff557c),
                        ),
                      ),
                      const Positioned(
                        left: 22,
                        top: 28,
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 26,
                          color: ArcadeColors.cyan,
                        ),
                      ),
                      Positioned(
                        left: 75,
                        bottom: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                ArcadeColors.yellow,
                                ArcadeColors.magenta,
                                Colors.transparent,
                              ],
                              stops: [0, .06, .20, 1],
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: ArcadeColors.yellow,
                            size: 30,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -.13,
                        child: Image.asset(
                          'assets/art/characters/chaos_hand.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
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
                        'Boss hand',
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
