import 'package:flutter_test/flutter_test.dart';
import 'package:touch_quest/services/ad_service.dart';

void main() {
  test('Earned reward cannot resolve before SDK dismissal', () async {
    final attempt = RewardAdAttempt();
    var resolved = false;
    attempt.result.then((_) => resolved = true);
    attempt.earned();
    await Future<void>.delayed(Duration.zero);
    expect(resolved, false);
    expect(attempt.state, RewardAdState.showing);
    attempt.dismissed();
    expect(await attempt.result, true);
    expect(attempt.state, RewardAdState.rewarded);
  });

  test(
    'Dismissal without earning is cancelled and never grants a late reward',
    () async {
      final attempt = RewardAdAttempt();
      attempt.dismissed();
      attempt.earned();
      expect(await attempt.result, false);
      expect(attempt.state, RewardAdState.cancelled);
    },
  );

  test(
    'Show failure blocks success even if reward callback happened',
    () async {
      final attempt = RewardAdAttempt();
      attempt.earned();
      attempt.failed();
      attempt.dismissed();
      expect(await attempt.result, false);
      expect(attempt.state, RewardAdState.failed);
    },
  );

  test('Duplicate SDK callbacks cannot resolve or reward twice', () async {
    final attempt = RewardAdAttempt();
    attempt.earned();
    attempt.earned();
    attempt.dismissed();
    attempt.dismissed();
    attempt.failed();
    expect(await attempt.result, true);
    expect(attempt.state, RewardAdState.rewarded);
  });

  test(
    'Web provider is observably unavailable and cannot simulate rewards',
    () async {
      final service = WebAdService();
      expect(service.rewardedReady, false);
      expect(service.rewardState.value, RewardAdState.unavailable);
      await service.initialize();
      expect(await service.reward(), false);
      expect(await service.reward(), false);
      service.dispose();
      service.dispose();
      expect(await service.reward(), false);
    },
  );

  test('Disposed mobile service returns no rewards or new requests', () async {
    final service = MobileAdService();
    service.dispose();
    await service.initialize();
    service.loadReward();
    service.loadInterstitial();
    expect(service.rewardedReady, false);
    expect(await service.reward(), false);
    service.dispose();
  });
}
