import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carby/models/food_log_entry.dart';
import 'package:carby/models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  Future<String?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      return cred.user?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  Future<void> addFoodLog(String uid, FoodLogEntry entry) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('food_log')
        .doc(entry.id)
        .set(entry.toMap());
  }

  Future<void> deleteFoodLog(String uid, String entryId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('food_log')
        .doc(entryId)
        .delete();
  }

  Stream<List<FoodLogEntry>> streamTodayLog(String uid) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('users')
        .doc(uid)
        .collection('food_log')
        .where('timestamp',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('timestamp', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FoodLogEntry.fromMap(d.data())).toList());
  }
}
