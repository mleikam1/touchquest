import 'package:flutter/material.dart';
import '../../game/core/game_session.dart';
import '../widgets/arcade_widgets.dart';

class GameplayHud extends StatelessWidget {
  const GameplayHud({
    super.key,
    required this.session,
    required this.best,
    required this.onPause,
  });
  final GameSession session;
  final int best;
  final VoidCallback onPause;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('gameplay-hud'),
    padding: const EdgeInsets.fromLTRB(22, 22, 18, 12),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff142762), Color(0xff08345f), Color(0xff061832)],
      ),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCORE',
                    style: ArcadeTypography.display.copyWith(fontSize: 18),
                  ),
                  Text(
                    formatNumber(session.score),
                    style: ArcadeTypography.display.copyWith(
                      fontSize: 39,
                      height: 1,
                      shadows: const [
                        Shadow(color: Color(0xff428aff), blurRadius: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  'BEST',
                  style: ArcadeTypography.display.copyWith(fontSize: 16),
                ),
                Text(
                  formatNumber(best),
                  style: ArcadeTypography.display.copyWith(
                    fontSize: 25,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 34),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffb5d5ff)),
              ),
              child: IconButton(
                tooltip: 'Pause',
                onPressed: onPause,
                icon: const Icon(Icons.pause_rounded, size: 25),
                constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Semantics(
          label: 'Time remaining',
          value: '${session.remaining.toStringAsFixed(1)} seconds',
          child: Container(
            height: (MediaQuery.textScalerOf(context).scale(18) + 10).clamp(
              30.0,
              100.0,
            ),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xff01091f),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xff688ada), width: 1.2),
              boxShadow: const [
                BoxShadow(color: Color(0x6600d9ff), blurRadius: 4),
              ],
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: (session.remaining / 1.5).clamp(0, 1),
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: session.remaining < .4
                            ? const [Color(0xffff8c1b), Color(0xffff376f)]
                            : const [Color(0xff00ef84), Color(0xff54ffc4)],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0xff00dfa5), blurRadius: 9),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${session.remaining.toStringAsFixed(1)}s',
                    style: ArcadeTypography.display.copyWith(
                      fontSize: 18,
                      height: 1,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key, required this.session});
  final GameSession session;
  @override
  Widget build(BuildContext context) {
    final upcoming = milestones.keys
        .where((n) => n > session.rawTaps)
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: NeonPanel(
        borderColor: const Color(0xffa7afdf),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ArcadeColors.yellow, width: 1.4),
              ),
              child: Icon(
                upcoming == null ? Icons.workspace_premium : Icons.auto_awesome,
                color: ArcadeColors.yellow,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upcoming == null
                        ? '100,000 taps reached!'
                        : 'Next: ${formatNumber(upcoming)} taps',
                    style: const TextStyle(
                      fontSize: 14,
                      color: ArcadeColors.muted,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    upcoming == null
                        ? 'Tap God ascended'
                        : milestones[upcoming]!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: upcoming == null ? 1 : session.rawTaps / upcoming,
                    minHeight: 2,
                    color: ArcadeColors.yellow,
                    backgroundColor: ArcadeColors.panelHighlight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
