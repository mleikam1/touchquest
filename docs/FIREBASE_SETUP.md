# Firebase setup

No Firebase credentials were present in the empty repository. The shipped default is fully playable offline guest mode. No cloud deployment has been performed.

1. Create/select your Firebase project; register Android `com.touchquest.touch_quest`, iOS `com.touchquest.touchQuest` (confirm the exact Xcode bundle ID), and Web applications.
2. Enable Anonymous, Google and Facebook in Authentication. For Google Android register debug/release SHA-1/SHA-256 fingerprints. Configure Google's iOS reversed-client-ID URL scheme. Set GOOGLE_SERVER_CLIENT_ID to the Web OAuth client ID used for native token exchange.
3. For Facebook create your own Meta app, configure valid OAuth redirect URLs from Firebase, Android key hashes, and iOS URL schemes/App ID/client token. The native SDK has auto-init and automatic tracking disabled by default. Follow the current provider's platform instructions. Do not invent IDs.
4. Copy `config/example.json` to ignored `config/local.json`. Fill Firebase options for the target platform and set FIREBASE_ENABLED true. Firebase client config is public app metadata; service-account keys must never be put in client config or committed.
5. Run `flutter run -d chrome --dart-define-from-file=config/local.json` (or target device). Use separate option files per platform because appId differs.
6. Configure Firebase CLI project selection, then run `cd firebase/functions && npm install && cd ../..` and `firebase deploy --only firestore,functions --project YOUR_PROJECT_ID`.
7. Exercise anonymous play → Google/Facebook link → restart → data persistence. A credential-already-in-use error leaves guest data intact; automatic merging into an existing provider identity is intentionally not destructive. Reauthenticate when deletion reports `requires-recent-login` and retry. Verify deployed `deletePlayerData` removes the private profile, runs and rankings after Auth deletion.

The cloud integration uses official Firebase provider linking and native Google/Facebook credentials. It has not been tested against real credentials. No real global scores are fabricated. `inspectRun` checks plausibility and marks submissions, but does not claim proof of human input. Public `leaderboards` accepts writes only from trusted Admin SDK code. To publish ranked runs, implement trusted verification, rate limits and App Check, then write category/value/displayName/uid entries. Campaign and Hall of Fame use the same collection with their respective categories.

Analytics is opt-in and contains run/milestone events, not per-tap events. Test rules and deletion with emulators and your deployed project before release. Rules were reviewed locally, but emulator integration tests require Firebase CLI/project setup.

References: [Firebase Flutter authentication](https://firebase.google.com/docs/auth/flutter/federated-auth), [account linking](https://firebase.google.com/docs/auth/flutter/account-linking).
