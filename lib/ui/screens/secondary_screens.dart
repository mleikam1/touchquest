import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../game/core/game_session.dart';
import '../../services/ad_service.dart';
import '../../services/feedback_service.dart';
import '../../services/firebase_service.dart';
import '../../services/save_service.dart';
import '../widgets/arcade_widgets.dart';
import 'legal_copy.dart';

const _body = TextStyle(
  fontFamily: 'Rajdhani',
  fontWeight: FontWeight.w600,
  color: ArcadeColors.white,
  fontSize: 18,
);
const _heading = TextStyle(
  fontFamily: 'BarlowCondensed',
  fontWeight: FontWeight.w800,
  color: ArcadeColors.white,
  fontSize: 22,
);
const _cyan = ArcadeColors.cyan;
const _muted = ArcadeColors.muted;

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({
    super.key,
    required this.save,
    required this.onNavigate,
    required this.onStart,
  });
  final SaveService save;
  final ValueChanged<String> onNavigate;
  final void Function(GameMode, int) onStart;
  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  int? selectedWorld;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.save,
    builder: (context, _) => Column(
      children: [
        ArcadeHeader(
          title: selectedWorld == null
              ? 'CAMPAIGN'
              : worlds[selectedWorld!].toUpperCase(),
          onBack: () {
            if (selectedWorld != null) {
              setState(() => selectedWorld = null);
            } else {
              widget.onNavigate('menu');
            }
          },
        ),
        Expanded(
          child: selectedWorld == null ? _worlds() : _stages(selectedWorld!),
        ),
        ArcadeBottomNav(selected: 'campaign', onNavigate: widget.onNavigate),
      ],
    ),
  );

  Widget _worlds() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
    itemCount: worlds.length,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final done = (widget.save.number('campaign') - index * 5).clamp(0, 5);
      final cardHeight =
          123.0 *
          math.max(1.0, MediaQuery.textScalerOf(context).scale(19) / 19);
      final unlocked = widget.save.number('campaign') >= index * 5;
      return Semantics(
        button: true,
        label:
            '${worlds[index]}, ${unlocked ? '$done of 5 stages cleared' : 'locked'}',
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => setState(() => selectedWorld = index),
          child: NeonPanel(
            padding: EdgeInsets.zero,
            borderColor: unlocked ? _cyan : const Color(0xff245078),
            child: SizedBox(
              height: cardHeight,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(11),
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        unlocked
                            ? Colors.transparent
                            : const Color(0xff041629).withValues(alpha: .3),
                        BlendMode.srcATop,
                      ),
                      child: _WorldArt(index: index, width: 108, height: 108),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 13, 12, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${index + 1}. ${worlds[index]}',
                            style: _body.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 11),
                          if (unlocked)
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: done / 5,
                                    minHeight: 21,
                                    backgroundColor: const Color(0xff020b22),
                                    color: _cyan.withValues(alpha: .5),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '$done/5',
                                    style: _body.copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 19,
                                  color: _muted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Locked',
                                  style: _body.copyWith(
                                    color: _muted,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _stages(int world) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _WorldArt(index: world, height: 190),
      ),
      const SizedBox(height: 22),
      Text('FIVE STAGES. ONE NEW WORLD.', style: _heading),
      const SizedBox(height: 6),
      Text(
        'Keep tapping inside the current area. Watch the dashed preview before each switch.',
        style: _body.copyWith(color: _muted, fontSize: 17),
      ),
      const SizedBox(height: 18),
      for (var local = 0; local < 5; local++) ...[
        Builder(
          builder: (context) {
            final stage = world * 5 + local;
            final unlocked = stage <= widget.save.number('campaign');
            final done = stage < widget.save.number('campaign');
            return ArcadeButton(
              label: 'STAGE ${stage + 1}  ·  ${25 + stage * 5} TAPS',
              icon: done
                  ? Icons.check_circle_outline
                  : unlocked
                  ? Icons.play_arrow_rounded
                  : Icons.lock_outline,
              style: done
                  ? ArcadeButtonStyle.green
                  : ArcadeButtonStyle.secondary,
              onPressed: unlocked
                  ? () => widget.onStart(GameMode.campaign, stage)
                  : null,
            );
          },
        ),
        const SizedBox(height: 12),
      ],
      if (widget.save.number('campaign') < world * 5)
        Text(
          'Clear the previous world to unlock these stages.',
          style: _body.copyWith(color: _muted),
        ),
    ],
  );
}

