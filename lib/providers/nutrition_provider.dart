import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:carby/models/food_log_entry.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/models/nutrient_gap.dart';
import 'package:carby/services/firebase_service.dart';

class NutritionProvider extends ChangeNotifier {
  final FirebaseService _firebase;
  final _uuid = const Uuid();

  List<FoodLogEntry> _log = [];
  StreamSubscription<List<FoodLogEntry>>? _sub;
  bool _loading = false;

  NutritionProvider(this._firebase);

  List<FoodLogEntry> get log => _log;
  bool get loading => _loading;

  double get totalCalories =>
      _log.fold(0, (s, e) => s + e.totalCalories);
  double get totalProtein =>
      _log.fold(0, (s, e) => s + e.totalProtein);
  double get totalCarbs =>
      _log.fold(0, (s, e) => s + e.totalCarbs);
  double get totalFat =>
      _log.fold(0, (s, e) => s + e.totalFat);
  double get totalFiber =>
      _log.fold(0, (s, e) => s + e.totalFiber);

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

  void startListening(String uid) {
    _sub?.cancel();
    _sub = _firebase.streamTodayLog(uid).listen(
      (entries) {
        _log = entries;
        notifyListeners();
      },
      onError: (e) {
        _log = [];
        notifyListeners();
      },
      cancelOnError: false,
    );
  }

  Future<void> addEntry(String uid, Food food, double grams) async {
    final entry = FoodLogEntry(
      id: _uuid.v4(),
      food: food,
      grams: grams,
      timestamp: DateTime.now(),
    );
    await _firebase.addFoodLog(uid, entry);
    // stream will update _log
  }

  Future<void> removeEntry(String uid, String entryId) async {
    await _firebase.deleteFoodLog(uid, entryId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
