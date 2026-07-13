import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:carby/models/food_log_entry.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/models/nutrient_gap.dart';
import 'package:carby/services/firebase_service.dart';

class NutritionProvider extends ChangeNotifier {
  static const _logKey = 'food_log';

  final FirebaseService _firebase;
  final _uuid = const Uuid();

  List<FoodLogEntry> _all = []; // full local history (all days)
  List<FoodLogEntry> _log = []; // today's entries (derived from _all)
  StreamSubscription<List<FoodLogEntry>>? _sub;
  bool _loading = false;
  bool _loaded = false;

  NutritionProvider(this._firebase) {
    // Load persisted log immediately so data survives restarts without Firebase.
    _loadLocal();
  }

  List<FoodLogEntry> get log => _log;
  List<FoodLogEntry> get allEntries => _all;
  bool get loading => _loading;

  double get totalCalories => _log.fold(0, (s, e) => s + e.totalCalories);
  double get totalProtein => _log.fold(0, (s, e) => s + e.totalProtein);
  double get totalCarbs => _log.fold(0, (s, e) => s + e.totalCarbs);
  double get totalFat => _log.fold(0, (s, e) => s + e.totalFat);
  double get totalFiber => _log.fold(0, (s, e) => s + e.totalFiber);

  List<NutrientGap> getNutrientGaps(int calorieGoal) {
    return [
      NutrientGap(
        key: 'protein',
        name: 'Protein',
        current: totalProtein,
        target: RDA.protein,
        unit: 'g',
        foodSuggestions: RDA.suggestions['protein']!,
      ),
      NutrientGap(
        key: 'carbs',
        name: 'Kohlenhydrate',
        current: totalCarbs,
        target: RDA.carbs,
        unit: 'g',
        foodSuggestions: RDA.suggestions['carbs']!,
      ),
      NutrientGap(
        key: 'fat',
        name: 'Fett',
        current: totalFat,
        target: RDA.fat,
        unit: 'g',
        foodSuggestions: RDA.suggestions['fat']!,
      ),
      NutrientGap(
        key: 'fiber',
        name: 'Ballaststoffe',
        current: totalFiber,
        target: RDA.fiber,
        unit: 'g',
        foodSuggestions: RDA.suggestions['fiber']!,
      ),
    ];
  }

  List<String> getRecommendations(int calorieGoal) {
    final gaps = getNutrientGaps(calorieGoal)
        .where((g) => !g.isMet)
        .toList()
      ..sort((a, b) => a.percentage.compareTo(b.percentage));

    final suggestions = <String>{};
    for (final gap in gaps.take(3)) {
      suggestions.addAll(gap.foodSuggestions.take(2));
    }
    return suggestions.toList();
  }

  bool _isToday(DateTime t) {
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  void _recomputeToday() {
    _log = _all.where((e) => _isToday(e.timestamp)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _loadLocal() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_logKey);
    if (raw != null) {
      try {
        _all = (jsonDecode(raw) as List)
            .map((m) => FoodLogEntry.fromMap(m as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    _recomputeToday();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _logKey, jsonEncode(_all.map((e) => e.toMap()).toList()));
  }

  void startListening(String uid) {
    _loadLocal();
    _sub?.cancel();
    _sub = _firebase.streamTodayLog(uid).listen(
      (entries) {
        // Never let an empty/unavailable cloud response wipe the local log.
        if (entries.isEmpty) return;
        final ids = _all.map((e) => e.id).toSet();
        final incoming = entries.where((e) => !ids.contains(e.id)).toList();
        if (incoming.isEmpty) return;
        _all = [..._all, ...incoming];
        _recomputeToday();
        _persist();
        notifyListeners();
      },
      onError: (e) {
        // Keep local data; ignore cloud errors.
      },
      cancelOnError: false,
    );
  }

  // Fires when total entry count reaches the donation-nudge threshold
  VoidCallback? onFifthEntry;

  Future<void> addEntry(String uid, Food food, double grams) async {
    await _loadLocal();
    final entry = FoodLogEntry(
      id: _uuid.v4(),
      food: food,
      grams: grams,
      timestamp: DateTime.now(),
    );
    _all = [..._all, entry];
    _recomputeToday();
    notifyListeners();
    await _persist();
    // Cloud sync in background — never blocks or breaks local save.
    _firebase.addFoodLog(uid, entry).catchError((_) {});
    _checkDonationNudge();
  }

  Future<void> _checkDonationNudge() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt('total_entries') ?? 0) + 1;
    await prefs.setInt('total_entries', count);
    final nextTrigger = prefs.getInt('donation_next_trigger') ?? 5;
    if (count >= nextTrigger) onFifthEntry?.call();
  }

  Future<void> removeEntry(String uid, String entryId) async {
    _all = _all.where((e) => e.id != entryId).toList();
    _recomputeToday();
    notifyListeners();
    await _persist();
    _firebase.deleteFoodLog(uid, entryId).catchError((_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
