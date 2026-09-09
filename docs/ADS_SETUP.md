# Advertising setup

Native debug builds select Google's official test ad units. Android/iOS app IDs currently contain the official sample app IDs. No production ad account credentials were supplied or impressions tested on a device.

- Android production app ID: pass Gradle property `-PADMOB_APP_ID=YOUR_APP_ID` (or an untracked Gradle properties value).
- iOS production app ID: replace the sample GADApplicationIdentifier in Runner/Info.plist using your release configuration.
- Release ad unit IDs: ADMOB_BANNER_ID, ADMOB_REWARDED_ID and ADMOB_INTERSTITIAL_ID from a dart-define JSON file. Release builds with missing IDs do not load ads. Do not ship sample app IDs as your own production configuration.
- UMP requests consent info and presents the required form before canRequestAds is checked. Configure the consent messages and test geography in AdMob. Settings includes Ad privacy choices and presents the provider form when UMP requires it.
- A 320×50 banner lives in a distinct 58px bottom region within SafeArea. No game pointer listener reaches it.
- Rewarded revive resolves only after the SDK reward callback and ad dismissal. Failure/dismissal without reward does not revive. One revive per run; revived runs are unranked.
- Campaign interstitials run after every third completed-stage transition, never during gameplay.
- The Trollvertisement is Canvas game comedy and cannot invoke an ad click or impression.

## Web bridge extension

WebAdService is currently a safe no-op. To add a provider, implement the same interface with a JS interop adapter. Use a provider contract such as `window.touchQuestAds.showRewarded({onEarned, onClosed, onError})`; resolve true only when onEarned has occurred and onClosed completes. Keep the game paused for the full ad lifetime. Handle missing global/provider, blocked requests, rejection and timeouts as false. Render banners only in the existing separate ad slot. No simulated rewarded success is allowed. This JS bridge is a documented extension point, not a configured browser ad network.

Before release: verify UMP privacy-options entry, child-directed/age treatment as appropriate, native SKAdNetwork entries from the current SDK documentation, app-ads.txt, store advertising declarations and production-device reward tests.
