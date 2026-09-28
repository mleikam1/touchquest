import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../game/core/game_session.dart';
import '../game/touch_quest_game.dart';
import '../services/save_service.dart';
import '../services/firebase_service.dart';
import '../services/feedback_service.dart';
import '../services/ad_service.dart';
import '../ui/widgets/arcade_widgets.dart';
import '../ui/widgets/tutorial_tap_artwork.dart';
import '../ui/screens/main_menu_screen.dart';
import '../ui/screens/chaos_intro_screen.dart';
import '../ui/screens/secondary_screens.dart';
import '../ui/overlays/gameplay_hud.dart';
import '../ui/overlays/game_over_overlay.dart';
import '../ui/preview/ui_fixture_data.dart';

class TouchQuestApp extends StatelessWidget {
  const TouchQuestApp({
    super.key,
    required this.save,
    this.enableServices = true,
    this.preview,
  });
  final SaveService save;
  final bool enableServices;
  final String? preview;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Touch Quest',
    debugShowCheckedModeBanner: false,
    theme: arcadeTheme(),
    home: QuestShell(
      save: save,
      enableServices: enableServices,
      initialScenario: kReleaseMode ? null : preview,
    ),
  );
}

class QuestShell extends StatefulWidget {
  const QuestShell({
    super.key,
    required this.save,
    this.enableServices = true,
    this.initialScenario,
  });
  final SaveService save;
  final bool enableServices;
  final String? initialScenario;
  @override
  State<QuestShell> createState() => _QuestShellState();
}

