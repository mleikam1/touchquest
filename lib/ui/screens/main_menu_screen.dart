import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/arcade_widgets.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.onPlay,
    required this.onNavigate,
    this.glow = 0,
  });
  final VoidCallback onPlay;
  final ValueChanged<String> onNavigate;
  final double glow;
  @override
  Widget build(BuildContext context) => ArcadeBackground(
    asset: 'assets/art/backgrounds/menu.png',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < 760;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(26, short ? 34 : 48, 26, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: math.min(constraints.maxWidth - 52, 330),
                    height: short ? 169 : 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: ArcadeColors.cyan.withValues(
                              alpha: .025 + glow * .014,
                            ),
                            blurRadius: 80,
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scaleX: 1.06,
                        scaleY: .88,
                        child: const ArcadeLogo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'TAP. SURVIVE. ASCEND.',
                    style: ArcadeTypography.display.copyWith(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      shadows: const [
                        Shadow(color: Color(0xff1baeff), blurRadius: 13),
                      ],
                    ),
                  ),
                  SizedBox(height: short ? 22 : 28),
                  SizedBox(
                    width: 278,
                    child: ArcadeButton(
                      label: 'PLAY',
                      onPressed: onPlay,
                      style: ArcadeButtonStyle.primary,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final item in const [
                    ('CAMPAIGN', 'campaign'),
                    ('CHAOS RUN', 'chaos'),
                    ('LEADERBOARD', 'leaderboard'),
                    ('PROFILE', 'profile'),
                    ('SETTINGS', 'settings'),
                  ]) ...[
                    SizedBox(
                      width: 244,
                      child: ArcadeButton(
                        label: item.$1,
                        onPressed: () => onNavigate(item.$2),
                        height: 48,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 12, color: ArcadeColors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final item in const [
                        (
                          'Achievements',
                          'achievements',
                          Icons.emoji_events_outlined,
                        ),
                        ('Skins', 'skins', Icons.workspace_premium_outlined),
                        ('Profile', 'profile', Icons.person_outline),
                        ('Settings', 'settings', Icons.settings),
                      ])
                        Tooltip(
                          message: item.$1,
                          child: Semantics(
                            label: item.$1,
                            button: true,
                            child: NeonPanel(
                              padding: EdgeInsets.zero,
                              radius: 12,
                              borderColor: const Color(0xff789cc8),
                              child: IconButton(
                                onPressed: () => onNavigate(item.$2),
                                icon: Icon(
                                  item.$3,
                                  size: 28,
                                  color: item.$2 == 'achievements'
                                      ? const Color(0xffffe5a3)
                                      : ArcadeColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
