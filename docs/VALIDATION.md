# Validation — September 9, 2026

Environment: macOS 15.7.4 arm64, Flutter 3.44.4 stable, Dart 3.12.2, Xcode 26.3, Android SDK 36.1.0 / Java 21. Repository was empty with no starting commit.

| Check | Result |
|---|---|
| flutter pub get | PASS; locked compatible package versions |
| dart format . | PASS; project formatted |
| flutter analyze | PASS; no issues |
| flutter test | PASS; 16 tests |
| Node validation tests | PASS; 4 tests |
| flutter build web | PASS; release web and Wasm dry-run compilation |
| flutter build apk --debug | PASS; debug APK |
| flutter build ios --no-codesign | PASS; unsigned Runner.app, 60.8 MB |
| Browser smoke test | PASS; menu, distinct taps, timeout/results, persisted best, campaign map and target |
| Responsive visual check | PASS at 1280×720 desktop and 390×844 mobile |
| git diff --check | PASS |

The first iOS build failed because Firebase requires iOS 15; project deployment targets were corrected to 15.0 and the build passed. Android emitted upstream Kotlin Gradle migration notices; these did not prevent the build. Dependency update availability messages are not analyzer findings.

Xcode's generated Swift package source links live under build/ios. They are excluded from analysis and Git. On macOS, `dart format .` may also traverse these generated dependency copies; CI runs on Linux and does not generate that iOS tree. For routine source-only formatting after native builds, use `dart format lib test`.

No physical-device performance benchmark, store signing, credential-backed Firebase/OAuth test, production ad impression, web ad provider or deployed Firestore rule test was performed. These are explicitly not claimed as passing. Cloud submissions remain unverified and cannot enter public rankings through client writes.

Backend module loading was also checked with the resolved Firebase Admin 14.3.0 / Functions 7.3.2 packages. Admin initialization uses the current modular API. `npm audit --omit=dev` reports zero vulnerabilities after constraining legacy transitive uuid versions to the compatible fixed 11.1.1 line. Function deployment still requires the user's Firebase project and is not claimed.