class _QuestShellState extends State<QuestShell>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final cloud = FirebaseService(save);
  late final audio = FeedbackService(save);
  late final ads = preview ? WebAdService() : AdService.create();
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  SaveService get save => widget.save;
  bool get preview => widget.initialScenario != null && !kReleaseMode;
  bool get services => widget.enableServices && !preview;
  String page = 'menu', notice = '', rewardMessage = '';
  String? scenario;
  GameSession? session;
  TouchQuestGame? game;
  int savedTaps = 0, previousMultiplier = 1;
  bool finished = false, busy = false, warning = false, reviveReady = false;
  double hudElapsed = 0;
  Size? fixtureSize;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    save.addListener(refresh);
    ads.rewardState.addListener(refresh);
    if (!preview) animation.repeat(reverse: true);
    if (preview) selectScenario(widget.initialScenario!);
    if (services) unawaited(setup());
  }

  Future<void> setup() async {
    await cloud.init();
    if (!mounted) return;
    await audio.init();
    if (!mounted) return;
    if (session?.state == RunState.playing) {
      await audio.music(true, overdrive: session!.multiplier == 2);
      if (!mounted) return;
    }
    try {
      await ads.initialize();
    } catch (e) {
      debugPrint('Ads unavailable: $e');
    }
    refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    save.removeListener(refresh);
    WidgetsBinding.instance.removeObserver(this);
    animation.dispose();
    game?.pauseEngine();
    if (services) unawaited(audio.dispose());
    ads.rewardState.removeListener(refresh);
    ads.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) pause();
  }

  @override
  void didChangeMetrics() {
    if (!preview) pause();
  }

  Future<void> checkpoint() async {
    if (preview || session == null) return;
    final s = session!;
    final previous = savedTaps;
    savedTaps = s.rawTaps;
    await save.record(s, previous);
  }

  void pause() {
    if (session?.state == RunState.playing) {
      session!.pause();
      game?.pauseEngine();
      if (services) {
        audio.haptics.cancel();
        unawaited(audio.music(false));
      }
      unawaited(checkpoint());
      refresh();
    }
  }

  void resume() {
    session!.resume();
    game!.resumeEngine();
    reviveReady = false;
    if (services) unawaited(audio.music(true));
    refresh();
  }

  void start(GameMode mode, {int stage = 0}) {
    if (!mounted) return;
    animation.stop();
    game?.pauseEngine();
    session = GameSession(
      mode: mode,
      stage: stage,
      velocityPerk: save.badges.contains(15000),
      seed: preview ? 42 : DateTime.now().millisecondsSinceEpoch,
    );
    savedTaps = 0;
    previousMultiplier = 1;
    hudElapsed = 0;
    finished = false;
    warning = false;
    reviveReady = false;
    notice = '';
    rewardMessage = '';
    scenario = null;
    fixtureSize = null;
    game = TouchQuestGame(session!, save, frame);
    page = 'play';
    if (services) {
      unawaited(cloud.event('mode_selected', {'mode': mode.name}));
      unawaited(cloud.event('game_started', {'mode': mode.name}));
      if (mode == GameMode.campaign) {
        unawaited(cloud.event('campaign_level_started', {'stage': stage}));
      }
      unawaited(audio.music(true));
    }
    refresh();
  }

  void frame() {
    final s = session!;
    if (s.multiplier != previousMultiplier) {
      previousMultiplier = s.multiplier;
      if (services) {
        unawaited(
          audio.music(
            s.state == RunState.playing,
            overdrive: s.multiplier == 2,
          ),
        );
      }
    }
    if (s.remaining < .6 && !warning) {
      warning = true;
      if (services) {
        audio.haptic();
        audio.sound('danger');
      }
    }
    if ((s.state == RunState.over || s.state == RunState.won) && !finished) {
      finished = true;
      unawaited(checkpoint());
      if (services) {
        unawaited(cloud.submit(s.toJson()));
        unawaited(
          cloud.event('game_over', {
            'raw_taps': s.rawTaps,
            'mode': s.mode.name,
          }),
        );
        if (s.mode == GameMode.campaign) {
          unawaited(
            cloud.event(
              s.state == RunState.won
                  ? 'campaign_level_completed'
                  : 'campaign_level_failed',
              {'stage': s.stage},
            ),
          );
        }
        audio.sound(s.state == RunState.won ? 'milestone' : 'gameover');
        unawaited(audio.music(false));
      }
    }
    if (s.duration - hudElapsed >= 1 / 30 ||
        finished ||
        s.state == RunState.paused) {
      hudElapsed = s.duration;
      refresh();
    }
  }

  void tap(Offset p) {
    final s = session!;
    final before = s.rawTaps;
    final unlocked = s.tap(p);
    if (s.rawTaps > before) {
      game!.burst(
        p,
        celebrate: unlocked.any((n) => [1000, 10000, 100000].contains(n)),
      );
      warning = false;
      if (services) audio.tap(s.rawTaps, funny: s.active(300, 12));
      for (final n in unlocked) {
        notice = milestones[n]!;
        if (services) {
          audio.celebration(n);
          unawaited(cloud.event('milestone_$n'));
          unawaited(cloud.event('achievement_unlocked', {'threshold': n}));
        }
      }
      if (unlocked.isNotEmpty || s.rawTaps % 50 == 0) unawaited(checkpoint());
    }
    frame();
    refresh();
  }

  Future<void> action(Future<void> Function() work) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await work();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void navigate(String next) {
    if (next == 'home') next = 'menu';
    if (page == 'play') {
      pause();
      unawaited(checkpoint());
    }
    if (services) audio.sound('menu');
    page = next;
    if (!preview && next == 'menu' && !save.flag('reduceMotion', false)) {
      animation.repeat(reverse: true);
    } else {
      animation.stop();
    }
    refresh();
  }

  void selectScenario(String value) {
    scenario = value;
    fixtureSize = null;
    game?.pauseEngine();
    page = switch (value) {
      '01_main_menu' => 'menu',
      '06_campaign_map' => 'campaign',
      '07_chaos_entry' => 'chaos',
      '08_profile' => 'profile',
      '09_settings' => 'settings',
      '10_leaderboards' => 'leaderboard',
      'gallery' => 'gallery',
      _ => 'play',
    };
    if (value == '06_campaign_map') save.data['campaign'] = 0;
    if (page == 'play') {
      final casual = value == '02_casual_gameplay' || value == '05_game_over';
      final s = GameSession(
        mode: casual ? GameMode.casual : GameMode.campaign,
        stage: casual ? 0 : 49,
        seed: 42,
      );
      s.rawTaps = s.score = switch (value) {
        '02_casual_gameplay' => 127,
        '03_transition_warning' => 482,
        '04_target_mode' => 583,
        _ => 2847,
      };
      s.duration = value == '05_game_over' ? 86 : 24;
      s.remaining = value == '03_transition_warning' ? .9 : 1.5;
      for (final n in milestones.keys.where((n) => n <= s.rawTaps)) {
        s.fired.add(n);
        s.ages[n] = 12;
      }
      if (value == '05_game_over') {
        s.score = 4521;
        s.state = RunState.over;
      }
      session = s;
      finished = value == '05_game_over';
      game = TouchQuestGame(
        s,
        save,
        frame,
        frozen: true,
        seed: 42,
        fixtureTime: .18,
      );
    }
  }

  void applyFixture(Size size) {
    if (!preview ||
        scenario == null ||
        scenario == '05_game_over' ||
        fixtureSize == size) {
      return;
    }
    fixtureSize = size;
    final s = session!;
    s.resize(size.width, size.height);
    RRect area(double x, double y, double w, double h) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * x,
            size.height * y,
            size.width * w,
            math.max(88, size.height * h),
          ),
          const Radius.circular(18),
        );
    if (scenario == '03_transition_warning') {
      s.zones.setFixture(
        active: area(.20, .61, .56, .23),
        next: area(.20, .22, .56, .18),
        previewTapsRemaining: 2,
        previewElapsed: .3,
      );
    }
    if (scenario == '04_target_mode') {
      s.zones.setFixture(active: area(.19, .24, .65, .23), activationAge: .08);
      game!.burst(s.zones.active.center, celebrate: true);
      game!.previewEffectsAt(.16);
    }
    s.state = RunState.playing;
  }

  Future<void> revive() async {
    await action(() async {
      rewardMessage = '';
      if (services) await cloud.event('revive_offered');
      final earned = await ads.reward();
      if (!mounted) return;
      if (session!.revive(rewarded: earned)) {
        finished = false;
        reviveReady = true;
        game!.pauseEngine();
        if (services) {
          audio.sound('revive');
          await cloud.event('revive_completed');
        }
      } else {
        rewardMessage = ads.rewardState.value == RewardAdState.failed
            ? 'The ad could not play. Your run is still saved.'
            : 'Ad closed without a reward. Your run is still saved.';
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1,
          colors: [Color(0xff142357), Color(0xff030717)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 600;
            final width = wide
                ? math.min(430.0, constraints.maxHeight * 390 / 844)
                : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        disableAnimations: save.flag('reduceMotion', false),
                      ),
                      child: buildPage(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  Widget buildPage() => switch (page) {
    'menu' => MainMenuScreen(
      onPlay: () => start(GameMode.casual),
      onNavigate: navigate,
      glow: save.flag('reduceMotion', false) ? 0 : animation.value,
    ),
    'play' => play(),
    'campaign' => CampaignScreen(
      save: save,
      onNavigate: navigate,
      onStart: (mode, stage) => start(mode, stage: stage),
    ),
    'chaos' => ChaosIntroScreen(
      onStart: () => start(GameMode.chaos),
      onBack: () => navigate('menu'),
    ),
    'profile' => ProfileScreen(
      save: save,
      cloud: cloud,
      onNavigate: navigate,
      fixture: preview,
    ),
    'settings' => SettingsScreen(
      save: save,
      cloud: cloud,
      audio: audio,
      ads: ads,
      onNavigate: navigate,
    ),
    'leaderboard' => LeaderboardScreen(
      save: save,
      cloud: cloud,
      onNavigate: navigate,
      fixture: preview,
    ),
    'skins' || 'achievements' => CollectionScreen(
      save: save,
      onNavigate: navigate,
      achievements: page == 'achievements',
      fixture: preview,
    ),
    'account' => AccountScreen(
      save: save,
      cloud: cloud,
      ads: ads,
      onNavigate: navigate,
    ),
    'privacy' ||
    'terms' => LegalScreen(privacy: page == 'privacy', onNavigate: navigate),
    'gallery' => gallery(),
    _ => MainMenuScreen(
      onPlay: () => start(GameMode.casual),
      onNavigate: navigate,
    ),
  };
  Widget play() {
    final s = session!;
    return Stack(
      children: [
        Positioned.fill(
          child: ArcadeBackground(
            child: Column(
              children: [
                GameplayHud(
                  session: s,
                  best: save.number('bestScore'),
                  onPause: pause,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      applyFixture(constraints.biggest);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Listener(
                              key: const ValueKey('playable-arena'),
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (e) => tap(e.localPosition),
                              child: GameWidget(game: game!),
                            ),
                          ),
                          if (s.mode == GameMode.casual)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity:
                                      s.rawTaps == 0 ||
                                          scenario == '02_casual_gameplay'
                                      ? 1
                                      : 0,
                                  duration: save.flag('reduceMotion', false)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 220),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 40),
                                      Text(
                                        'TAP ANYWHERE!',
                                        style: ArcadeTypography.display
                                            .copyWith(
                                              fontSize: 30,
                                              fontStyle: FontStyle.italic,
                                              shadows: const [
                                                Shadow(
                                                  color: Color(0xff1494ff),
                                                  blurRadius: 15,
                                                ),
                                              ],
                                            ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: TutorialTapArtwork(
                                            size: math.min(
                                              330,
                                              constraints.maxWidth - 28,
                                            ),
                                            reduced: save.flag(
                                              'reduceMotion',
                                              false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (scenario == '03_transition_warning' ||
                              scenario == '04_target_mode')
                            Positioned(
                              left: s.zones.active.center.dx - 9,
                              top: s.zones.active.center.dy - 2,
                              width: 104,
                              height: 114,
                              child: IgnorePointer(
                                child: Image.asset(
                                  'assets/art/characters/tutorial_hand.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          if (notice.isNotEmpty &&
                              s.ages[s.highest] != null &&
                              s.ages[s.highest]! < 3)
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 12,
                              child: IgnorePointer(
                                child: NeonPanel(
                                  borderColor: ArcadeColors.yellow,
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    notice,
                                    textAlign: TextAlign.center,
                                    style: ArcadeTypography.display.copyWith(
                                      color: ArcadeColors.yellow,
                                      fontSize: 23,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                MilestoneCard(session: s),
                BannerAdSlot(
                  preview: preview,
                  child: s.state == RunState.playing
                      ? ads.banner()
                      : const SizedBox(width: 320, height: 50),
                ),
              ],
            ),
          ),
        ),
        if (s.state == RunState.paused)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xed050a24),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: NeonPanel(
                    borderColor: ArcadeColors.cyan,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.pause_circle_outline,
                          size: 60,
                          color: ArcadeColors.cyan,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          reviveReady ? 'READY TO RETURN?' : 'QUEST PAUSED',
                          textAlign: TextAlign.center,
                          style: ArcadeTypography.title(32),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your run is safe. Take a breather.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 26),
                        ArcadeButton(
                          label: reviveReady ? 'READY — RESUME' : 'RESUME',
                          onPressed: resume,
                          style: ArcadeButtonStyle.blue,
                        ),
                        const SizedBox(height: 14),
                        ArcadeButton(
                          label: 'MAIN MENU',
                          onPressed: () => navigate('menu'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (s.state == RunState.over || s.state == RunState.won)
          Positioned.fill(
            child: GameOverOverlay(
              session: s,
              preview: preview,
              rewardReady: preview || ads.rewardedReady,
              busy: busy,
              rewardMessage: rewardMessage.isNotEmpty
                  ? rewardMessage
                  : switch (ads.rewardState.value) {
                      RewardAdState.loading => 'Loading rewarded ad…',
                      RewardAdState.failed =>
                        'Ad failed to load. Try again when available.',
                      RewardAdState.cancelled => 'Ad closed without a reward.',
                      _ => '',
                    },
              onRevive: preview
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Preview only — no ads or rewards requested.',
                        ),
                      ),
                    )
                  : revive,
              onRetry: () => action(() async {
                final won = s.state == RunState.won;
                if (won && !preview) await ads.stageBreak();
                if (services) await cloud.event('game_restarted');
                if (!mounted) return;
                start(s.mode, stage: won ? math.min(49, s.stage + 1) : s.stage);
              }),
              onMenu: () => navigate('menu'),
              onShare: () => action(() async {
                await SharePlus.instance.share(
                  ShareParams(
                    text:
                        'I survived ${s.rawTaps} taps in Touch Quest. Think your finger can beat mine? ${const String.fromEnvironment('GAME_URL')}',
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget gallery() => ArcadeBackground(
    child: Column(
      children: [
        ArcadeHeader(title: 'UI GALLERY', onBack: () => navigate('menu')),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'DEVELOPER PREVIEW · ISOLATED MEMORY DATA',
            style: TextStyle(color: ArcadeColors.cyan, fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final entry in uiScenarios.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ArcadeButton(
                    label: entry.value.toUpperCase(),
                    onPressed: () {
                      selectScenario(entry.key);
                      refresh();
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
