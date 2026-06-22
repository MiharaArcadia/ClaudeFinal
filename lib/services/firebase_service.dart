import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:carby/models/food_log_entry.dart';
import 'package:carby/models/user_profile.dart';

class FirebaseService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get isAvailable => _auth != null && _db != null;

  String? get currentUid => _auth?.currentUser?.uid;
  bool get isSignedIn => _auth?.currentUser != null;

  Future<String?> signInAnonymously() async {
    if (!isAvailable) return null;
    try {
      final cred = await _auth!.signInAnonymously();
      return cred.user?.uid;
    } catch (e) {
      debugPrint('[Firebase] signInAnonymously failed: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    if (!isAvailable) return;
    try {
      await _db!.collection('users').doc(profile.uid).set(profile.toMap());
    } catch (e) {
      debugPrint('[Firebase] saveUserProfile failed: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (!isAvailable) return null;
    try {
      final doc = await _db!.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('[Firebase] getUserProfile failed: $e');
      return null;
    }
  }

  Future<void> addFoodLog(String uid, FoodLogEntry entry) async {
    if (!isAvailable) return;
    try {
      await _db!
          .collection('users')
          .doc(uid)
          .collection('food_log')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      debugPrint('[Firebase] addFoodLog failed: $e');
    }
  }

  Future<void> deleteFoodLog(String uid, String entryId) async {
    if (!isAvailable) return;
    try {
      await _db!
          .collection('users')
          .doc(uid)
          .collection('food_log')
          .doc(entryId)
          .delete();
    } catch (e) {
      debugPrint('[Firebase] deleteFoodLog failed: $e');
    }
  }

  Stream<List<FoodLogEntry>> streamTodayLog(String uid) {
    if (!isAvailable) return Stream.value([]);
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _db!
          .collection('users')
          .doc(uid)
          .collection('food_log')
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('timestamp', isLessThan: endOfDay.toIso8601String())
          .snapshots()
          .map((snap) {
            try {
              return snap.docs.map((d) => FoodLogEntry.fromMap(d.data())).toList();
            } catch (e) {
              debugPrint('[Firebase] streamTodayLog deserialize failed: $e');
              return <FoodLogEntry>[];
            }
          });
    } catch (e) {
      debugPrint('[Firebase] streamTodayLog failed: $e');
      return Stream.value([]);
    }
  }
}
