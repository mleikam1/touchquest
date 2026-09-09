import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'save_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseService {
  FirebaseService(this.save);
  final SaveService save;
  bool available = false;
  bool googleInitialized = false;
  String status = 'Offline guest · saved on this device';
  static const enabled = bool.fromEnvironment('FIREBASE_ENABLED');
  Future<void> init() async {
    if (!enabled) return;
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
          appId: String.fromEnvironment('FIREBASE_APP_ID'),
          messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
          iosBundleId: 'com.touchquest.touchQuest',
        ),
      );
      available = true;
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        save.flag('analytics', false),
      );
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      status = 'Connected guest';
      await sync();
    } catch (e) {
      available = false;
      status = 'Cloud unavailable. Your local progress is safe.';
      debugPrint('Firebase initialization: $e');
    }
  }

  String get name => available
      ? FirebaseAuth.instance.currentUser?.displayName ?? 'Guest adventurer'
      : 'Guest adventurer';
  Future<void> signIn(bool google) async {
    if (!available) {
      throw StateError(
        'Cloud sign-in is not configured. See docs/FIREBASE_SETUP.md. Guest play is ready.',
      );
    }
    final provider = google ? GoogleAuthProvider() : FacebookAuthProvider();
    final current = FirebaseAuth.instance.currentUser;
    if (kIsWeb) {
      if (current?.isAnonymous == true) {
        await current!.linkWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithPopup(provider);
      }
    } else {
      AuthCredential credential;
      if (google) {
        if (!googleInitialized) {
          await GoogleSignIn.instance.initialize(
            serverClientId: const String.fromEnvironment(
              'GOOGLE_SERVER_CLIENT_ID',
            ),
          );
          googleInitialized = true;
        }
        final account = await GoogleSignIn.instance.authenticate();
        credential = GoogleAuthProvider.credential(
          idToken: account.authentication.idToken,
        );
      } else {
        final result = await FacebookAuth.instance.login();
        if (result.status != LoginStatus.success ||
            result.accessToken == null) {
          throw StateError(result.message ?? 'Facebook sign-in cancelled.');
        }
        credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
      }
      if (current?.isAnonymous == true) {
        await current!.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    }
    await sync();
    status = 'Account connected';
  }

  Future<void> sync() async {
    if (!available) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) await save.merge(snapshot.data()!);
    await ref.set({
      ...save.data,
      'displayName': name,
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> submit(Map<String, dynamic> run) async {
    if (!available) return;
    try {
      await FirebaseFirestore.instance.collection('runs').add({
        ...run,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'clientVersion': '1.0.0',
        'verified': false,
      });
      await sync();
    } catch (e) {
      debugPrint('Run upload pending: $e');
      status = 'Run saved locally; cloud upload failed.';
    }
  }

  Future<List<Map<String, dynamic>>> leaderboard(String metric) async {
    if (!available) return [];
    final snap = await FirebaseFirestore.instance
        .collection('leaderboards')
        .where('category', isEqualTo: metric)
        .orderBy('value', descending: true)
        .limit(30)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<void> setAnalytics(bool enabled) async {
    if (available) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
    }
  }

  Future<void> event(String name, [Map<String, Object>? parameters]) async {
    if (!available || !save.flag('analytics', false)) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }

  Future<void> signOut() async {
    if (available) {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInAnonymously();
    }
    status = 'Guest · local progress retained';
  }

  Future<void> deleteAccount() async {
    if (available) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Deletion of the identity comes first: recent-login failures retain cloud data.
        await user.delete();
        // A deployed Auth onDelete cleanup function removes owned data.
      }
    }
    await save.clear();
    status = 'Account deleted';
  }
}
