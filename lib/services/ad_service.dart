import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardAdState {
  unavailable,
  loading,
  ready,
  showing,
  cancelled,
  failed,
  rewarded,
}

/// SDK callback reducer. Reward alone never completes a successful attempt.
/// Dismissal without reward closes it as cancelled; late/duplicate SDK callbacks
/// cannot promote a cancelled or failed attempt into a revive.
class RewardAdAttempt {
  final _result = Completer<bool>();
  bool _earned = false;
  RewardAdState state = RewardAdState.showing;
  Future<bool> get result => _result.future;
  bool get isComplete => _result.isCompleted;
  void earned() {
    if (!isComplete) _earned = true;
  }

  void dismissed() =>
      _finish(_earned ? RewardAdState.rewarded : RewardAdState.cancelled);
  void failed() => _finish(RewardAdState.failed);
  void _finish(RewardAdState outcome) {
    if (isComplete) return;
    state = outcome;
    _result.complete(outcome == RewardAdState.rewarded);
  }
}

abstract class AdService {
  bool get rewardedReady;
  ValueListenable<RewardAdState> get rewardState;
  Widget banner();
  Future<void> initialize();
  Future<bool> reward();
  Future<void> stageBreak();
  Future<void> privacyOptions();
  void dispose();
  static AdService create() => kIsWeb ? WebAdService() : MobileAdService();
}

class WebAdService implements AdService {
  @override
  final ValueNotifier<RewardAdState> rewardState = ValueNotifier(
    RewardAdState.unavailable,
  );
  bool _disposed = false;
  @override
  bool get rewardedReady => false;
  @override
  Widget banner() => const AdPlaceholder();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> privacyOptions() async {}
  @override
  Future<bool> reward() async => false;
  @override
  Future<void> stageBreak() async {}
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    rewardState.dispose();
  }
}

class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 50,
    width: 320,
    child: Center(
      child: Text(
        'Advertisement unavailable',
        style: TextStyle(
          color: Color(0xffa8bcd8),
          fontSize: 11,
          letterSpacing: .2,
        ),
      ),
    ),
  );
}

class MobileAdService implements AdService {
  BannerAd? _banner;
  RewardedAd? _reward, _showingReward;
  InterstitialAd? _interstitial, _showingInterstitial;
  RewardAdAttempt? _attempt;
  Completer<void>? _stageCompletion;
  final loaded = ValueNotifier(false);
  @override
  final ValueNotifier<RewardAdState> rewardState = ValueNotifier(
    RewardAdState.unavailable,
  );
  int breaks = 0;
  bool disposed = false, _rewardLoading = false, _interstitialLoading = false;
  bool _initializing = false, _initialized = false;
  bool get android => defaultTargetPlatform == TargetPlatform.android;

  void _rewardStatus(RewardAdState status) {
    if (!disposed) rewardState.value = status;
  }

  String unit(String type) {
    if (kReleaseMode) {
      return switch (type) {
        'banner' => const String.fromEnvironment('ADMOB_BANNER_ID'),
        'reward' => const String.fromEnvironment('ADMOB_REWARDED_ID'),
        _ => const String.fromEnvironment('ADMOB_INTERSTITIAL_ID'),
      };
    }
    final suffix = android
        ? switch (type) {
            'banner' => '6300978111',
            'reward' => '5224354917',
            _ => '1033173712',
          }
        : switch (type) {
            'banner' => '2934735716',
            'reward' => '1712485313',
            _ => '4411468910',
          };
    return 'ca-app-pub-3940256099942544/$suffix';
  }

  @override
  bool get rewardedReady => !disposed && _reward != null && _attempt == null;

