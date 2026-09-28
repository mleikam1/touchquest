import 'package:flutter/material.dart';
import '../../game/core/game_session.dart';
import '../widgets/arcade_widgets.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.session,
    required this.onRetry,
    required this.onMenu,
    required this.onRevive,
    this.onShare,
    this.rewardReady = false,
    this.busy = false,
    this.rewardMessage = '',
    this.preview = false,
  });
  final GameSession session;
  final VoidCallback onRetry, onMenu;
  final VoidCallback? onRevive, onShare;
  final bool rewardReady, busy, preview;
  final String rewardMessage;
  @override
  Widget build(BuildContext context) {
    final won = session.state == RunState.won;
    final seconds = session.duration.floor();
    final stats = [
      ('RAW TAPS', formatNumber(session.rawTaps)),
      ('SCORE', formatNumber(session.score)),
      ('TIME SURVIVED', '${seconds ~/ 60}m ${seconds % 60}s'),
      ('HIGHEST MILESTONE', formatNumber(session.highest)),
      ('AVERAGE TAPS / SEC', session.tapRate.toStringAsFixed(1)),
      ('REVIVES USED', '${session.reviveCount}'),
    ];
    return ArcadeBackground(
      asset: 'assets/art/backgrounds/gameover.png',
      crimson: true,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 48, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 146,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Transform.rotate(
                        angle: -.06,
                        child: BeveledTitle(
                          text: won ? 'STAGE\nCLEARED' : 'GAME\nOVER',
                          fontSize: 84,
                          colors: const [
                            Color(0xffffff91),
                            Color(0xffffb958),
                            Color(0xffff4167),
                          ],
                          stroke: const Color(0xffffd685),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  NeonPanel(
                    color: const Color(0xdd210620),
                    borderColor: const Color(0xffb84085),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        for (final row in stats)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    row.$1,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  row.$2,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeonPanel(
                    color: const Color(0xcc210d32),
                    borderColor: const Color(0xff624382),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Text(
                      won
                          ? '“Quest cleared. Finger promoted!”'
                          : session.rawTaps == 0
                          ? '“Every quest starts with one tap.”'
                          : session.rawTaps >= 1000
                          ? '“That was legendary!\nYour finger earned a breather.”'
                          : session.reason,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (!won && session.reviveCount == 0) ...[
                    ArcadeButton(
                      label: busy ? 'LOADING REWARD…' : 'WATCH AD TO REVIVE',
                      icon: Icons.ondemand_video,
                      style: ArcadeButtonStyle.green,
                      onPressed: rewardReady && !busy ? onRevive : null,
                      height: 57,
                    ),
                    if (!rewardReady || rewardMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          rewardMessage.isNotEmpty
                              ? rewardMessage
                              : 'Rewarded ads unavailable on this device',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ArcadeColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 13),
                  ],
                  ArcadeButton(
                    label: won && session.stage < 49
                        ? 'NEXT STAGE'
                        : 'TRY AGAIN',
                    style: ArcadeButtonStyle.blue,
                    onPressed: busy ? null : onRetry,
                    height: 56,
                  ),
                  const SizedBox(height: 14),
                  ArcadeButton(
                    label: 'MAIN MENU',
                    onPressed: busy ? null : onMenu,
                    height: 54,
                  ),
                  if (session.reviveCount > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'REVIVED RUN · UNRANKED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: ArcadeColors.muted,
                        ),
                      ),
                    ),
                  if (onShare != null && !preview)
                    TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share, size: 15),
                      label: const Text('Share your quest'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