class _WorldArt extends StatelessWidget {
  const _WorldArt({required this.index, this.width, required this.height});
  final int index;
  final double? width;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: LayoutBuilder(
      builder: (context, bounds) {
        final tileWidth = math.max(bounds.maxWidth, height);
        return ClipRect(
          child: OverflowBox(
            maxWidth: tileWidth * 5,
            maxHeight: height * 2,
            alignment: Alignment(-1 + (index % 5) / 2, -1 + (index ~/ 5) * 2.0),
            child: Image.asset(
              'assets/art/worlds/world_atlas.png',
              width: tileWidth * 5,
              height: height * 2,
              fit: BoxFit.fill,
              errorBuilder: (_, _, _) => CustomPaint(
                size: Size(tileWidth * 5, height * 2),
                painter: _WorldFallbackPainter(index),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _WorldFallbackPainter extends CustomPainter {
  _WorldFallbackPainter(this.index);
  final int index;
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.pinkAccent,
      Colors.blueGrey,
      Colors.cyan,
      Colors.deepPurpleAccent,
      Colors.deepOrange,
      Colors.teal,
      Colors.pinkAccent,
      Colors.purple,
      Colors.green,
      Colors.amber,
    ];
    final accent = colors[index % colors.length];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: .3), const Color(0xff03081c)],
        ).createShader(Offset.zero & size),
    );
    final random = math.Random(index + 42);
    for (var i = 0; i < 17; i++) {
      final x = random.nextDouble() * size.width;
      final h = size.height * (.15 + random.nextDouble() * .5);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - h, size.width * .12, h),
        Paint()..color = accent.withValues(alpha: .22),
      );
      canvas.drawLine(
        Offset(x, size.height - h),
        Offset(x, size.height),
        Paint()
          ..color = accent
          ..strokeWidth = 1,
      );
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height * .25),
      size.shortestSide * .12,
      Paint()
        ..color = accent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_WorldFallbackPainter oldDelegate) =>
      oldDelegate.index != index;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.save,
    required this.cloud,
    required this.onNavigate,
    this.fixture = false,
  });
  final SaveService save;
  final FirebaseService cloud;
  final ValueChanged<String> onNavigate;
  final bool fixture;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: save,
    builder: (context, _) {
      final title = save.badges.contains(100000)
          ? 'Tap God'
          : save.badges.contains(1000)
          ? 'Ascended Tapper'
          : 'Rookie Tapper';
      return Column(
        children: [
          ArcadeHeader(
            title: 'MY PROFILE',
            onBack: () => onNavigate('menu'),
            trailing: IconButton(
              tooltip: 'Account',
              icon: const Icon(Icons.more_vert, color: ArcadeColors.white),
              onPressed: () => onNavigate('account'),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              children: [
                Row(
                  children: [
                    NeonPanel(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Transform.scale(
                          scale: 1.2,
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/art/characters/robot.png',
                            width: 106,
                            height: 106,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cloud.name,
                            style: _body.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            title,
                            style: _body.copyWith(color: _cyan, fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(50, 48),
                        side: const BorderSide(color: Color(0xff25618a)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      onPressed: () => _editName(context),
                      child: Text(
                        'EDIT',
                        style: _heading.copyWith(fontSize: 17, color: _cyan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        'LIFETIME TAPS',
                        formatNumber(save.number('lifetimeTaps')),
                        bright: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        'BEST RUN',
                        formatNumber(save.number('bestRawRun')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        'ACHIEVEMENTS',
                        '${save.badges.where(milestones.containsKey).length}/${milestones.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        'WORLDS CLEARED',
                        '${(save.number('campaign') ~/ 5).clamp(0, worlds.length)}/${worlds.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  'BADGES',
                  onMore: () => onNavigate('achievements'),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    for (final n in [1000, 10000, 100000]) ...[
                      Expanded(
                        child: BadgeTile(
                          threshold: n,
                          unlocked: save.badges.contains(n),
                          onTap: () => showBadgeDetails(context, n, save),
                        ),
                      ),
                      if (n != 100000) const SizedBox(width: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 43),
                _SectionLabel(
                  'SKINS & EFFECTS',
                  onMore: () => onNavigate('skins'),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    for (var i = 0; i < cosmetics.length; i++) ...[
                      Expanded(
                        child: EffectTile(
                          effect: cosmetics[i],
                          selected:
                              save.choice('skin', 'cyan') == cosmetics[i].id,
                          onTap: () =>
                              showEffectDetails(context, cosmetics[i], save),
                        ),
                      ),
                      if (i < cosmetics.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                ),
                if (!(fixture && !kReleaseMode)) ...[
                  const SizedBox(height: 20),
                  Text(
                    cloud.status,
                    style: _body.copyWith(fontSize: 13, color: _muted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          ArcadeBottomNav(
            selected: 'profile',
            onNavigate: onNavigate,
            destinations: const ['home', 'profile', 'settings'],
          ),
        ],
      );
    },
  );

  Future<void> _editName(BuildContext context) async {
    var editedName = cloud.name;
    String? error;
    bool busy = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => _QuestDialog(
          title: 'EDIT PROFILE',
          children: [
            TextFormField(
              initialValue: editedName,
              onChanged: (value) => editedName = value,
              maxLength: 24,
              autofocus: true,
              style: _body,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Player name',
                errorText: error,
                counterStyle: _body.copyWith(color: _muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
            ArcadeButton(
              label: busy ? 'SAVING…' : 'SAVE NAME',
              style: ArcadeButtonStyle.blue,
              onPressed: busy
                  ? null
                  : () async {
                      final name = editedName.trim();
                      if (name.isEmpty) {
                        setDialogState(() => error = 'Enter a player name.');
                        return;
                      }
                      setDialogState(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        if (fixture && !kReleaseMode) {
                          await save.set('displayName', name);
                        } else {
                          await cloud.updateDisplayName(name);
                        }
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (_) {
                        if (context.mounted) {
                          setDialogState(() {
                            error = 'Saved locally. Cloud sync is unavailable.';
                            busy = false;
                          });
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, {this.bright = false});
  final String label, value;
  final bool bright;
  @override
  Widget build(BuildContext context) => NeonPanel(
    padding: const EdgeInsets.fromLTRB(13, 16, 10, 16),
    borderColor: const Color(0xff245078),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _body.copyWith(color: _muted, fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          value,
          style: _heading.copyWith(
            color: bright ? const Color(0xff26fdd8) : ArcadeColors.white,
            fontSize: 28,
            height: 1.05,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {this.onMore});
  final String title;
  final VoidCallback? onMore;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: _heading)),
      if (onMore != null)
        SizedBox(
          height: 28,
          child: TextButton(
            onPressed: onMore,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(
              'VIEW ALL',
              style: _body.copyWith(fontSize: 12, color: _cyan),
            ),
          ),
        ),
    ],
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.save,
    required this.cloud,
    required this.audio,
    required this.ads,
    required this.onNavigate,
  });
  final SaveService save;
  final FirebaseService cloud;
  final FeedbackService audio;
  final AdService ads;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: save,
    builder: (context, _) => Column(
      children: [
        ArcadeHeader(title: 'SETTINGS', onBack: () => onNavigate('menu')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              _SettingsGroup(
                children: [
                  _volume('Music', 'musicVolume', 'music', .12),
                  _volume('Sound Effects', 'sfxVolume', 'sfx', .35),
                  _toggle(
                    'Haptics',
                    'haptics',
                    onChange: (value) {
                      if (!value) {
                        audio.haptics.cancel();
                      } else {
                        audio.haptic();
                      }
                    },
                  ),
                  _choice(
                    context,
                    'Haptic Intensity',
                    'intensity',
                    ['low', 'normal', 'high'],
                    'normal',
                    onChanged: () => audio.haptic(strong: true),
                  ),
                  _toggle('Reduce Motion', 'reduceMotion', fallback: false),
                  _toggle('Reduce Flashing', 'reduceFlashing'),
                  _choice(context, 'Effects Quality', 'quality', [
                    'auto',
                    'low',
                    'high',
                  ], 'auto'),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    label: 'Account',
                    onTap: () => onNavigate('account'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: ArcadeColors.white,
                      size: 22,
                    ),
                  ),
                  _SettingsRow(
                    label: 'Notifications',
                    trailing: Text(
                      'Coming Soon',
                      style: _body.copyWith(fontSize: 15, color: _muted),
                    ),
                  ),
                  _SettingsRow(
                    label: 'Privacy Policy',
                    onTap: () => onNavigate('privacy'),
                  ),
                  _SettingsRow(
                    label: 'Terms of Service',
                    onTap: () => onNavigate('terms'),
                  ),
                  _SettingsRow(
                    label: 'App Version',
                    trailing: Text(
                      '1.0.0',
                      style: _body.copyWith(fontSize: 16, color: _muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ArcadeBottomNav(
          selected: 'settings',
          onNavigate: onNavigate,
          destinations: const ['home', 'settings'],
        ),
      ],
    ),
  );

  Widget _volume(String title, String key, String flag, double fallback) =>
      _SettingsRow(
        label: title,
        trailing: SizedBox(
          width: 145,
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: _cyan,
              inactiveTrackColor: Color(0xff030d25),
              thumbColor: _cyan,
            ),
            child: Slider(
              label: '${(save.volume(key, fallback) * 100).round()}%',
              value: save.flag(flag) ? save.volume(key, fallback) : 0,
              onChanged: (value) {
                unawaited(save.set(flag, value > 0));
                unawaited(audio.updateVolume(key, value));
              },
              onChangeEnd: (_) {
                if (key == 'sfxVolume') audio.sound('menu');
              },
            ),
          ),
        ),
      );
  Widget _toggle(
    String title,
    String key, {
    bool fallback = true,
    ValueChanged<bool>? onChange,
  }) => _SettingsRow(
    label: title,
    trailing: SizedBox(
      height: 40,
      child: Switch(
        value: save.flag(key, fallback),
        activeThumbColor: Colors.white,
        activeTrackColor: ArcadeColors.green,
        inactiveThumbColor: const Color(0xffdde9ff),
        inactiveTrackColor: const Color(0xff345276),
        onChanged: (value) {
          unawaited(save.set(key, value));
          onChange?.call(value);
        },
      ),
    ),
  );
  Widget _choice(
    BuildContext context,
    String title,
    String key,
    List<String> choices,
    String fallback, {
    VoidCallback? onChanged,
  }) => _SettingsRow(
    label: title,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _capitalize(save.choice(key, fallback)),
          style: _body.copyWith(fontSize: 16),
        ),
        const Icon(Icons.chevron_right, size: 20, color: _muted),
      ],
    ),
    onTap: () => showDialog<void>(
      context: context,
      builder: (context) => _QuestDialog(
        title: title.toUpperCase(),
        children: [
          for (final value in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArcadeButton(
                label: value.toUpperCase(),
                icon: save.choice(key, fallback) == value ? Icons.check : null,
                onPressed: () {
                  unawaited(save.set(key, value));
                  onChanged?.call();
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    ),
  );
}

String _capitalize(String value) =>
    '${value[0].toUpperCase()}${value.substring(1)}';

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => NeonPanel(
    padding: EdgeInsets.zero,
    borderColor: const Color(0xff1a375f),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xff173354),
              indent: 12,
              endIndent: 12,
            ),
        ],
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, this.trailing, this.onTap});
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Expanded(child: Text(label, style: _body)),
            if (trailing != null) ...[const SizedBox(width: 5), trailing!],
          ],
        ),
      ),
    ),
  );
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
    required this.save,
    required this.cloud,
    required this.onNavigate,
    this.fixture = false,
  });
  final SaveService save;
  final FirebaseService cloud;
  final ValueChanged<String> onNavigate;
  final bool fixture;
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int tab = 0;
  String metric = 'rawTaps';
  final Map<String, Future<List<Map<String, dynamic>>>> requests = {};
  bool get preview => widget.fixture && !kReleaseMode;
  Future<List<Map<String, dynamic>>> _load(String category) =>
      requests.putIfAbsent(category, () => widget.cloud.leaderboard(category));
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ArcadeHeader(
        title: 'LEADERBOARDS',
        onBack: () => widget.onNavigate('menu'),
        trailing: IconButton(
          tooltip: 'Close leaderboard',
          onPressed: () => widget.onNavigate('menu'),
          icon: const Icon(Icons.cancel_outlined, color: _muted, size: 23),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 7, 18, 0),
        child: _TabStrip(
          labels: const ['Global', 'Friends', 'Hall of Fame'],
          selected: tab,
          onChanged: (value) => setState(() => tab = value),
        ),
      ),
      if (tab == 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 7, 16, 3),
          child: Row(
            children: [
              Text(
                'UNASSISTED',
                style: _body.copyWith(
                  color: _muted,
                  fontSize: 12,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: metric,
                    isDense: true,
                    isExpanded: true,
                    style: _body.copyWith(fontSize: 14, color: _cyan),
                    dropdownColor: ArcadeColors.panel,
                    items: const [
                      DropdownMenuItem(
                        value: 'rawTaps',
                        child: Text('BEST RAW RUN'),
                      ),
                      DropdownMenuItem(
                        value: 'score',
                        child: Text('BEST SCORE'),
                      ),
                      DropdownMenuItem(
                        value: 'campaign',
                        child: Text('CAMPAIGN PROGRESS'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => metric = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      Expanded(
        child: tab == 1
            ? const _EmptyState(
                icon: Icons.people_outline,
                title: 'Friends are coming soon',
                message:
                    'Play as a guest or connect an account. Friend rankings will appear here when available.',
              )
            : preview
            ? _entries(_fixtureRows, metric)
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: _load(tab == 2 ? 'hallOfFame' : metric),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _cyan,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Rankings unavailable',
                      message:
                          'Your local progress is safe. Try again when your connection is ready.',
                      action: ArcadeButton(
                        label: 'TRY AGAIN',
                        onPressed: () => setState(
                          () =>
                              requests.remove(tab == 2 ? 'hallOfFame' : metric),
                        ),
                      ),
                    );
                  }
                  final entries = snapshot.data ?? [];
                  if (entries.isEmpty) {
                    return _EmptyState(
                      icon: widget.cloud.available
                          ? Icons.leaderboard_outlined
                          : Icons.cloud_off_outlined,
                      title: widget.cloud.available
                          ? 'No verified entries yet'
                          : 'You’re playing offline',
                      message: widget.cloud.available
                          ? 'Only server-validated, unassisted results appear in these rankings.'
                          : 'Cloud rankings are unavailable. Your runs and achievements stay saved on this device.',
                      action: widget.save.number('bestRawRun') > 0
                          ? NeonPanel(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'YOUR LOCAL BEST',
                                    style: _body.copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    formatNumber(
                                      widget.save.number('bestRawRun'),
                                    ),
                                    style: _heading.copyWith(color: _cyan),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    );
                  }
                  return _entries(entries, tab == 2 ? 'hallOfFame' : metric);
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Text(
          preview
              ? 'PREVIEW DATA · NOT LIVE RANKINGS'
              : 'All modes · verified · revived runs excluded',
          style: _body.copyWith(color: _muted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
      ArcadeBottomNav(
        selected: 'leaderboard',
        onNavigate: widget.onNavigate,
        destinations: const ['home', 'leaderboard'],
      ),
    ],
  );

  Widget _entries(List<Map<String, dynamic>> entries, String category) =>
      ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final item = entries[index];
          final mine = preview
              ? index == 3
              : item['uid'] != null &&
                    item['uid'] == widget.cloud.currentUserId;
          final value = (item['value'] as num?) ?? 0;
          final rankColor = index == 0
              ? ArcadeColors.yellow
              : index == 1
              ? const Color(0xffd0e1ff)
              : index == 2
              ? const Color(0xffe0ab78)
              : ArcadeColors.white;
          return Container(
            constraints: const BoxConstraints(minHeight: 49),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              gradient: mine
                  ? const LinearGradient(
                      colors: [Color(0xff0c487f), Color(0xff09284d)],
                    )
                  : null,
              borderRadius: mine ? BorderRadius.circular(8) : null,
              border: mine
                  ? Border.all(color: _cyan)
                  : const Border(
                      bottom: BorderSide(color: Color(0xff16325a), width: .7),
                    ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 31,
                  child: Text(
                    '${index + 1}',
                    style: _heading.copyWith(fontSize: 21, color: rankColor),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['displayName'] as String? ?? 'Adventurer',
                    style: _body.copyWith(
                      fontSize: 19,
                      fontWeight: mine ? FontWeight.w700 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  category == 'campaign' && !preview
                      ? '${value.toInt()}/50'
                      : formatNumber(value),
                  style: _body.copyWith(
                    fontSize: 19,
                    color: mine ? ArcadeColors.yellow : ArcadeColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      );
}

const _fixtureRows = [
  {'displayName': 'TapGod', 'value': 102847},
  {'displayName': 'NeonNinja', 'value': 89341},
  {'displayName': 'PixelPro', 'value': 76592},
  {'displayName': 'TapMaster', 'value': 66421},
  {'displayName': 'LunaTaps', 'value': 54887},
  {'displayName': 'ChaosKing', 'value': 50331},
  {'displayName': 'SparkQueen', 'value': 48219},
  {'displayName': 'TapLegend', 'value': 46772},
  {'displayName': 'MysticTap', 'value': 44690},
  {'displayName': 'HyperHands', 'value': 42331},
];

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => NeonPanel(
    padding: const EdgeInsets.all(3),
    borderColor: const Color(0xff1b385f),
    radius: 11,
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Semantics(
              selected: i == selected,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  backgroundColor: i == selected ? _cyan : Colors.transparent,
                  foregroundColor: i == selected
                      ? const Color(0xff041830)
                      : _muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () => onChanged(i),
                child: Text(
                  labels[i],
                  style: _body.copyWith(
                    fontSize: 16,
                    color: i == selected ? const Color(0xff041830) : _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _cyan, size: 52),
          const SizedBox(height: 18),
          Text(
            title,
            style: _heading.copyWith(fontSize: 27),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 9),
          Text(
            message,
            style: _body.copyWith(color: _muted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    ),
  );
}

class Cosmetic {
  const Cosmetic(
    this.id,
    this.name,
    this.threshold,
    this.color,
    this.description,
  );
  final String id, name, description;
  final int threshold;
  final Color color;
}

const cosmetics = [
  Cosmetic(
    'magenta',
    'Tap Explosion',
    200,
    ArcadeColors.magenta,
    'A bright magenta spark blooms at every accepted tap.',
  ),
  Cosmetic(
    'burst',
    'Overdrive Spark',
    500,
    ArcadeColors.orange,
    'Warm starbursts for a finger that never gives up.',
  ),
  Cosmetic(
    'cyan',
    'Electric Cyan',
    0,
    ArcadeColors.cyan,
    'The original cool cyan glow. Ready from your first tap.',
  ),
  Cosmetic(
    'gold',
    'Golden Touch',
    5000,
    ArcadeColors.yellow,
    'A golden trail earned through 5,000 raw taps in one run.',
  ),
];

class BadgeTile extends StatelessWidget {
  const BadgeTile({
    super.key,
    required this.threshold,
    required this.unlocked,
    required this.onTap,
  });
  final int threshold;
  final bool unlocked;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        '${formatNumber(threshold)} tap badge, ${unlocked ? 'unlocked' : 'locked'}',
    child: InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: NeonPanel(
          padding: const EdgeInsets.all(5),
          borderColor: unlocked
              ? ArcadeColors.yellow.withValues(alpha: .75)
              : const Color(0xff356089),
          radius: 11,
          child: unlocked
              ? CustomPaint(painter: MedalPainter(threshold))
              : const Icon(
                  Icons.lock_rounded,
                  size: 35,
                  color: Color(0xff4a7298),
                ),
        ),
      ),
    ),
  );
}

/// Editable vector medal vocabulary shared by profile and achievement reveals.
class MedalPainter extends CustomPainter {
  const MedalPainter(this.threshold);
  final int threshold;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .44;
    final rim = Path();
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12 - math.pi / 2;
      final r = radius * (i.isEven ? 1 : .86);
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        rim.moveTo(p.dx, p.dy);
      } else {
        rim.lineTo(p.dx, p.dy);
      }
    }
    rim.close();
    canvas.drawPath(
      rim,
      Paint()
        ..color = ArcadeColors.orange.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      rim,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffffee95), Color(0xfffcb212), Color(0xff9f4804)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      center,
      radius * .73,
      Paint()..color = const Color(0xff43270c),
    );
    canvas.drawCircle(
      center,
      radius * .73,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xffffd850)
        ..strokeWidth = 1.5,
    );
    final text = threshold >= 1000 ? '${threshold ~/ 1000}K' : '$threshold';
    final label = TextPainter(
      text: TextSpan(
        text: text,
        style: _heading.copyWith(
          fontSize: radius * .75,
          color: const Color(0xffffdf55),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
  }

  @override
  bool shouldRepaint(MedalPainter oldDelegate) =>
      oldDelegate.threshold != threshold;
}

class EffectTile extends StatelessWidget {
  const EffectTile({
    super.key,
    required this.effect,
    required this.onTap,
    this.selected = false,
  });
  final Cosmetic effect;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${effect.name}${selected ? ', equipped' : ''}',
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: NeonPanel(
          padding: const EdgeInsets.all(2),
          radius: 10,
          borderColor: effect.color.withValues(alpha: .75),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: EffectPainter(effect: effect)),
              ),
              if (selected)
                const Positioned(
                  right: 3,
                  top: 3,
                  child: Icon(Icons.check_circle, color: _cyan, size: 15),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class EffectPainter extends CustomPainter {
  const EffectPainter({required this.effect, this.phase = .42});
  final Cosmetic effect;
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * .5,
      size.height * (effect.id == 'magenta' ? .78 : .5),
    );
    final r = size.shortestSide * .43;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          effect.color.withValues(alpha: .8),
          effect.color.withValues(alpha: .15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, glow);
    final random = math.Random(
      effect.id.codeUnits.fold<int>(0, (a, b) => a + b),
    );
    for (var i = 0; i < 30; i++) {
      final angle = effect.id == 'magenta'
          ? math.pi + random.nextDouble() * math.pi
          : random.nextDouble() * math.pi * 2;
      final distance = r * (.28 + random.nextDouble() * .8);
      final travel = .8 + phase * .3;
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * distance * travel;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * distance * .35;
      final color = i % 4 == 0
          ? Colors.white
          : i.isEven
          ? effect.color
          : ArcadeColors.magenta;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = effect.color.withValues(alpha: .7)
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withValues(alpha: .8)
          ..strokeWidth = i.isEven ? 1.4 : .6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(end, i % 5 == 0 ? 1.6 : .7, Paint()..color = color);
    }
    canvas.drawCircle(
      center,
      size.shortestSide * .055,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    if (effect.id == 'cyan') {
      canvas.drawCircle(
        center,
        r * .29,
        Paint()
          ..color = _cyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
    if (effect.id == 'gold') {
      final start = Offset(size.width * .16, size.height * .15);
      final end = Offset(size.width * .85, size.height * .85);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = ArcadeColors.orange
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = ArcadeColors.yellow
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        start + const Offset(3, 0),
        end,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(EffectPainter oldDelegate) =>
      oldDelegate.effect != effect || oldDelegate.phase != phase;
}

Future<void> showBadgeDetails(
  BuildContext context,
  int threshold,
  SaveService save,
) {
  // Retired milestones can remain in historical saves, but have no UI entry.
  if (!milestones.containsKey(threshold)) return Future<void>.value();
  return showDialog<void>(
    context: context,
    builder: (context) {
      final unlocked = save.badges.contains(threshold);
      return _QuestDialog(
        title: milestones[threshold]!,
        children: [
          Center(
            child: SizedBox(
              width: 125,
              height: 125,
              child: CustomPaint(painter: MedalPainter(threshold)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            unlocked ? 'UNLOCKED' : '${formatNumber(threshold)} RAW TAPS',
            textAlign: TextAlign.center,
            style: _heading.copyWith(
              color: unlocked ? ArcadeColors.yellow : _cyan,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked
                ? 'You earned this badge by reaching ${formatNumber(threshold)} raw taps in one run.'
                : 'Reach ${formatNumber(threshold)} raw taps in a single run. Boosted score does not count toward this milestone.',
            textAlign: TextAlign.center,
            style: _body.copyWith(color: _muted),
          ),
          if (!unlocked) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (save.number('bestRawRun') / threshold).clamp(0, 1),
                minHeight: 6,
                color: _cyan,
                backgroundColor: const Color(0xff020c23),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'BEST: ${formatNumber(save.number('bestRawRun'))}',
              style: _body.copyWith(fontSize: 14, color: _muted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    },
  );
}

Future<void> showEffectDetails(
  BuildContext context,
  Cosmetic effect,
  SaveService save,
) => showDialog<void>(
  context: context,
  builder: (context) => _EffectDialog(effect: effect, save: save),
);

class _EffectDialog extends StatefulWidget {
  const _EffectDialog({required this.effect, required this.save});
  final Cosmetic effect;
  final SaveService save;
  @override
  State<_EffectDialog> createState() => _EffectDialogState();
}

class _EffectDialogState extends State<_EffectDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  @override
  void initState() {
    super.initState();
    if (!widget.save.flag('reduceMotion', false)) {
      animation.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effect = widget.effect;
    final unlocked =
        effect.threshold == 0 || widget.save.badges.contains(effect.threshold);
    return _QuestDialog(
      title: effect.name.toUpperCase(),
      children: [
        SizedBox(
          height: 180,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => CustomPaint(
              painter: EffectPainter(
                effect: effect,
                phase: widget.save.flag('reduceMotion', false)
                    ? .42
                    : animation.value,
              ),
            ),
          ),
        ),
        Text(
          effect.description,
          style: _body.copyWith(color: _muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        if (unlocked)
          ArcadeButton(
            label: widget.save.choice('skin', 'cyan') == effect.id
                ? 'EQUIPPED'
                : 'EQUIP EFFECT',
            icon: Icons.check,
            style: ArcadeButtonStyle.blue,
            onPressed: () async {
              await widget.save.set('skin', effect.id);
              if (context.mounted) Navigator.pop(context);
            },
          )
        else
          Text(
            'UNLOCK AT ${formatNumber(effect.threshold)} RAW TAPS IN ONE RUN',
            textAlign: TextAlign.center,
            style: _heading.copyWith(fontSize: 18, color: _cyan),
          ),
      ],
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.save,
    required this.onNavigate,
    this.achievements = false,
    this.fixture = false,
  });
  final SaveService save;
  final ValueChanged<String> onNavigate;
  final bool achievements, fixture;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ArcadeHeader(
        title: achievements ? 'ACHIEVEMENTS' : 'SKINS & EFFECTS',
        onBack: () => onNavigate('profile'),
      ),
      Expanded(
        child: ListenableBuilder(
          listenable: save,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                achievements
                    ? '${save.badges.where(milestones.containsKey).length} / ${milestones.length} UNLOCKED'
                    : 'Earn effects with real taps. No purchase required.',
                style: _body.copyWith(color: _muted),
              ),
              const SizedBox(height: 20),
              if (achievements)
                Wrap(
                  spacing: 14,
                  runSpacing: 18,
                  children: [
                    for (final entry in milestones.entries)
                      SizedBox(
                        width: 98,
                        child: Column(
                          children: [
                            BadgeTile(
                              threshold: entry.key,
                              unlocked: save.badges.contains(entry.key),
                              onTap: () =>
                                  showBadgeDetails(context, entry.key, save),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.value,
                              textAlign: TextAlign.center,
                              style: _body.copyWith(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
                for (final effect in cosmetics)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NeonPanel(
                      child: InkWell(
                        onTap: () => showEffectDetails(context, effect, save),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 88,
                              child: EffectTile(
                                effect: effect,
                                selected:
                                    save.choice('skin', 'cyan') == effect.id,
                                onTap: () =>
                                    showEffectDetails(context, effect, save),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(effect.name, style: _heading),
                                  const SizedBox(height: 4),
                                  Text(
                                    effect.threshold == 0 ||
                                            save.badges.contains(
                                              effect.threshold,
                                            )
                                        ? save.choice('skin', 'cyan') ==
                                                  effect.id
                                              ? 'Equipped'
                                              : 'Tap to preview & equip'
                                        : '${formatNumber(effect.threshold)} raw taps to unlock',
                                    style: _body.copyWith(
                                      fontSize: 15,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: _cyan),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
      ArcadeBottomNav(
        selected: 'profile',
        onNavigate: onNavigate,
        destinations: const ['home', 'profile', 'settings'],
      ),
    ],
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.save,
    required this.cloud,
    required this.ads,
    required this.onNavigate,
  });
  final SaveService save;
  final FirebaseService cloud;
  final AdService ads;
  final ValueChanged<String> onNavigate;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool busy = false;
  String? notice;
  Future<void> _act(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      notice = null;
    });
    try {
      await action();
      if (mounted) setState(() => notice = widget.cloud.status);
    } catch (_) {
      if (mounted) {
        setState(
          () => notice =
              'This action could not be completed. Check your connection and try again. Account deletion may require signing in again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ArcadeHeader(
        title: 'ACCOUNT',
        onBack: () => widget.onNavigate('settings'),
      ),
      Expanded(
        child: ListenableBuilder(
          listenable: widget.save,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(22),
            children: [
              NeonPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cloud.name,
                      style: _heading.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.cloud.status,
                      style: _body.copyWith(color: _muted),
                    ),
                    if (notice != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        notice!,
                        style: _body.copyWith(fontSize: 15, color: _cyan),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!widget.cloud.isLinkedAccount) ...[
                Text(
                  widget.cloud.available
                      ? 'Connect an account to keep your progress across devices.'
                      : 'Account services are not configured in this build. Guest progress is saved on this device.',
                  style: _body.copyWith(color: _muted),
                ),
                const SizedBox(height: 16),
                ArcadeButton(
                  label: 'CONTINUE WITH GOOGLE',
                  onPressed: busy || !widget.cloud.available
                      ? null
                      : () => _act(() => widget.cloud.signIn(true)),
                ),
                const SizedBox(height: 12),
                ArcadeButton(
                  label: 'CONTINUE WITH FACEBOOK',
                  onPressed: busy || !widget.cloud.available
                      ? null
                      : () => _act(() => widget.cloud.signIn(false)),
                ),
              ] else ...[
                ArcadeButton(
                  label: 'SYNC PROGRESS',
                  icon: Icons.sync,
                  onPressed: busy ? null : () => _act(widget.cloud.sync),
                ),
                const SizedBox(height: 12),
                ArcadeButton(
                  label: 'SIGN OUT',
                  onPressed: busy ? null : () => _act(widget.cloud.signOut),
                ),
              ],
              const SizedBox(height: 24),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    label: 'Optional analytics',
                    trailing: Switch(
                      value: widget.save.flag('analytics', false),
                      activeTrackColor: ArcadeColors.green,
                      onChanged: busy
                          ? null
                          : (value) => _act(() async {
                              await widget.cloud.setAnalytics(value);
                              await widget.save.set('analytics', value);
                            }),
                    ),
                  ),
                  _SettingsRow(
                    label: 'Ad privacy choices',
                    trailing: const Icon(Icons.chevron_right, color: _muted),
                    onTap: busy
                        ? null
                        : () async {
                            if (kIsWeb) {
                              await showDialog<void>(
                                context: context,
                                builder: (_) => const _QuestDialog(
                                  title: 'AD PRIVACY',
                                  children: [
                                    Text(
                                      'Web advertising is not configured. No ad consent is required in this build.',
                                      style: _body,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              await _act(widget.ads.privacyOptions);
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Analytics is optional and off by default. You can keep playing without signing in.',
                style: _body.copyWith(color: _muted, fontSize: 15),
              ),
              const SizedBox(height: 26),
              TextButton(
                onPressed: busy ? null : _delete,
                child: Text(
                  widget.cloud.isLinkedAccount
                      ? 'DELETE ACCOUNT & PROGRESS'
                      : 'DELETE LOCAL PROGRESS',
                  style: _heading.copyWith(
                    color: const Color(0xffff8799),
                    fontSize: 19,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ArcadeButton(
                label: 'CONTINUE PLAYING',
                onPressed: () => widget.onNavigate('menu'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _QuestDialog(
        title: widget.cloud.isLinkedAccount
            ? 'DELETE ACCOUNT?'
            : 'DELETE PROGRESS?',
        children: [
          Text(
            widget.cloud.isLinkedAccount
                ? 'This deletes your account and local progress. Cloud cleanup requires the configured server deletion service. This cannot be undone.'
                : 'This removes all progress and preferences saved on this device. This cannot be undone.',
            style: _body.copyWith(color: _muted),
          ),
          const SizedBox(height: 20),
          ArcadeButton(
            label: 'KEEP MY PROGRESS',
            style: ArcadeButtonStyle.blue,
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 10),
          ArcadeButton(
            label: 'DELETE PERMANENTLY',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _act(widget.cloud.deleteAccount);
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.onNavigate, this.privacy = true});
  final ValueChanged<String> onNavigate;
  final bool privacy;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ArcadeHeader(
        title: privacy ? 'PRIVACY POLICY' : 'TERMS OF SERVICE',
        onBack: () => onNavigate('settings'),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
          child: NeonPanel(
            child: Text(
              privacy ? privacyText : termsText,
              style: _body.copyWith(fontSize: 17, height: 1.5, color: _muted),
            ),
          ),
        ),
      ),
    ],
  );
}

class _QuestDialog extends StatelessWidget {
  const _QuestDialog({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: NeonPanel(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: _heading.copyWith(fontSize: 24)),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}