  @override
  Future<void> initialize() async {
    if (disposed || _initializing || _initialized) return;
    if (unit('banner').isEmpty &&
        unit('reward').isEmpty &&
        unit('interstitial').isEmpty) {
      return;
    }
    _initializing = true;
    if (unit('reward').isNotEmpty) _rewardStatus(RewardAdState.loading);
    try {
      final consent = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          if (disposed) {
            if (!consent.isCompleted) consent.complete();
            return;
          }
          ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (!consent.isCompleted) consent.complete();
          });
        },
        (error) {
          if (!consent.isCompleted) consent.complete();
        },
      );
      await consent.future;
      if (disposed) return;
      final canRequest = await ConsentInformation.instance.canRequestAds();
      if (disposed) return;
      if (!canRequest) {
        _rewardStatus(RewardAdState.unavailable);
        return;
      }
      await MobileAds.instance.initialize();
      if (disposed) return;
      _initialized = true;
      if (unit('banner').isNotEmpty) {
        _banner = BannerAd(
          size: AdSize.banner,
          adUnitId: unit('banner'),
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              if (disposed) {
                ad.dispose();
                return;
              }
              loaded.value = true;
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              if (!disposed) {
                loaded.value = false;
                _banner = null;
              }
              debugPrint('Banner: $error');
            },
          ),
        );
        await _banner!.load();
      }
      if (disposed) return;
      loadReward();
      loadInterstitial();
    } catch (_) {
      _rewardStatus(RewardAdState.failed);
      rethrow;
    } finally {
      _initializing = false;
    }
  }

  void loadReward({bool preserveOutcome = false}) {
    if (disposed || _rewardLoading || _reward != null || _attempt != null) {
      return;
    }
    if (unit('reward').isEmpty) {
      _rewardStatus(RewardAdState.unavailable);
      return;
    }
    _rewardLoading = true;
    if (!preserveOutcome) _rewardStatus(RewardAdState.loading);
    unawaited(
      RewardedAd.load(
        adUnitId: unit('reward'),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardLoading = false;
            if (disposed) {
              ad.dispose();
              return;
            }
            _reward = ad;
            _rewardStatus(RewardAdState.ready);
          },
          onAdFailedToLoad: (error) {
            _rewardLoading = false;
            _rewardStatus(RewardAdState.failed);
            debugPrint('Reward ad: $error');
          },
        ),
      ).catchError((Object error) {
        _rewardLoading = false;
        _rewardStatus(RewardAdState.failed);
        debugPrint('Reward ad: $error');
      }),
    );
  }

  void loadInterstitial() {
    if (disposed ||
        _interstitialLoading ||
        _interstitial != null ||
        unit('interstitial').isEmpty) {
      return;
    }
    _interstitialLoading = true;
    unawaited(
      InterstitialAd.load(
        adUnitId: unit('interstitial'),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialLoading = false;
            if (disposed) {
              ad.dispose();
            } else {
              _interstitial = ad;
            }
          },
          onAdFailedToLoad: (error) {
            _interstitialLoading = false;
            debugPrint('Interstitial: $error');
          },
        ),
      ).catchError((Object error) {
        _interstitialLoading = false;
        debugPrint('Interstitial: $error');
      }),
    );
  }

  @override
  Widget banner() => ValueListenableBuilder<bool>(
    valueListenable: loaded,
    builder: (context, ready, child) => ready && _banner != null
        ? SizedBox(width: 320, height: 50, child: AdWidget(ad: _banner!))
        : const AdPlaceholder(),
  );

  @override
  Future<bool> reward() async {
    if (!rewardedReady) return false;
    final ad = _reward!;
    _reward = null;
    _showingReward = ad;
    final attempt = _attempt = RewardAdAttempt();
    _rewardStatus(RewardAdState.showing);
    void finish({bool failed = false}) {
      if (attempt.isComplete) return;
      if (failed) {
        attempt.failed();
      } else {
        attempt.dismissed();
      }
      _attempt = null;
      _showingReward = null;
      ad.dispose();
      if (!disposed) {
        _rewardStatus(attempt.state);
        loadReward(preserveOutcome: true);
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(failed: true),
    );
    try {
      await ad.show(onUserEarnedReward: (_, reward) => attempt.earned());
    } catch (_) {
      finish(failed: true);
    }
    return attempt.result;
  }

  @override
  Future<void> privacyOptions() async {
    if (disposed) return;
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    if (disposed) return;
    if (status == PrivacyOptionsRequirementStatus.required) {
      final done = Completer<void>();
      ConsentForm.showPrivacyOptionsForm((error) {
        if (done.isCompleted) return;
        if (error != null) {
          done.completeError(StateError(error.message));
        } else {
          done.complete();
        }
      });
      await done.future;
    }
  }

  @override
  Future<void> stageBreak() async {
    if (disposed || _stageCompletion != null) return;
    breaks++;
    if (breaks % 3 != 0 || _interstitial == null) return;
    final ad = _interstitial!;
    _interstitial = null;
    _showingInterstitial = ad;
    final done = _stageCompletion = Completer<void>();
    void finish() {
      if (done.isCompleted) return;
      ad.dispose();
      _showingInterstitial = null;
      _stageCompletion = null;
      done.complete();
      if (!disposed) loadInterstitial();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(),
    );
    try {
      await ad.show();
    } catch (_) {
      finish();
    }
    await done.future;
  }

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    _attempt?.failed();
    if (_stageCompletion?.isCompleted == false) _stageCompletion!.complete();
    _banner?.dispose();
    _reward?.dispose();
    _showingReward?.dispose();
    _interstitial?.dispose();
    _showingInterstitial?.dispose();
    loaded.dispose();
    rewardState.dispose();
  }
}
